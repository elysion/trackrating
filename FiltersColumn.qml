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


        function select(name) {
            for (var i = 0; i < model.count; ++i) {
                if (name === model.get(i).Name) {
                    currentIndex = i
                    break
                }
            }
        }

        function refresh() {
            var currentItem = categorySelect.currentText
            categorySelect.model.clear()
            categorySelect.currentIndex = -1

            Database.getCategories(function(categories) {
                for (var i = 0; i < categories.length; ++i) {
                    var item = categories.item(i)
                    var name = item.Name
                    var id = item.CategoryId

                    categorySelect.model.append({
                                                    modelData: name,
                                                    text: name,
                                                    Name: name,
                                                    CategoryId: id
                                                })
                }

                if (categories.length === 0) {
                    return root.noCategories()
                }

                if (currentItem) {
                    select(currentItem)
                } else {
                    currentIndex = 0
                }
            })
        }

        model: ListModel {}
    }
    
    FilterList {
        id: tagsList

        title: "Tags"

        anchors {
            left: parent.left
            right: parent.right
            top: categoriesList.bottom
        }

        function select(name) {
            for (var i = 0; i < model.count; ++i) {
                if (name === model.get(i).Name) {
                    currentIndex = i
                    break
                }
            }
        }

        function refresh() {
            var select = tagSelect
            var currentItem = select.currentText
            select.model.clear()
            select.currentIndex = -1

            Database.getTags(function(tags) {
                for (var i = 0; i < tags.length; ++i) {
                    var item = tags[i]
                    var id = item.TagId
                    var name = item.Name
                    select.model.append({
                                            modelData: name,
                                            text: name,
                                            Name: name,
                                            TagId: id
                                        })
                }

                if (tags.length === 0) {
                    return root.noTags()
                }

                if (currentItem) {
                    select(currentItem)
                } else {
                    currentIndex = 0
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
