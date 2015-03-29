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

    signal clicked(variant track)
    signal rated(variant track, bool isMoreThan)

    property string comparisonTerm
    property bool sideBarVisible: false
    property int cellWidth
    property bool playing: false
    property variant track

    width: childrenRect.width
    height: childrenRect.height

    Item {
        id: content

        width: childrenRect.width
        height: childrenRect.height

        Image {
            id: cover

            width: cellWidth * 0.8
            height: width
            source: "image://cover/" + modelData.Location

            Rectangle {
                id: infoBackground
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    right: parent.right
                }
                color: "black"
                height: 100
                opacity: 0.7
            }

            Text {
                id: trackInfo
                property variant info: trackInfoProvider.getTrackInfo(modelData.Location)

                anchors {
                    fill: infoBackground
                    margins: 10
                }

                color: "white"
                font {
                    bold: true
                    pointSize: 30
                }

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                elide: Text.ElideRight
                maximumLineCount: 2
                text: info.artist + " - " + info.title
                wrapMode: Text.Wrap
            }

            PlayerButton {
                anchors.centerIn: parent

                width: 75
                height: 75
                source: "qrc:/images/play.png"
                visible: !root.playing

                onClicked: root.clicked(modelData)
            }

            Spinner {
                id: spinner
                visible: root.playing
                anchors.centerIn: parent
            }
        }

        Rectangle {
            id: sideBar
            color: "black"

            anchors {
                left: cover.right
                top: cover.top
                bottom: cover.bottom
            }

            visible: root.sideBarVisible
            width: 100

            Item {
                anchors {
                    fill: parent
                    margins: 10
                }

                ImageButton {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: 10
                    }

                    width: parent.width

                    label: "Less " + root.comparisonTerm
                    imageSource: "qrc:/images/down.png"

                    onClicked: root.rated(modelData, false)
                }

                ImageButton {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        topMargin: 10
                    }

                    width: parent.width

                    label: "More " + root.comparisonTerm
                    imageSource: "qrc:/images/up.png"

                    onClicked: root.rated(modelData, true)
                }
            }
        }
    }

    DropShadow {
        anchors.fill: content
        radius: 10
        samples: radius * 2
        source: content
        color: Qt.rgba(0, 0, 0, 0.5)
        transparentBorder: true
    }
}
