import QtQuick
import Quickshell

Rectangle {
    id: root

    required property color accentColor
    required property string activeFont

    width: clockColumn.width + 50
    height: clockColumn.height + 30

    radius: 15
    color: '#92000000'
    border.color: "#11ffffff"
    border.width: 2

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Column {
        id: clockColumn
        anchors.left: parent.left
        anchors.leftMargin: 25
        anchors.top: parent.top
        anchors.topMargin: 10

        Text {
            id: clockTime
            text: Qt.formatTime(clock.date, "h:mm")
            font.family: root.activeFont
            font.pixelSize: 72
            font.weight: Font.Medium
            color: root.accentColor
            antialiasing: true
        }

        Rectangle {
            id: divider
            width: clockTime.contentWidth + 120
            height: 1
            color: root.accentColor
            opacity: 0.4
        }

        Item {
            id: dateRow
            width: divider.width
            height: dayText.contentHeight

            Text {
                id: dayText
                anchors.right: parent.right
                text: Qt.formatDate(clock.date, "dddd").toLowerCase()
                font.family: root.activeFont
                font.weight: Font.Normal
                font.pixelSize: 38
                font.letterSpacing: 2
                color: root.accentColor
            }
        }
    }
}
