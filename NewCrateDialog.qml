import QtQuick 2.0
import QtQuick.Dialogs 1.2

QueryDialog {
    title: "Create a new crate"

    property bool firstCrate: false
    queryLabel: "Crate name: "

    standardButtons: StandardButton.Ok | StandardButton.Cancel
}

