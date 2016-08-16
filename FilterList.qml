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

    property alias model: list.model
    property alias title: titleText.text
    property int currentIndex: -1
    
    Item {
        id: title
        
        height: 30
        
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        
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
            text: "⌄"
            color: "#636363"
            font.pointSize: 20
            anchors {
                left: titleText.right
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -2
                leftMargin: 4
            }
        }
    }
    
    ListView {
        id: list
        
        anchors {
            left: parent.left
            right: parent.right
            top: title.bottom
            bottom: parent.bottom
        }
        
        height: 200
        
        delegate: Rectangle {
            height: 24
            color: index === root.currentIndex ? '#dddddd' : 'transparent'

            anchors {
                left: parent.left
                right: parent.right
            }

            Text {
                text: modelData
                color: "#272727"

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 16
                }
            }

            MouseArea {
                anchors.fill: parent

                onClicked: root.currentIndex = index
            }
        }
        
        model: ListModel {}
    }
}
