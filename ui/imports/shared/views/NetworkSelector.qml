import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../controls"

Item {
    id: root
    height: visible ? tabBar.height + stackLayout.height + 2* Style.current.xlPadding : 0

    signal networkChanged(int chainId)

    property var store
    property var suggestedRoutes
    property var selectedNetwork
    property int amountToSend: 0
    property var selectedAccount

    StatusSwitchTabBar {
        id: tabBar
        anchors.top: parent.top
        anchors.topMargin: Style.current.bigPadding
        anchors.horizontalCenter: parent.horizontalCenter
        StatusSwitchTabButton {
            text: qsTr("Simple")
        }
        StatusSwitchTabButton {
            text: qsTr("Advanced")
        }
        StatusSwitchTabButton {
            text: qsTr("Custom")
        }
    }

    StackLayout {
        id: stackLayout
        anchors.top: tabBar.bottom
        anchors.topMargin: Style.current.bigPadding
        height: currentIndex == 0 ? networksSimpleRoutingPage.height + networksSimpleRoutingPage.anchors.margins + Style.current.bigPadding:
                                    currentIndex == 1 ? advancedNetworkRoutingPage.height + advancedNetworkRoutingPage.anchors.margins + Style.current.bigPadding:
                                                        customNetworkRoutingPage.height + customNetworkRoutingPage.anchors.margins + Style.current.bigPadding
        width: parent.width
        currentIndex: tabBar.currentIndex

        Rectangle {
            id: simple
            radius: 13
            color: Theme.palette.indirectColor1
            NetworksSimpleRoutingView {
                id: networksSimpleRoutingPage
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 16
                selectedNetwork: root.selectedNetwork
                suggestedRoutes: root.suggestedRoutes
                amountToSend: root.amountToSend
                onNetworkChanged:  {
                    root.selectedNetwork = network
                    root.networkChanged(network.chainId)
                }
            }
        }

        Rectangle {
            id: advanced
            radius: 13
            color: Theme.palette.indirectColor1
            NetworksAdvancedCustomRoutingView {
                id: advancedNetworkRoutingPage
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 16
                store: root.store
                selectedNetwork: root.selectedNetwork
                selectedAccount: root.selectedAccount
                amountToSend: root.amountToSend
            }
        }

        Rectangle {
            id: custom
            radius: 13
            color: Theme.palette.indirectColor1
            NetworksAdvancedCustomRoutingView {
                id: customNetworkRoutingPage
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 16
                store: root.store
                selectedNetwork: root.selectedNetwork
                selectedAccount: root.selectedAccount
                amountToSend: root.amountToSend
                customMode: true
            }
        }
    }
}
