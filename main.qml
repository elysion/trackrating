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
            var trackInfo = trackInfoProvider.getTrackInfo(file)
            var crate = crateCheckBox.getCurrentCrate()
            Database.addTrack(trackInfo.artist, trackInfo.title, trackInfo.url, crate.CrateId)
        })

        optionsRow.updateList()
    }

    function addFolder(folder) {
        var tracks = filesInFolderProvider.getFiles(folder)
        addTracks(tracks)
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
                    ratedCheckBox.select(false)
                    crateCheckBox.refresh()
                    crateCheckBox.currentIndex = 0
                    trackListModel.refresh()
                }
            }
            MenuItem {
                text: qsTr("Add category")

                onTriggered: {
                    Database.getCategories(function(categories) {
                        newCategoryDialog.firstCategory = categories.length === 0
                        newCategoryDialog.open()
                    })
                }
            }
            MenuItem {
                text: qsTr("Add crate")

                onTriggered: {
                    Database.getCrates(function(crates) {
                        newCrateDialog.open()
                    })
                }
            }

            MenuItem {
                text: qsTr("E&xit")
                onTriggered: Qt.quit();
            }
        }
    }

    NewCategoryDialog {
        id: newCategoryDialog

        onAccepted: {
            firstCategory = false
            Database.createCategory(queryResult)
            categoryCheckBox.refresh()
            categoryCheckBox.selectCategory(queryResult)
            ratedCheckBox.select(false)
            queryResult = ""
        }
    }

    NewCrateDialog {
        id: newCrateDialog

        onAccepted: {
            Database.createCrate(queryResult)
            crateCheckBox.refresh()
            crateCheckBox.selectCrate(queryResult)
            queryResult = ""
            trackListModel.refresh()
        }
    }

    FileDialog {
        id: importFolderDialog
        selectFolder: true

        onAccepted: {
            root.addFolder(folder)
            trackListModel.refresh()
        }
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
            var crate = crateCheckBox.getCurrentCrate()
            Database.getTracks(crate.CrateId, sort || "Artist", filter || "", function(results) {
                importOverlay.visible = results.length === 0
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
                        var crate = crateCheckBox.getCurrentCrate()
                        if (crate === undefined) return

                        var category = categoryCheckBox.getCurrentCategory()
                        if (category === undefined) return

                        if (ratedCheckBox.rated()) {
                            Database.getRatedTracksFor(category.CategoryId, crate.CrateId, showTracks)
                        } else {
                            Database.getUnratedTracksFor(category.CategoryId, crate.CrateId, null, showTracks)
                        }

                        function showTracks(tracks) {
                            trackListModel.showTracksFromDbResults(tracks)
                        }
                    }

                    Text {
                        text: "Crate:"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    ComboBox {
                        id: crateCheckBox

                        function select(crate) {
                            for (var i = 0; i < model.count; ++i) {
                                if (model.get(i).Name === crate) {
                                    currentIndex = i
                                    break
                                }
                            }
                        }

                        function getCurrentCrate() {
                            var currentCrate = model.get(currentIndex)
                            if (!model || !currentCrate) return undefined
                            return currentCrate
                        }

                        width: 200

                        onCurrentIndexChanged: optionsRow.updateList()

                        model: ListModel {}

                        function selectCrate(name) {
                            for (var i = 0; i < model.count; ++i) {
                                if (name === model.get(i).Name) {
                                    currentIndex = i
                                    break
                                }
                            }
                        }

                        function refresh() {
                            var currentItem = currentText
                            model.clear()
                            currentIndex = -1

                            Database.getCrates(function(crates) {
                                for (var i = 0; i < crates.length; ++i) {
                                    var name = crates.item(i).Name
                                    crateCheckBox.model.append({text: crates.item(i).Name, Name: name, CrateId: crates.item(i).CrateId})
                                }

                                if (crates.length === 0) {
                                    newCrateDialog.firstCrate = true
                                    newCrateDialog.open()
                                }

                                if (currentItem) {
                                    selectCrate(currentItem)
                                }
                            })
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

                        function selectCategory(name) {
                            for (var i = 0; i < model.count; ++i) {
                                if (name === model.get(i).Name) {
                                    currentIndex = i
                                    break
                                }
                            }
                        }

                        function refresh() {
                            var currentItem = categoryCheckBox.currentText
                            categoryCheckBox.model.clear()
                            categoryCheckBox.currentIndex = -1

                            Database.getCategories(function(categories) {
                                for (var i = 0; i < categories.length; ++i) {
                                    var name = categories.item(i).Name
                                    categoryCheckBox.model.append({text: categories.item(i).Name, Name: name, CategoryId: categories.item(i).CategoryId})
                                }

                                if (categories.length === 0) {
                                    newCategoryDialog.firstCategory = true
                                    newCategoryDialog.open()
                                }

                                if (currentItem) {
                                    selectCategory(currentItem)
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

                        function select(rated) {
                            currentIndex = rated ? 1 : 0
                        }

                        function rated() {
                            return currentIndex === 1
                        }

                        width: 200

                        onCurrentIndexChanged: optionsRow.updateList()

                        model: ["Unrated", "Rated"]
                    }
                }

                Component.onCompleted: {
                    crateCheckBox.refresh()
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
                    rateTab.startComparison(track, categoryCheckBox.getCurrentCategory(), crateCheckBox.getCurrentCrate())
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
                        shortcut: "Ctrl+R"

                        onTriggered: {
                            var track = contextMenuTrigger.selectedTrackProxy
                            player.play(track.Location)
                            rateTab.startComparison(track, categoryCheckBox.getCurrentCategory(), crateCheckBox.getCurrentCrate())
                            tabs.activeTab = 1
                        }
                    }

                    MenuItem {
                        text: "Play"
                        shortcut: "Enter"

                        onTriggered: {
                            player.play(contextMenuTrigger.selectedTrackProxy.Location)
                        }
                    }

                    MenuItem {
                        text: "Remove"

                        onTriggered: {
                            Database.removeTrack(contextMenuTrigger.selectedTrackProxy.TrackId,
                                                 contextMenuTrigger.selectedTrackProxy.CrateId)
                            optionsRow.updateList()
                        }
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

                Item {
                    id: importOverlay

                    anchors.fill: parent
                    visible: false

                    Rectangle {
                        color: "black"
                        opacity: 0.75

                        anchors.fill: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                    }

                    Column {
                        anchors.centerIn: parent

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "white"
                            text: "Crate empty."
                        }

                        Button {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Add folders"

                            onClicked: importFolderDialog.open()
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
                var crate = crateCheckBox.getCurrentCrate()

                tracks.forEach(function(track) {
                    Database.removeTrack(track.TrackId, crate.CrateId)
                })

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
                ratedCheckBox.select(true)
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
