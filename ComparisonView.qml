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

    signal allTracksRated
    signal trackRated(variant track)
    signal trackClicked(variant track)
    signal comparingTracks(variant unrated, variant rated)

    onComparingTracks: {
        root.unrated = unrated
        root.rated = rated
    }

    property variant unrated
    property variant rated
    property bool playing

    property variant category
    property variant crate
    property string currentTrackLocation

    function contains(object, value) {
        for (var key in object) {
            if (object[key] === value) return true
        }

        return false
    }

    function startComparison(unrated, category, crate) {
        var trackId = unrated.TrackId
        var categoryId = category.CategoryId
        var crateId = crate.CrateId

        Database.resetRating(trackId, categoryId, crateId)
        Database.ensureRatingExists(trackId, categoryId, crateId)

        Database.initiateCategoryRating(trackId, categoryId, crateId, function() {
            compare(unrated, category, crate)
        })
    }

    function compare(unrated, category, crate) {
        root.category = category
        root.crate = crate

        var categoryId = category.CategoryId
        var crateId = crate.CrateId
        var unratedTrackId = unrated.TrackId

        Database.getNextComparisonId(unrated.TrackId, null, categoryId, crateId, function(nextId) {
            if (nextId === null) {
                // TODO: unrated.TrackId not needed?
                Database.getUnratedTracksFor(categoryId, crateId, unrated.TrackId, function(tracks) {
                    var comparison = tracks[Math.floor(tracks.length/2)]
                    setGridTracks(unrated, comparison)
                })
            } else {
                Database.getTrackInfo(nextId, function(next) {
                    setGridTracks(unrated, next)
                })

                function setGridTracks(unrated, rated) {
                    root.comparingTracks(unrated, rated)
                    grid.tracks = [unrated, rated]
                }
            }
        })
    }

    function rateTrack(track, isMoreThan, comparison) {
        var categoryId = root.category.CategoryId
        var crateId = root.crate.CrateId
        var comparisonId = comparison.TrackId
        var trackId = track.TrackId

        Database.rateTrack(trackId, isMoreThan, comparisonId, categoryId, crateId)

        Database.getNextComparisonId(trackId, comparisonId, categoryId, crateId, function(nextComparison) {
            if (!nextComparison) {
                if (isMoreThan) {
                    Database.rateTrackAbove(trackId, comparisonId, categoryId, crateId)
                } else {
                    Database.rateTrackBelow(trackId, comparisonId, categoryId, crateId)
                }
                // TODO: remove trackId as it is not really used
                Database.getUnratedTracksFor(categoryId, crateId, trackId, function(unrated) {
                    if (unrated.length === 0) {
                        root.allTracksRated()
                        notification.show("All tracks rated in terms of \"" + category.Name + "\" in " + crate.Name)
                    } else {
                        root.trackRated(track)
                        var nextTrackForComparison = unrated.item(Math.floor(unrated.length/2))
                        startComparison(nextTrackForComparison, category, crate)
                    }
                })
            } else {
                compare(track, root.category, root.crate)
            }
        })
    }
    
    Text {
        id: header

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
        currentTrackLocation: root.currentTrackLocation
        playing: root.playing

        anchors {
            top: header.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        onTrackClicked: root.trackClicked(track)
        onTrackRated: rateTrack(track, isMoreThan, comparison)
    }   
}
