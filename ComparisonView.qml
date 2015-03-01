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
    anchors.fill: parent

    signal tracksRated

    property variant category

    function play(url) {
        player.play(url)
    }

    function contains(object, value) {
        for (var key in object) {
            if (object[key] === value) return true
        }

        return false
    }

    function startComparison(unrated, category) {
        var trackId = unrated.TrackId
        var categoryId = category.CategoryId

        Database.resetRating(trackId, categoryId)
        Database.ensureRatingExists(trackId, categoryId)

        Database.initiateCategoryRating(trackId, categoryId, function() {
            compare(unrated, category)
        })
    }

    function compare(unrated, category) {
        root.category = category

        var categoryId = category.CategoryId
        var unratedTrackId = unrated.TrackId

        Database.getNextComparisonId(unrated.TrackId, null, category.CategoryId, function(nextId) {
            if (nextId === null) {
                // TODO: unrated.TrackId not needed?
                Database.getUnratedTracksFor(categoryId, unrated.TrackId, function(tracks) {
                    var comparison = tracks[Math.floor(tracks.length/2)]
                    setGridTracks(unrated, comparison)
                })
            } else {
                Database.getTrackInfo(nextId, function(next) {
                    setGridTracks(unrated, next)
                })

                function setGridTracks(unrated, rated) {
                    grid.tracks = [unrated, rated]
                }
            }
        })
    }
    
    Text {
        anchors {
            top: parent.top
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }

        font.pointSize: 20
        text: "Rate tracks in terms of \"" + root.category.Name + "\""
    }

    TrackComparison {
        id: grid

        comparisonTerm: root.category.Name
        currentTrackLocation: player.source

        anchors {
            top: parent.top
            bottom: player.top
            left: parent.left
            right: parent.right
        }

        onTrackClicked: player.play(track.Location)
        onTrackRated: {
            var categoryId = root.category.CategoryId
            var comparisonId = comparison.TrackId
            var trackId = track.TrackId

            Database.rateTrack(trackId, isMoreThan, comparisonId, categoryId)

            Database.getNextComparisonId(trackId, comparisonId, categoryId, function(nextComparison) {
                if (!nextComparison) {
                    if (isMoreThan) {
                        Database.rateTrackAbove(trackId, comparisonId, categoryId)
                    } else {
                        Database.rateTrackBelow(trackId, comparisonId, categoryId)
                    }
                    // TODO: remove trackId as it is not really used
                    Database.getUnratedTracksFor(categoryId, trackId, function(unrated) {
                        if (unrated.length === 0) {
                            root.tracksRated()
                        } else {
                            var nextTrackForComparison = unrated.item(Math.floor(unrated.length/2))
                            startComparison(nextTrackForComparison, category)
                        }
                    })
                } else {
                    compare(track, root.category)
                }
            })
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
}
