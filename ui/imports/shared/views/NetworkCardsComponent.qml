import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

Item {
    id: networkCardsComponent

    property bool customMode: false
    property var selectedNetwork: ""
    property var selectedAccount
    property var layer1Networks
    property var layer2Networks
    property int amountToSend: 0

    QtObject {
        id: d
        property var selectedFromNetwork
        property var selectedToNetwork
    }

    width: 410
    height: networkCardsLayout.height

    RowLayout {
        id: networkCardsLayout
        width: parent.width
        ColumnLayout {
            id: fromNetworksLayout
            spacing: 12
            StatusBaseText {
                font.pixelSize: 10
                color: Theme.palette.baseColor1
                text: qsTr("Your Balances").toUpperCase()
            }
            Repeater {
                model: networkCardsComponent.layer1Networks
                StatusCard {
                    primaryText: model.chainName
                    secondaryText: amountToSend//balance === 0 ? "No Balance" : !hasGas ? "No Gas" : amountToSend
                    //                                    tertiaryText: "BALANCE: " + balance
                    state: "default"//balance === 0 || !hasGas ? "unavailable" :  "default"
                    cardIcon.source: Style.png(model.iconUrl)
                    disabledText: "Disabled"
                    advancedMode: networkCardsComponent.customMode
                    Component.onCompleted: {
                        if(selectedNetwork.chainName === model.chainName)
                            d.selectedFromNetwork = this
                    }
                }
            }
            Repeater {
                model: networkCardsComponent.layer2Networks
                StatusCard {
                    primaryText: model.chainName
                    secondaryText: amountToSend//balance === 0 ? "No Balance" : !hasGas ? "No Gas" : amountToSend
                    //                                    tertiaryText: "BALANCE: " + balance
                    state: "default"//balance === 0 || !hasGas ? "unavailable" :  "default"
                    cardIcon.source: Style.png(model.iconUrl)
                    disabledText: "Disabled"
                    advancedMode: networkCardsComponent.customMode
                    Component.onCompleted: {
                        if(selectedNetwork.chainName === model.chainName)
                            d.selectedFromNetwork = this
                    }
                }
            }
        }
        ColumnLayout {
            id: toNetworksLayout
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            spacing: 12
            StatusBaseText {
                Layout.alignment: Qt.AlignRight
                Layout.maximumWidth: 70
                font.pixelSize: 10
                color: Theme.palette.baseColor1
                text: selectedAccount.address
                elide: Text.ElideMiddle
            }
            Repeater {
                model: networkCardsComponent.layer1Networks
                StatusCard {
                    primaryText: model.chainName
                    //                                    secondaryText: tokensToReceive
                    tertiaryText: ""
                    //                                    state: preferred ? "default" : "unprefeered"
                    cardIcon.source: Style.png(model.iconUrl)
                    //                                    opacity: preferred ? 1 : 0
                    disabledText: "Disabled"
                    advancedMode: networkCardsComponent.customMode
                    Component.onCompleted: {
                        if(selectedNetwork.chainName === model.chainName)
                            d.selectedToNetwork = this
                    }
                }
            }
            Repeater {
                model: networkCardsComponent.layer2Networks
                StatusCard {
                    primaryText: model.chainName
                    secondaryText: amountToSend//balance === 0 ? "No Balance" : !hasGas ? "No Gas" : amountToSend
                    //                                    tertiaryText: "BALANCE: " + balance
                    state: "default"//balance === 0 || !hasGas ? "unavailable" :  "default"
                    cardIcon.source: Style.png(model.iconUrl)
                    disabledText: "Disabled"
                    advancedMode: networkCardsComponent.customMode
                    Component.onCompleted: {
                        if(selectedNetwork.chainName === model.chainName)
                            d.selectedToNetwork = this
                    }
                }
            }
        }
    }

    Canvas {
        id: canvas
        x: networkCardsLayout.x + fromNetworksLayout.x
        y: networkCardsLayout.y
        width: networkCardsLayout.width
        height: networkCardsLayout.height

        function clear() {
            var ctx = getContext("2d");
            ctx.reset()
        }

        onPaint: {
            // Get the canvas context
            var ctx = getContext("2d");
            StatusQUtils.Utils.drawArrow(ctx, d.selectedFromNetwork.x + d.selectedFromNetwork.width,
                                         d.selectedFromNetwork.y + d.selectedFromNetwork.height/2,
                                         toNetworksLayout.x + d.selectedToNetwork.x,
                                         d.selectedToNetwork.y + d.selectedToNetwork.height/2,
                                         '#627EEA')
        }
    }
}
