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
    property int offset: 0
    property bool moreTagsAvailable: false

    onTrackChanged: root.offset = 0

    function moreTags() {
        Database.getTags(function (tags) {
            if (offset + root.model.length >= tags.length - 1) {
                offset = 0
            } else {
                offset += root.model.length
            }

            update()
        })
    }

    function update() {
        Database.getTags(function (tags) {
            Database.getTagsForTrack(track, function (tagsForTrack) {
                Database.getNextTags(track, offset, function(nextTags) {
                    root.model = nextTags
                })
                root.moreTagsAvailable = tags.length > root.model.length + tagsForTrack.length
            })
        })
    }

    Row {
        id: row

        property variant keys: ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            margins: 5
        }

        spacing: 5

        Repeater {
            model: root.model

            delegate: TagRectangle {
                key: row.keys[index]
                tag: modelData.Name
            }
        }

        TagRectangle {
            key: "0"
            tag: "More tags..."
            visible: !!root.track && root.moreTagsAvailable
        }

        TagRectangle {
            key: "+"
            tag: "Create and add new tag"
            visible: !!root.track && root.moreTagsAvailable
        }
    }
}
