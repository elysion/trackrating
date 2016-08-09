import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import "database.js" as Database
import "Theme.js" as Theme

Rectangle {
    id: root

    property int activeTab
    signal tabSelected(int tab)

    Row {
        anchors.centerIn: parent
        spacing: 1

        Repeater {
            model: ["List", "Rate"]

            delegate: Rectangle {
                property bool selected: index === root.activeTab
                width: 70
                height: 25
                radius: 4
                color: selected ? Theme.SelectedColor : mouseArea.containsMouse ? Theme.PressedColor : "transparent"

                SharpText {
                    anchors.centerIn: parent
                    color: selected ? Theme.SelectedTextColor : mouseArea.containsMouse ? Theme.PressedTextColor : Theme.ButtonTextColor
                    text: modelData
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: "PointingHandCursor"
                    onClicked: root.tabSelected(index)
                }
            }
        }
    }
}
