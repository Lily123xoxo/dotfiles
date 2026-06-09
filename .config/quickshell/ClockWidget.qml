import QtQuick
import Quickshell

Rectangle {
    id: root

    required property color accentColor
    required property string activeFont

    width: clockColumn.width + 90
    height: clockColumn.height + 20

    radius: 15
    color: root.withAlpha(Qt.darker(root.accentColor, 5), 0.67)
    border.color: 'transparent'
    border.width: 2

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Column {
        id: clockColumn
        anchors.centerIn: parent
        bottomPadding: 15
    
        Row {
            id: timeDateRow
            anchors.horizontalCenter: parent.horizontalCenter
            
            Text {
                id: clockTime
                text: Qt.formatTime(clock.date, "h:mmAP")
                topPadding: -5
                font.family: root.activeFont
                font.pixelSize: 102
                font.letterSpacing: 4
                font.weight: Font.Medium
                color: root.accentColor
                antialiasing: true
            }
        }

        // Divider - Month - Divider
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Rectangle {
                width: (daysRow.width - monthText.contentWidth - 20) / 2
                height: 1
                anchors.verticalCenter: parent.verticalCenter
                color: root.withAlpha(root.accentColor, 0.4)
            }

            Text {
                id: monthText
                text: Qt.formatDate(clock.date, "MMM").toUpperCase()
                font.family: root.activeFont
                font.pixelSize: 20
                font.weight: Font.Medium
                color: root.accentColor
            }

            Rectangle {
                width: (daysRow.width - monthText.contentWidth - 20) / 2
                height: 1
                anchors.verticalCenter: parent.verticalCenter
                color: root.withAlpha(root.accentColor, 0.4)
            }
        }

        Row {
            topPadding: 5
            id: daysRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15
            
            Repeater {
                model: 7

                Column {
                    width: 36

                    // Days of the week
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.locale().dayName(index).substring(0, 2)
                        font.family: root.activeFont
                        font.weight: Font.Normal
                        font.pixelSize: 22
                        font.letterSpacing: 2
                        color: root.dayColor(index, Qt.lighter(root.accentColor, 1.2), Qt.darker(root.accentColor, 1.2))
                    }

                    // Corresponding Date
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: root.dayColor(index, root.accentColor, Qt.darker(root.accentColor, 2))
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            anchors.centerIn: parent
                            text: root.dateForDayIndex(index)
                            font.family: root.activeFont
                            font.weight: Font.DemiBold
                            font.pixelSize: 22
                            color: root.dayColor(index, Qt.darker(root.accentColor, 2), Qt.lighter(root.accentColor, 1.2))
                        }
                    }
                }
            }
        }
    }

    /* Functions go here */

    function withAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha);
    }

    function dayColor(index, activeColor, inactiveColor) {
        return index === clock.date.getDay() ? activeColor : inactiveColor;
    }

    function dateForDayIndex(index) {
        return new Date(clock.date.getFullYear(), clock.date.getMonth(), clock.date.getDate() + (index - clock.date.getDay())).getDate();
    }
}