import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0

import "../panels"

SettingsContentBase {
    id: root

    ColumnLayout {
        spacing: Constants.settingsSection.itemSpacing
        width: root.contentWidth

        GlossaryEntry {
            id: entryAccount
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            name: qsTr("Account")
            //: This letter corresponds to the section title above, so here it is "A" because the title above is "Account"
            letter: qsTr("A")
            description: qsTr("Your Status account, accessed by the seed phrase that you create or import during onboarding. A Status account can hold more than one Ethereum address, in addition to the one created during onboarding. We refer to these as additional accounts within the wallet")
        }

        GlossaryEntry {
            id: entryChatKey
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            name: qsTr("Chat Key")
            //: This letter corresponds to the section title above, so here it is "C" because the title above is "Chat Key"
            letter: qsTr("C")
            description: qsTr("Messages on the Status chat protocol are sent and received using encryption keys. The public chat key is a string of characters you share with others so they can send you messages in Status.")
        }

        GlossaryEntry {
            id: entryChatName
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            name: qsTr("Chat Name")
            description: qsTr("Three random words, derived algorithmically from your chat key and used as your default alias in chat. Chat names are completely unique; no other user can have the same three words.")
        }

        GlossaryEntry {
            id: entryENSName
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            name: qsTr("ENS Name")
            //: This letter corresponds to the section title above, so here it is "E" because the title above is "ENS Name"
            letter: qsTr("E")
            description: qsTr("Custom alias for your chat key that you can register using the Ethereum Name Service. ENS names are decentralized usernames.")
        }

        GlossaryEntry {
            id: entryMailserver
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            name: qsTr("Mailserver")
            //: This letter corresponds to the section title above, so here it is "M" because the title above is "Mailserver"
            letter: qsTr("M")
            description: qsTr("A node in the Status network that routes and stores messages, for up to 30 days.")
        }

        GlossaryEntry {
            id: entryPeer
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            name: qsTr("Peer")
            //: This letter corresponds to the section title above, so here it is "P" because the title above is "Peer"
            letter: qsTr("P")
            description: qsTr("A device connected to the Status chat network. Each user can represent one or more peers, depending on their number of devices")
        }

        GlossaryEntry {
            id: entrySeedPhrase
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            name: qsTr("Seed Phrase")
            //: This letter corresponds to the section title above, so here it is "S" because the title above is "Seed Phrase"
            letter: qsTr("S")
            description: qsTr("A 64 character hex address based on the Ethereum standard and beginning with 0x. Public-facing, your wallet key is shared with others when you want to receive funds. Also referred to as an “Ethereum address” or “wallet address.")
        }

        StatusBaseText {
            id: faqLink
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            text: qsTr("Frequently asked questions")
            font.pixelSize: 15
            color: Theme.palette.primaryColor1

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: {
                    parent.font.underline = true
                }
                onExited: {
                    parent.font.underline = false
                }
                onClicked: {
                    Global.openLink("https://status.im/docs/FAQs.html")
                }
            }
        }
        StatusBaseText {
            id: issueLink
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            text: qsTr("Submit a bug")
            font.pixelSize: 15
            color: Theme.palette.primaryColor1

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: {
                    parent.font.underline = true
                }
                onExited: {
                    parent.font.underline = false
                }
                onClicked: {
                    Global.openLink("https://github.com/status-im/nim-status-client/issues/new")
                }
            }
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            text: qsTr("Request a feature")
            font.pixelSize: 15
            color: Theme.palette.primaryColor1

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: {
                    parent.font.underline = true
                }
                onExited: {
                    parent.font.underline = false
                }
                onClicked: {
                    Global.openLink("https://discuss.status.im/c/features/51")
                }
            }
        }

    }
}

