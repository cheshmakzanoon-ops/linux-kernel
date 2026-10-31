// SPDX-License-Identifier: GPL-2.0-only
// Installation slideshow for Nimbus OS.
import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    function nextSlide() {
        presentation.goToNextSlide();
    }

    Timer {
        id: advanceTimer
        interval: 12000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: nextSlide()
    }

    Slide {
        Image {
            id: welcomeLogo
            source: "file:///usr/share/pixmaps/nimbus-logo.svg"
            width: 128; height: 128
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 40
        }
        Text {
            anchors.top: welcomeLogo.bottom
            anchors.topMargin: 24
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "#2F7CF6"
            font.pixelSize: 22
            text: qsTr("Welcome to Nimbus OS")
        }
        Text {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 60
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 15
            text: qsTr("Sit back while your new desktop settles in. "
                     + "In a few minutes you will have a calm, fast and "
                     + "uncluttered workspace ready to go.")
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 16
            textFormat: Text.RichText
            text: qsTr("<h2 style='color:#2F7CF6'>Privacy first</h2>"
                     + "<p>Nimbus OS sends no telemetry and shows no ads. "
                     + "Your files, your settings and your activity stay "
                     + "on your machine unless you decide otherwise.</p>")
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 16
            textFormat: Text.RichText
            text: qsTr("<h2 style='color:#2F7CF6'>Built on the Linux kernel</h2>"
                     + "<p>Under the hood sits the Linux kernel and the solid "
                     + "Debian foundation, bringing broad hardware support, "
                     + "regular security updates and thousands of free "
                     + "software packages.</p>")
        }
    }

    // Slideshow API 2: called when the slideshow becomes visible / hidden.
    function onActivate() {
        presentation.currentSlide = 0;
    }

    function onLeave() {
    }
}
