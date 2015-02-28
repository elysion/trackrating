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

    function toggle() {
        if (player.playbackState === Audio.PlayingState)
            player.pause()
        else player.play()
    }

    function play(url) {
        if (url) player.source = url
        player.play()
    }

    Audio {
        id: player

        onPositionChanged: {
            slider.setPosition(position)
        }
    }

    Image {
        id: bgWaveform
        
        opacity: player.playbackState === Audio.PlayingState ? 0.5 : 0.25
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
                opacity: bgWaveform.opacity
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
                source: "qrc:/images/rwd.svg"
                smooth: true
            }
            PlayerButton {
                width: 30
                height: width
                onClicked: root.toggle()
                source: "qrc:/images/play.svg"
                smooth: true
            }
            PlayerButton {
                width: 30
                height: width
                source: "qrc:/images/fwd.svg"
                smooth: true
            }
        }
    }
}
