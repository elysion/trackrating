import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import "database.js" as Database
import "filters.js" as Filters

RowLayout {
    id: root

    property variant crate
    property variant category
    property variant tag
    property bool rated
    property alias filter: filterSelect.currentIndex

    signal noCategories
    signal noTags
    signal exportAsPlaylist

    function selectCategoryFilter() {
        filterSelect.currentIndex = Filters.CATEGORY_FILTER_INDEX
    }

    function selectTagFilter() {
        filterSelect.currentIndex = Filters.TAG_FILTER_INDEX
    }

    function selectNoFilter() {
        filterSelect.currentIndex = Filters.NO_FILTER_INDEX
    }

    function selectRated(rated) {
        ratedCheckBox.currentIndex = rated ? 1 : 0
    }

    function selectCrate(name) {
        crateSelect.select(name)
    }

    function selectCategory(name) {
        categorySelect.select(name)
    }

    function selectTag(name) {
        tagSelect.select(name)
    }

    function refresh() {
        categorySelect.refresh()
        tagSelect.refresh()
        selectRated(false)
        crateSelect.refresh()
        crateSelect.currentIndex = 0
    }
    
    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        margins: 10
    }

    height: crateSelect.height + (anchors.margins * 2)
    
    Row {
        id: optionsRow
        
        spacing: 10

        Text {
            text: "Crate:"
            anchors.verticalCenter: parent.verticalCenter
        }
        
        ComboBox {
            id: crateSelect
            anchors.verticalCenter: parent.verticalCenter
            
            function select(crate) {
                for (var i = 0; i < model.count; ++i) {
                    if (model.get(i).Name === crate) {
                        currentIndex = i
                        break
                    }
                }
            }

            function refresh() {
                var currentItem = currentText
                model.clear()
                currentIndex = -1

                Database.getCrates(function(crates) {
                    for (var i = 0; i < crates.length; ++i) {
                        var name = crates.item(i).Name
                        crateSelect.model.append({text: crates.item(i).Name, Name: name, CrateId: crates.item(i).CrateId})
                    }

                    if (currentItem) {
                        select(currentItem)
                    } else {
                        currentIndex = 0
                    }
                })
            }
            
            model: ListModel {}
            width: 200
            
            onCurrentIndexChanged: root.crate = model.get(currentIndex)
        }
        
        Text {
            text: "Filter:"
            anchors.verticalCenter: parent.verticalCenter
        }

        ComboBox {
            id: filterSelect
            model: Filters.FILTER_NAMES
            currentIndex: Filters.CATEGORY_FILTER_INDEX

            function value() {
                return model.get(currentIndex)
            }
        }
        
        ComboBox {
            id: categorySelect
            visible: filterSelect.currentIndex === Filters.CATEGORY_FILTER_INDEX
            anchors.verticalCenter: parent.verticalCenter

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
            width: 200
            
            onCurrentIndexChanged: {
                root.category = model.get(currentIndex)
            }
        }

        ComboBox {
            id: tagSelect
            visible: filterSelect.currentIndex === Filters.TAG_FILTER_INDEX
            anchors.verticalCenter: parent.verticalCenter

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

            model: ListModel {}
            width: 200

            onCurrentIndexChanged: {
                root.tag = model.get(currentIndex)
            }
        }
        
        Text {
            text: "Show:"
            anchors.verticalCenter: parent.verticalCenter
        }
        
        ComboBox {
            id: ratedCheckBox
            anchors.verticalCenter: parent.verticalCenter
            
            visible: root.filter === Filters.CATEGORY_FILTER_INDEX
            width: 200
            model: ["Unrated", "Rated"]

            onCurrentIndexChanged: root.rated = currentIndex === 1
        }

        Rectangle {
            color: "black"
            opacity: 0.5
            height: parent.height
            width: 1
        }

        Button {
            text: "Export as playlist"
            onClicked: root.exportAsPlaylist()
        }
    }
    
    Component.onCompleted: {
        crateSelect.refresh()
        categorySelect.refresh()
    }
}
