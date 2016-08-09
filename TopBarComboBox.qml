import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import QtQuick.Controls.Styles 1.4
import "database.js" as Database
import "filters.js" as Filters

ComboBox {
    id: root

    property string iconSource
    
    anchors.verticalCenter: parent.verticalCenter
    
    style: ComboBoxStyle {
        background: Rectangle {
            implicitHeight: 16
            color: "#838284"
            radius: 4
            
            Text {
                text: "⌄"
                color: "white"
                font.pointSize: 26
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -4
                    margins: 4
                }
            }

            Image {
                visible: root.iconSource !== undefined
                source: root.iconSource
                opacity: 0.7
                height: 16
                antialiasing: false
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 4
                }
                fillMode: Image.PreserveAspectFit
            }
        }
        textColor: "white"
        label: Text {
            color: "white"
            anchors {
                fill: parent
                leftMargin: 4
                rightMargin: 12
            }
            elide: Text.ElideRight
            antialiasing: false
            text: "    " + control.currentText
//            horizontalAlignment: Text.AlignHCenter
        }
    }
    
}
