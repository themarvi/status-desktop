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

SettingsPageLayout {
    id: root

    property var membersModel
    property var bannedMembersModel
    property string communityName

    property bool editable: true
    property int pendingRequests

    signal membershipRequestsClicked()
    signal userProfileClicked(string id)
    signal kickUserClicked(string id)
    signal banUserClicked(string id)
    signal unbanUserClicked(string id)

    title: qsTr("Members")

    content: ColumnLayout {
        spacing: 8

        StatusTabBar {
            id: membersTabBar
            Layout.fillWidth: true

            StatusTabButton {
                id: allMembersBtn
                width: implicitWidth
                text: qsTr("All members")
            }

// TODO will be added in next phase
//            StatusTabButton {
//                id: pendingRequestsBtn
//                width: implicitWidth
//                text: qsTr("Pending Requests")
//                enabled: false
//            }
// Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
//            StatusTabButton {
//                id: rejectedRequestsBtn
//                width: implicitWidth
//                enabled: root.contactsStore.receivedButRejectedContactRequestsModel.count > 0 ||
//                         root.contactsStore.sentButRejectedContactRequestsModel.count > 0
//                btnText: qsTr("Rejected Requests")
//            }

            StatusTabButton {
                id: bannedBtn
                width: implicitWidth
                enabled: bannedMembersModel.count > 0
                text: qsTr("Banned")
            }
        }

        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: membersTabBar.currentIndex

            CommunityMembersTabPanel {
                model: root.membersModel
                placeholderText: qsTr("Search %1's %2 member(s)").arg(root.communityName).arg(root.membersModel.count)
                panelType: CommunityMembersTabPanel.TabType.AllMembers

                onUserProfileClicked: root.userProfileClicked(id)
                onKickUserClicked: {
                    kickModal.userNameToKick = name
                    kickModal.userIdToKick = id
                    kickModal.open()
                }

                onBanUserClicked: {
                    banModal.userNameToBan = name
                    banModal.userIdToBan = id
                    banModal.open()
                }
            }

            CommunityMembersTabPanel {
                model: root.bannedMembersModel
                placeholderText: qsTr("Search %1's %2 banned member(s)").arg(root.communityName).arg(root.bannedMembersModel.count)
                panelType: CommunityMembersTabPanel.TabType.BannedMembers
                onUserProfileClicked: root.userProfileClicked(id)
                onUnbanUserClicked: root.unbanUserClicked(id)
            }
        }
    }

    StatusModal {
        id: banModal

        property string userNameToBan: ""
        property string userIdToBan: ""

        readonly property string text: qsTr("Are you sure you ban <b>%1</b> from %2?").arg(userNameToBan).arg(root.communityName)

        anchors.centerIn: parent
        header.title: qsTr("Ban %1").arg(userNameToBan)

        contentItem: StatusBaseText {
            id: banContentText
            anchors.centerIn: parent
            font.pixelSize: 15
            color: Theme.palette.directColor1
            leftPadding: 15
            topPadding: 15
            rightPadding: 15
            bottomPadding: 15
            wrapMode: Text.WordWrap
            text: banModal.text
        }

        rightButtons: [
            StatusButton {
                text: qsTr("Cancel")
                onClicked: banModal.close()
            },
            StatusButton {
                id: banButton
                text: qsTr("Ban")
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    root.banUserClicked(banModal.userIdToBan)
                    banModal.close()
                }
            }
        ]
    }

    StatusModal {
        id: kickModal

        property string userNameToKick: ""
        property string userIdToKick: ""

        readonly property string text : qsTr("Are you sure you kick <b>%1</b> from %2?").arg(userNameToKick).arg(communityName)

        anchors.centerIn: parent
        header.title: qsTr("Kick %1").arg(userNameToKick)

        contentItem: StatusBaseText {
            id: kickContentText
            anchors.centerIn: parent
            font.pixelSize: 15
            color: Theme.palette.directColor1
            leftPadding: 15
            topPadding: 15
            rightPadding: 15
            bottomPadding: 15
            wrapMode: Text.WordWrap
            text: kickModal.text
        }

        rightButtons: [
            StatusButton {
                text: qsTr("Cancel")
                onClicked: kickModal.close()
            },
            StatusButton {
                text: qsTr("Kick")
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    root.kickUserClicked(kickModal.userIdToKick)
                    kickModal.close()
                }
            }
        ]
    }
}
