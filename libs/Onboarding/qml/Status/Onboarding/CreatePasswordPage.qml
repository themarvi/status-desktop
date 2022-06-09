import QtQuick
import QtQuick.Controls

import Status.Onboarding

import "base"

SetupNewProfilePageBase {
    id: root

    TempTextInput {
        id: passwordInput

        text: newAccountController.password
        Binding {
            target: newAccountController
            property: "password"
            value: passwordInput.text
        }

        width: 416
        height: 44

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: alignmentItem.top
            bottomMargin: 112
        }

        font.pointSize: 23
        verticalAlignment: TextInput.AlignVCenter
    }

    TempTextInput {
        id: confirmPasswordInput

        text: newAccountController.confirmationPassword
        Binding {
            target: newAccountController
            property: "confirmationPassword"
            value: confirmPasswordInput.text
        }

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

    Button {
        text: qsTr("Create Password")

        anchors.horizontalCenter: alignmentItem.horizontalCenter
        anchors.top: alignmentItem.bottom
        anchors.topMargin: 125

        enabled: newAccountController.passwordIsValid && newAccountController.confirmationPasswordIsValid

        onClicked: root.pageDone()
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
