import QtQuick 2.13
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

StatusDropdown {
    id: root
    property bool ready: root.tokenAmountValue > 0 && root.tokenName !== d.defaultTokenNameText
    property string tokenAmountValue: ""
    property string tokenName: d.defaultTokenNameText
    property url tokenImage: ""

    signal addToken(string tokenName, url tokenImage, string tokenAmountValue)

    function reset() {
        root.tokenAmountValue = ""
        root.tokenName = d.defaultTokenNameText
        root.tokenImage = ""
    }

    QtObject {
        id: d
        property int minHeight: 232 // By design
        property int extendedHeight: 417
        property string defaultTokenNameText: qsTr("Choose token")
    }

    width: 289 // default by design
    height: d.minHeight

    contentItem: Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: mainTokensView

        onSourceComponentChanged: {
            if(sourceComponent == tokensExtendedView) {
                // Update dropdown height if extended view
                root.height = Math.min(item.contentHeight + item.anchors.topMargin + item.anchors.bottomMargin, d.extendedHeight)
            }
            else {
                // Oterwise, update dropdown height with the minimum heigh by design
                root.height = d.minHeight
            }
        }
    }

    onClosed: reset()

    Component {
        id: mainTokensView

        ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                anchors.topMargin: 16
                spacing: 8
                StatusSwitchTabBar {
                    id: tabBar
                    implicitWidth: 273 // by design
                    implicitHeight: 36 // by design
                    StatusSwitchTabButton {
                        text: qsTr("Token")
                        pixelSize: 13
                    }
                    StatusSwitchTabButton {
                        text: qsTr("Collectibles")
                        pixelSize: 13
                    }
                    StatusSwitchTabButton {
                        text: qsTr("ENS")
                        pixelSize: 13
                    }
                }
                StackLayout {
                    width: parent.width
                    currentIndex: tabBar.currentIndex
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        StatusPickerButton {
                            Layout.fillWidth: true
                            Layout.topMargin: 8
                            implicitHeight: 36
                            type: StatusPickerButton.Type.Next
                            bgColor: Theme.palette.baseColor5
                            contentColor: Theme.palette.directColor1
                            text: root.tokenName
                            textPixelSize: 13
                            image: StatusImageSettings {
                                source: root.tokenImage
                                width: 20
                                height: 20
                                isIdenticon: false
                            }
                            onClicked: loader.sourceComponent = tokensExtendedView
                        }
                        StatusInput {
                            Layout.fillWidth: true
                            implicitHeight: 42
                            input.text: root.tokenAmountValue
                            input.font.pixelSize: 13
                            rightPadding: amountText.implicitWidth + leftPadding
                            input.placeholderText: "0"
                            input.placeholderTextColor: Theme.palette.directColor1
                            //TODO: validators: real numbers
                            StatusBaseText {
                                id: amountText
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.top: parent.top
                                anchors.topMargin: parent.leftPadding
                                text: qsTr("Amount")
                                color: Theme.palette.baseColor1
                                font.pixelSize: 13
                            }
                            onTextChanged: root.tokenAmountValue = input.text
                        }
                        // Just a filler
                        Item { Layout.fillHeight: true}
                        // TODO: Needed `StatusButton` redesign that allows to fill the width.
                        StatusButton {
                            enabled: root.ready
                            text: qsTr("Add")
                            height: 44
                            Layout.alignment: Qt.AlignHCenter
                            //Layout.fillWidth: true
                            onClicked: { root.addToken(root.tokenName, root.tokenImage, root.tokenAmountValue) }
                        }
                    }

                    // TODO
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    // TODO
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
    }

    Component {
        id: tokensExtendedView

        TokensListDropdownContent {
            anchors.fill: parent
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            headerModel: ListModel {
                ListElement { index: 0; icon: "next"; iconSize: 12; description: qsTr("Back"); rotation: 180; spacing: 0 }
                ListElement { index: 1; icon: "add"; iconSize: 16; description: qsTr("Mint token"); rotation: 0; spacing: 8 }
                ListElement { index: 2; icon: "invite-users"; iconSize: 16; description: qsTr("Import existing token"); rotation: 180; spacing: 8 }
            }
            // TODO: Replace to real data, now dummy model
            model: ListModel {
                ListElement {imageSource: "qrc:imports/assets/png/tokens/SOCKS.png"; name: "Unisocks"; shortName: "SOCKS"; selected: false; category: "Community tokens"}
                ListElement {imageSource: "qrc:imports/assets/png/tokens/ZRX.png"; name: "Ox"; shortName: "ZRX"; selected: false; category: "Listed tokens"}
                ListElement {imageSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "1inch"; shortName: "ZRX"; selected: false; category: "Listed tokens"}
                ListElement {imageSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "Aave"; shortName: "AAVE"; selected: false; category: "Listed tokens"}
                ListElement {imageSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "Amp"; shortName: "AMP"; selected: false; category: "Listed tokens"}
            }
            onClickHeaderItem: {
                if(index === 0) loader.sourceComponent = mainTokensView // Go back
                else if(index === 1) console.log("TODO: Mint token")
                else if(index === 2) console.log("TODO: Import existing token")
            }
            onClickItem: {
                // Go back
                loader.sourceComponent = mainTokensView

                // Update new token info
                root.tokenName = shortName
                root.tokenImage = imageSource
            }
        }
    }
}
