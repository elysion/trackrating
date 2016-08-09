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
    property variant track

    signal tagRemoved()

    visible: !!root.model

    onTrackChanged: {
        update()
    }

    function update() {
        Database.getTagsForTrack(track, function (tags) {
            root.model = tags
        })
    }

    Row {
        id: row

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            margins: 5
        }

        property variant keys: ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

        spacing: 5

        SharpText {
            text: "Current tags:"
            color: "white"
            height: 24
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
        }

        Repeater {
            model: root.model

            delegate: TagRectangle {
                tag: modelData.Name
                showX: true
                onRemove: {
                    Database.removeTagFromTrack(root.track, modelData, function () {
                        root.tagRemoved()
                    })
                }
            }
        }
    }
}
