import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Status.Containers

import "base"

OnboardingPageBase {
    id: root

    signal setupNewAccount()

    backAvailable: false

    ColumnLayout {
        anchors {
            centerIn: parent
            verticalCenterOffset: -117
        }

        Label {
            text: qsTr("Welcome to Status")
        }

        LayoutSpacer {
            Layout.preferredHeight: 103
        }

        Button {
            text: qsTr("I am new to Status")
            onClicked: root.setupNewAccount()
        }
    }
}
