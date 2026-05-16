import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// SDDM requires explicit versioning for imports
// Attribution for SVG loafing cat: <a href="https://www.vecteezy.com/free-vector/cat-loaf">Cat Loaf Vectors by Vecteezy</a>

Rectangle {
    property color backgroundColor: "#000000"
    property color borderColor: '#666666'
    property int borderWidth: 2
    property int fieldRadius: 20
    property int buttonFontSize: 18
    property color accentColor: '#c94635'
    property int highlightFadeOut: 400
    property real textHoverScale: 1.2
    property int selectedUserIndex: 0

    ListModel { id: errorLog }

    width: Screen.width
    height: Screen.height
    color: backgroundColor

    Image {
        id: loafFrame
        source: "loaf-frame.svg"
        anchors.centerIn: parent
        width: parent.width * 0.9
        height: parent.height * 0.9
        fillMode: Image.PreserveAspectFit
        opacity: 0.3
    }

    Rectangle {

        property int formFieldHeight: height * 0.1

        id: mainPanel

        anchors.horizontalCenter: loafFrame.horizontalCenter
        anchors.verticalCenter: loafFrame.verticalCenter
        anchors.verticalCenterOffset: 200

        width: loafFrame.paintedWidth * 0.6
        height: loafFrame.paintedHeight * 0.5
        radius: 30  
        color: backgroundColor
        border.width: borderWidth
        border.color: borderColor

        Rectangle {
            id: username

            anchors.top: mainPanel.top
            anchors.left: mainPanel.left
            anchors.right: consolePanel.left
            anchors.topMargin: 20
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            height: parent.formFieldHeight
            radius: fieldRadius
            border.width: borderWidth
            border.color: borderColor
            color: "transparent"

            TextField {
                id: usernameField

                anchors.fill: parent
                anchors.margins: 5

                text: userModel.data(userModel.index(0, 0), Qt.UserRole + 1)
                focus: text === ""

                font.pixelSize: 20
                color: "#FFFFFF"
                verticalAlignment: TextInput.AlignVCenter
                background: null
            }
        }

        Rectangle {
            id: password

            anchors.top: username.bottom
            anchors.left: mainPanel.left
            anchors.right: consolePanel.left
            anchors.topMargin: 20
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            height: parent.formFieldHeight
            radius: fieldRadius
            border.width: borderWidth
            border.color: borderColor
            color: "transparent"

            TextField {
                id: passwordField

                anchors.fill: parent
                anchors.margins: 5

                placeholderText: "password"
                placeholderTextColor: '#999999'

                echoMode: TextInput.Password
                focus: usernameField.text !== ""
                Keys.onReturnPressed: login()

                font.pixelSize: 20
                color: "#FFFFFF"
                verticalAlignment: TextInput.AlignVCenter
                background: null
            }
        } 

        Rectangle {
            id: consolePanel

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 20

            width: parent.width * 0.4
            radius: fieldRadius
            border.width: borderWidth
            border.color: borderColor
            color: "transparent"

            Column {
                id: consoleContent
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 15
                spacing: 8

                Text {
                    text: "> @" + (sddm.hostName || "unknown")
                    color: "#ffffff"
                    font.pixelSize: 15
                }

                Text {
                    id: clockText
                    text: "> " + Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss")
                    color: "#ffffff"
                    font.pixelSize: 15

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: clockText.text = "> " + Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss")
                    }
                }

                ComboBox {
                    id: sessionSelector
                    width: parent.width
                    model: sessionModel
                    textRole: "name"
                }
            }

            Rectangle {
                id: consoleDivider
                anchors.top: consoleContent.bottom
                anchors.topMargin: 40
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: borderColor
            }

            Flickable {
                id: consoleFlickable
                anchors.top: consoleDivider.bottom
                anchors.topMargin: 10
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                anchors.bottomMargin: 10
                contentHeight: consoleLog.height
                clip: true

                Column {
                    id: consoleLog
                    width: parent.width
                    spacing: 4

                    Text {
                        text: "> initialisation complete"
                        color: '#929292'
                        font.pixelSize: 15
                    }

                    Repeater {
                        model: errorLog
                        Text {
                            text: "> " + model.text
                            color: "#ff5555"
                            font.pixelSize: 15
                        }
                    }

                    Text {
                        text: "> hello world"
                        color: '#929292'
                        font.pixelSize: 15
                    }

                    Text {
                        text: "> _"
                        color: '#929292'
                        font.pixelSize: 15
                    }
                }

                onContentHeightChanged: {
                    contentY = Math.max(0, contentHeight - height)
                }
            }
        }

        RowLayout {
            id: buttonRow
            
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: consolePanel.left
            anchors.bottomMargin: 20
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            height: parent.height * 0.5
            spacing: 10

            Rectangle {
                id: shutdown

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: fieldRadius
                border.width: borderWidth
                border.color: "transparent"
                color: "transparent"

                states: State {
                    name: "hovered"; when: shutdownMouse.containsMouse
                    PropertyChanges { target: shutdown; border.color: accentColor; scale: 1.05 }
                    PropertyChanges { target: shutdownText; scale: textHoverScale }
                }
                transitions: [
                    Transition {
                        from: ""; to: "hovered"
                        ColorAnimation { duration: 0 }
                        NumberAnimation { property: "scale"; duration: 0 }
                    },
                    Transition {
                        from: "hovered"; to: ""
                        ColorAnimation { duration: highlightFadeOut }
                        NumberAnimation { property: "scale"; duration: 800; easing.type: Easing.OutBack }
                    }
                ]

                Text {
                    id: shutdownText
                    anchors.centerIn: parent
                    text: "shutdown"
                    color: "#ffffff"
                    font.pixelSize: buttonFontSize
                }
                MouseArea {
                    id: shutdownMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: powerOff()
                }
            }

            Rectangle {
                id: reboot

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: fieldRadius
                border.width: borderWidth
                border.color: "transparent"
                color: "transparent"

                states: State {
                    name: "hovered"; when: rebootMouse.containsMouse
                    PropertyChanges { target: reboot; border.color: accentColor; scale: 1.05 }
                    PropertyChanges { target: rebootText; scale: textHoverScale }
                }
                transitions: [
                    Transition {
                        from: ""; to: "hovered"
                        ColorAnimation { duration: 0 }
                        NumberAnimation { property: "scale"; duration: 0 }
                    },
                    Transition {
                        from: "hovered"; to: ""
                        ColorAnimation { duration: highlightFadeOut }
                        NumberAnimation { property: "scale"; duration: 800; easing.type: Easing.OutBack }
                    }
                ]

                Text {
                    id: rebootText
                    anchors.centerIn: parent
                    text: "reboot"
                    color: "#ffffff"
                    font.pixelSize: buttonFontSize
                }
                MouseArea {
                    id: rebootMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: reboot()
                }
            }

            Rectangle {
                id: sleep

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: fieldRadius
                border.width: borderWidth
                border.color: "transparent"
                color: "transparent"

                states: State {
                    name: "hovered"; when: sleepMouse.containsMouse
                    PropertyChanges { target: sleep; border.color: accentColor; scale: 1.05 }
                    PropertyChanges { target: sleepText; scale: textHoverScale }
                }
                transitions: [
                    Transition {
                        from: ""; to: "hovered"
                        ColorAnimation { duration: 0 }
                        NumberAnimation { property: "scale"; duration: 0 }
                    },
                    Transition {
                        from: "hovered"; to: ""
                        ColorAnimation { duration: highlightFadeOut }
                        NumberAnimation { property: "scale"; duration: 800; easing.type: Easing.OutBack }
                    }
                ]

                Text {
                    id: sleepText
                    anchors.centerIn: parent
                    text: "sleep"
                    color: "#ffffff"
                    font.pixelSize: buttonFontSize
                }
                MouseArea {
                    id: sleepMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: suspend()
                }
            }

            Rectangle {
                id: loginButton

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: fieldRadius
                border.width: borderWidth
                border.color: "transparent"
                color: "transparent"

                states: State {
                    name: "hovered"; when: loginMouse.containsMouse
                    PropertyChanges { target: loginButton; border.color: accentColor; scale: 1.05 }
                    PropertyChanges { target: loginText; scale: textHoverScale }
                }
                transitions: [
                    Transition {
                        from: ""; to: "hovered"
                        ColorAnimation { duration: 0 }
                        NumberAnimation { property: "scale"; duration: 0 }
                    },
                    Transition {
                        from: "hovered"; to: ""
                        ColorAnimation { duration: highlightFadeOut }
                        NumberAnimation { property: "scale"; duration: 400; easing.type: Easing.OutBack }
                    }
                ]

                Text {
                    id: loginText
                    anchors.centerIn: parent
                    text: "login"
                    color: "#ffffff"
                    font.pixelSize: buttonFontSize
                }
                MouseArea {
                    id: loginMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: login()
                }
            }
        }

    }

