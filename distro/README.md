<!-- SPDX-License-Identifier: GPL-2.0-only -->
# Nimbus OS

Nimbus OS is an original desktop Linux distribution with a clean
"top menu bar + dock" layout. It is built from three pieces:

* **This kernel tree**, configured with `kernel/configs/nimbus.config`
  and packaged as `linux-image-*-nimbus` Debian packages.
* **Debian 13 "trixie"** as the userland base.
* **KDE Plasma 6** with an original Nimbus look-and-feel: a top bar with
  global menu, clock and system tray; a floating, centered bottom dock;
  window buttons on the left; light and dark color schemes; and an
  original wallpaper.

> **Status: v1.0 scaffold.** The configuration, artwork and build
> plumbing are in place, but the full pipeline (kernel -> image -> boot ->
> install) has **not yet been tested end-to-end**. Expect rough edges and
> please report what breaks.

## Layout

```
kernel/configs/nimbus.config     kconfig fragment (on top of x86_64_defconfig)
distro/
├── Makefile                     targets: kernel, image, qemu, clean
├── README.md                    this file
├── LEGAL.md                     trademark / licensing notes
├── kernel/
│   └── build-kernel.sh          builds linux-image .debs (bindeb-pkg)
├── mkosi/                       mkosi config: Debian trixie, Plasma 6, SDDM,
│   └── mkosi.postinst.chroot    systemd-boot, Calamares; post-install hook
├── rootfs/                      overlay copied to / in the image
│   ├── etc/os-release           Nimbus OS identity
│   ├── etc/calamares/           installer config + "nimbus" branding
│   └── usr/share/               look-and-feel org.nimbusos.desktop,
│                                color schemes NimbusLight/NimbusDark,
│                                wallpaper "Nimbus", Plymouth theme "nimbus",
│                                fontconfig (Inter / JetBrains Mono), logo,
│                                nimbus-welcome first-run app
└── out/                         build output (kernel .debs, disk image)
.github/workflows/nimbus.yml     CI: kernel, image, lint
```

## Prerequisites

A Debian or Ubuntu x86_64 host with:

```sh
sudo apt install build-essential bc bison flex libssl-dev libelf-dev \
    dwarves debhelper rsync cpio kmod qemu-system-x86 ovmf
```

plus **mkosi >= 25** (e.g. `pipx install git+https://github.com/systemd/mkosi@v25.3`).
Building the image needs root (or a working unprivileged user-namespace
setup) and roughly 20 GB of free disk space.

## Building

From the top of the kernel tree:

```sh
make -C distro kernel   # x86_64_defconfig + nimbus.config -> distro/out/kernel/*.deb
make -C distro image    # mkosi: Debian trixie + Plasma 6 + Nimbus overlay
make -C distro qemu     # boot the image in QEMU with OVMF (UEFI)
make -C distro clean    # remove build output
```

The kernel step is equivalent to:

```sh
make x86_64_defconfig nimbus.config
make -j"$(nproc)" bindeb-pkg LOCALVERSION=-nimbus
```

## Live session

| User     | Password |
|----------|----------|
| `nimbus` | `nimbus` |

The live user has `sudo` rights. Change the password (or install with
Calamares and create your own account) before using the system for anything
real.

## Keyboard shortcuts

| Shortcut          | Action                          |
|-------------------|---------------------------------|
| `Meta+Space`      | Search / launcher (KRunner)     |
| `Meta+Shift+3`    | Screenshot of the full screen   |
| `Meta+Shift+4`    | Screenshot of a selected region |
| `Meta+Up`         | Overview (all windows/desktops) |

## Roadmap / TODO

- [ ] End-to-end test of kernel -> image -> boot -> Calamares install
- [ ] arm64 support (kernel config, mkosi architecture, CI job)
- [ ] Hybrid ISO output (BIOS + UEFI, USB-bootable)
- [ ] OTA / atomic updates (e.g. A/B images via systemd-sysupdate)
- [ ] Original Nimbus icon theme (Papirus is used for now)
- [ ] Own application suite (settings front-end, updater, more first-run flows)

## License

Nimbus-specific files are GPL-2.0-only, like the kernel. See
[LEGAL.md](LEGAL.md) for third-party licenses and trademark notes.
