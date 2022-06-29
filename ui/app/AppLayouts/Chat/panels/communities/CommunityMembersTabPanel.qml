import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.controls.chat 1.0

import "../../layouts"

Item {
    id: root

    property string placeholderText
    property var model

    signal userProfileClicked(string id)
    signal kickUserClicked(string id, string name)
    signal banUserClicked(string id, string name)
    signal unbanUserClicked(string id)

    enum TabType {
        AllMembers,
        BannedMembers
    }

    property int panelType: CommunityMembersTabPanel.TabType.AllMembers

    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors.fill: parent

        StatusBaseInput {
            id: memberSearch
            Layout.preferredWidth: 351
            rightPadding: 0
            placeholderText: root.placeholderText
            icon.name: "search"
            enabled: model.count > 0
        }

        ListView {
            id: membersList

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: root.model
            clip: true

            delegate: StatusMemberListItem {
                id: memberItem

                readonly property bool itsMe: model.pubKey.toLowerCase() === userProfile.pubKey.toLowerCase()
                readonly property bool isHovered: !memberItem.itsMe && memberItem.sensor.containsMouse

                components: [
                    StatusButton {
                        visible: (root.panelType === CommunityMembersTabPanel.TabType.AllMembers) && isHovered
                        text: qsTr("Kick")
                        type: StatusBaseButton.Type.Danger
                        size: StatusBaseButton.Size.Small
                        onClicked: root.kickUserClicked(model.pubKey, model.displayName)
                    },

                    StatusButton {
                        visible: (root.panelType === CommunityMembersTabPanel.TabType.AllMembers) && isHovered
                        text: qsTr("Ban")
                        type: StatusBaseButton.Type.Danger
                        size: StatusBaseButton.Size.Small
                        onClicked: root.banUserClicked(model.pubKey, model.displayName)
                    },

                    StatusButton {
                        visible: (root.panelType === CommunityMembersTabPanel.TabType.BannedMembers) && isHovered
                        text: qsTr("Unban")
                        type: StatusBaseButton.Type.Normal
                        size: StatusBaseButton.Size.Small
                        onClicked: root.unbanUserClicked(model.pubKey)
                    }
                ]

                width: membersList.width
                visible: memberSearch.text === "" || title.toLowerCase().includes(memberSearch.text.toLowerCase())
                height: visible ? implicitHeight : 0
                color: "transparent"

                pubKey: Utils.getElidedCompressedPk(model.pubKey)
                nickName: model.localNickname
                userName: {
                    let tempUserName = model.displayName
                    if (memberItem.itsMe) {
                        tempUserName += qsTr(" (You)")
                    }
                    return tempUserName
                }
                status: model.onlineStatus
                icon.color: Theme.palette.userCustomizationColors[Utils.colorIdForPubkey(model.pubKey)] // FIXME: use model.colorId
                image.source: model.icon
                image.isIdenticon: false
                ringSettings.ringSpecModel: Utils.getColorHashAsJson(model.pubKey)
                statusListItemIcon.badge.visible: (root.panelType === CommunityMembersTabPanel.TabType.AllMembers)

                onClicked: root.userProfileClicked(model.pubKey)
            }
        }
    }
}
