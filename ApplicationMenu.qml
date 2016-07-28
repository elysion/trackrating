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
        MenuSeparator { }
        MenuItem {
            text: qsTr("Clear database")
            onTriggered: root.clearDatabase()
        }
        MenuSeparator { }
        MenuItem {
            text: qsTr("E&xit")
            onTriggered: root.exit()
        }
    }

    Menu {
        title: qsTr("&Add")

        MenuItem {
            text: qsTr("Category")
            onTriggered: root.addCategory()
        }
        MenuItem {
            text: qsTr("Tag")
            onTriggered: root.addTag()
        }

        MenuItem {
            text: qsTr("Crate")
            onTriggered: root.addCrate()
        }
    }
}

