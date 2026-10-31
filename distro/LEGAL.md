<!-- SPDX-License-Identifier: GPL-2.0-only -->
# Nimbus OS legal notes

## No affiliation

Nimbus OS is an independent community project. It is **not affiliated with,
sponsored by, or endorsed by Apple Inc.** or any other operating-system
vendor. Any resemblance in general desktop layout (a top menu bar and a
bottom dock) is a common, functional design pattern, not an imitation of
any specific product.

Nimbus OS contains **no Apple code, fonts, icons, wallpapers, sounds,
or trademarks**, and it does not use or reference any Apple product names
in its branding.

## Original artwork

All Nimbus artwork — the logo, the `Nimbus` wallpaper, the NimbusLight and
NimbusDark color schemes, the `nimbus` Plymouth and Calamares branding,
and the `org.nimbusos.desktop` look-and-feel — is original work created for
this project and licensed under **GPL-2.0-only**.

## Third-party components

Third-party components keep their own licenses. The main ones are:

| Component        | License                                   |
|------------------|-------------------------------------------|
| Linux kernel     | GPL-2.0 (with syscall note); see `COPYING` |
| Debian packages  | Various; see `/usr/share/doc/*/copyright`  |
| KDE Plasma / Frameworks / apps | Mostly GPL-2.0+/LGPL-2.1+ (see each project) |
| Papirus icon theme | GPL-3.0                                  |
| Inter font       | SIL Open Font License 1.1 (OFL-1.1)       |
| JetBrains Mono font | SIL Open Font License 1.1 (OFL-1.1)    |
| Calamares installer | GPL-3.0                                 |

These components are installed from Debian packages in the built image;
their source and license texts are available from Debian.

## Rules for contributors

* Do **not** add proprietary or unclearly licensed assets: no fonts, icons,
  wallpapers, sounds, screenshots or code copied from Apple, Microsoft,
  Google or any other vendor's products.
* Only contribute work you created yourself or that is under a license
  compatible with redistribution in this project; state the license and
  source of any third-party asset in the commit message.
* Add an SPDX license identifier to every new file where comments are
  allowed.
* Kernel changes follow the normal kernel process, including the
  Developer Certificate of Origin (`Signed-off-by`), see
  `Documentation/process/submitting-patches.rst` and
  `Documentation/process/coding-assistants.rst`.

## The "Nimbus OS" name (placeholder)

"Nimbus OS" is a working project name and has **not** been registered as a
trademark. Before any public release, the project should run a trademark
clearance search and may rename if a conflict exists. Until a formal policy
is published:

* You may use the name "Nimbus OS" to refer to this project and to
  unmodified builds of it.
* Modified or redistributed builds should make clear they are modified
  (e.g. "based on Nimbus OS") and should not imply official endorsement.
* The Nimbus logo may be used to refer to the project, but not as the
  logo of an unrelated product.
