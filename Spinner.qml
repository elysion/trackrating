import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import "database.js" as Database

Image {
    id: spinner
    
    width: 75
    height: 75
    source: "qrc:/images/spinner.png"
    
    RotationAnimation on rotation {
        loops: Animation.Infinite
        from: 0
        to: 360
        duration: 1000
    }
}
