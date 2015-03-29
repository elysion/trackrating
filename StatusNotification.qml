import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import "database.js" as Database

Item {
    id: notification

    function show(text) {
        notificationText.text = text
        state = "visible"
    }

    function update(status) {
        statusText.text = status
    }

    function hide() {
        state = "hidden"
    }

    anchors.centerIn: parent

    Rectangle {
        id: rectangle

        anchors.centerIn: parent
        color: "#444"
        width: 400
        height: 100
        opacity: 0.8
        radius: 20
        visible: true
    }

    Column {
        anchors {
            fill: rectangle
            margins: 10
        }

        spacing: 10

        Text {
            id: notificationText

            anchors {
                left: parent.left
                right: parent.right
            }

            horizontalAlignment: Text.AlignHCenter
            color: "white"
            elide: Text.ElideMiddle
            font.pointSize: 20
            maximumLineCount: 3
            wrapMode: Text.Wrap
        }

        Text {
            id: statusText

            anchors {
                left: parent.left
                right: parent.right
            }

            horizontalAlignment: Text.AlignHCenter
            color: "white"
            font.pointSize: 12
            maximumLineCount: 3
            wrapMode: Text.Wrap
        }

        Spinner {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 20
            height: width
        }
    }

    state: "hidden"
    states: [
        State {
            name: "visible"
            PropertyChanges {
                target: notification
                opacity: 1
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: notification
                opacity: 0
            }
        }
    ]

    transitions: Transition {
        PropertyAnimation {
            properties: "opacity"
        }
    }
}
