import QtQuick 2.4
import QtQuick.Dialogs 1.2

import "database.js" as Database

QueryDialog {
    id: root
    
    property bool firstCategory: false

    title: "Create a new category"
    infoText: firstCategory ? "No categories exist. Please create one in order to start rating." : ""
    queryLabel: "Category name: "

    standardButtons: firstCategory ? StandardButton.Ok : StandardButton.Ok | StandardButton.Cancel
}
