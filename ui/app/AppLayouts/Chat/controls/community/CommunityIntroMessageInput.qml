import QtQuick 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

StatusInput {
    id: root

    leftPadding: 0
    rightPadding: 0
    label: qsTr("Community introduction and rules")
    charLimit: 1400

    input.multiline: true
    input.implicitHeight: 400

    input.placeholder.text: qsTr("What new members will read before joining (eg. community rules, welcome message, etc.). Members will need to tick a check box agreeing to these rules before they are allowed to join your community.")
    input.placeholder.wrapMode: Text.WordWrap

    input.verticalAlignment: TextEdit.AlignTop

    validators: [
        StatusMinLengthValidator {
            minLength: 1
            errorMessage: Utils.getErrorMessage(root.errors,
                                                qsTr("community intro message"))
        }
    ]
    validationMode: StatusInput.ValidationMode.Always
}
