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
    id: root

    signal importFiles()
    signal importFolder()
    
    anchors.fill: parent
    visible: false
    
    Rectangle {
        color: "black"
        opacity: 0.75
        
        anchors.fill: parent
    }
    
    MouseArea {
        anchors.fill: parent
    }
    
    Column {
        anchors.centerIn: parent
        height: childrenRect.height
        spacing: 10
        
        SharpText {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            text: "Crate empty."
        }
        
        Row {
            spacing: 10
            
            Button {
                text: "Add folder"
                
                onClicked: root.importFolder()
            }
            
            SharpText {
                anchors.verticalCenter: parent.verticalCenter
                text: "Or"
                color: "white"
            }
            
            Button {
                text: "Add files"
                
                onClicked: root.importFiles()
            }
        }
    }
}
