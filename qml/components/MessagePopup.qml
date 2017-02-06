import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

Popup {
    id: messagePopup
    modal: true
    contentHeight: aboutColumn.height+16
    x: parent.width/6
    y: parent.width/4
    width: parent.width/1.5

    Column {
        id: aboutColumn
        spacing: 16

        Label {
            id: titleText            
            font.bold: true
            width: messagePopup.availableWidth
            elide: Text.ElideRight
            font.pixelSize: 16
        }

        Label {
            id: msgText
            width: messagePopup.availableWidth            
            wrapMode: Label.Wrap
            font.pixelSize: 14            
        }
    }

    function show(title, message) {
        titleText.text = title;
        msgText.text = message;
        messagePopup.open();
    }
}
