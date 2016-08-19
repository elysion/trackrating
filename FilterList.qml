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
    property alias title: title.text
    property int currentIndex: -1
    property int maxHeight: 100
    property bool collapsed: false

    property bool enablePopup: false

    signal startRating

    height: childrenRect.height

    function select(name) {
        for (var i = 0; i < model.count; ++i) {
            var itemAtIndex = model.get(i)
            if (name === itemAtIndex.Name) {
                root.currentIndex = i
                break
            }
        }
    }

    FilterListTitle {
        id: title

        arrow: root.collapsed ? Qt.UpArrow : Qt.DownArrow

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.collapsed = !root.collapsed
        }
    }
    
    ListView {
        id: list
        
        anchors {
            left: parent.left
            right: parent.right
            top: title.bottom
        }

        visible: !root.collapsed
        height: root.collapsed ? 0 : contentHeight > maxHeight ? maxHeight : contentHeight
                
        delegate: FilterListItem {
            id: filterListItem

            text: modelData
            selected: index === root.currentIndex
            onClicked: {
                if (mouse.button === Qt.LeftButton) {
                    root.currentIndex = index
                } else if (root.enablePopup) {
                    popup.popup()
                }
            }

            Menu {
                id: popup
                MenuItem {
                    text: 'Start rating'
                    onTriggered: {
                        root.currentIndex = index
                        root.startRating()
                    }
                }
            }
        }
        
        model: ListModel {}
    }
}
