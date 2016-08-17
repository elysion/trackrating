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

Rectangle {
    id: root

    property alias text: text.text
    property bool selected: false
    signal clicked()
    
    height: 24
    color: root.selected ? '#cccccc' : 'transparent'
    
    anchors {
        left: parent.left
        right: parent.right
    }
    
    SharpText {
        id: text
        color: "#272727"
        
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 16
        }
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
