import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import "../../../../shared/views"
import "../../../../shared/panels"
import "./"

StatusModal {
    id: popup
    enum ChannelType {
        ActiveChannel,
        ContextChannel
    }
    property bool addMembers: false
    property int currMemberCount: 1
    property int memberCount: 1
    readonly property int maxMembers: 10
    property var pubKeys: []
    property int channelType: GroupInfoPopup.ChannelType.ActiveChannel
    property QtObject channel
    property bool isAdmin: false
    property Component pinnedMessagesPopupComponent

    function resetSelectedMembers(){
        pubKeys = [];
        memberCount = channel.members.rowCount();
        currMemberCount = memberCount;
        contentItem.contactList.membersData.clear();
        const contacts = getContactListObject()

        contacts.forEach(function (contact) {
            if(popup.channel.contains(contact.publicKey) ||
                    !contact.isContact) {
                return;
            }
            contentItem.contactList.membersData.append(contact)
        })
    }

    anchors.centerIn: parent

    onClosed: {
        popup.destroy();
    }

    onOpened: {
        addMembers = false;
        popup.isAdmin = popup.channel.isAdmin(profileModel.profile.pubKey)
        btnSelectMembers.enabled = false;
        resetSelectedMembers();
    }

    function doAddMembers(){
        if(pubKeys.length === 0) return;
        chatsModel.groups.addMembers(popup.channel.id, JSON.stringify(pubKeys));
        popup.close();
    }

    header.title: addMembers ? qsTr("Add members") : popup.channel.name
    header.subTitle: {
        let cnt = memberCount;
        if(addMembers){
            //% "%1 / 10 members"
            return qsTrId("%1-/-10-members").arg(cnt)
        } else {
            //% "%1 members"
            if(cnt > 1) return qsTrId("%1-members").arg(cnt);
            //% "1 member"
            return qsTrId("1-member");
        }
    }
    header.icon.isLetterIdenticon: true
    header.icon.background.color: popup.channel.color
    header.editable: true

    onEditButtonClicked: {
        renameGroupPopup.open()
    }

    contentItem: Item {
        width: popup.width
        implicitHeight: addMembers ? addMembersItem.height : groupInfoItem.height

        property alias contactList: contactList

        RenameGroupPopup {
            id: renameGroupPopup
        }

        Item {
            id: groupInfoItem
            width: popup.width
            height: childrenRect.height
            anchors.top: parent.top
            visible: !addMembers
            StatusListItem {
                id: pinnedMessagesButton
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                property int pinnedCount: chatsModel.messageView.pinnedMessagesList.count
                visible: pinnedCount > 0
                title: qsTr("Pinned messages")
                icon.name: "pin"
                label: pinnedCount
                components: [
                    StatusIcon {
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]
                sensor.onClicked: {
                    openPopup(pinnedMessagesPopupComponent)
                }
            }
            StatusModalDivider {
                id: divider
                visible: pinnedMessagesButton.visible
                anchors.top: pinnedMessagesButton.bottom
                topPadding: 8
                bottomPadding: 8
            }

            ScrollView {
                id: scrollView
                width: parent.width
                height: 300
                anchors.top: divider.visible ? divider.bottom : parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 16

                contentHeight: Math.max(300, memberListColumn.height)
                bottomPadding: 8
                clip: true

                Column {
                    id: memberListColumn
                    width: parent.width - 32
                    visible: memberList.count > 0 || height > 0
                    anchors.horizontalCenter: parent.horizontalCenter

                    Repeater {
                        id: memberList
                        model: popup.channel.members
                        // TODO: Replace this with a component because we render memberItems like this in different places in the app
                        delegate: StatusListItem {
                            id: memberItem
                            property string nickname: appMain.getUserNickname(model.publicKey)
                            property string profileImage: appMain.getProfileImage(model.publicKey) || ""
                            image.isIdenticon: !profileImage
                            image.source: profileImage || model.identicon
                            title: {
                                if (menuButton.visible) {
                                    return !model.userName.endsWith(".eth") && !!nickname ?
                                        nickname : Utils.removeStatusEns(model.userName)
                                }
                                //% "You"
                                return qsTrId("You")
                            }

                            label: model.isAdmin ? qsTr("Admin") : ""

                            sensor.onClicked: {
                                openProfilePopup(model.userName, model.publicKey, profileImage || model.identicon, '', nickname, popup)
                            }

                            components: [
                                StatusFlatRoundButton {
                                    id: menuButton
                                    width: 32
                                    height: 32
                                    visible: model.publicKey.toLowerCase() !== profileModel.profile.pubKey.toLowerCase()
                                    icon.name: "more"
                                    type: StatusFlatRoundButton.Type.Secondary
                                    onClicked: {
                                        highlighted = true
                                        groupMemberContextMenu.popup(-groupMemberContextMenu.width+menuButton.width, menuButton.height + 4)
                                    }

                                    StatusPopupMenu {
                                        id: groupMemberContextMenu

                                        onClosed: {
                                            menuButton.highlighted = false
                                        }

                                        StatusMenuItem {
                                            text: qsTr("Make Admin")
                                            icon.name: "admin"
                                            onTriggered: chatsModel.groups.makeAdmin(popup.channel.id, model.publicKey)
                                        }

                                        StatusMenuItem {
                                            text: qsTr("Remove from group")
                                            icon.name: "remove-contact"
                                            type: StatusMenuItem.Type.Danger
                                            onTriggered: chatsModel.groups.kickMember(popup.channel.id,  model.publicKey)
                                        }
                                    }
                                }
                            ]
                        }
                    }
                }
            }

            Connections {
                target: chatsModel.channelView
                onActiveChannelChanged: {
                    if (popup.channelType === GroupInfoPopup.ChannelType.ActiveChannel) {
                        popup.channel = chatsModel.channelView.activeChannel
                        resetSelectedMembers()
                    }
                }
                onContextChannelChanged: {
                    if (popup.channelType === GroupInfoPopup.ChannelType.ContextChannel) {
                        popup.channel = chatsModel.channelView.contextChannel
                        resetSelectedMembers()
                    }
                }
            }
        }

        Item {
            id: addMembersItem
            anchors.top: parent.top
            width: parent.width
            height: childrenRect.height
            visible: addMembers

            StatusInput {
                id: searchBox
                input.placeholderText: qsTr("Search for communities or topics")
                input.icon.name: "search"
                input.height: 36
                input.topPadding: 9
                input.bottomPadding: 6
                visible: addMembers
                anchors.top: parent.top
                anchors.topMargin: 8
            }

            StatusModalDivider {
                id: divider2
                anchors.top: searchBox.bottom
                topPadding: 8
                bottomPadding: 8
            }

            NoFriendsRectangle {
                visible: contactList.membersData.count === 0 && memberCount === 0
                height: 300
                anchors.top: divider2.bottom
                anchors.topMargin: Style.current.xlPadding
                anchors.horizontalCenter: parent.horizontalCenter
            }

            NoFriendsRectangle {
                visible: contactList.membersData.count === 0 && memberCount > 0
                height: 300
                width: 340
                //% "All your contacts are already in the group"
                text: qsTrId("group-chat-all-contacts-invited")
                textColor: Theme.palette.directColor1
                anchors.top: divider2.bottom
                anchors.topMargin: Style.current.xlPadding
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ContactList {
                id: contactList
                anchors.top: divider2.bottom
                anchors.topMargin: 50
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                visible: addMembers && contactList.membersData.count > 0
                selectMode: memberCount < maxMembers
                searchString: searchBox.text.toLowerCase()
                onItemChecked: function(pubKey, itemChecked){
                    var idx = pubKeys.indexOf(pubKey)
                    if(itemChecked){
                        if(idx === -1){
                            pubKeys.push(pubKey)
                        }
                    } else {
                        if(idx > -1){
                            pubKeys.splice(idx, 1);
                        }
                    }
                    memberCount = popup.channel.members.rowCount() + pubKeys.length;
                    btnSelectMembers.enabled = pubKeys.length > 0
                }
            }
        }
    }

    leftButtons: [
        StatusRoundButton {
            visible: addMembers
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            icon.rotation: 180
            onClicked : {
                addMembers = false;
                resetSelectedMembers();
            }
        }
    ]

    rightButtons: [
        StatusButton {
            visible: !addMembers
            //% "Add members"
            text: qsTrId("add-members")
            onClicked: {
                addMembers = true;
            }
        },
        StatusButton {
            id: btnSelectMembers
            visible: addMembers
            enabled: memberCount >= currMemberCount
            //% "Add selected"
            text: qsTrId("add-selected")
            onClicked: doAddMembers()
        }
    ]
}
