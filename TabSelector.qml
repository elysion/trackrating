import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import "database.js" as Database
import "Theme.js" as Theme
import "filters.js" as Filters

Rectangle {
    id: root

    property int activeTab: 0
    property variant crate: ({})
    property variant category: ({})
    property bool rated: true
    property bool showRatedUnratedSelect

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
        crateSelect.refresh()
        categorySelect.refresh()
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: "#e4e4e4"
    }

    RowLayout {
        id: rows
        anchors {
            margins: 10
            verticalCenter: parent.verticalCenter
            left: parent.left
        }

        Row {
            spacing: 10

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

            TopBarComboBox {
                id: categorySelect

                visible: root.activeTab === 1
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
                onCurrentIndexChanged: root.category = model.get(currentIndex)

                model: ListModel {}
                width: 160
            }

            ExclusiveGroup {
                id: checkedInputGroup
            }

            Row {
                id: ratedUnratedSelect

                visible: root.showRatedUnratedSelect && root.activeTab === 0

                spacing: 1
                TopBarRadioButton {
                    id: ratedRadio

                    text: "Rated"
                    checked: true
                    anchors.verticalCenter: parent.verticalCenter
                    exclusiveGroup: checkedInputGroup
                    onCheckedChanged: if (checked) root.rated = true
                }

                TopBarRadioButton {
                    id: unratedRadio

                    text: "Unrated"
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

    Row {
        property int minimumWidth: 800 // TODO: get width from rows
        anchors.centerIn: parent.width > minimumWidth ? parent : undefined
        anchors.left: parent.width > minimumWidth ? undefined : rows.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        spacing: 1

        Repeater {
            model: ["List", "Rate"]

            delegate: Rectangle {
                property bool selected: index === root.activeTab
                width: 70
                height: 25
                radius: 4
                color: selected ? Theme.SelectedColor : mouseArea.containsMouse ? Theme.PressedColor : "transparent"

                SharpText {
                    anchors.centerIn: parent
                    color: selected ? Theme.SelectedTextColor : mouseArea.containsMouse ? Theme.PressedTextColor : Theme.ButtonTextColor
                    text: modelData
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: "PointingHandCursor"
                    onClicked: {
                        root.activeTab = index
                    }
                }
            }
        }
    }
}
