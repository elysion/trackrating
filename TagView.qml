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

    property variant model
    property variant excluded: []

    Row {
        id: row

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            margins: 5
        }

        spacing: 5

        Repeater {
            model: root.model

            delegate: Rectangle {
                opacity: 0.5
                radius: 4
                width: childrenRect.width + 10
                height: childrenRect.height + 10

                Text {
                    text: (index+1) + ": " + modelData.Name
                    anchors {
                        left: parent.left
                        top: parent.top
                        margins: 5
                    }
                }
            }
        }
    }
}
