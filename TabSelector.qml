import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import "database.js" as Database

Row {
    id: root
    
    property int activeTab
    signal tabSelected(int tab)

    anchors {
        bottom: parent.bottom
        bottomMargin: 10
        horizontalCenter: parent.horizontalCenter
    }
    
    spacing: 10
    
    Repeater {
        model: ["List", "Rate"]
        
        delegate: Rectangle {
            width: 100
            height: 20
            radius: 20
            color: "#8cf"
            opacity: index === root.activeTab || mouseArea.containsMouse ? 0.95 : 0.75
            
            Text {
                anchors.centerIn: parent
                color: "white"
                font.bold: true
                text: modelData
            }
            
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                cursorShape: "PointingHandCursor"
                hoverEnabled: true
                onClicked: root.tabSelected(index)
            }
        }
    }
}
