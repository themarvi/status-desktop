import QtQuick 2.12

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0
import "../stores"

StatusInput {
    id: privateKey

    function resetMe() {
        _internal.errorString = ""
        privateKey.text = ""
        privateKey.reset()
        reset()
    }

    function validateMe()  {
        if (privateKey.text === "") {
            _internal.errorString = qsTr("You need to enter a private key")
        } else if (!Utils.isPrivateKey(privateKey.text)) {
            _internal.errorString = qsTr("Enter a valid private key (64 characters hexadecimal string)")
        } else {
            _internal.errorString = ""
        }
        return _internal.errorString === ""
    }

    QtObject {
        id: _internal
        property int privateKeyCharLimit: 66
        property string errorString: ""
    }

    label: qsTr("Private key")
    charLimit: _internal.privateKeyCharLimit
    input.multiline: true
    input.minimumHeight: 80
    input.maximumHeight: 108
    input.placeholderText: qsTr("Paste the contents of your private key")
    errorMessage: _internal.errorString
    validators: [
        StatusMinLengthValidator {
            minLength: 1
            errorMessage: qsTr("You need to enter a private key")
        },
        StatusValidator {
            property var validate: function (value) {
                return Utils.isPrivateKey(value)
            }
            errorMessage: qsTr("Enter a valid private key (64 characters hexadecimal string)")
        }
    ]
    onVisibleChanged:  {
        if(visible)
            privateKey.input.edit.forceActiveFocus();
    }
}


