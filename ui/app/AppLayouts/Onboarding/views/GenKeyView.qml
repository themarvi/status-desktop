import QtQuick 2.13

import "../popups"
import "../stores"
import "../shared"

Item {
    property var onClosed: function () {}
    id: genKeyView
    anchors.fill: parent

    Component.onCompleted: {
        genKeyModal.open()
    }

    GenKeyModal {
        property bool wentNext: false
        id: genKeyModal
        onNextClick: function (selectedIndex, displayName) {
            wentNext = true
            OnboardingStore.setCurrentAccountAndDisplayName(selectedIndex, displayName)
            createPasswordModal.open()
        }
        onClosed: function () {
            if (!wentNext) {
                genKeyView.onClosed()
            }
        }
    }

    CreatePasswordModal {
        id: createPasswordModal
        onClosed: function () {
            genKeyView.onClosed()
        }
    }
}
