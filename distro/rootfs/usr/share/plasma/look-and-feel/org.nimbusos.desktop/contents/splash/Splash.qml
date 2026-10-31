// SPDX-License-Identifier: GPL-2.0-only
// Nimbus OS boot-to-desktop splash (KSplashQML, Plasma 6 / Qt6).
// ksplashqml drives the "stage" property from 1 to 6 as the session starts.

import QtQuick

Rectangle {
    id: root
    color: "#1E1E1F"

    property int stage

    onStageChanged: {
        if (stage >= 6) {
            outroAnimation.running = true;
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0

        Image {
            id: logo
            anchors.centerIn: parent
            source: "images/logo.svg"
            sourceSize.width: 128
            sourceSize.height: 128
            width: 128
            height: 128
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Rectangle {
            id: track
            anchors.top: logo.bottom
            anchors.topMargin: 48
            anchors.horizontalCenter: parent.horizontalCenter
            width: 180
            height: 2
            radius: 1
            color: "#3A3A3C"

            Rectangle {
                id: bar
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                radius: 1
                color: "#F2F2F7"
                width: track.width * Math.min(Math.max(root.stage, 0), 6) / 6

                Behavior on width {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: 600
        easing.type: Easing.InOutQuad
    }

    OpacityAnimator {
        id: outroAnimation
        running: false
        target: content
        from: 1
        to: 0
        duration: 400
        easing.type: Easing.InOutQuad
    }

    Component.onCompleted: {
        introAnimation.running = true;
    }
}
