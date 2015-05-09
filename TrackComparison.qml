import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import "database.js" as Database

Item {
    id: grid

    signal trackClicked(variant track)
    signal trackRated(variant track, bool isMoreThan, variant comparison)

    property string comparisonTerm
    property alias tracks: repeater.model

    onTracksChanged: {
        comparedTrack = tracks[1]
    }

    property variant comparedTrack
    property real cellWidth: {
        var proposedWidth = tracks ? width / tracks.length : height
        return proposedWidth < height ? proposedWidth : height
    }

    property string currentTrackLocation
    property bool playing

    Row {
        anchors.centerIn: parent
        spacing: 50

        Repeater {
            id: repeater

            delegate: ComparisonTrackItem {
                id: comparisonTrackItem
                sideBarVisible: index == 0
                cellWidth: grid.cellWidth
                comparisonTerm: grid.comparisonTerm
                playing: grid.currentTrackLocation === modelData.Location && root.playing

                onClicked: grid.trackClicked(track)
                onRated: {
                    grid.trackRated(track, isMoreThan, grid.comparedTrack)
                }
            }
        }
    }
}
