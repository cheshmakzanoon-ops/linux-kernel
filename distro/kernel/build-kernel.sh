#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Build the Nimbus OS kernel as Debian packages from this source tree.
# Run from the repository root. Resulting .debs land in distro/out/kernel/.
#
# Environment:
#   OUT              kbuild output dir (default: <repo>/distro/out/kbuild)
#   KDEB_PKGVERSION  Debian package version (default: <kernelversion>-1nimbus)
#   JOBS             parallel jobs (default: nproc)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

if [[ ! -f Makefile || ! -f kernel/configs/nimbus.config ]]; then
	echo "error: run from the kernel repository root" >&2
	exit 1
fi

OUT="${OUT:-$REPO_ROOT/distro/out/kbuild}"
DEB_DIR="$REPO_ROOT/distro/out/kernel"
JOBS="${JOBS:-$(nproc)}"
mkdir -p "$OUT" "$DEB_DIR"
OUT="$(cd "$OUT" && pwd)"

make O="$OUT" x86_64_defconfig nimbus.config

KVER="$(make -s O="$OUT" kernelversion)"
KDEB_PKGVERSION="${KDEB_PKGVERSION:-${KVER}-1nimbus}"

make O="$OUT" -j"$JOBS" bindeb-pkg \
	LOCALVERSION=-nimbus \
	KDEB_PKGVERSION="$KDEB_PKGVERSION"

# bindeb-pkg writes packages to the parent of the output directory.
shopt -s nullglob
debs=("$(dirname "$OUT")"/*.deb)
if (( ${#debs[@]} == 0 )); then
	echo "error: no .deb packages found in $(dirname "$OUT")" >&2
	exit 1
fi
mv -f "${debs[@]}" "$DEB_DIR"/
for f in "$(dirname "$OUT")"/*.buildinfo "$(dirname "$OUT")"/*.changes; do
	mv -f "$f" "$DEB_DIR"/
done

echo "Kernel packages in $DEB_DIR:"
ls -1 "$DEB_DIR"/*.deb
