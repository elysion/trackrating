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

    property variant track
    property variant previousTrack: track
    property bool playing: player.playbackState === Audio.PlayingState
    property alias position: player.position
    property alias muted: player.muted

    signal playbackStarted

    function getTag(index) {
        return tags.model.length > index ? tags.model[index] : undefined
    }

    function updateTags() {
        tags.update()
        trackTagsView.update()
    }

    function toggle() {
        if (root.playing)
            player.pause()
        else player.play()
    }

    function play(track) {
        // TODO: clone
        root.track = {
            TrackId: track.TrackId,
            Location: track.Location,
            Artist: track.Artist,
            Title: track.Artist,
            Tags: track.Tags,
            Filename: track.Filename,
            CrateId: track.CrateId
        }
        updateTags()
        player.source = root.track.Location
        player.play()
    }

    function seekForward() {
        seek(20000)
    }

    function seekBackward() {
        seek(-20000)
    }

    function seek(deltaMs) {
        player.seek(player.position + deltaMs)
    }

    LinearGradient {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#000" }
            GradientStop { position: 1.0; color: "#333" }
        }
    }

    Audio {
        id: player

        onPositionChanged: {
            slider.setPosition(position)
        }

        onPlaybackStateChanged: {
            if (playbackState === Audio.PlayingState) {
                root.playbackStarted()
            }
        }
    }

    Image {
        id: bgWaveform
        
        opacity: root.playing ? 0.25 : 0.1
        source: "image://waveform/"+root.track.Location
        smooth: false
        
        anchors {
            left: parent.left
            right: cover.left
            top: parent.top
            bottom: parent.bottom
        }
        
        Item {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            
            width: parent.width * slider.value
            clip: true
            
            Image {
                id: waveform
                
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                
                width: bgWaveform.width
                opacity: 1
                source: "image://waveform/"+root.track.Location
                smooth: false
                clip: true
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                player.seek(mouse.x / width * player.duration)
            }
        }
    }
    
    Slider {
        id: slider
        
        anchors {
            left: parent.left
            right: cover.left
            verticalCenter: parent.verticalCenter
            leftMargin: 10
            rightMargin: 10
        }
        
        visible: false
        
        function setPosition(position) {
            if (!pressed) {
                value = position / player.duration
            }
        }
        
        onValueChanged: {
            if (pressed) {
                player.seek(value * player.duration)
            }
        }
    }

    TrackTagsView {
        id: trackTagsView

        track: root.track

        anchors {
            left: parent.left
            right: cover.left
            top: parent.top
        }

        onTagRemoved: root.updateTags()
    }

    AddTagsView {
        id: tags

        track: root.track

        anchors {
            left: parent.left
            right: cover.left
            bottom: parent.bottom
        }

        height: 50
    }
    
    Image {
        id: cover
        
        height: parent.height
        width: height
        
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        
        source: "image://cover/"+root.track.Location
        smooth: true
        
        Row {
            id: buttons

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 10
            }
            
            spacing: 10
            
            PlayerButton {
                width: 30
                height: width
                onClicked: player.seek(0)
                source: "qrc:/images/rwd.png"
                smooth: true
            }
            PlayerButton {
                width: 30
                height: width
                onClicked: root.toggle()
                source: root.playing ? "qrc:/images/pause.png" : "qrc:/images/play.png"
                smooth: true
            }
            PlayerButton {
                width: 30
                height: width
                source: "qrc:/images/fwd.png"
                smooth: true
            }
        }
    }
}
