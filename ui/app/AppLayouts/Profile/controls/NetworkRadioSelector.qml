import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import shared.popups 1.0
import shared.controls 1.0

RadioButtonSelector {
    id: root

    property var advancedStore
    property string network: ""
    property string networkName: ""
    property string newNetwork: ""

    title: networkName == "" ? Utils.getNetworkName(network) : networkName
    checked: root.advancedStore.currentNetworkName === root.title

    onCheckedChanged: {
        if (checked) {
            if (root.advancedStore.currentNetworkName === root.network)
                return

            root.newNetwork = root.network;
            Global.openPopup(confirmDialogComponent)
        }
    }

    Component {
        id: confirmDialogComponent
        ConfirmationDialog {
            id: confirmDialog
            header.title: qsTr("Warning!")
            confirmationText: qsTr("The account will be logged out. When you unlock it again, the selected network will be used")
            onConfirmButtonClicked: {
                root.advancedStore.setNetworkName(root.newNetwork)
            }
            onClosed: {
                destroy()
            }
        }
    }
}
