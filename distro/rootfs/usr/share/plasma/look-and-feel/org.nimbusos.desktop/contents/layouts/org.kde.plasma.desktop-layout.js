// SPDX-License-Identifier: GPL-2.0-only
//
// Nimbus OS default Plasma 6 layout:
//   - a slim top bar: launcher, global menu, spacer, system tray, clock
//   - a floating, centered, dock-like bottom panel with pinned launchers

// ---------------------------------------------------------------- top bar
var topBar = new Panel;
topBar.location = "top";
topBar.height = 28;
topBar.floating = false;
topBar.hiding = "none";
topBar.alignment = "left";
topBar.lengthMode = "fill";
topBar.opacity = "translucent";

var launcher = topBar.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "/usr/share/pixmaps/nimbus-logo.svg");
launcher.writeConfig("alphaSort", true);

topBar.addWidget("org.kde.plasma.appmenu");
topBar.addWidget("org.kde.plasma.panelspacer");
topBar.addWidget("org.kde.plasma.systemtray");

var clock = topBar.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", true);
clock.writeConfig("dateFormat", "shortDate");

// ------------------------------------------------------------- bottom dock
var dock = new Panel;
dock.location = "bottom";
dock.height = 56;
dock.alignment = "center";
dock.lengthMode = "fit";
dock.floating = true;
dock.hiding = "dodgewindows";
dock.opacity = "translucent";

var tasks = dock.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:firefox-esr.desktop",
    "applications:org.kde.konsole.desktop",
    "applications:org.kde.kate.desktop",
    "applications:systemsettings.desktop",
    "applications:org.kde.discover.desktop"
].join(","));
tasks.writeConfig("showOnlyCurrentDesktop", false);
tasks.writeConfig("indicateAudioStreams", true);

dock.addWidget("org.kde.plasma.marginsseparator");
dock.addWidget("org.kde.plasma.trash");

// ------------------------------------------------------------ wallpaper
var allDesktops = desktops();
for (var i = 0; i < allDesktops.length; i++) {
    var d = allDesktops[i];
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    d.writeConfig("Image", "file:///usr/share/wallpapers/Nimbus/");
}
