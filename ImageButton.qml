import QtQuick 2.4

Item {
    id: root

    property alias label: text.text
    property alias imageSource: image.source

    signal clicked()

    width: childrenRect.width
    height: childrenRect.height

    SharpText {
        id: text
        color: "#cccccc"
        font.bold: true

        wrapMode: Text.Wrap
        visible: text !== ""
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
    }

    Image {
        id: image

        anchors {
            horizontalCenter: text.horizontalCenter
            top: text.bottom
            topMargin: 5
        }

        height: 30
        width: 30
    }

    opacity: mouseArea.containsMouse ? 0.95 : 0.75

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
        hoverEnabled: true
        cursorShape: "PointingHandCursor"
    }
}
