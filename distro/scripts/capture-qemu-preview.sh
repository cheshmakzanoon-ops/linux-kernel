#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Boot the generated Nimbus disk in an ephemeral QEMU VM and save real
# framebuffer captures. This is a first-boot visual diagnostic, not a
# substitute for a verified graphical login or installation test.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
image_dir="$repo_root/distro/out/image"
preview_dir="${RUNNER_TEMP:-/tmp}/nimbus-preview"
mkdir -p "$preview_dir"

image="$(find "$image_dir" -maxdepth 1 -type f -name '*.raw' -print -quit)"
if [[ -z "$image" ]]; then
    echo "nimbus preview: no mkosi .raw disk image found" >&2
    exit 1
fi

firmware=""
vars_template=""
for candidate in /usr/share/OVMF/OVMF_CODE_4M.fd /usr/share/OVMF/OVMF_CODE.fd; do
    if [[ "$candidate" == *_4M.fd ]]; then
        vars_candidate="/usr/share/OVMF/OVMF_VARS_4M.fd"
    else
        vars_candidate="/usr/share/OVMF/OVMF_VARS.fd"
    fi
    if [[ -r "$candidate" && -r "$vars_candidate" ]]; then
        firmware="$candidate"
        vars_template="$vars_candidate"
        break
    fi
done
if [[ -z "$firmware" ]]; then
    echo "nimbus preview: complete OVMF UEFI firmware pair is missing" >&2
    exit 1
fi
vars_copy="${RUNNER_TEMP:-/tmp}/nimbus-ovmf-vars.fd"
cp "$vars_template" "$vars_copy"

accel="tcg"
if [[ -r /dev/kvm && -w /dev/kvm ]]; then
    accel="kvm"
fi

monitor="$preview_dir/qemu-monitor.sock"
echo "nimbus preview: booting $image with $accel"
qemu-system-x86_64 \
    -machine q35 -accel "$accel" -cpu max -smp 2 -m 4096 \
    -drive "file=$image,format=raw,if=virtio,snapshot=on" \
    -drive "if=pflash,format=raw,unit=0,readonly=on,file=$firmware" \
    -drive "if=pflash,format=raw,unit=1,file=$vars_copy" \
    -vga virtio -display none \
    -monitor "unix:$monitor,server=on,wait=off" \
    -serial "file:$preview_dir/serial.log" -no-reboot \
    >"$preview_dir/qemu.log" 2>&1 &
qemu_pid=$!

cleanup() {
    kill "$qemu_pid" 2>/dev/null || true
    wait "$qemu_pid" 2>/dev/null || true
    rm -f "$vars_copy" "$monitor"
}
trap cleanup EXIT

elapsed=0
captured=0
for delay in 60 120 120; do
    sleep "$delay"
    elapsed=$((elapsed + delay))
    if ! kill -0 "$qemu_pid" 2>/dev/null; then
        echo "nimbus preview: QEMU exited before ${elapsed}s" >&2
        tail -n 80 "$preview_dir/qemu.log" >&2 || true
        break
    fi

    ppm="$preview_dir/boot-${elapsed}s.ppm"
    png="$preview_dir/boot-${elapsed}s.png"
    if python3 - "$monitor" "$ppm" <<'PY'
import socket
import sys

def read_prompt(client):
    chunks = []
    while True:
        part = client.recv(4096)
        if not part:
            raise RuntimeError("QEMU HMP monitor closed unexpectedly")
        chunks.append(part)
        data = b"".join(chunks)
        if b"(qemu)" in data:
            return data.decode(errors="replace")

with socket.socket(socket.AF_UNIX) as client:
    client.settimeout(30)
    client.connect(sys.argv[1])
    read_prompt(client)  # Consume the initial banner and prompt.
    client.sendall(("screendump " + sys.argv[2] + "\n").encode())
    reply = read_prompt(client)
    print("QEMU HMP:", reply.strip())
    if "error" in reply.lower() or "not found" in reply.lower():
        raise RuntimeError("QEMU screendump failed: " + reply.strip())
PY
    then
        # Let QEMU finish writing the PPM frame before Pillow opens it.
        sleep 2
        if [[ -s "$ppm" ]]; then
            python3 - "$ppm" "$png" <<'PY'
from PIL import Image
import sys

with Image.open(sys.argv[1]) as screenshot:
    screenshot.convert("RGB").save(sys.argv[2])
PY
            captured=$((captured + 1))
            echo "nimbus preview: saved $png"
        fi
    else
        echo "nimbus preview: failed to capture at ${elapsed}s" >&2
    fi
done

echo "nimbus preview: saved $captured screenshot(s)"
if (( captured == 0 )); then
    exit 1
fi
