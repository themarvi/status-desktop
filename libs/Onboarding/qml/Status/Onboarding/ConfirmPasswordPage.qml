import QtQuick
import QtQuick.Controls

import Status.Onboarding

import "base"

SetupNewProfilePageBase {
    id: root

    TempTextInput {
        id: confirmPasswordInput

        text: qsTr("1234567890")

        width: 416
        height: 44

        anchors {
            horizontalCenter: alignmentItem.horizontalCenter
            verticalCenter: alignmentItem.verticalCenter
            verticalCenterOffset: -baselineOffset
        }

        font.pointSize: 23
        verticalAlignment: TextInput.AlignVCenter
    }

    Label {
        id: errorLabel

        anchors {
            bottom: finalizeButton.top
            horizontalCenter: finalizeButton.horizontalCenter
            margins: 10
        }

        color: "red"
        text: qsTr("Something went wrong")
        visible: false
    }

    Button {
        id: finalizeButton
        text: qsTr("Finalize Status Password Creation")

        anchors {
            horizontalCenter: alignmentItem.horizontalCenter
            top: alignmentItem.bottom
            topMargin: 125
        }

        enabled: confirmPasswordInput.text === newAccountController.password

        onClicked: {
            // TODO have states to drive async creation
            errorLabel.visible = false
            finalizeButton.enabled = false
            bussyIndicatorMouseArea.enabled = true

            newAccountController.createAccount()
        }
    }

    Connections {
        target: newAccountController
        function onAccountCreatedAndLoggedIn() {
            bussyIndicatorMouseArea.enabled = false
            root.pageDone()
        }
        function onAccountCreationError() {
            errorLabel.visible = true;
            bussyIndicatorMouseArea.enabled = false
        }
    }

    MouseArea {
        id: bussyIndicatorMouseArea

        anchors.fill: parent

        acceptedButtons: Qt.NoButton
        enabled: false
        cursorShape: Qt.BusyCursor
    }

    component TempTextInput: TextInput {
        width: 416
        height: 44

        font.pointSize: 23
        verticalAlignment: TextInput.AlignVCenter

        Rectangle {
            anchors {
                fill: parent
                margins: -1
            }
            border.width: 1
            z: parent.z - 1
        }
    }
}
