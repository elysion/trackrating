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

    property variant tag: ({})
    property variant category: ({})

    function refresh() {
        var list = tagsList
        //                    var currentItem = ...
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

            //                        if (currentItem) {
            //                            select(currentItem)
            //                        } else {
            //                            currentIndex = 0
            //                        }
        })

        list = categoriesList
        list.model.clear()

        Database.getCategories(function(categories) {
            for (var i = 0; i < categories.length; ++i) {
                var item = categories[i]
                var id = item.CategoryId
                var name = item.Name
                list.model.append({
                                      modelData: name,
                                      text: name,
                                      Name: name,
                                      CategoryId: id
                                  })
            }

            //                        if (currentItem) {
            //                            select(currentItem)
            //                        } else {
            //                            currentIndex = 0
            //                        })
        })
    }

    anchors {
        top: parent.top
        left: parent.left
        bottom: parent.bottom
    }
    
    color: "#f6f6f6"
    width: 200
    
    FilterList {
        id: categoriesList

        title: "Categories"

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.verticalCenter
        }

        onCurrentIndexChanged: {
            if (currentIndex != -1) {
                tagsList.currentIndex = -1
            }

            root.category = model.get(currentIndex)
        }
    }
    
    FilterList {
        id: tagsList

        title: "Tags"

        anchors {
            left: parent.left
            right: parent.right
            top: parent.verticalCenter
            bottom: parent.bottom
        }

        onCurrentIndexChanged: {
            if (currentIndex != -1) {
                categoriesList.currentIndex = -1
            }

            root.tag = model.get(currentIndex)
        }
    }
}
