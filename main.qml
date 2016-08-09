import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import "database.js" as Database
import trackrating 1.0
import FileDialog 1.0
import "filters.js" as Filters

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

    ThreadedTrackInfoProvider {
        id: threadedTrackInfoProvider

        property string crateId
        property int total
        property int processed

        onResultReady: {
            Database.addTrack(trackInfo.artist, trackInfo.title, trackInfo.filename, trackInfo.url, crateId)
            sortBar.updateList()
            processed++
            statusNotification.update('Processing: ' + (processed + 1) + '/' + total)

            if (processed === total) {
                statusNotification.hide()
            }
        }
    }

    function addTracks(urls) {
        threadedTrackInfoProvider.processed = 0
        threadedTrackInfoProvider.total = urls.length

        statusNotification.show('Importing tracks')

        threadedTrackInfoProvider.crateId = sortBar.crate.CrateId
        threadedTrackInfoProvider.getTrackInfo(toArray(urls))
    }

    function addFolder(folder) {
        var tracks = filesInFolderProvider.getFiles(folder)
        addTracks(tracks)
    }

    function exportPlaylist(file) {
        var tracks = []
        for (var i = 0; i < trackListModel.count; ++i) {
            tracks.push(trackListModel.get(i).Location.replace(/^(file:\/{2})/,""))
        }

        var playlist = tracks.join("\n")
        console.log(file, playlist)
        FileIO.write(file, playlist)
    }

    function startsWith(needle, haystack) {
        return haystack.toString().substr(0, needle.length) === needle
    }

    function isEmpty(str) {
        return str.toString().trim().length === 0
    }

    function not(predicate) {
        return function (/*arguments*/) {
            var args = toArray(arguments)
            return !predicate.apply(this, args)
        }
    }

    function and(/*predicates*/) {
        var predicates = toArray(arguments)

        return function (/*arguments*/) {
            var args = toArray(arguments)
            return predicates.reduce(function (memo, predicate) {
                return memo && predicate.apply(null, args)
            }, true)
        }
    }

    function toArray(arrayLike) {
        return Array.prototype.slice.call(arrayLike)
    }

    function importPlaylist(file) {
        var files = FileIO.read(file).filter(and(not(isEmpty), not(startsWith.bind(null, '#'))))
        if (files.length > 0) {
            root.addTracks(files)
        }
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

        onImportPlaylist: {
            importPlaylistDialog.open()
        }

        onAddCategory: {
            Database.getCategories(function(categories) {
                newCategoryDialog.firstCategory = categories.length === 0
                newCategoryDialog.open()
            })
        }

        onAddCrate: {
            newCrateDialog.open()
        }

        onAddTag: {
            newTagDialog.open()
        }

        onExportPlaylist: exportAction.trigger()

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
            sortBar.selectCrateFilter()
            sortBar.selectCrate(queryResult)
            queryResult = ""
            trackListModel.refresh()
        }
    }

    NewTagDialog {
        id: newTagDialog

        onAccepted: {
            Database.createTag(queryResult)
            sortBar.refresh()
            sortBar.selectTagFilter()
            sortBar.selectTag(queryResult)
            queryResult = ""
            trackListModel.refresh()
        }
    }

    FileDialog {
        id: importFolderDialog
        selectFolder: true
        title: "Import folder"

        onAccepted: {
            root.addFolder(folder)
        }
    }

    FileDialog {
        id: importFilesDialog
        selectMultiple: true
        nameFilters: [ "Audio files (*.mp3)" ]
        title: "Import files"

        onAccepted: {
            root.addTracks(fileUrls)
        }
    }

    FileDialog {
        id: importPlaylistDialog
        nameFilters: [ "Playlist files (*.m3u)" ]
        title: "Import playlist"

        onAccepted: {
            root.importPlaylist(fileUrl)
        }
    }

    FileSaveDialog {
        id: exportPlaylistDialog
        onAccepted: {
            root.exportPlaylist(fileUrl)
        }
    }

    ListModel {
        id: trackListModel

        function showTracksFromDbResults(results) {
            clear()

            for (var i = 0; i < results.length; ++i) {
                append(results[i])
            }

            importOverlay.refresh()
        }
    }

    Item {
        id: wrapper

        anchors.fill: parent


        Keys.onLeftPressed: {
            player.seekBackward()
            event.accepted = true
        }

        Keys.onRightPressed: {
            player.seekForward()
            event.accepted = true
        }

        Keys.onSpacePressed: {
            player.toggle()
            event.accepted = true
        }

        Keys.onPressed: {
            var keys = [Qt.Key_1, Qt.Key_2, Qt.Key_3, Qt.Key_4, Qt.Key_5,
                        Qt.Key_6, Qt.Key_7, Qt.Key_8, Qt.Key_9]
            var index = keys.indexOf(event.key)
            if (index !== -1) {
                player.addTag(index)
                event.accepted = true
            } else if (event.key === Qt.Key_0) {
                player.moreTags()
                event.accepted = true
            } else if (event.key === Qt.Key_Plus) {
                newTagDialog.open()
                // TODO: add tag to track
                event.accepted = true
            }
        }


        TopBar {
            id: sortBar

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            onNoCategories: {
                newCategoryDialog.firstCategory = true
                newCategoryDialog.open()
            }

            onFilterChanged: updateList()
            onCategoryChanged: updateList()
            onTagChanged: updateList()
            onCrateChanged: updateList()
            onRatedChanged: updateList()

            function updateList() {
                if (crate === undefined) return

                var tagId = filter === Filters.TAG_FILTER_INDEX ? tag.TagId : undefined
                var categoryId = filter === Filters.CATEGORY_FILTER_INDEX ? category.CategoryId : undefined

                if (filter === Filters.NO_FILTER_INDEX) {
                    Database.getAllTracksFor(crate.CrateId, showTracks)
                } else {
                    if (!tagId && !categoryId) return

                    if (categoryId) {
                        if (rated) {
                            Database.getRatedTracksFor(categoryId, crate.CrateId, showTracks)
                        } else {
                            Database.getUnratedTracksFor(categoryId, crate.CrateId, null, showTracks)
                        }
                    } else {
                        Database.getTaggedTracksFor(tagId, crate.CrateId, showTracks)
                    }
                }

                function addIndexToTracks(tracks) {
                    tracks.map(function (track, index) {
                        track['Index'] = index + 1
                    })
                }

                function showTracks(tracks) {
                    addIndexToTracks(tracks)
                    trackListModel.showTracksFromDbResults(tracks)
                }
            }
        }

        TabSelector {
            id: tabSelector

            anchors {
                top: sortBar.bottom
                bottomMargin: 10
                left: parent.left
                right: parent.right
            }

            activeTab: tabs.activeTab
            onTabSelected: tabs.activeTab = tab

            height: 40
        }

        Item {
            id: tabs

            anchors {
                top: tabSelector.bottom
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

            Action {
                id: exportAction
                text: "&Export"
                shortcut: "Ctrl+E"
                onTriggered: {
                    var isCategorySelected = sortBar.filter == Filters.CATEGORY_FILTER_INDEX

                    var filenameParts

                    switch (sortBar.filter) {
                        case Filters.CATEGORY_FILTER_INDEX:
                            filenameParts = [sortBar.category.Name,
                                (sortBar.rated ? "Rated" : "Unrated")]
                            break
                        case Filters.TAG_FILTER_INDEX:
                            filenameParts = [sortBar.tag.Name]
                        break
                        default:
                            filenameParts = ["All"]
                        break
                    }

                    exportPlaylistDialog.filename = [sortBar.crate.Name, filenameParts.join("_")].join("_") + ".m3u"

                    exportPlaylistDialog.open()
                }
            }

            TrackList {
                id: trackList
                anchors.fill: parent

                visible: tabs.activeTab === 0
                focus: visible

                showIndex: sortBar.rated

                model: trackListModel

                Component.onCompleted: {
                    sortBar.refresh()
                    sortBar.updateList()
                    importOverlay.refresh()
                }

                onDoubleClicked: {
                    player.play(model.get(row))
                }

                onReturnClicked: {
                    var tracks = trackList.getSelectedTracks()
                    player.play(tracks[0])
                }

                function startRatingCurrentlySelectedTrack() {
                    var tracks = trackList.getSelectedTracks()
                    var track = tracks[0]
                    player.play(track)
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
                            player.play(track)
                            rateTab.startComparison(track, sortBar.category, sortBar.crate)
                            tabs.activeTab = 1
                        }
                    }

                    MenuItem {
                        text: "Play"
                        shortcut: "Enter"

                        onTriggered: {
                            player.play(contextMenuTrigger.selectedTrackProxy)
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

            Keys.onDeletePressed: {
                var tracks = trackList.getSelectedTracks()
                var crate = sortBar.crate

                tracks.forEach(function(track) {
                    Database.removeTrack(track.TrackId, crate.CrateId)
                })

                sortBar.updateList()
                event.accepted = true
            }

            ComparisonView {
                id: rateTab

                anchors.fill: parent
                visible: tabs.activeTab === 1
                focus: visible
                currentTrackLocation: player.track.Location
                playing: player.playing
                property int playbackStartPosition: 100000
                property int unratedPosition: playbackStartPosition
                property int ratedPosition: playbackStartPosition

                onRatedChanged: ratedPosition = playbackStartPosition
                onUnratedChanged: unratedPosition = playbackStartPosition

                function startDelayedPlaybackPositionRestore() {
                    positionRestoreTimer.restart()
                }

                function restorePlaybackPosition() {
                    var unratedPlaying = isUnratedPlaying()

                    if (unratedPlaying) {
                        player.seek(unratedPosition)
                    }
                    else if (!unratedPlaying) {
                        player.seek(ratedPosition)
                    }
                }

                Timer {
                    id: positionRestoreTimer

                    repeat: false
                    interval: 200
                    running: false

                    onTriggered: {
                        rateTab.restorePlaybackPosition()
                    }
                }

                onAllTracksRated: {
                    sortBar.updateList()
                    sortBar.selectRated(true)
                    tabs.activeTab = 0
                }

                onTrackClicked: player.play(track)

                onComparingTracks: {
                    if (player.track.Location !== rated.Location &&
                            player.track.Location !== unrated.Location) {
                        player.play(unrated)
                    }
                }

                onTrackRated: {
                    notification.show(track.Artist + " - " + track.Title + " rated!")
                }

                Keys.onUpPressed: {
                    rateTrack(unrated, true, rated)
                    event.accepted = true
                }

                Keys.onDownPressed: {
                    rateTrack(unrated, false, rated)
                    event.accepted = true
                }

                Keys.onTabPressed: {
                    var unratedPlaying = isUnratedPlaying()

                    if (unratedPlaying) unratedPosition = player.position
                    else ratedPosition = player.position

                    player.play(unratedPlaying ? rated : unrated)

                    event.accepted = true
                }

                function isUnratedPlaying() {
                    return unrated && player.track.Location === unrated.Location
                }
            }
        }

        TrackPlayer {
            id: player

            focus: true

            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            height: 200

            function addTag(index) {
                var tag = player.getTag(index)
                if (tag) {
                    Database.addTag(player.track, tag)
                    player.updateTags()
                    sortBar.updateList()
                }
            }

            onPlaybackStarted: {
                rateTab.startDelayedPlaybackPositionRestore()
            }
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

        StatusNotification {
            id: statusNotification
        }
    }
}
