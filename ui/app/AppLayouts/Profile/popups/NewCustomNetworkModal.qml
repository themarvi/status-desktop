import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import shared.status 1.0
import shared.controls 1.0

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

StatusModal {
    id: addNetworkPopup
    header.title: qsTr("Add network")
    height: 644

    property var advancedStore

    property string nameValidationError: ""
    property string rpcValidationError: ""
    property string networkValidationError: ""
    property int networkId: 1;
    property string networkType: Constants.networkMainnet

    function validate() {
        nameValidationError = ""
        rpcValidationError = ""
        networkValidationError = "";

        if (nameInput.text === "") {
            nameValidationError = qsTr("You need to enter a name")
        }

        if (rpcInput.text === "") {
            rpcValidationError = qsTr("You need to enter the RPC endpoint URL")
        } else if(!Utils.isURL(rpcInput.text)) {
            rpcValidationError = qsTr("Invalid URL")
        }

        if (customRadioBtn.checked) {
            if (networkInput.text === "") {
                networkValidationError = qsTr("You need to enter the network id")
            } else if (isNaN(networkInput.text)){
                networkValidationError = qsTr("Should be a number");
            } else if (parseInt(networkInput.text, 10) <= 4){
                networkValidationError = qsTr("Invalid network id");
            }
        }
        return !nameValidationError && !rpcValidationError && !networkValidationError
    }

    onOpened: {
        nameInput.text = "";
        rpcInput.text = "";
        networkInput.text = "";
        mainnetRadioBtn.checked = true;
        addNetworkPopup.networkId = 1;
        addNetworkPopup.networkType = Constants.networkMainnet;

        nameValidationError = "";
        rpcValidationError = "";
        networkValidationError = "";
    }

    rightButtons: [
        StatusButton {
            text: qsTr("Save")
            enabled: nameInput.text !== "" && rpcInput.text !== ""
            onClicked: {
                if (!addNetworkPopup.validate()) {
                    return;
                }

                if (customRadioBtn.checked){
                    addNetworkPopup.networkId = parseInt(networkInput.text, 10);
                }

                addNetworkPopup.advancedStore.addCustomNetwork(nameInput.text,
                                                               rpcInput.text,
                                                               addNetworkPopup.networkId,
                                                               addNetworkPopup.networkType)
                addNetworkPopup.close()
            }
        }
    ]

    contentItem: Item {
        anchors.fill: parent
        anchors {
            topMargin: (Style.current.padding + addNetworkPopup.topPadding)
            leftMargin: Style.current.padding
            rightMargin: Style.current.padding
            bottomMargin: (Style.current.padding + addNetworkPopup.bottomPadding)
        }
        Input {
            id: nameInput
            label: qsTr("Name")
            placeholderText: qsTr("Specify a name")
            validationError: addNetworkPopup.nameValidationError
        }

        Input {
            id: rpcInput
            label: qsTr("RPC URL")
            placeholderText: qsTr("Specify a RPC URL")
            validationError: addNetworkPopup.rpcValidationError
            anchors.top: nameInput.bottom
            anchors.topMargin: Style.current.padding
        }

        StatusSectionHeadline {
            id: networkChainHeadline
            text: qsTr("Network chain")
            anchors.top: rpcInput.bottom
            anchors.topMargin: Style.current.padding
        }

        Column {
            id: radioButtonsColumn
            anchors.top: networkChainHeadline.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            anchors.leftMargin: Style.current.padding
            spacing: 0

            ButtonGroup {
                id: networkChainGroup
            }

            RadioButtonSelector {
                id: mainnetRadioBtn
                objectName: "main"
                title: qsTr("Main network")
                buttonGroup: networkChainGroup
                checked: true
                onCheckedChanged: {
                    if (checked) {
                        addNetworkPopup.networkId = 1;
                        addNetworkPopup.networkType = Constants.networkMainnet;
                    }
                }
            }

            RadioButtonSelector {
                title: qsTr("Ropsten test network")
                buttonGroup: networkChainGroup
                onCheckedChanged: {
                    if (checked) {
                        addNetworkPopup.networkId = 3;
                        addNetworkPopup.networkType = Constants.networkRopsten;
                    }
                }
            }

            RadioButtonSelector {
                title: qsTr("Rinkeby test network")
                buttonGroup: networkChainGroup
                onCheckedChanged: {
                    if (checked) {
                        addNetworkPopup.networkId = 4;
                        addNetworkPopup.networkType = Constants.networkRinkeby;
                    }
                }
            }

            RadioButtonSelector {
                id: customRadioBtn
                objectName: "custom"
                title: qsTr("Custom")
                buttonGroup: networkChainGroup
                onCheckedChanged: {
                    if (checked) {
                        addNetworkPopup.networkType = "";
                    }
                    networkInput.visible = checked;
                }
            }
        }

        Input {
            id: networkInput
            anchors.top: radioButtonsColumn.bottom
            anchors.topMargin: Style.current.halfPadding
            visible: false
            label: qsTr("Network Id")
            placeholderText: qsTr("Specify the network id")
            validationError: addNetworkPopup.networkValidationError
        }
    }
}
