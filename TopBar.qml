import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import "database.js" as Database

RowLayout {
    id: root

    property variant crate
    property variant category
    property bool rated

    signal noCategories

    function selectRated(rated) {
        ratedCheckBox.currentIndex = rated ? 1 : 0
    }

    function selectCrate(name) {
        crateSelect.select(name)
    }

    function selectCategory(name) {
        categorySelect.select(name)
    }

    function refresh() {
        categorySelect.refresh()
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
    
    Row {
        id: optionsRow
        
        spacing: 10

        Text {
            text: "Crate:"
            anchors.verticalCenter: parent.verticalCenter
        }
        
        ComboBox {
            id: crateSelect
            
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
            text: "Category:"
            anchors.verticalCenter: parent.verticalCenter
        }
        
        ComboBox {
            id: categorySelect

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
                        var name = categories.item(i).Name
                        categorySelect.model.append({
                                modelData: categories.item(i).Name,
                                text: categories.item(i).Name,
                                Name: name,
                                CategoryId: categories.item(i).CategoryId
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
        
        Text {
            text: "Show:"
            anchors.verticalCenter: parent.verticalCenter
        }
        
        ComboBox {
            id: ratedCheckBox
            
            width: 200
            model: ["Unrated", "Rated"]

            onCurrentIndexChanged: root.rated = currentIndex === 1
        }
    }
    
    Component.onCompleted: {
        crateSelect.refresh()
        categorySelect.refresh()
    }
}
