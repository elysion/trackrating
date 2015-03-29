import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Dialogs 1.2
import "database.js" as Database

Dialog {
    id: queryDialog

    width: 300
    height: root.infoText != "" ? 130 : 100

    property alias categoryName: textField.text
    property alias infoText: infoText.text
    property alias queryLabel: label.text
    property alias queryResult: textField.text

    Column {
        anchors.fill: parent

        spacing: 10

        Text {
            id: infoText
            visible: root.infoText != ""

            anchors {
                left: parent.left
                right: parent.right
            }

            wrapMode: Text.Wrap
        }

        Item {
            height: childrenRect.height

            anchors {
                left: parent.left
                right: parent.right
            }

            Text {
                id: label
            }

            TextField {
                id: textField

                anchors {
                    left: label.right
                    right: parent.right
                }
            }
        }
    }

    standardButtons: firstCategory ? StandardButton.Ok : StandardButton.Ok | StandardButton.Cancel
}
