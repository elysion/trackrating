import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import "database.js" as Database

ApplicationWindow {
    id: root

    title: qsTr("Track Rating")
    width: 640
    height: 480
    visible: true

    Settings {
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
    }

    function addTracks(urls) {
        player.play(urls[0])
        urls.forEach(function(file) {
            var trackInfo = trackInfoProvider.getTrackInfo(file);
            Database.addOrReplaceTrack(trackInfo.artist, trackInfo.title, file)
        })

        trackListModel.refresh()
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            MenuItem {
                text: qsTr("Import f&iles")
                onTriggered: importFilesDialog.open()
            }
            MenuItem {
                text: qsTr("Import f&older")
                onTriggered: importFolderDialog.open()
            }
            MenuItem {
                text: qsTr("Clear database")
                onTriggered: {
                    Database.clearDatabase()
                    categoryCheckBox.refresh()
                    trackListModel.refresh()
                }
            }
            MenuItem {
                text: qsTr("Add category")
                onTriggered: newCategoryDialog.open()
            }

            MenuItem {
                text: qsTr("E&xit")
                onTriggered: Qt.quit();
            }
        }
    }

    Dialog {
        id: newCategoryDialog

        title: "Create a new category"

        Item {
            anchors.fill: parent

            Text {
                id: label

                anchors {
                    left: parent.left
                    top: parent.top
                }

                text: "Category: "
            }

            TextField {
                id: textField

                anchors {
                    left: label.right
                    right: parent.right
                    top: parent.top
                }
            }
        }

        standardButtons: StandardButton.Ok | StandardButton.Cancel

        onAccepted: {
            Database.createCategory(textField.text)
            categoryCheckBox.refresh()
        }
    }

    FileDialog {
        id: importFolderDialog
        selectFolder: true
    }

    FileDialog {
        id: importFilesDialog
        selectMultiple: true
        nameFilters: [ "Audio files (*.mp3)" ]
        onAccepted: {
            root.addTracks(fileUrls)
        }
    }

    ListModel {
        id: trackListModel

        function refresh(sort, filter) {
            sort = sort || "Artist"
            filter = filter || ""

            Database.getTracks(sort, filter, function(results) {
                showTracksFromDbResults(results)
            })
        }

        function showTracksFromDbResults(results) {
            clear()

            for (var i = 0; i < results.length; ++i) {
                var item = results.item(i)
                for (var key in item) {
                    console.log(key, item[key])
                }
                append(results.item(i))
            }
        }
    }

    Item {
        id: tabs

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: player.top
        }

        property int activeTab: 0

        Item {
            anchors.fill: parent
            visible: tabs.activeTab === 0

            RowLayout {
                id: sortBar

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 10
                }

                Row {
                    id: optionsRow

                    spacing: 10

                    function updateList() {
                        var category = categoryCheckBox.getCurrentCategory()
                        if (category === undefined) return

                        if (ratedCheckBox.currentIndex === 1) {
                            Database.getRatedTracksFor(category.CategoryId, showTracks)
                        } else {
                            Database.getUnratedTracksFor(category.CategoryId, null, showTracks)
                        }

                        function showTracks(tracks) {
                            trackListModel.showTracksFromDbResults(tracks)
                        }
                    }

                    Text {
                        text: "Category:"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    ComboBox {
                        id: categoryCheckBox
                        width: 200

                        function getCurrentCategory() {
                            if (!model || !model.get(currentIndex)) return undefined
                            return model.get(currentIndex)
                        }

                        function refresh() {
                            categoryCheckBox.model.clear()

                            Database.getCategories(function(categories) {
                                for (var i = 0; i < categories.length; ++i) {
                                    categoryCheckBox.model.append({text: categories.item(i).Name, Name: categories.item(i).Name, CategoryId: categories.item(i).CategoryId})
                                }
                            })
                        }

                        model: ListModel {}

                        onCurrentIndexChanged: {
                            optionsRow.updateList()
                        }
                    }

                    Text {
                        text: "Show:"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    ComboBox {
                        id: ratedCheckBox
                        width: 200

                        onCurrentIndexChanged: optionsRow.updateList()

                        model: ["Unrated", "Rated"]
                    }
                }

                Component.onCompleted: {
                    categoryCheckBox.refresh()
                }
            }

            TrackList {
                anchors {
                    top: sortBar.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                model: trackListModel

                Component.onCompleted: {
                    model.refresh()
                }

                onDoubleClicked: {

                    player.play(model.get(row).Location)
                    rateTab.startComparison(model.get(row), categoryCheckBox.getCurrentCategory())

                    tabs.activeTab = 1
                }
            }
        }

        ComparisonView {
            id: rateTab

            anchors.fill: parent
            visible: tabs.activeTab === 1
            currentTrackLocation: player.source

            onTracksRated: {
                trackListModel.refresh()
                tabs.activeTab = 0
            }

            onTrackClicked: player.play(track.Location)
        }

        Row {
            anchors {
                bottom: parent.bottom
                bottomMargin: 10
                horizontalCenter: parent.horizontalCenter
            }

            spacing: 10

            Repeater {
                model: ["List", "Rate"]

                delegate: Rectangle {
                    width: 100
                    height: 20
                    radius: 20
                    color: "#8cf"
                    opacity: index === tabs.activeTab || mouseArea.containsMouse ? 0.95 : 0.75

                    Text {
                        anchors.centerIn: parent
                        color: "white"
                        font.bold: true
                        text: modelData
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        cursorShape: "PointingHandCursor"
                        hoverEnabled: true
                        onClicked: tabs.activeTab = index
                    }
                }
            }
        }
    }

    TrackPlayer {
        id: player

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        height: 200
    }

    DropArea {
        anchors.fill: parent

        onEntered: {
            drag.accept(Qt.LinkAction);
        }
        onDropped: {
            if (drop.hasUrls) {
                root.addTracks(drop.urls)
            }
        }
    }
}
