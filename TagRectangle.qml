import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import "database.js" as Database

Item {
    id: root
    width: childrenRect.width
    height: childrenRect.height

    property string tag
    property string key
    property bool showX: false

    signal remove(variant tag)
    
    Rectangle {
        id: rectangle
        opacity: 0.5
        radius: 4

        width: textColumn.width + 10
        height: text.height + 10
    }

    Row {
        id: textColumn
        spacing: 5

        anchors {
            centerIn: rectangle
        }

        SharpText {
            id: text
            text: (root.key ? root.key + ": " : '') + root.tag
        }

        Item {
            id: removeTagButton
            visible: root.showX
            width: childrenRect.width
            height: childrenRect.height

            Rectangle {
                id: circle
                radius: 16

                width: 16
                height: 16

                color: "black"
                opacity: 0.5
            }

            SharpText {
                text: 'x'
                color: "white"
                opacity: mouseArea.containsMouse ? 1 : 0.5

                anchors {
                    centerIn: circle
                    verticalCenterOffset: -1
                }
            }

            MouseArea {
                id: mouseArea

                anchors.fill: circle
                cursorShape: "PointingHandCursor"
                hoverEnabled: true

                onClicked: root.remove(tag)
            }
        }
    }
}
