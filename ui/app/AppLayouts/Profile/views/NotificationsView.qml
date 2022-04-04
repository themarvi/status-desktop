import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import shared.panels 1.0
import shared.status 1.0
import shared.controls 1.0

import "../stores"
import "../popups"
import "../panels"
import "./"

SettingsContentBase {
    id: root

    property NotificationsStore notificationsStore

    Item {
        id: notificationsContainer
        width: root.contentWidth
        height: this.childrenRect.height + 100

        property Component mutedChatsModalComponent: MutedChatsModal {}


        ButtonGroup {
            id: notificationSetting
        }

        ButtonGroup {
            id: soundSetting
        }

        ButtonGroup {
            id: messageSetting
        }

        Column {
            id: column
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            RadioButtonSelector {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                title: qsTr("All messages")
                buttonGroup: notificationSetting
                checked: localAccountSensitiveSettings.notificationSetting === Constants.notifyAllMessages
                onCheckedChanged: {
                    if (checked) {
                        localAccountSensitiveSettings.notificationSetting = Constants.notifyAllMessages
                    }
                }
            }

            RadioButtonSelector {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                title: qsTr("Just @mentions")
                buttonGroup: notificationSetting
                checked:  localAccountSensitiveSettings.notificationSetting === Constants.notifyJustMentions
                onCheckedChanged: {
                    if (checked) {
                        localAccountSensitiveSettings.notificationSetting = Constants.notifyJustMentions
                    }
                }
            }

            RadioButtonSelector {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                title: qsTr("Nothing")
                buttonGroup: notificationSetting
                checked:  localAccountSensitiveSettings.notificationSetting === Constants.notifyNone
                onCheckedChanged: {
                    if (checked) {
                        localAccountSensitiveSettings.notificationSetting = Constants.notifyNone
                    }
                }
            }
        }

        Separator {
            id: separator
            anchors.top: column.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.left: parent.left
            anchors.right: parent.right
        }

        StatusSectionHeadline {
            id: sectionHeadlineSound
            text: qsTr("Appearance")
            anchors.top: separator.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Style.current.padding
            anchors.rightMargin: Style.current.padding
        }

        Column {
            id: column2
            anchors.top: sectionHeadlineSound.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width

            // TODO: replace with StatusListItem
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Play a sound when receiving a notification")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.notificationSoundsEnabled
                onClicked: {
                    localAccountSensitiveSettings.notificationSoundsEnabled = checked
                }
            }

            // TODO: replace with StatusListItem
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Use your operating system's notifications")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.useOSNotifications
                onClicked: {
                    localAccountSensitiveSettings.useOSNotifications = checked
                }

                StatusBaseText {
                    id: detailText
                    text: qsTr("Setting this to false will instead use Status' notification style as seen below")
                    color: Theme.palette.baseColor1
                    width: parent.width
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.leftMargin: Style.current.padding
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 2
                }
            }
        }

        Column {
            id: column3
            spacing: Style.current.bigPadding
            anchors.top: column2.bottom
            anchors.topMargin: Style.current.padding*2
            anchors.left: parent.left
            anchors.right: parent.right

            StatusBaseText {
                text: qsTr("Message preview")
                font.pixelSize: 15
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                color: Theme.palette.directColor1
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 10

                NotificationAppearancePreviewPanel {
                    name: qsTr("Anonymous")
                    notificationTitle: "Status"
                    notificationMessage: qsTr("You have a new message")
                    buttonGroup: messageSetting
                    checked: localAccountSensitiveSettings.notificationMessagePreviewSetting === Constants.notificationPreviewAnonymous
                    onRadioCheckedChanged: {
                        if (checked) {
                            localAccountSensitiveSettings.notificationMessagePreviewSetting = Constants.notificationPreviewAnonymous
                        }
                    }
                }

                NotificationAppearancePreviewPanel {
                    name: qsTr("Name only")
                    notificationTitle: "Vitalik Buterin"
                    notificationMessage: qsTr("You have a new message")
                    buttonGroup: messageSetting
                    checked: localAccountSensitiveSettings.notificationMessagePreviewSetting === Constants.notificationPreviewNameOnly
                    onRadioCheckedChanged: {
                        if (checked) {
                            localAccountSensitiveSettings.notificationMessagePreviewSetting = Constants.notificationPreviewNameOnly
                        }
                    }
                }

                NotificationAppearancePreviewPanel {
                    name: qsTr("Name & Message")
                    notificationTitle: "Vitalik Buterin"
                    notificationMessage: qsTr("Hi there! Yes, no problem, let me know if I can help.")
                    buttonGroup: messageSetting
                    checked: localAccountSensitiveSettings.notificationMessagePreviewSetting === Constants.notificationPreviewNameAndMessage
                    onRadioCheckedChanged: {
                        if (checked) {
                            localAccountSensitiveSettings.notificationMessagePreviewSetting = Constants.notificationPreviewNameAndMessage
                        }
                    }
                }
            }

            StatusBaseText {
                text: qsTr("No preview or Advanced? Go to Notification Center")
                font.pixelSize: 15
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                color: Theme.palette.directColor1
            }
        }

        Separator {
            id: separator2
            anchors.top: column3.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.left: parent.left
            anchors.right: parent.right
        }

        StatusSectionHeadline {
            id: sectionHeadlineContacts
            text: qsTr("Contacts & Users")
            anchors.top: separator2.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Style.current.padding
            anchors.rightMargin: Style.current.padding
        }

        Column {
            id: column4
            anchors.top: sectionHeadlineContacts.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width

            // TODO: replace with StatusListItem
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Notify on new requests")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.notifyOnNewRequests
                onClicked: {
                    localAccountSensitiveSettings.notifyOnNewRequests = checked
                }
            }

            // TODO: replace with StatusListItem
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Muted users")
                currentValue: root.notificationsStore.mutedContactsModel.count > 0 ?
                                  root.notificationsStore.mutedContactsModel.count : qsTr("None")
                isSwitch: false
                onClicked: {
                    const mutedChatsModal = notificationsContainer.mutedChatsModalComponent.createObject(notificationsContainer)
                    mutedChatsModal.model = root.notificationsStore.notificationsModule.mutedContactsModel
                    mutedChatsModal.title = qsTr("Muted contacts");
                    mutedChatsModal.noContentText = qsTr("Muted contacts will appear here");

                    mutedChatsModal.unmuteChat.connect(function(chatId){
                        root.notificationsStore.unmuteChat(chatId)
                    })

                    mutedChatsModal.open();
                }
            }

            // TODO: replace with StatusListItem
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Muted chats")
                currentValue: root.notificationsStore.mutedChatsModel.count > 0 ?
                                  root.notificationsStore.mutedChatsModel.count : qsTr("None")
                isSwitch: false
                onClicked: {
                    const mutedChatsModal = notificationsContainer.mutedChatsModalComponent.createObject(notificationsContainer)
                    mutedChatsModal.model = root.notificationsStore.notificationsModule.mutedChatsModel
                    mutedChatsModal.title = qsTr("Muted chats");
                    mutedChatsModal.noContentText = qsTr("Muted chats will appear here");

                    mutedChatsModal.unmuteChat.connect(function(chatId){
                        root.notificationsStore.unmuteChat(chatId)
                    })

                    mutedChatsModal.open();
                }

                StatusBaseText {
                    text: qsTr("You can limit what gets shown in notifications")
                    color: Theme.palette.baseColor1
                    width: parent.width
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.leftMargin: Style.current.padding
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 2
                }
            }
        }

        Separator {
            id: separator3
            anchors.top: column4.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.left: parent.left
            anchors.right: parent.right
        }

        Column {
            id: column5
            spacing: Style.current.smallPadding
            anchors.top: separator3.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width

            StatusBaseText {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                text: qsTr("Reset notification settings")
                font.pixelSize: 15
                color: Theme.palette.dangerColor1
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: {
                        parent.font.underline = true
                    }
                    onExited: {
                        parent.font.underline = false
                    }
                    onClicked: {
                        localAccountSensitiveSettings.notificationSetting = Constants.notifyAllMessages
                        localAccountSensitiveSettings.notificationSoundsEnabled = true
                        localAccountSensitiveSettings.notificationMessagePreviewSetting = Constants.notificationPreviewNameAndMessage
                        localAccountSensitiveSettings.allowNotificationsFromNonContacts = false
                    }
                }
            }

            StatusBaseText {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                text: qsTr("Restore default notification settings and unmute all chats and users")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }
        }
    }
}
