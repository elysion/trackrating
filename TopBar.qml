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

Rectangle {
    id: root

    property variant crate
    property variant category
    property variant tag
    property bool rated: true
    property alias filter: filterSelect.currentIndex

    signal noCategories
    signal noTags

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
        if (rated) ratedRadio.checked = true
        else unratedRadio.checked = true
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

    height: row.childrenRect.height + (row.anchors.margins * 2) + 1

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#e6e6e6" }
        GradientStop { position: 1.0; color: "#d0d0d0" }
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: 1
        color: "#f6f6f6"
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: 1
        color: "#aeaeae"
    }

    RowLayout {
        id: row
        anchors {
            fill: parent
            margins: 10
        }

        Row {
            id: optionsRow

            spacing: 10

//            SharpText {
//                text: "Crate:"
//                font.pointSize: 13
//                anchors.verticalCenter: parent.verticalCenter
//            }

            TopBarComboBox {
                id: crateSelect

                iconSource: "qrc:/images/crate_16x16_white.png"

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
                width: 160

                onCurrentIndexChanged: root.crate = model.get(currentIndex)
            }

//            SharpText {
//                text: "Filter:"
//                font.pointSize: 13
//                anchors.verticalCenter: parent.verticalCenter
//            }

            TopBarComboBox {
                id: filterSelect
                model: Filters.FILTER_NAMES
                currentIndex: Filters.CATEGORY_FILTER_INDEX
                iconSource: "qrc:/images/filter_16x16_white.png"

                anchors.verticalCenter: parent.verticalCenter
                width: 180


                function value() {
                    return model.get(currentIndex)
                }
            }

            TopBarComboBox {
                id: categorySelect

                visible: filterSelect.currentIndex === Filters.CATEGORY_FILTER_INDEX
                anchors.verticalCenter: parent.verticalCenter
                iconSource: "qrc:/images/tag_16x16_white.png"

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
                width: 160

                onCurrentIndexChanged: {
                    root.category = model.get(currentIndex)
                }
            }

            TopBarComboBox {
                id: tagSelect
                visible: filterSelect.currentIndex === Filters.TAG_FILTER_INDEX
                anchors.verticalCenter: parent.verticalCenter
                iconSource: "qrc:/images/tag_16x16_white.png"

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
                width: 160

                onCurrentIndexChanged: {
                    root.tag = model.get(currentIndex)
                }
            }

//            SharpText {
//                text: "Show:"
//                font.pointSize: 13
//                anchors.verticalCenter: parent.verticalCenter
//                visible: root.filter === Filters.CATEGORY_FILTER_INDEX
//            }

            ExclusiveGroup {
                id: checkedInputGroup
            }

            Row {
                spacing: 1
                TopBarRadioButton {
                    id: ratedRadio

                    text: "Rated"
                    checked: true
                    visible: root.filter === Filters.CATEGORY_FILTER_INDEX
                    anchors.verticalCenter: parent.verticalCenter
                    exclusiveGroup: checkedInputGroup
                    onCheckedChanged: if (checked) root.rated = true
                }

                TopBarRadioButton {
                    id: unratedRadio

                    text: "Unrated"
                    visible: root.filter === Filters.CATEGORY_FILTER_INDEX
                    anchors.verticalCenter: parent.verticalCenter
                    exclusiveGroup: checkedInputGroup
                    onCheckedChanged: if (checked) root.rated = false
                }
            }
        }

        Component.onCompleted: {
            crateSelect.refresh()
            categorySelect.refresh()
        }
    }
}
