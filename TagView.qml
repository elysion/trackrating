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
            visible: root.model !== undefined && root.model.length === row.keys.length
        }
    }
}