/* Functions go here */

    function login() {
        errorLog.clear()
        sddm.login(
            usernameField.text,
            passwordField.text,
            sessionSelector.currentIndex
        )
    }

    function selectUser(index) {
        selectedUserIndex = index
    }

    function populateSessions() {
        var sessions = []
        for (var i = 0; i < sessionModel.rowCount(); i++) {
            sessions.push(sessionModel.data(sessionModel.index(i, 0), Qt.UserRole))
        }
        return sessions
    }

    function showError(message) {
        errorLog.append({ text: message })
    }

    function powerOff() {
        sddm.powerOff()
    }

    function reboot() {
        sddm.reboot()
    }

    function suspend() {
        sddm.suspend()
    }

    // Unused
    function hibernate() {
        sddm.hibernate()
    }

    property var errorMessages: [
        "segfault (core dumped)",
        "error: auth returned nullptr",
        "fatal: password mismatch at 0xDEADBEEF",
        "panic: invalid credentials",
        "403 forbidden",
        "err: stack overflow in auth.c:42",
        "SIGTERM: credential process killed",
        "throw new Error('wrong password')",
        "exit code 1: permission denied"
    ]

    Connections {
        target: sddm
        onLoginSucceeded: {}
        onLoginFailed: {
            showError(errorMessages[Math.floor(Math.random() * errorMessages.length)])
            passwordField.text = ""
        }
    }
}
