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

    property alias source: player.source
    property bool playing: player.playbackState === Audio.PlayingState

    function toggle() {
        if (root.playing)
            player.pause()
        else player.play()
    }

    function play(url) {
        if (url) player.source = url
        player.play()
    }

    function seekForward() {
        seek(40000)
    }

    function seekBackward() {
        seek(-40000)
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
    }

    Image {
        id: bgWaveform
        
        opacity: root.playing ? 0.25 : 0.1
        source: "image://waveform/"+player.source
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
                source: "image://waveform/"+player.source
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
    
    Image {
        id: cover
        
        height: parent.height
        width: height
        
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        
        source: "image://cover/"+player.source
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
