import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1 as StatusQControls

import shared.panels 1.0
import shared.status 1.0

import utils 1.0

Rectangle {
    id: root
    height: 220
    anchors.left: parent.left
    anchors.leftMargin: Style.current.padding
    anchors.right: parent.right
    anchors.rightMargin: Style.current.padding
    border.color: Style.current.border
    radius: 16
    color: Style.current.transparent
    property var activeCommunity
    property var store
    property var communitySectionModule
    property bool hasAddedContacts

    signal manageCommunityClicked()

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        propagateComposedEvents: true
        onClicked: {
            /* Prevents sending events to the component beneath
               if Right Mouse Button is clicked. */
            mouse.accepted = false;
        }
    }

    Rectangle {
        width: 70
        height: 4
        color: Style.current.secondaryMenuBackground
        anchors.top: parent.top
        anchors.topMargin: -2
        anchors.horizontalCenter: parent.horizontalCenter
    }

    SVGImage {
        anchors.top: parent.top
        anchors.topMargin: -6
        anchors.horizontalCenter: parent.horizontalCenter
        source: Style.svg("chatEmptyHeader")
        width: 66
        height: 50
    }

    StatusQControls.StatusFlatRoundButton {
        id: closeImg
        implicitWidth: 32
        implicitHeight: 32
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        icon.height: 20
        icon.width: 20
        icon.name: "close-circle"
        type: StatusQControls.StatusFlatRoundButton.Type.Tertiary
        onClicked: {
            let hiddenBannerIds = localAccountSensitiveSettings.hiddenCommunityWelcomeBanners || []
            if (hiddenBannerIds.includes(root.activeCommunity.id)) {
                return
            }
            hiddenBannerIds.push(root.activeCommunity.id)
            localAccountSensitiveSettings.hiddenCommunityWelcomeBanners = hiddenBannerIds
        }
    }

    StatusBaseText {
        id: welcomeText
        text: qsTr("Welcome to your community!")
        anchors.top: parent.top
        anchors.topMargin: 60
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 15
        color: Theme.palette.directColor1
        wrapMode: Text.WordWrap
        anchors.right: parent.right
        anchors.rightMargin: Style.current.xlPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.xlPadding
    }

    StatusQControls.StatusButton {
        id: addMembersBtn
        text: qsTr("Add members")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: manageBtn.top
        anchors.bottomMargin: Style.current.halfPadding
        onClicked: Global.openPopup(Global.inviteFriendsToCommunityPopup, {
            community: root.activeCommunity,
            hasAddedContacts: root.hasAddedContacts,
            communitySectionModule: root.communitySectionModule
        })
    }

    StatusQControls.StatusFlatButton {
        id: manageBtn
        text: qsTr("Manage community")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding

        onClicked: root.manageCommunityClicked()
    }
}
