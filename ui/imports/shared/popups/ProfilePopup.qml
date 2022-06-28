import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.stores 1.0
import shared.controls.chat 1.0
import shared.panels 1.0
import shared.views.chat 1.0


import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: popup

    property Popup parentPopup

    property var profileStore
    property var contactsStore

    property string userPublicKey: ""
    property string userDisplayName: ""
    property string userName: ""
    property string userNickname: ""
    property string userEnsName: ""
    property string userIcon: ""
    property int userTrustStatus: Constants.trustStatus.unknown
    property int verificationStatus: Constants.verificationStatus.unverified
    property string text: ""
    property string challenge: ""
    property string response: ""

    property bool userIsEnsVerified: false
    property bool userIsBlocked: false
    property bool userIsUntrustworthy: false
    property bool userTrustIsUnknown: false
    property bool isCurrentUser: false
    property bool isAddedContact: false
    property bool isMutualContact: false
    property bool isVerificationSent: false
    property bool isVerified: false
    property bool isTrusted: false
    property bool hasReceivedVerificationRequest: false

    property bool showRemoveVerified: false
    property bool showVerifyIdentitySection: false
    property bool showVerificationPendingSection: false
    property bool showIdentityVerified: false
    property bool showIdentityVerifiedUntrustworthy: false

    property string verificationChallenge: ""
    property string verificationResponse: ""
    property string verificationResponseDisplayName: ""
    property string verificationResponseIcon: ""
    property string verificationRequestedAt: ""
    property string verificationRepliedAt: ""

    readonly property int animationDuration: 500

    signal blockButtonClicked(name: string, address: string)
    signal unblockButtonClicked(name: string, address: string)
    signal removeButtonClicked(address: string)

    signal contactUnblocked(publicKey: string)
    signal contactBlocked(publicKey: string)

    function openPopup(publicKey, state = "") {
        // All this should be improved more, but for now we leave it like this.
        let contactDetails = Utils.getContactDetailsAsJson(publicKey);
        userPublicKey = publicKey;
        userDisplayName = contactDetails.displayName;
        userName = contactDetails.alias;
        userNickname = contactDetails.localNickname;
        userEnsName = contactDetails.name;
        userIcon = contactDetails.displayIcon;
        userIsEnsVerified = contactDetails.ensVerified;
        userIsBlocked = contactDetails.isBlocked;
        isAddedContact = contactDetails.isContact;
        isMutualContact = contactDetails.isContact && contactDetails.hasAddedUs
        userTrustStatus = contactDetails.trustStatus
        userTrustIsUnknown = contactDetails.trustStatus === Constants.trustStatus.unknown
        userIsUntrustworthy = contactDetails.trustStatus === Constants.trustStatus.untrustworthy
        verificationStatus = contactDetails.verificationStatus
        isVerificationSent = verificationStatus !== Constants.verificationStatus.unverified

        if (isMutualContact && popup.contactsStore.hasReceivedVerificationRequestFrom(publicKey)) {
            popup.hasReceivedVerificationRequest = true
        }

        if(isMutualContact && isVerificationSent) {
            let verificationDetails = popup.contactsStore.getSentVerificationDetailsAsJson(publicKey);

            verificationStatus = verificationDetails.requestStatus;
            verificationChallenge = verificationDetails.challenge;
            verificationResponse = verificationDetails.response;
            verificationResponseDisplayName = verificationDetails.displayName;
            verificationResponseIcon = verificationDetails.icon;
            verificationRequestedAt = verificationDetails.requestedAt;
            verificationRepliedAt = verificationDetails.repliedAt;
        }
        isTrusted = verificationStatus === Constants.verificationStatus.trusted
        isVerified = verificationStatus === Constants.verificationStatus.verified

        text = ""; // this is most likely unneeded
        isCurrentUser = popup.profileStore.pubkey === publicKey;
        showFooter = !isCurrentUser;
        popup.open();

        if (state == "openNickname") {
            nicknamePopup.open();
        } else if (state == "contactRequest") {
            sendContactRequestModal.open()
        } else if (state == "blockUser") {
            blockUser();
        } else if (state == "unblockUser") {
            unblockUser();
        }
    }

    SequentialAnimation {
        id: wizardAnimation
        ScriptAction {
            id: step1
            property int loadingTime: 0
            Behavior on loadingTime { NumberAnimation { duration: animationDuration }}
            onLoadingTimeChanged: {
                if (isVerificationSent) {
                    stepsListModel.setProperty(1, "loadingTime", step1.loadingTime);
                }
            }
            script: {
                step1.loadingTime = animationDuration;
                stepsListModel.setProperty(0, "loadingTime", step1.loadingTime);

                if (isVerificationSent) {
                    stepsListModel.setProperty(0, "stepCompleted", true);
                }
            }
        }
        PauseAnimation {
            duration: animationDuration + 100
        }
        ScriptAction {
            id: step2
            property int loadingTime: 0
            Behavior on loadingTime { NumberAnimation { duration: animationDuration } }
            onLoadingTimeChanged: {
                if (isVerificationSent && !!verificationResponse) {
                    stepsListModel.setProperty(2, "loadingTime", step2.loadingTime);
                }
            }
            script: {
                if (isVerificationSent && !!verificationChallenge) {
                    step2.loadingTime = animationDuration;
                    if (isVerificationSent && !!verificationResponse) {
                        stepsListModel.setProperty(1, "stepCompleted", true);
                    }
                }
            }
        }
        PauseAnimation {
            duration: animationDuration + 100
        }
        ScriptAction {
            script: {
                if (verificationStatus === Constants.verificationStatus.trusted) {
                    stepsListModel.setProperty(2, "stepCompleted", true);
                }
            }
        }
    }

    function blockUser() {
        contentItem.blockContactConfirmationDialog.contactName = userName;
        contentItem.blockContactConfirmationDialog.contactAddress = userPublicKey;
        contentItem.blockContactConfirmationDialog.open();
    }

    function unblockUser() {
        contentItem.unblockContactConfirmationDialog.contactName = userName;
        contentItem.unblockContactConfirmationDialog.contactAddress = userPublicKey;
        contentItem.unblockContactConfirmationDialog.open();
    }

    width: 700

    header.title: {
        if(showVerifyIdentitySection || showVerificationPendingSection){
            return qsTr("Verify %1's Identity").arg(userIsEnsVerified ? userName : userDisplayName)
        }
        return qsTr("%1's Profile").arg(userIsEnsVerified ? userName : userDisplayName)
    }
    header.subTitle: userIsEnsVerified ? userName : Utils.getElidedCompressedPk(userPublicKey)
    header.subTitleElide: Text.ElideMiddle

    QtObject {
        id: d

        readonly property int contentSpacing: 5
        readonly property int contentMargins: 16
    }

    headerActionButton:  StatusFlatRoundButton {
        type: StatusFlatRoundButton.Type.Secondary
        width: 32
        height: 32

        icon.width: 20
        icon.height: 20
        icon.name: "qr"
        onClicked: contentItem.qrCodePopup.open()
    }

    Component {
        id: contactTopComponent

        ProfileHeader {
            displayName: popup.userDisplayName
            pubkey: popup.userPublicKey
            icon: popup.isCurrentUser ? popup.profileStore.icon : popup.userIcon

            trustStatus: popup.userTrustStatus
            isContact: isAddedContact
            store: profileStore
            displayNameVisible: false
            pubkeyVisible: false
            compact: false
            displayNamePlusIconsVisible: true
            pubkeyVisibleWithCopy: true
            onEditClicked: {
                if(!isCurrentUser){
                    nicknamePopup.open()
                } else {
                    Global.openEditDisplayNamePopup()
                }
            }

            imageOverlay: Item {
                visible: popup.isCurrentUser

                StatusFlatRoundButton {
                    width: 24
                    height: 24

                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        rightMargin: -8
                    }

                    type: StatusFlatRoundButton.Type.Secondary
                    icon.name: "pencil"
                    icon.color: Theme.palette.directColor1
                    icon.width: 12.5
                    icon.height: 12.5

                    onClicked: Global.openChangeProfilePicPopup()
                }
            }
        }
    }

    contentItem: ColumnLayout {
        id: modalContent

        property alias qrCodePopup: qrCodePopup
        property alias unblockContactConfirmationDialog: unblockContactConfirmationDialog
        property alias blockContactConfirmationDialog: blockContactConfirmationDialog
        property alias removeContactConfirmationDialog: removeContactConfirmationDialog

        anchors.left: parent.left
        anchors.right: parent.right
        spacing: d.contentSpacing

        clip: true

        Item {
            implicitHeight: 32
            Layout.fillWidth: true
        }

        Loader {
            sourceComponent: contactTopComponent
            Layout.fillWidth: true
        }

        StatusBanner {
            visible: popup.userIsBlocked
            type: StatusBanner.Type.Danger
            statusText: qsTr("Blocked")
            Layout.fillWidth: true
        }

        ListModel {
            id: stepsListModel
            ListElement {description:"Send Request"; loadingTime: 0; stepCompleted: false}
            ListElement {description:"Receive Response"; loadingTime: 0; stepCompleted: false}
            ListElement {description:"Confirm Identity"; loadingTime: 0; stepCompleted: false}
        }

        StatusWizardStepper {
            id: wizardStepper
            maxDuration: animationDuration
            visible: showVerifyIdentitySection || showVerificationPendingSection || showIdentityVerified || showIdentityVerifiedUntrustworthy
            width: parent.width
            stepsModel: stepsListModel
        }

        Separator {
            visible: wizardStepper.visible
            implicitHeight: 32
        }

        StatusBaseText {
            id: confirmLbl
            visible: showIdentityVerified
            text: qsTr("You have confirmed %1's identity. From now on this verification emblem will always be displayed alongside %1's nickname.").arg(userIsEnsVerified ? userEnsName : userDisplayName)
            font.pixelSize: Style.current.additionalTextSize
            horizontalAlignment : Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 363
            wrapMode: Text.WordWrap
            color: Theme.palette.baseColor1
        }
        

        StatusBaseText {
            id: confirmUntrustworthyLbl
            visible: showIdentityVerifiedUntrustworthy
            text: qsTr("You have marked %1 as Untrustworthy. From now on this Untrustworthy emblem will always be displayed alongside %1's nickname.").arg(userIsEnsVerified ? userEnsName : userDisplayName)
            font.pixelSize: Style.current.additionalTextSize
            horizontalAlignment : Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 363
            wrapMode: Text.WordWrap
            color: Theme.palette.baseColor1
        }

        Item {
            visible: checkboxIcon.visible || dangerIcon.visible
            height: visible ? 16 : 0
            width: parent.width
        }

        StatusRoundIcon {
            id: checkboxIcon
            visible: confirmLbl.visible
            icon.name: "checkbox"
            icon.width: 16
            icon.height: 16
            icon.color: Theme.palette.white
            Layout.alignment: Qt.AlignHCenter
            color: Theme.palette.primaryColor1
            width: 32
            height: 32
        }

        StatusRoundIcon {
            id: dangerIcon
            visible: confirmUntrustworthyLbl.visible
            icon.name: "tiny/subtract"
            icon.width: 5
            icon.height: 21
            icon.color: Theme.palette.white
            Layout.alignment: Qt.AlignHCenter
            color: Theme.palette.dangerColor1
            width: 32
            height: 32
        }

        Item {
            visible: checkboxIcon.visible || dangerIcon.visible
            height: visible ? 16 : 0
            Layout.fillWidth: true
        }

        StatusInput {
            id: challengeTxt
            visible: showVerifyIdentitySection
            charLimit: 280
            input.text: popup.challenge
            Layout.fillWidth: true
            Layout.rightMargin: d.contentMargins
            Layout.leftMargin: d.contentMargins
            input.multiline: true
            input.implicitHeight: 152
            input.placeholderText: qsTr("Ask a question that only the real %1 will be able to answer e.g. a question about a shared experience, or ask Mark to enter a code or phrase you have sent to them via a different communication channel (phone, post, etc...).").arg(userIsEnsVerified ? userEnsName : userDisplayName)
        }

        MessageView {
            id: challengeMessage
            visible: showVerificationPendingSection
            Layout.fillWidth: true
            isMessage: true
            shouldRepeatHeader: true
            messageTimestamp: popup.verificationRequestedAt
            senderDisplayName: userProfile.name
            senderIcon: userProfile.icon
            message: popup.verificationChallenge
            messageContentType: Constants.messageContentType.messageType
            placeholderMessage: true
        }

        MessageView {
            id: responseMessage
            visible: showVerificationPendingSection && !!verificationResponse
            width: parent.width
            isMessage: true
            shouldRepeatHeader: true
            messageTimestamp: popup.verificationRepliedAt
            senderDisplayName: popup.verificationResponseDisplayName
            senderIcon: popup.verificationResponseIcon
            message: popup.verificationResponse
            messageContentType: Constants.messageContentType.messageType
            placeholderMessage: true
        }


        Item {
            height: 32
            Layout.fillWidth: true
        }
    }

    // TODO: replace with StatusStackModal
    ModalPopup {
        id: qrCodePopup
        width: 320
        height: 320
        Image {
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            source: globalUtils.qrCode(userPublicKey)
            anchors.horizontalCenter: parent.horizontalCenter
            height: 212
            width: 212
            mipmap: true
            smooth: false
        }
    }

    UnblockContactConfirmationDialog {
        id: unblockContactConfirmationDialog
        onUnblockButtonClicked: {
            popup.contactsStore.unblockContact(userPublicKey)
            unblockContactConfirmationDialog.close();
            popup.close()
            popup.contactUnblocked(userPublicKey)
        }
    }

    BlockContactConfirmationDialog {
        id: blockContactConfirmationDialog
        onBlockButtonClicked: {
            popup.contactsStore.blockContact(userPublicKey)
            blockContactConfirmationDialog.close();
            popup.close()

            popup.contactBlocked(userPublicKey)
        }
    }

    ConfirmationDialog {
        id: removeContactConfirmationDialog
        header.title: qsTr("Remove contact")
        confirmationText: qsTr("Are you sure you want to remove this contact?")
        onConfirmButtonClicked: {
            if (isAddedContact) {
                popup.contactsStore.removeContact(userPublicKey);
            }
            removeContactConfirmationDialog.close();
            popup.close();
        }
    }

    NicknamePopup {
        id: nicknamePopup
        nickname: popup.userNickname
        header.subTitle: popup.header.subTitle
        header.subTitleElide: popup.header.subTitleElide
        onEditDone: {
            if(popup.userNickname !== newNickname)
            {
                popup.userNickname = newNickname;
                popup.contactsStore.changeContactNickname(userPublicKey, newNickname);
            }
            popup.close()
        }
    }

    // TODO: replace with StatusStackModal
    SendContactRequestModal {
        id: sendContactRequestModal
        anchors.centerIn: parent
        width: popup.width
        visible: false
        header.title: qsTr("Send Contact Request to") + " " + userDisplayName
        topComponent: contactTopComponent
        onAccepted: popup.contactsStore.sendContactRequest(userPublicKey, message)
        onClosed: popup.close()
    }
    
    leftButtons:[
        StatusButton {
            text: qsTr("Cancel verification")
            visible: !isVerified && isMutualContact && isVerificationSent && showVerificationPendingSection
            onClicked: {
                popup.contactsStore.cancelVerificationRequest(userPublicKey);
                popup.close()
            }
        }
    ]

    rightButtons: [
        StatusFlatButton {
            text: userIsBlocked ?
                qsTr("Unblock User") :
                qsTr("Block User")
            type: StatusBaseButton.Type.Danger
            visible: !isAddedContact
            onClicked: userIsBlocked ? unblockUser() : blockUser()
        },

        StatusFlatButton {
            visible:  !showRemoveVerified && !showIdentityVerified && !showVerifyIdentitySection && !showVerificationPendingSection && !userIsBlocked && isAddedContact
            type: StatusBaseButton.Type.Danger
            text: qsTr('Remove Contact')
            onClicked: {
                contentItem.removeContactConfirmationDialog.parentPopup = popup;
                contentItem.removeContactConfirmationDialog.open();
            }
        },

        StatusButton {
            text: qsTr("Send Contact Request")
            visible: !userIsBlocked && !isAddedContact
            onClicked: sendContactRequestModal.open()
        },

        StatusButton {
            text: qsTr("Mark Untrustworthy")
            visible:!showIdentityVerifiedUntrustworthy && !showIdentityVerified && !showVerifyIdentitySection && userTrustIsUnknown
            enabled: !showVerificationPendingSection || verificationResponse !== ""
            type: StatusBaseButton.Type.Danger
            onClicked: {
                if (showVerificationPendingSection) {
                    popup.showIdentityVerified = false;
                    popup.showIdentityVerifiedUntrustworthy = true;
                    popup.showVerificationPendingSection = false;
                    popup.showVerifyIdentitySection = false;
                    stepsListModel.setProperty(2, "stepCompleted", true);
                    popup.contactsStore.verifiedUntrustworthy(userPublicKey);
                } else {
                    popup.contactsStore.markUntrustworthy(userPublicKey);
                    popup.close();
                }
            }
        },

        StatusButton {
            text: qsTr("Remove 'Identity Verified' status")
            visible: isTrusted && !showIdentityVerified && !showRemoveVerified
            type: StatusBaseButton.Type.Danger
            onClicked: {
                showRemoveVerified = true
            }
        },

        StatusButton {
            text: qsTr("No")
            visible: showRemoveVerified
            type: StatusBaseButton.Type.Danger
            onClicked: {
                showRemoveVerified = false
            }
        },

        StatusButton {
            text: qsTr("Yes")
            visible: showRemoveVerified
            onClicked: {
                popup.contactsStore.removeTrustStatus(userPublicKey);
                popup.close();
            }
        },

        StatusButton {
            text: qsTr("Remove Untrustworthy Mark")
            visible: userIsUntrustworthy
            onClicked: {
                popup.contactsStore.removeTrustStatus(userPublicKey);
                popup.close();
            }
        },

        StatusButton {
            text: qsTr("Verify Identity")
            visible: !showIdentityVerifiedUntrustworthy && !showIdentityVerified &&
                !showVerifyIdentitySection && isMutualContact  && !isVerificationSent
                && !hasReceivedVerificationRequest
            onClicked: {
                popup.showVerifyIdentitySection = true
            }
        },

        StatusButton {
            text: qsTr("Verify Identity pending...")
            visible: (!showIdentityVerifiedUntrustworthy && !showIdentityVerified && !isTrusted
                && isMutualContact && isVerificationSent && !showVerificationPendingSection) ||
                (hasReceivedVerificationRequest && !isTrusted)
            onClicked: {
                if (hasReceivedVerificationRequest) {
                    try {
                        let request = popup.contactsStore.getVerificationDetailsFromAsJson(popup.userPublicKey)
                        Global.openPopup(contactVerificationRequestPopupComponent, {
                            senderPublicKey: request.from,
                            senderDisplayName: request.displayName,
                            senderIcon: request.icon,
                            challengeText: request.challenge,
                            responseText: request.response,
                            messageTimestamp: request.requestedAt,
                            responseTimestamp: request.repliedAt
                        })
                    } catch (e) {
                        console.error("Error getting or parsing verification data", e)
                    }
                } else {
                    popup.showVerificationPendingSection = true
                    wizardAnimation.running = true
                }
            }
        },


        StatusButton {
            text: qsTr("Send verification request")
            visible: showVerifyIdentitySection && isMutualContact  && !isVerificationSent
            onClicked: {
                popup.contactsStore.sendVerificationRequest(userPublicKey, Utils.escapeHtml(challengeTxt.input.text));
                stepsListModel.setProperty(1, "stepCompleted", true);
                Global.displayToastMessage(qsTr("Verification request sent"),
                                       "",
                                       "checkmark-circle",
                                       false,
                                       Constants.ephemeralNotificationType.normal,
                                       "");
                popup.close();
            }
        },

        StatusButton {
            text: qsTr("Confirm Identity")
            visible: isMutualContact  && isVerificationSent && isVerified && !isTrusted && showVerificationPendingSection
            enabled: verificationChallenge !== "" && verificationResponse !== ""
            onClicked: {
                popup.showIdentityVerified = true;
                popup.showIdentityVerifiedUntrustworthy = false;
                popup.showVerificationPendingSection = false;
                popup.showVerifyIdentitySection = false;
                stepsListModel.setProperty(2, "stepCompleted", true);
                popup.contactsStore.verifiedTrusted(userPublicKey);
                popup.isTrusted = true
            }
        },

        StatusButton {
            visible: showIdentityVerified || showIdentityVerifiedUntrustworthy
            text: qsTr("Rename")
            onClicked: {
                nicknamePopup.open()
            }
        },

        StatusButton {
            visible: showIdentityVerified || showIdentityVerifiedUntrustworthy
            text: qsTr("Close")
            onClicked: {
                popup.close();
            }
        }
    ]

    Component {
        id: contactVerificationRequestPopupComponent
        ContactVerificationRequestPopup {
            onResponseSent: {
                popup.contactsStore.acceptVerificationRequest(senderPublicKey, response)
            }
            onVerificationRefused: {
                popup.contactsStore.declineVerificationRequest(senderPublicKey)
            }
        }
    }
}
