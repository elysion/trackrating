import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import "database.js" as Database

Item {
    id: root
    property alias model: table.model
    signal doubleClicked(int row)

    Text {
        id: title
        text: "Unsorted tracks"
    }

    TableView {
        id: table

        anchors {
            top: title.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        TableViewColumn { role: "Artist"; title: "Artist" ; width: 100 }
        TableViewColumn { role: "Title"; title: "Title" ; width: 200 }

        onDoubleClicked: root.doubleClicked(row)
    }
}
