import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

StatusScrollView {
    id: root

    property string title: qsTr("Community Colour")

    property var rightButtons: StatusButton {
        text: qsTr("Select Community Colour")
        onClicked: root.accepted()
    }

    property alias color: colorSpace.color

    signal accepted()

    onColorChanged: {
        if (!hexInput.locked)
            hexInput.text = color.toString();

        if (colorSelectionGrid.selectedColor != color)
            colorSelectionGrid.selectedColorIndex = -1;
    }

    Component.onCompleted: {
        hexInput.text = color.toString();
    }

    padding: 0

    ColumnLayout {
        id: column
        width: root.availableWidth
        spacing: 12

        StatusColorSpace {
            id: colorSpace

            property real hueFactor: Math.max(rootColor.g + rootColor.b * 0.4,
                                                rootColor.g + rootColor.r * 0.6)

            minSaturate: Math.max(0.4, hueFactor * 0.55)
            maxSaturate: 1.0
            minValue: 0.4
            // Curve to pick colors readable with white text
            maxValue: Math.min(1.0, 1.65 - hueFactor * 0.5)
            Layout.alignment: Qt.AlignHCenter
        }

        StatusInput {
            id: hexInput

            property color newColor: text
            // TODO: editingFinished() signal instead of this crutch
            property bool locked: false

            implicitWidth: 256
            validators: [
                StatusRegularExpressionValidator {
                    regularExpression: /^#(?:[0-9a-fA-F]{3}){1,2}$/
                    errorMessage: qsTr("This is not a valid colour")
                }
            ]
            validationMode: StatusInput.ValidationMode.Always

            onNewColorChanged: {
                if (!valid)
                    return;

                locked = true;
                root.color = newColor;
                locked = false;
            }
            Layout.alignment: Qt.AlignHCenter
        }

        StatusBaseText {
            text: qsTr("White text should be legable on top of this colour")
            font.pixelSize: 15
        }

        Rectangle {
            implicitHeight: 48
            radius: 10
            color: root.color
            Layout.fillWidth: true

            StatusBaseText {
                id: preview
                x: 16
                y: 16
                text: root.color.toString()
                color: Theme.palette.white
                font.pixelSize: 15
            }
        }

        StatusBaseText {
            text: qsTr("Standard colours")
            font.pixelSize: 15
        }

        StatusColorSelectorGrid {
            id: colorSelectionGrid
            columns: 8
            model: ["#4360df", "#887af9", "#d37ef4", "#51d0f0", "#26a69a", "#7cda00", "#eab700", "#fa6565"]
            selectedColorIndex: -1
            onColorSelected: {
                root.color = selectedColor;
            }
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
