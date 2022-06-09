import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Status.Containers

import "base"

OnboardingPageBase {
    id: root

    ColumnLayout {
        anchors {
            centerIn: parent
            verticalCenterOffset: 50
        }

        Label {
            text: qsTr("Welcome back")
            Layout.alignment: Qt.AlignHCenter
        }

        LayoutSpacer {
            Layout.preferredHeight: 210
        }
    }

    component TempTextInput: TextInput {
        width: 328
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
