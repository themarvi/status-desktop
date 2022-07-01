import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

RowLayout {
    id: networksSimpleRoutingView

    property var selectedNetwork
    property var suggestedRoutes
    property int amountToSend: 0

    signal networkChanged(var network)

    spacing: 10

    StatusRoundIcon {
        Layout.alignment: Qt.AlignTop
        radius: 8
        icon.name: "flash"
    }
    ColumnLayout {
        Layout.alignment: Qt.AlignTop
        StatusBaseText {
            Layout.maximumWidth: 410
            font.pixelSize: 15
            font.weight: Font.Medium
            color: Theme.palette.directColor1
            //% "Networks"
            text: qsTr("Networks")
            wrapMode: Text.WordWrap
        }
        StatusBaseText {
            Layout.maximumWidth: 410
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: qsTr("Choose a network to use for the transaction")
            wrapMode: Text.WordWrap
        }
        ColumnLayout {
            Layout.topMargin: Style.current.bigPadding
            Layout.alignment: Qt.AlignCenter
            visible: networksSimpleRoutingView.suggestedRoutes.length === 0
            StatusIcon {
                Layout.alignment: Qt.AlignHCenter
                visible: networksSimpleRoutingView.suggestedRoutes.length === 0 && networksSimpleRoutingView.amountToSend > 0
                icon: "cancel"
                color: Theme.palette.dangerColor1
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 15
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: Theme.palette.dangerColor1
                text: networksSimpleRoutingView.amountToSend > 0 ? qsTr("Balance exceeded"): qsTr("No networks available")
                wrapMode: Text.WordWrap
            }
        }
        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: row.height + 10
            Layout.topMargin: Style.current.bigPadding
            contentWidth: row.width
            contentHeight: row.height + 10
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            clip: true
            visible: networksSimpleRoutingView.suggestedRoutes.length > 0
            Row {
                id: row
                spacing: 16
                Repeater {
                    id: repeater
                    model: networksSimpleRoutingView.suggestedRoutes
                    StatusListItem {
                        id: item
                        implicitWidth: 126
                        title: modelData.chainName
                        subTitle: ""
                        image.source: Style.png("networks/" + modelData.chainName.toLowerCase())
                        image.width: 32
                        image.height: 32
                        leftPadding: 5
                        rightPadding: 5
                        color: "transparent"
                        border.color: Style.current.primary
                        border.width: networksSimpleRoutingView.selectedNetwork !== undefined ? networksSimpleRoutingView.selectedNetwork.chainId === modelData.chainId ? 1 : 0 : 0
                        onClicked: {
                            networksSimpleRoutingView.networkChanged(modelData)
                        }
                    }
                }
            }
        }
    }
}
