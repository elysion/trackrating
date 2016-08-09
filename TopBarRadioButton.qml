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

RadioButton {
    id: topBarRadioButton
    
    style: RadioButtonStyle {
        background: Rectangle {
            implicitHeight: 22
            color: control.checked ? "#838284" : control.pressed ? '#6e6d6e' : 'transparent'
            radius: 4
        }
        indicator: Item{}
        label: Text {
            color: control.checked || control.pressed ? "white" : 'black'
            width: 60
            text: control.text
            antialiasing: false
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
