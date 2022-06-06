import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import shared.panels 1.0
import "../controls"
import "../stores"

import utils 1.0

OnboardingBasePage {
    id: root

    property KeycardStore keycardStore

    Component.onCompleted: {
        keycardStore.startKeycardFlow()
    }

    QtObject {
        id: d
        readonly property string pluginKeycardState: "pluginKeycardState"
        readonly property string insertKeycardState: "insertKeycardState"
        readonly property string readingKeycardState: "readingKeycardState"

        property int index: 0
        property variant images : [
            Style.svg("keycard/card0@2x"),
            Style.svg("keycard/card1@2x"),
            Style.svg("keycard/card2@2x"),
            Style.svg("keycard/card3@2x")
        ]
    }

    Timer {
        interval: 400
        running: true
        repeat: true
        onTriggered: {
            d.index++
        }
    }

    ColumnLayout {
        anchors.centerIn: parent

        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: sourceSize.height
            Layout.preferredWidth: sourceSize.width
            fillMode: Image.PreserveAspectFit
            antialiasing: true
            source: d.images[d.index % d.images.length]
            mipmap: true
        }

        StyledText {
            id: title
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            font.bold: true
            font.letterSpacing: -0.2
        }
    }

    states: [
        State {
            name: d.pluginKeycardState
            when: keycardStore.keycardModule.flowState === d.pluginKeycardState
            PropertyChanges {
                target: title
                text: qsTrId("Plug in Keycard reader...")
                font.pixelSize: 22
                color: Style.current.textColor
            }
        },
        State {
            name: d.insertKeycardState
            when: keycardStore.keycardModule.flowState === d.insertKeycardState
            PropertyChanges {
                target: title
                text: qsTrId("Insert your Keycard...")
                font.pixelSize: 22
                color: Style.current.textColor
            }
        },
        State {
            name: d.readingKeycardState
            when: keycardStore.keycardModule.flowState === d.readingKeycardState
            PropertyChanges {
                target: title
                text: qsTr("Reading Keycard...")
                font.pixelSize: 15
                color: Style.current.secondaryText
            }
        }
    ]
}
