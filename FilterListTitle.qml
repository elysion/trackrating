import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import "database.js" as Database
import trackrating 1.0
import FileDialog 1.0
import "filters.js" as Filters

Item {
    id: root

    property alias text: titleText.text
    property int arrow: Qt.DownArrow
    
    height: 30
    
    SharpText {
        id: titleText
        
        anchors {
            verticalCenter: parent.verticalCenter
            leftMargin: 12
            left: parent.left
        }
        
        color: "#636363"
        font.pointSize: 11
    }
    
    SharpText {
        text: root.arrow === Qt.DownArrow ? "▼" : "▲"
        color: "#636363"
        font.pointSize: 6
        anchors {
            left: titleText.right
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: 1
            leftMargin: 4
        }
    }
}
