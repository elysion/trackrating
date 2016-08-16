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

    OptionsRow {
        id: optionsRow

        anchors {
            fill: parent
        }
    }
}
