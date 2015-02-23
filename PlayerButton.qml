import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import "database.js" as Database

Image {
    id: root
    signal clicked

    opacity: mouseArea.containsMouse ? 0.95 : 0.75
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
        hoverEnabled: true
        cursorShape: "PointingHandCursor"
    }
    
}
