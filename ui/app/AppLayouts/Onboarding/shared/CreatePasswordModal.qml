import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3

import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls 1.0

import "../stores"

// TODO: replace with StatusModal
ModalPopup {
    property var privacyStore
    property bool loading: false
    property bool firstPasswordFieldValid: false
    property bool repeatPasswordFieldValid: false
    property string passwordValidationError: ""
    property string repeatPasswordValidationError: ""

    signal offerToStorePassword(string password, bool runStoreToKeychainPopup)

    id: popup
    title: qsTr("Store password")
    height: 500

    onOpened: {
        firstPasswordField.text = "";
        firstPasswordField.forceActiveFocus(Qt.MouseFocusReason)
    }

    Input {
        id: firstPasswordField
        anchors.rightMargin: 56
        anchors.leftMargin: 56
        anchors.top: parent.top
        anchors.topMargin: Style.current.xlPadding
        placeholderText: qsTr("Current password...")
        textField.echoMode: TextInput.Password
        onTextChanged: {
            [firstPasswordFieldValid, passwordValidationError] =
                Utils.validatePasswords("first", firstPasswordField, repeatPasswordField);
            [repeatPasswordFieldValid, repeatPasswordValidationError] =
                Utils.validatePasswords("repeat", firstPasswordField, repeatPasswordField);
        }
    }

    Input {
        id: repeatPasswordField
        enabled: firstPasswordFieldValid
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        anchors.right: firstPasswordField.right
        anchors.left: firstPasswordField.left
        anchors.top: firstPasswordField.bottom
        anchors.topMargin: Style.current.xlPadding
        placeholderText: qsTr("Confirm password…")
        textField.echoMode: TextInput.Password
        Keys.onReturnPressed: function(event) {
            if (submitBtn.enabled) {
                submitBtn.clicked(event)
            }
        }
        onTextChanged: {
            [repeatPasswordFieldValid, repeatPasswordValidationError] =
                Utils.validatePasswords("repeat", firstPasswordField, repeatPasswordField);
        }
    }

    StyledText {
        id: validationError
        text: {
            if (passwordValidationError !== "") return passwordValidationError;
            if (repeatPasswordValidationError !== "") return repeatPasswordValidationError;
            return "";
        }
        anchors.top: repeatPasswordField.bottom
        anchors.topMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: Style.current.xlPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.xlPadding
        horizontalAlignment: Text.AlignHCenter
        color: Style.current.danger
        font.pixelSize: 11
    }

    footer: Item {
        width: parent.width
        height: submitBtn.height

        StatusButton {
            id: submitBtn
            anchors.bottom: parent.bottom
            anchors.topMargin: Style.current.padding
            anchors.right: parent.right
            state: loading ? "pending" : "default"

            text: qsTr("Store password")

            enabled: firstPasswordFieldValid && repeatPasswordFieldValid && !loading

            MessageDialog {
                id: importError
                title: qsTr("Error importing account")
                text: qsTr("An error occurred while importing your account: ")
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
                onVisibilityChanged: {
                    loading = false
                }
            }

            MessageDialog {
                id: importLoginError
                title: qsTr("Login failed")
                text: qsTr("Login failed. Please re-enter your password and try again.")
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
                onVisibilityChanged: {
                    loading = false
                }
            }

            onClicked: {
                // validate the entered password
                var validatePassword = privacyStore.validatePassword(repeatPasswordField.text)
                if(!validatePassword) {
                    firstPasswordFieldValid = false
                    passwordValidationError = qsTr("Incorrect password")
                }
                else {
                    popup.offerToStorePassword(repeatPasswordField.text, true)
                    popup.close()
                }
            }
        }
    }
}
