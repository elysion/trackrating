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
            var crate = sortBar.crate
            Database.addTrack(trackInfo.artist, trackInfo.title, trackInfo.url, crate.CrateId)
        })

        sortBar.updateList()
    }

    function addFolder(folder) {
        var tracks = filesInFolderProvider.getFiles(folder)
        addTracks(tracks)
    }

    menuBar: ApplicationMenu {
        onClearDatabase: {
            Database.clearDatabase()
            sortBar.refresh()
            trackListModel.refresh()
            importOverlay.refresh()
        }

        onImportFolder: {
            importFolderDialog.open()
        }

        onImportFiles: {
            importFilesDialog.open()
        }

        onAddCategory: {
            Database.getCategories(function(categories) {
                newCategoryDialog.firstCategory = categories.length === 0
                newCategoryDialog.open()
            })
        }

        onAddCrate: {
            Database.getCrates(function(crates) {
                newCrateDialog.open()
            })
        }

        onExit: Qt.quit()
    }

    NewCategoryDialog {
        id: newCategoryDialog

        onAccepted: {
            firstCategory = false
            Database.createCategory(queryResult)
            sortBar.refresh()
            sortBar.selectCategory(queryResult)
            queryResult = ""
        }
    }

    NewCrateDialog {
        id: newCrateDialog

        onAccepted: {
            Database.createCrate(queryResult)
            sortBar.refresh()
            sortBar.selectCrate(queryResult)
            queryResult = ""
            trackListModel.refresh()
        }
    }

    FileDialog {
        id: importFolderDialog
        selectFolder: true

        onAccepted: {
            root.addFolder(folder)
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
            var crate = sortBar.crate
            Database.getTracks(crate.CrateId, sort || "Artist", filter || "", function(results) {
                showTracksFromDbResults(results)
            })
        }

        function showTracksFromDbResults(results) {
            clear()

            for (var i = 0; i < results.length; ++i) {
                append(results.item(i))
            }

            importOverlay.refresh()
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
                sortBar.updateList()
            }
        }

        Item {
            anchors.fill: parent
            visible: tabs.activeTab === 0
            focus: visible

            TopBar {
                id: sortBar

                onNoCategories: {
                    newCategoryDialog.firstCategory = true
                    newCategoryDialog.open()
                }

                onCategoryChanged: updateList()
                onCrateChanged: updateList()
                onRatedChanged: updateList()

                function updateList() {
                    if (crate === undefined) return
                    if (category === undefined) return

                    if (rated) {
                        Database.getRatedTracksFor(category.CategoryId, crate.CrateId, showTracks)
                    } else {
                        Database.getUnratedTracksFor(category.CategoryId, crate.CrateId, null, showTracks)
                    }

                    function showTracks(tracks) {
                        trackListModel.showTracksFromDbResults(tracks)
                    }
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
                    sortBar.refresh()
                    sortBar.updateList()
                    importOverlay.refresh()
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
                    rateTab.startComparison(track, sortBar.category, sortBar.crate)
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
                            rateTab.startComparison(track, sortBar.category, sortBar.crate)
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
                            sortBar.updateList()
                        }
                    }
                }

                ImportOverlay {
                    id: importOverlay

                    onImportFolder: importFolderDialog.open()
                    onImportFiles: importFilesDialog.open()

                    function refresh() {
                        Database.getTrackCount(function(trackCount) {
                            importOverlay.visible = trackCount === 0
                        })
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
                var crate = sortBar.crate

                tracks.forEach(function(track) {
                    Database.removeTrack(track.TrackId, crate.CrateId)
                })

                sortBar.updateList()
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
                sortBar.updateList()
                sortBar.selectRated(true)
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

        TabSelector {
            id: tabSelector

            activeTab: tabs.activeTab
            onTabSelected: tabs.activeTab = tab
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

    Notification {
        id: notification
    }
}
