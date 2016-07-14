import QtQuick 2.4
import QtQuick.Controls 1.3

MenuBar {
    id: root

    signal clearDatabase
    signal addCategory
    signal addCrate
    signal addTag
    signal importFiles
    signal importFolder
    signal importPlaylist
    signal exit

    Menu {
        title: qsTr("&File")
        MenuItem {
            text: qsTr("Import f&iles")
            onTriggered: root.importFiles()
        }
        MenuItem {
            text: qsTr("Import f&older")
            onTriggered: root.importFolder()
        }
        MenuItem {
            text: qsTr("Import &playlist")
            onTriggered: root.importPlaylist()
        }
        MenuItem {
            text: qsTr("Clear database")
            onTriggered: root.clearDatabase()
        }
        MenuItem {
            text: qsTr("Add category")
            onTriggered: root.addCategory()
        }
        MenuItem {
            text: qsTr("Add tag")
            onTriggered: root.addTag()
        }

        MenuItem {
            text: qsTr("Add crate")
            onTriggered: root.addCrate()
        }

        MenuItem {
            text: qsTr("E&xit")
            onTriggered: root.exit()
        }
    }
}

