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
    
    Component.onCompleted: refresh()

    property variant tag
    property variant category

    signal startRating()

    function refresh() {
        categoriesList.refresh()
        tagsList.refresh()
    }

    anchors {
        top: parent.top
        left: parent.left
        bottom: parent.bottom
    }
    
    color: "#e6e6e6"
    width: 200

    FilterListItem {
        id: allTracks

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        text: "All tracks"

        selected: !root.category && !root.tag

        MouseArea {
            anchors.fill: parent

            onClicked: {
                tagsList.currentIndex = -1
                categoriesList.currentIndex = -1
            }
        }
    }

    FilterList {
        id: categoriesList

        title: "Categories"
        maxHeight: parent.height / 2 - allTracks.height
        enablePopup: true

        onStartRating: root.startRating()

        anchors {
            left: parent.left
            right: parent.right
            top: allTracks.bottom
        }

        onCurrentIndexChanged: {
            if (currentIndex != -1) {
                tagsList.currentIndex = -1
            }

            root.category = model.get(currentIndex)
        }

        function refresh() {
            var list = categoriesList
            var currentItem = root.category && root.category.Name
            list.model.clear()

            Database.getCategories(function(categories) {
                for (var i = 0; i < categories.length; ++i) {
                    var item = categories.item(i)
                    var name = item.Name
                    var id = item.CategoryId

                    list.model.append({
                                                    modelData: name,
                                                    text: name,
                                                    Name: name,
                                                    CategoryId: id
                                                })
                }

                if (currentItem) {
                    select(currentItem)
                }
            })
        }

        model: ListModel {}
    }
    
    FilterList {
        id: tagsList

        title: "Tags"
        maxHeight: parent.height / 2 - allTracks.height

        anchors {
            left: parent.left
            right: parent.right
            top: categoriesList.bottom
        }

        function refresh() {
            var list = tagsList
            var currentItem = root.tag && root.tag.Name
            list.model.clear()

            Database.getTags(function(tags) {
                for (var i = 0; i < tags.length; ++i) {
                    var item = tags[i]
                    var id = item.TagId
                    var name = item.Name
                    list.model.append({
                                          modelData: name,
                                          text: name,
                                          Name: name,
                                          TagId: id
                                      })
                }

                if (currentItem) {
                    select(currentItem)
                }
            })
        }

        onCurrentIndexChanged: {
            if (currentIndex != -1) {
                categoriesList.currentIndex = -1
            }

            root.tag = model.get(currentIndex)
        }

        model: ListModel {}
    }
}
