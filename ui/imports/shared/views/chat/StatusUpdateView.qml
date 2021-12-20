import QtQuick 2.3
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.panels.chat 1.0
import shared.controls.chat 1.0

import StatusQ.Controls 0.1

MouseArea {
    id: root
//    property var store
    property bool hovered: containsMouse
    property var container
    property int statusAgeEpoch: 0
    property var messageContextMenu

    signal userNameClicked(bool isProfileClick)
    signal setMessageActive(string messageId, bool active)
    signal emojiBtnClicked(bool isProfileClick, bool isSticker, bool isImage, var image, bool emojiOnly)
    signal clickMessage(bool isProfileClick, bool isSticker, bool isImage, var image, bool emojiOnly, bool hideEmojiPicker, bool isReply)

//    TODO bring those back and remove dynamic scoping
//    property var emojiReactionsModel
//    property string timestamp: ""
//    property bool isCurrentUser: false
//    property bool isMessageActive: false
//    property string userName: ""
//    property string localName: ""
//    property string displayUserName: ""
//    property bool isImage: false
//    property bool isMessage: false
//    property string profileImageSource: ""
//    property string userIdenticon: ""

    anchors.top: parent.top
    anchors.topMargin: 0
    height: (isImage ? chatImageContent.height : chatText.height) + chatName.height + 2* Style.current.padding + (emojiReactionsModel.length ? 20 : 0)
    width: parent.width
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    propagateComposedEvents: true

    signal chatImageClicked(string image)
    signal addEmoji(bool isProfileClick, bool isSticker, bool isImage , var image, bool emojiOnly, bool hideEmojiPicker)

    onClicked: {
        mouse.accepted = false
    }

    Rectangle {
        id: rootRect
        anchors.fill: parent
        radius: Style.current.radius
        color: root.hovered ? Style.current.border : Style.current.background

        UserImage {
            id: chatImage
            active: isMessage || isImage
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.top: parent.top
            anchors.topMargin: Style.current.halfPadding
//            messageContextMenu: root.messageContextMenu
//            profileImage: root.profileImageSource
//            isMessage: root.isMessage
//            identiconImageSource: root.userIdenticon
            onClickMessage: {
                root.clickMessage(true, false, false, null, false, false, isReplyImage)
            }
        }

        UsernameLabel {
            id: chatName
            z: 51
            visible: chatImage.visible
            anchors.leftMargin: Style.current.halfPadding
            anchors.top: chatImage.top
            anchors.left: chatImage.right
            label.font.pixelSize: Style.current.primaryTextFontSize
//            messageContextMenu: root.messageContextMenu
//            isCurrentUser: root.isCurrentUser
//            userName: root.userName
//            localName: root.localName
//            displayUserName: root.displayUserName
            onClickMessage: {
                root.userNameClicked(true);
            }
        }

        ChatTimePanel {
            id: chatTime
            // statusAgeEpoch is used to trigger Qt property update
            // since the returned string will be the same in 99% cases, this should not trigger ChatTime re-rendering
            text: Utils.formatAgeFromTime(timestamp, statusAgeEpoch)
            visible: chatName.visible
            anchors.verticalCenter: chatName.verticalCenter
            anchors.left: chatName.right
            anchors.leftMargin: Style.current.halfPadding
            //timestamp: timestamp
        }

        ChatTextView {
            id: chatText
            anchors.top: chatName.visible ? chatName.bottom : chatImage.top
            anchors.topMargin: chatName.visible ? 6 : 0
            anchors.left: chatImage.right
            anchors.leftMargin: Style.current.halfPadding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
//            store: root.store
        }

        Loader {
            id: chatImageContent
            active: isImage
            anchors.left: chatImage.right
            anchors.leftMargin: Style.current.halfPadding
            anchors.top: chatText.bottom
            z: 51

            sourceComponent: Component {
                StatusChatImage {
                    imageSource: image
                    imageWidth: 200
                    container: root.container
                    onClicked: {
                        root.chatImageClicked(image);
                    }
                }
            }
        }

        StatusFlatRoundButton  {
            id: emojiBtn
            width: 32
            height: 32
            anchors.top: rootRect.top
            anchors.topMargin: -height / 4
            anchors.right: rootRect.right
            anchors.rightMargin: Style.current.halfPadding
            visible: root.hovered
            icon.name: "reaction-b"
            icon.width: 20
            icon.height: 20
            type: StatusFlatRoundButton.Type.Tertiary
            backgroundHoverColor: Style.current.background
            onClicked: {
                // Set parent, X & Y positions for the messageContextMenu
                messageContextMenu.parent = emojiBtn
                messageContextMenu.setXPosition = function() { return -messageContextMenu.width + emojiBtn.width}
                messageContextMenu.setYPosition = function() { return -messageContextMenu.height - 4}
                root.emojiBtnClicked(false, false, false, null, true)
            }
        }

        DropShadow {
            anchors.fill: emojiBtn
            horizontalOffset: 0
            verticalOffset: 2
            radius: 10
            samples: 12
            color: "#22000000"
            source: emojiBtn
        }

        Loader {
            id: emojiReactionLoader
            active: emojiReactionsModel.length
            sourceComponent: emojiReactionsComponent
            anchors.left: chatImage.right
            anchors.leftMargin: Style.current.halfPadding
            anchors.top: isImage ? chatImageContent.bottom : chatText.bottom
            anchors.topMargin: Style.current.halfPadding
        }

        Component {
            id: emojiReactionsComponent
            EmojiReactionsPanel {
                store: messageStore
                emojiReactionsModel: reactionsModel
                isMessageActive: isMessageActive
                isCurrentUser: isCurrentUser
                onAddEmojiClicked: {
                    root.addEmoji(false, false, false, null, true, false);
                    // Set parent, X & Y positions for the messageContextMenu
                    messageContextMenu.parent = emojiReactionLoader
                    messageContextMenu.setXPosition = function() { return (messageContextMenu.parent.x + 4)}
                    messageContextMenu.setYPosition = function() { return (-messageContextMenu.height - 4)}
                }

                onToggleReaction: messageStore.toggleReaction(messageId, emojiID)

                onSetMessageActive: {
                    root.setMessageActive(messageId, active);
                }
            }
        }

        Separator {
            anchors.bottom: parent.bottom
            visible: !root.hovered
        }
    }
}
