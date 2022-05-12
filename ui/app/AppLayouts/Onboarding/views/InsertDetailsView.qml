import QtQuick 2.13
import QtQuick.Layouts 1.12
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared.panels 1.0

import utils 1.0
import shared.controls 1.0
import "../popups"
import "../stores"

Item {
    id: root

    property string pubKey
    property string address
    property string displayName
    signal createPassword()

    state: "username"

    Component.onCompleted: {
        if (!!OnboardingStore.onboardingModuleInst.importedAccountPubKey) {
            root.address = OnboardingStore.onboardingModuleInst.importedAccountAddress ;
            root.pubKey = OnboardingStore.onboardingModuleInst.importedAccountPubKey;
        }
    }

    Loader {
        active: !OnboardingStore.onboardingModuleInst.importedAccountPubKey
        sourceComponent: ListView {
            model: OnboardingStore.onboardingModuleInst.accountsModel
            delegate: Item {
                Component.onCompleted: {
                    if (index === 0) {
                        root.address = model.address;
                        root.pubKey = model.pubKey;
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.current.padding

        StyledText {
            id: usernameText
            text: qsTr("Your profile")
            font.weight: Font.Bold
            font.pixelSize: 22
            Layout.alignment: Qt.AlignHCenter
        }

        StyledText {
            id: txtDesc
            Layout.preferredWidth: (root.state === "username") ? 338 : 643
            color: Style.current.secondaryText
            text: qsTr("Longer and unusual names are better as they are less likely to be used by someone else.")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 15
        }

        Item {
            implicitWidth: 100
            implicitHeight: 100
            Layout.alignment: Qt.AlignHCenter
            StatusSmartIdenticon {
                id: userImage
                image {
                    width: 80
                    height: 80
                    isIdenticon: false
                }

                icon {
                    width: 80
                    height: 80
                    letterSize: 32
                    color: Theme.palette.miscColor5
                    charactersLen: 2
                }

                ringSettings {
                    ringSpecModel: Utils.getColorHashAsJson(root.pubKey)
                }
            }
            StatusRoundButton {
                id: updatePicButton
                width: 40
                height: 40
                anchors.top: parent.top
                anchors.right: parent.right
                type: StatusFlatRoundButton.Type.Secondary
                icon.name: "add"
                onClicked: {
                    uploadProfilePicPopup.currentProfileImg = userImage.image.source
                    uploadProfilePicPopup.open();
                }
            }
        }

        StatusInput {
            id: nameInput
            implicitWidth: 328
            Layout.preferredHeight: 78
            Layout.alignment: Qt.AlignHCenter
            input.placeholderText: qsTr("Display name")
            input.edit.font.capitalization: Font.Capitalize
            input.rightComponent: RoundedIcon {
                width: 14
                height: 14
                iconWidth: 14
                iconHeight: 14
                visible: (nameInput.input.text.length > 0)
                color: "transparent"
                source: Style.svg("close-filled")
                onClicked: {
                    nameInput.input.edit.clear();
                }
            }
            errorMessageCmp.wrapMode: Text.NoWrap
            errorMessageCmp.horizontalAlignment: Text.AlignHCenter
            validators: Constants.validators.displayName
            onTextChanged: {
                userImage.name = text;
            }
        }

        StyledText {
            id: chatKeyTxt
            color: Style.current.secondaryText
            text: qsTr("Chatkey:") + " " + Utils.getCompressedPk(root.pubKey)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 15
        }

        Item {
            id: chainsChatKeyImg
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 197
            implicitHeight: 84
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: Style.png("onboarding/chains")
            }
            RowLayout {
                id: test
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }
                EmojiHash {
                    publicKey: root.pubKey
                }
                StatusSmartIdenticon {
                    id: userImageCopy
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: 18
                    icon.width: 44
                    icon.height: 44
                    icon.color: "transparent"
                    ringSettings { ringSpecModel: Utils.getColorHashAsJson(root.pubKey) }
                }
            }
        }

        StatusButton {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: 125
            enabled: !!nameInput.text && nameInput.valid
            text: qsTr("Next")
            onClicked: {
                if (root.state === "username") {
                    if (OnboardingStore.accountCreated) {
                        OnboardingStore.updatedDisplayName(nameInput.text);
                    }
                    OnboardingStore.displayName = nameInput.text
                    root.displayName = nameInput.text;
                    root.state = "chatkey";
                } else {
                    createPassword();
                }
            }
        }

        UploadProfilePicModal {
            id: uploadProfilePicPopup
            anchors.centerIn: parent
            onSetProfileImage: {
                userImage.image.source = image
            }
        }
    }

    states: [
        State {
            name: "username"
            PropertyChanges {
                target: usernameText
                text: qsTr("Your profile")
            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("Longer and unusual names are better as they are less likely to be used by someone else.")
            }
            PropertyChanges {
                target: chatKeyTxt
                visible: false
            }
            PropertyChanges {
                target: chainsChatKeyImg
                visible: false
            }
            PropertyChanges {
                target: userImageCopy
                visible: false
            }
            PropertyChanges {
                target: updatePicButton
                visible: true
            }
            PropertyChanges {
                target: nameInput
                visible: true
            }
        },
        State {
            name: "chatkey"
            PropertyChanges {
                target: usernameText
                text: qsTr("Your emojihash and identicon ring")
            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("This set of emojis and coloured ring around your avatar are unique and represent your chat key, so your friends can easily distinguish you from potential impersonators.")
            }
            PropertyChanges {
                target: chatKeyTxt
                visible: true
            }
            PropertyChanges {
                target: chainsChatKeyImg
                visible: true
            }
            PropertyChanges {
                target: userImageCopy
                visible: true
            }
            PropertyChanges {
                target: updatePicButton
                visible: false
            }
            PropertyChanges {
                target: nameInput
                visible: false
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "*"
            SequentialAnimation {
                PropertyAction {
                    target: root
                    property: "opacity"
                    value: 0.0
                }
                PropertyAction {
                    target: root
                    property: "opacity"
                    value: 1.0
                }
            }
        }
    ]
}
