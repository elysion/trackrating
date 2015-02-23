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

    property string comparisonTerm
    property alias tracks: repeater.model
    property real cellWidth: {
        var proposedWidth = width / tracks.length
        return proposedWidth < height ? proposedWidth : height
    }

    Row {
        anchors.centerIn: parent

        Repeater {
            id: repeater

            delegate: Item {
                width: grid.cellWidth
                height: width

                Image {
                    id: cover

                    width: parent.width * 0.8
                    height: width
                    source: "image://cover/" + modelData.Location

                    anchors.centerIn: parent

                    Text {
                        property variant info: trackInfoProvider.getTrackInfo(modelData.Location)

                        anchors {
                            top: parent.bottom
                            topMargin: 10
                            horizontalCenter: parent.horizontalCenter
                        }

                        text: info.artist + " - " + info.title
                    }

                    LessButton {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                            bottomMargin: 10
                        }

                        term: grid.comparisonTerm
                    }

                    MoreButton {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.top
                            topMargin: 10
                        }

                        term: grid.comparisonTerm
                    }

                    PlayerButton {
                        anchors.centerIn: parent

                        width: 75
                        height: 75

                        source: "qrc:/images/play.svg"

                        onClicked: grid.trackClicked(modelData)
                    }
                }

                DropShadow {
                    anchors.fill: cover
                    radius: 10
                    samples: radius * 2
                    source: cover
                    color: Qt.rgba(0, 0, 0, 0.5)
                    transparentBorder: true
                }
            }
        }
    }
}
