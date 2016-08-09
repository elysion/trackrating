import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import "database.js" as Database
import QtQuick.Controls.Styles 1.4
import "Theme.js" as Theme

Item {
    id: root
    property alias model: table.model
    property bool showIndex: false
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

    SharpText {
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

        TableViewColumn { role: "Index"; title: "#" ; width: 40; visible: root.showIndex }
        TableViewColumn { role: "Artist"; title: "Artist" ; width: 100 }
        TableViewColumn { role: "Title"; title: "Title" ; width: 200 }
        TableViewColumn { role: "Tags"; title: "Tags" ; width: 200 }
        TableViewColumn { role: "Filename"; title: "Filename" ; width: 200 }

        onDoubleClicked: root.doubleClicked(row)

        Keys.onReturnPressed: {
            root.returnClicked()
        }

        focus: true

        style: TableViewStyle {
            alternateBackgroundColor: Theme.AlternateRowColor
            backgroundColor: Theme.RowColor
            highlightedTextColor: Theme.SelectedTextColor
            textColor: Theme.TextColor
            transientScrollBars: true

            rowDelegate: Rectangle {
                height: 30
                color: styleData.selected ? Theme.SelectedColor :
                         !styleData.alternate ? alternateBackgroundColor : backgroundColor
            }

            headerDelegate: Rectangle {
                    height: 30

                    SharpText {
                        id: textItem
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: styleData.textAlignment
                        anchors.leftMargin: horizontalAlignment === Text.AlignLeft ? 12 : 1
                        anchors.rightMargin: horizontalAlignment === Text.AlignRight ? 8 : 1
                        text: styleData.value
                        elide: Text.ElideRight
                        color: textColor
                    }
                    Rectangle {
                        anchors {
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                            topMargin: 2
                            bottomMargin: 2
                        }

                        width: 1
                        color: "#e6e6e6"
                    }
                    Rectangle {
                        anchors {
                            right: parent.right
                            left: parent.left
                            bottom: parent.bottom
                        }

                        height: 1
                        color: "#e6e6e6"
                    }
                }
        }
    }
}
