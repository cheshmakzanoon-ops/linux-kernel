// SPDX-License-Identifier: GPL-2.0-only
// Nimbus OS SDDM greeter theme (Qt 6 / SDDM 0.21).
// Uses the context objects SDDM injects: sddm, userModel, sessionModel, config.

import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#0B1220"

    readonly property color accent: config.accent ? config.accent : "#2F7CF6"
    readonly property string fontFamily: config.font ? config.font : "Inter"
    readonly property string bgSource: config.background
        ? config.background
        : "/usr/share/wallpapers/Nimbus/contents/images/3840x2160.svg"

    // Selected user, filled from the hidden ListView below.
    property string userName: userList.currentItem ? userList.currentItem.uName : userModel.lastUser
    property string userReal: userList.currentItem && userList.currentItem.uReal !== ""
        ? userList.currentItem.uReal : userName
    property string userIcon: userList.currentItem ? userList.currentItem.uIcon : ""
    property int sessionIndex: sessionBox.currentIndex >= 0 ? sessionBox.currentIndex : sessionModel.lastIndex

    function doLogin() {
        if (password.text.length === 0 || busy)
            return
        errorText.text = ""
        busy = true
        sddm.login(root.userName, password.text, root.sessionIndex)
    }
    property bool busy: false

    // Hidden view only used to read roles (name, realName, icon) of the last user.
    ListView {
        id: userList
        visible: false
        width: 1; height: 1
        model: userModel
        currentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
        delegate: Item {
            required property string name
            required property string realName
            required property string icon
            property string uName: name
            property string uReal: realName
            property string uIcon: icon
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.busy = false
            password.text = ""
            errorText.text = qsTr("Incorrect password")
            shake.restart()
            password.forceActiveFocus()
        }
        function onLoginSucceeded() {
            root.busy = false
        }
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: root.bgSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        sourceSize.width: root.width
        sourceSize.height: root.height
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#66000000" }
            GradientStop { position: 1.0; color: "#99000000" }
        }
    }

    // Clock and date, upper third.
    Column {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height / 6
        spacing: 4

        property date now: new Date()

        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: clock.now = new Date()
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(clock.now, "hh:mm")
            color: "white"
            font.family: root.fontFamily
            font.pixelSize: Math.round(root.height / 8)
            font.weight: Font.Light
            Accessible.role: Accessible.StaticText
            Accessible.name: qsTr("Time %1").arg(text)
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(clock.now, "dddd, d MMMM")
            color: "#E6FFFFFF"
            font.family: root.fontFamily
            font.pixelSize: Math.round(root.height / 40)
        }
    }

    // Login card.
    Column {
        id: loginBox
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.45
        spacing: 16
        width: 320
        transform: Translate { id: shakeOffset; x: 0 }

        SequentialAnimation {
            id: shake
            loops: 1
            NumberAnimation { target: shakeOffset; property: "x"; to: -14; duration: 50 }
            NumberAnimation { target: shakeOffset; property: "x"; to: 14; duration: 70 }
            NumberAnimation { target: shakeOffset; property: "x"; to: -10; duration: 70 }
            NumberAnimation { target: shakeOffset; property: "x"; to: 8; duration: 60 }
            NumberAnimation { target: shakeOffset; property: "x"; to: 0; duration: 50 }
        }

        // Avatar: user icon if available, else first letter on the accent colour.
        Item {
            id: avatar
            width: 112; height: 112
            anchors.horizontalCenter: parent.horizontalCenter
            Accessible.role: Accessible.Graphic
            Accessible.name: qsTr("Avatar of %1").arg(root.userReal)

            readonly property bool hasFace: face.status === Image.Ready
                && root.userIcon.indexOf("/usr/share/sddm/faces/") !== 0

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.accent
                border.color: "#80FFFFFF"
                border.width: 2
                visible: !avatar.hasFace
                Text {
                    anchors.centerIn: parent
                    text: root.userReal.length > 0 ? root.userReal.charAt(0).toUpperCase() : "?"
                    color: "white"
                    font.family: root.fontFamily
                    font.pixelSize: 48
                    font.weight: Font.DemiBold
                }
            }

            Image {
                id: face
                anchors.fill: parent
                source: root.userIcon !== "" ? "file://" + root.userIcon : ""
                sourceSize: Qt.size(width * 2, height * 2)
                fillMode: Image.PreserveAspectCrop
                visible: false
                layer.enabled: true
            }
            Rectangle {
                id: faceMask
                anchors.fill: parent
                radius: width / 2
                visible: false
                layer.enabled: true
            }
            MultiEffect {
                anchors.fill: parent
                source: face
                maskEnabled: true
                maskSource: faceMask
                visible: avatar.hasFace
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.userReal
            color: "white"
            font.family: root.fontFamily
            font.pixelSize: 22
            font.weight: Font.Medium
        }

        TextField {
            id: password
            width: parent.width
            height: 44
            focus: true
            echoMode: TextInput.Password
            passwordCharacter: "•"
            placeholderText: qsTr("Password")
            placeholderTextColor: "#B3FFFFFF"
            color: "white"
            selectionColor: root.accent
            font.family: root.fontFamily
            font.pixelSize: 15
            leftPadding: 18
            rightPadding: 18
            enabled: !root.busy
            KeyNavigation.tab: sessionBox
            Accessible.name: qsTr("Password for %1").arg(root.userReal)
            background: Rectangle {
                radius: height / 2
                color: password.activeFocus ? "#40FFFFFF" : "#2EFFFFFF"
                border.width: password.activeFocus ? 2 : 1
                border.color: password.activeFocus ? root.accent : "#4DFFFFFF"
            }
            onAccepted: root.doLogin()
            onTextEdited: errorText.text = ""
            Component.onCompleted: forceActiveFocus()
        }

        Text {
            id: errorText
            anchors.horizontalCenter: parent.horizontalCenter
            text: ""
            color: "#FFB4B4"
            font.family: root.fontFamily
            font.pixelSize: 14
            height: 18
            Accessible.role: Accessible.AlertMessage
            Accessible.name: text
        }
    }

    // Bottom bar: session picker and power actions.
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 28
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12

        ComboBox {
            id: sessionBox
            width: 220
            height: 38
            model: sessionModel
            textRole: "name"
            currentIndex: sessionModel.lastIndex
            font.family: root.fontFamily
            KeyNavigation.tab: rebootButton.visible ? rebootButton
                : (powerButton.visible ? powerButton : password)
            Accessible.name: qsTr("Session")
            contentItem: Text {
                leftPadding: 14
                rightPadding: sessionBox.indicator.width + 8
                text: sessionBox.displayText
                color: "white"
                font: sessionBox.font
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            background: Rectangle {
                radius: 10
                color: sessionBox.activeFocus ? "#40FFFFFF" : "#26FFFFFF"
                border.width: sessionBox.activeFocus ? 2 : 1
                border.color: sessionBox.activeFocus ? root.accent : "#33FFFFFF"
            }
        }

        component BarButton: Button {
            id: btn
            height: 38
            font.family: root.fontFamily
            leftPadding: 16
            rightPadding: 16
            contentItem: Text {
                text: btn.text
                color: "white"
                font: btn.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 10
                color: btn.down ? root.accent : (btn.hovered || btn.activeFocus ? "#40FFFFFF" : "#26FFFFFF")
                border.width: btn.activeFocus ? 2 : 1
                border.color: btn.activeFocus ? root.accent : "#33FFFFFF"
            }
            Keys.onReturnPressed: clicked()
            Keys.onEnterPressed: clicked()
        }

        BarButton {
            id: rebootButton
            text: qsTr("Restart")
            visible: sddm.canReboot
            Accessible.name: qsTr("Restart the computer")
            KeyNavigation.tab: powerButton.visible ? powerButton : password
            onClicked: sddm.reboot()
        }

        BarButton {
            id: powerButton
            text: qsTr("Shut down")
            visible: sddm.canPowerOff
            Accessible.name: qsTr("Shut down the computer")
            KeyNavigation.tab: password
            onClicked: sddm.powerOff()
        }
    }
}
