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
        urls.forEach(function(file) {
            var trackInfo = trackInfoProvider.getTrackInfo(file);
            Database.addOrReplaceTrack(trackInfo.artist, trackInfo.title, file)
        })

        optionsRow.updateList()
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

        onActiveTabChanged: {
            if (activeTab === 0) {
                optionsRow.updateList()
            }
        }

        Item {
            anchors.fill: parent
            visible: tabs.activeTab === 0
            focus: visible

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
                id: trackList
                anchors {
                    top: sortBar.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                model: trackListModel

                Component.onCompleted: {
                    optionsRow.updateList()
                }

                onDoubleClicked: {
                    player.play(model.get(row).Location)
                }

                onReturnClicked: {
                    var tracks = trackList.getSelectedTracks()
                    player.play(tracks[0].Location)
                }

                function startRatingCurrentlySelectedTrack() {
                    var tracks = trackList.getSelectedTracks()
                    var track = tracks[0]
                    player.play(track.Location)
                    rateTab.startComparison(track, categoryCheckBox.getCurrentCategory())
                    tabs.activeTab = 1
                }

                Action {
                    id: rateAction
                    text: "&Rate"
                    shortcut: "Ctrl+R"
                    onTriggered: trackList.startRatingCurrentlySelectedTrack()
                }

                MouseArea {
                    id: contextMenuTrigger

                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton

                    property variant selectedTrackProxy

                    onPressed: {
                        selectedTrackProxy = trackList.itemAt(mouse.x, mouse.y)
                        trackList.selectRowAt(mouse.x, mouse.y)
                        contextMenu.popup()
                    }
                }

                Menu {
                    id: contextMenu

                    MenuItem {
                        text: "Rate"

                        onTriggered: {
                            var track = contextMenuTrigger.selectedTrackProxy
                            player.play(track.Location)
                            rateTab.startComparison(track, categoryCheckBox.getCurrentCategory())
                            tabs.activeTab = 1
                        }
                    }

                    MenuItem {
                        text: "Play"
                        shortcut: "Ctrl+P"

                        onTriggered: {
                            player.play(contextMenuTrigger.selectedTrackProxy.Location)
                        }
                    }
                }
            }

            Keys.onLeftPressed: {
                player.seekBackward()
            }

            Keys.onRightPressed: {
                player.seekForward()
            }

            Keys.onDeletePressed: {
                var tracks = trackList.getSelectedTracks()

                tracks.forEach(function(track) {
                    Database.removeTrack(track.TrackId)
                })

                trackList.clearSelection()
                optionsRow.updateList()
            }
        }

        ComparisonView {
            id: rateTab

            anchors.fill: parent
            visible: tabs.activeTab === 1
            focus: visible
            currentTrackLocation: player.source
            playing: player.playing

            onAllTracksRated: {
                optionsRow.updateList()
                tabs.activeTab = 0
            }

            onTrackClicked: player.play(track.Location)

            onComparingTracks: {
                if (player.source !== rated.Location &&
                        player.source !== unrated.Location) {
                    player.play(unrated.Location)
                }
            }

            onTrackRated: {
                notification.show(track.Artist + " - " + track.Title + " rated!")
            }

            Keys.onLeftPressed: {
                player.seekBackward()
            }

            Keys.onRightPressed: {
                player.seekForward()
            }

            Keys.onUpPressed: {
                rateTrack(unrated, true, rated)
            }

            Keys.onDownPressed: {
                rateTrack(unrated, false, rated)
            }

            Keys.onTabPressed: {
                var unratedPlaying = player.source == unrated.Location
                player.source = unratedPlaying ? rated.Location : unrated.Location
                player.play()
            }
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

    Item {
        id: notification

        function show(text) {
            notificationText.text = text
            state = "visible"
            timer.restart()
        }

        function hide() {
            state = "hidden"
        }

        anchors.centerIn: parent

        Timer {
            id: timer
            interval: 2000
            running: false
            repeat: false
            onTriggered: notification.hide()
        }

        Rectangle {
            id: rectangle

            anchors.centerIn: parent
            color: "#444"
            width: 400
            height: 200
            opacity: 0.8
            radius: 20
            visible: true
        }

        Text {
            id: notificationText

            anchors {
                fill: rectangle
                margins: 10
            }

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            color: "white"
            elide: Text.ElideMiddle
            font.pointSize: 20
            maximumLineCount: 3
            wrapMode: Text.Wrap
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
}
