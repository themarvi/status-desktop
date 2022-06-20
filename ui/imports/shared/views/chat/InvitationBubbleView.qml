import QtQuick 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.panels 1.0
import shared.popups 1.0

Item {
    id: root
    anchors.left: parent.left
    height: rectangleBubbleLoader.height
    width: rectangleBubbleLoader.width

    property string communityId
    property var invitedCommunity
    property int innerMargin: 12
    property bool isLink: false
    property var store

    function getCommunity() {
        try {
            const communityJson = root.store.getSectionByIdJson(communityId)

            if (!communityJson) {
                root.store.requestCommunityInfo(communityId)
                return null
            }

            return JSON.parse(communityJson);
        } catch (e) {
            console.error("Error parsing community", e)
        }

        return null
    }

    Component.onCompleted: {
        root.invitedCommunity = getCommunity()
    }

    Connections {
        target: root.store.communitiesModuleInst
        onCommunityChanged: function (communityId) {
            if (communityId === root.communityId) {
                root.invitedCommunity = getCommunity()
            }
        }
    }

    Connections {
        target: root.store.communitiesModuleInst
        onCommunityAdded: function (communityId) {
            if (communityId === root.communityId) {
                root.invitedCommunity = getCommunity()
            }
        }
    }

    Component {
        id: confirmationPopupComponent
        ConfirmationDialog {
            property string settingsProp: ""
            property var onConfirmed: (function(){})
            showCancelButton: true
            //% "This feature is experimental and is meant for testing purposes by core contributors and the community. It's not meant for real use and makes no claims of security or integrity of funds or data. Use at your own risk."
            confirmationText: qsTrId("this-feature-is-experimental-and-is-meant-for-testing-purposes-by-core-contributors-and-the-community--it-s-not-meant-for-real-use-and-makes-no-claims-of-security-or-integrity-of-funds-or-data--use-at-your-own-risk-")
            //% "I understand"
            confirmButtonLabel: qsTrId("i-understand")
            onConfirmButtonClicked: {
                onConfirmed()
                close()
            }

            onCancelButtonClicked: {
                close()
            }
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: communityIntroDialog

        CommunityIntroDialog {
            anchors.centerIn: parent

            property var joinMethod: () => {}

            name: root.invitedCommunity ? root.invitedCommunity.name : ""
            introMessage: root.invitedCommunity ? root.invitedCommunity.introMessage : ""
            imageSrc: root.invitedCommunity ? root.invitedCommunity.image : ""

            onJoined: joinMethod()
        }
    }

    Loader {
        id: rectangleBubbleLoader
        active: !!invitedCommunity

        sourceComponent: Component {
            Rectangle {
                id: rectangleBubble
                property alias button: joinBtn
                property bool isPendingRequest: root.store.isCommunityRequestPending(communityId)
                width: 270
                height: column.implicitHeight
                radius: 16
                color: Style.current.background
                border.color: Style.current.border
                border.width: 1

                states: [
                    State {
                        name: "requiresEns"
                        when: invitedCommunity.ensOnly && !userProfile.ensName
                        PropertyChanges {
                            target: joinBtn
                            //% "Membership requires an ENS username"
                            text: qsTrId("membership-requires-an-ens-username")
                            enabled: false
                        }
                    },
                    State {
                        name: "inviteOnly"
                        when: invitedCommunity.access === Constants.communityChatInvitationOnlyAccess
                        PropertyChanges {
                            target: joinBtn
                            //% "You need to be invited"
                            text: qsTrId("you-need-to-be-invited")
                            enabled: false
                        }
                    },
                    State {
                        name: "pending"
                        when: invitedCommunity.access === Constants.communityChatOnRequestAccess &&
                              rectangleBubble.isPendingRequest
                        PropertyChanges {
                            target: joinBtn
                            //% "Pending"
                            text: qsTrId("invite-chat-pending")
                            enabled: false
                        }
                    },
                    State {
                        name: "joined"
                        when: (invitedCommunity.joined && invitedCommunity.isMember) ||
                              (invitedCommunity.access === Constants.communityChatPublicAccess &&
                                invitedCommunity.joined)
                        PropertyChanges {
                            target: joinBtn
                            //% "View"
                            text: qsTrId("view")
                        }
                    },
                    State {
                        name: "requestToJoin"
                        when: invitedCommunity.access === Constants.communityChatOnRequestAccess &&
                              !invitedCommunity.joined && !invitedCommunity.isMember &&
                              invitedCommunity.canRequestAccess
                        PropertyChanges {
                            target: joinBtn
                            //% "Request Access"
                            text: qsTrId("request-access")

                        }
                    },
                    State {
                        name: "unjoined"
                        when: (invitedCommunity.access === Constants.communityChatOnRequestAccess &&
                                invitedCommunity.isMember) ||
                              (invitedCommunity.access === Constants.communityChatPublicAccess &&
                                !invitedCommunity.joined)
                        PropertyChanges {
                            target: joinBtn
                            //% "Join"
                            text: qsTrId("join")
                        }
                    }
                ]

                // Not Refactored Yet
//                Connections {
//                    target: root.store.chatsModelInst.communities
//                    onMembershipRequestChanged: function(communityId, communityName, requestAccepted) {
//                        if (communityId === root.communityId) {
//                            rectangleBubble.isPendingRequest = false
//                        }
//                    }
//                }

                ColumnLayout {
                    id: column
                    width: parent.width
                    spacing: Style.current.halfPadding

                    // TODO add check if verified
                    StatusBaseText {
                        id: title
                        color: invitedCommunity.verifed ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
                        text: invitedCommunity.verifed ?
                                  //% "Verified community invitation"
                                  qsTrId("verified-community-invitation") :
                                  //% "Community invitation"
                                  qsTrId("community-invitation")
                        font.weight: Font.Medium
                        Layout.topMargin: Style.current.halfPadding
                        Layout.leftMargin: root.innerMargin
                        font.pixelSize: 13
                    }
                    StatusBaseText {
                        id: invitedYou
                        visible: text != ""
                        text: {
                            // Not Refactored Yet
                            return ""
    //                        if (root.store.chatsModelInst.channelView.activeChannel.chatType === Constants.chatType.oneToOne) {
    //                            return isCurrentUser ?
    //                                        //% "You invited %1 to join a community"
    //                                        qsTrId("you-invited--1-to-join-a-community").arg(root.store.chatsModelInst.userNameOrAlias(root.store.chatsModelInst.channelView.activeChannel.id))
    //                                        //% "%1 invited you to join a community"
    //                                      : qsTrId("-1-invited-you-to-join-a-community").arg(displayUserName)
    //                        } else {
    //                            return isCurrentUser ?
    //                                        //% "You shared a community"
    //                                        qsTrId("you-shared-a-community")
    //                                        //% "A community has been shared"
    //                                      : qsTrId("a-community-has-been-shared")
    //                        }
                        }
                        Layout.leftMargin: root.innerMargin
                        Layout.rightMargin: root.innerMargin
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                    }

                    Separator {
                        Layout.fillWidth: true
                    }

                    // TODO add image when it's supported
                    StatusBaseText {
                        id: communityName
                        text: invitedCommunity.name
                        Layout.topMargin: 2
                        Layout.leftMargin: root.innerMargin
                        Layout.fillWidth: true
                        Layout.rightMargin: root.innerMargin
                        font.weight: Font.Bold
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: 17
                        color: Theme.palette.directColor1
                    }

                    StatusBaseText {
                        id: communityDesc
                        text: invitedCommunity.description
                        Layout.leftMargin: root.innerMargin
                        Layout.rightMargin: root.innerMargin
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                    }

                    StatusBaseText {
                        id: communityNbMembers
                        // TODO add the plural support
                        //% "%1 members"
                        text: qsTrId("-1-members").arg(invitedCommunity.nbMembers)
                        Layout.leftMargin: root.innerMargin
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: Theme.palette.baseColor1
                    }

                    Separator {
                        Layout.fillWidth: true
                    }

                    Item {
                        id: btnItemId
                        Layout.topMargin: -column.spacing
                        Layout.fillWidth: true
                        height: 44
                        clip: true
                        StatusFlatButton {
                            id: joinBtn
                            anchors.fill: parent
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 16
                            enabled: true
                            text: qsTr("Unsupported state")
                            onClicked: {

                                let onBtnClick = function(){
                                    let error

                                    if (rectangleBubble.state === "joined") {
                                        root.store.setActiveCommunity(communityId);
                                        return
                                    }
                                    if (rectangleBubble.state === "unjoined") {
                                        Global.openPopup(communityIntroDialog, { joinMethod: () => {
                                                                 let error = root.store.joinCommunity(communityId)
                                                                 if (error) joiningError.showError(error)
                                                             } });
                                    }
                                    else if (rectangleBubble.state === "requestToJoin") {
                                        Global.openPopup(communityIntroDialog, { joinMethod: () => {
                                                                 let error = root.store.requestToJoinCommunity(communityId, userProfile.name)
                                                                 if (error) joiningError.showError(error)
                                                                 else rectangleBubble.isPendingRequest = root.store.isCommunityRequestPending(communityId)
                                                             } });
                                    }

                                    if (error) joiningError.showError(error)
                                }

                                if (localAccountSensitiveSettings.communitiesEnabled) {
                                    onBtnClick();
                                } else {
                                    Global.openPopup(confirmationPopupComponent, { onConfirmed: onBtnClick });
                                }
                            }

                            MessageDialog {
                                id: joiningError

                                function showError(error) {
                                    joiningError.text = error
                                    joiningError.open()
                                }

                                //% "Error joining the community"
                                title: qsTrId("error-joining-the-community")
                                icon: StandardIcon.Critical
                                standardButtons: StandardButton.Ok
                            }
                        }
                    }
                }
            }
        }
    }
}
