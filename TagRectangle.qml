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
    width: childrenRect.width
    height: childrenRect.height

    property string tag
    property string key
    
    Rectangle {
        id: rectangle
        opacity: 0.5
        radius: 4

        width: text.width + 10
        height: text.height + 10
    }

    Text {
        id: text
        text: root.key + ": " + root.tag

        anchors {
            centerIn: rectangle
        }
    }
}
