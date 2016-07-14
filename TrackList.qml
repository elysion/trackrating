import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import "database.js" as Database

Item {
    id: root
    property alias model: table.model
    signal doubleClicked(int row)
    signal returnClicked

    function itemAt(x, y) {
        return model.get(table.rowAt(x, y))
    }

    function selectRowAt(x, y) {
        table.selection.clear()
        table.selection.select(table.rowAt(x, y))
    }

    function getSelectedTracks() {
        var tracks = []

        table.selection.forEach(function(row) {
            tracks.push(model.get(row))
        })

        return tracks
    }

    function clearSelection() {
        table.selection.clear()
    }

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

        selectionMode: SelectionMode.ExtendedSelection

        TableViewColumn { role: "Artist"; title: "Artist" ; width: 100 }
        TableViewColumn { role: "Title"; title: "Title" ; width: 200 }
        TableViewColumn { role: "Tags"; title: "Tags" ; width: 200 }
        TableViewColumn { role: "Filename"; title: "Filename" ; width: 200 }

        onDoubleClicked: root.doubleClicked(row)

        Keys.onReturnPressed: {
            root.returnClicked()
        }

        focus: true
    }
}
