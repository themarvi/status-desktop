import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.controls 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1 as StatusQControls

StatusModal {
    id: root
    width: 400
    height: 400

    property var store

    function validate(communityKey) {
        return communityKey.trim() !== ""
    }

    header.title: qsTr("Access existing community")

    onClosed: {
        root.destroy();
    }

    contentItem: Item {
        width: root.width - 32
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        height: childrenRect.height

        StyledTextArea {
            id: keyInput
            label: qsTr("Community private key")
            placeholderText: "0x0..."
            customHeight: 110
            anchors.left: parent.left
            anchors.right: parent.right

            onTextChanged: {
                importButton.enabled = root.validate(keyInput.text)
            }
        }

        StatusBaseText {
            id: infoText1
            text: qsTr("Entering a community key will grant you the ownership of that community. Please be responsible with it and don’t share the key with people you don’t trust.")
            anchors.top: keyInput.bottom
            wrapMode: Text.WordWrap
            anchors.topMargin: Style.current.bigPadding
            width: parent.width
            font.pixelSize: 13
            color: Theme.palette.baseColor1
        }
    }

    rightButtons: [
        StatusQControls.StatusButton {
            id: importButton
            enabled: false
            text: qsTr("Import")
            onClicked: {
                let communityKey = keyInput.text.trim();
                if (!communityKey.startsWith("0x")) {
                    communityKey = "0x" + communityKey;
                }

                root.store.importCommunity(communityKey);
                root.close();
            }
        }
    ]
}
