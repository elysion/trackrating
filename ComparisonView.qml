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

    property variant category

    function play(url) {
        player.play(url)
    }

    function contains(object, value) {
        for (var key in object) {
            if (object[key] === object) return true
        }

        return false
    }

    function compare(unrated, category) {
        root.category = category
        console.log(category.Name, category.Id)

        Database.getRatedTracksFor(category.Id, function(rated) {
            if (contains(rated, unrated)) {
                console.log("Already rated!")
                return
            }

            if (rated.length !== 0) {
                setGridTracks(unrated, rated[Math.floor(rated.length / 2)])
            } else {
                Database.getUnratedTracksFor(category.Id, function(tracks) {
                    // TODO: get next/previous track if tracks[Math.floor(tracks.length/2)] is @unrated
                    setGridTracks(unrated, tracks[Math.floor(tracks.length/2)])
                })
            }

            function setGridTracks(unrated, rated) {
                grid.tracks = [unrated, rated]
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

        anchors {
            top: parent.top
            bottom: player.top
            left: parent.left
            right: parent.right
        }

        onTrackClicked: player.play(track.Location)
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
