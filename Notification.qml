import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import "database.js" as Database

Item {
    id: notification
    
    function show(text) {
        notificationText.text = text
        state = "visible"
        timer.restart()
    }
    
    function hide() {
        state = "hidden"
    }
    
    anchors.centerIn: parent
    
    Timer {
        id: timer
        interval: 2000
        running: false
        repeat: false
        onTriggered: notification.hide()
    }
    
    Rectangle {
        id: rectangle
        
        anchors.centerIn: parent
        color: "#444"
        width: 400
        height: 200
        opacity: 0.8
        radius: 20
        visible: true
    }
    
    Text {
        id: notificationText
        
        anchors {
            fill: rectangle
            margins: 10
        }
        
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        
        color: "white"
        elide: Text.ElideMiddle
        font.pointSize: 20
        maximumLineCount: 3
        wrapMode: Text.Wrap
    }
    
    state: "hidden"
    states: [
        State {
            name: "visible"
            PropertyChanges {
                target: notification
                opacity: 1
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: notification
                opacity: 0
            }
        }
    ]
    
    transitions: Transition {
        PropertyAnimation {
            properties: "opacity"
        }
    }
}
