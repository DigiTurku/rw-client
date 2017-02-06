import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3

Item {
    id: igs

    signal fileSelected(string src);

    function startSelector() {
        filesDialog.open();
    }

    FileDialog {
        id: filesDialog
        folder: shortcuts.pictures
        nameFilters: [ "*.jpg" ]
        title: qsTr("Select image file")
        selectExisting: true
        selectFolder: false
        selectMultiple: false
        onAccepted: {
            // XXX: Need to convert to string, otherwise sucka
            var f=""+fileUrl
            fileSelected(f);
        }
    }
}
