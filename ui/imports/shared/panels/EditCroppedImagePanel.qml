import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Layout 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

Item {
    id: root

    property alias source: croppedPreview.source
    property alias cropRect: croppedPreview.cropRect
    /*required*/ property alias aspectRatio: imageCropWorkflow.aspectRatio

    property alias roundedImage: imageCropWorkflow.roundedImage

    /*required*/ property alias imageFileDialogTitle: imageCropWorkflow.imageFileDialogTitle
    /*required*/ property alias title: imageCropWorkflow.title
    /*required*/ property alias acceptButtonText: imageCropWorkflow.acceptButtonText

    property string dataImage: ""

    property bool userSelectedImage: false
    readonly property bool nothingToShow: state === d.noImageState

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight


    states: [
        State {
            name: d.dataImageState
            when: root.dataImage.length > 0 && !userSelectedImage
        },
        State {
            name: d.noImageState
            when: root.dataImage.length === 0 && !userSelectedImage
        },
        State {
            name: d.imageSelectedState
            when: userSelectedImage
        }
    ]

    QtObject {
        id: d

        readonly property string dataImageState: "dataImage"
        readonly property string noImageState: "noImage"
        readonly property string imageSelectedState: "imageSelected"
        readonly property int buttonsInsideOffset: 5
    }

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: !imageCropEditor.visible

            StatusRoundedImage {
                anchors.fill: parent

                visible: root.state === d.dataImageState

                image.source: root.dataImage
                showLoadingIndicator: true
                border.width: 1
                border.color: Style.current.border
                radius: root.roundedImage ? width/2 : croppedPreview.radius
            }

            StatusImageCrop {
                id: croppedPreview
                anchors.fill: parent

                visible: root.state === d.imageSelectedState
                windowStyle: imageCropWorkflow.windowStyle
                wallColor: Theme.palette.statusAppLayout.backgroundColor
                wallTransparency: 1
                clip:true
            }

            StatusRoundButton {
                id: editButton

                icon.name: "edit"

                readonly property real rotationRadius: roundedImage ? parent.width/2 : imageCropEditor.radius
                transform: [
                    Translate {
                        x: -editButton.width/2 - d.buttonsInsideOffset
                        y: -editButton.height/2 - d.buttonsInsideOffset
                    },
                    Rotation { angle: -editRotationTransform.angle },
                    Rotation {
                        id: editRotationTransform
                        angle: 225
                        origin.x: editButton.rotationRadius
                    },
                    Translate {
                        x: root.roundedImage ? 0 : editButton.parent.width - 2 * editButton.rotationRadius
                        y: (root.roundedImage ? 0 : editButton.parent.height - 2 * editButton.rotationRadius) + editButton.rotationRadius
                    }
                ]
                type: StatusRoundButton.Type.Secondary

                onClicked: imageCropWorkflow.chooseImageToCrop()
            }
        }

        Rectangle {
            id: imageCropEditor

            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: root.state === d.noImageState

            radius: roundedImage ? Math.max(width, height)/2 : croppedPreview.radius
            color: Style.current.inputBackground

            StatusRoundButton {
                id: addButton

                icon.name: "add"

                readonly property real rotationRadius: root.roundedImage ? parent.width/2 : imageCropEditor.radius
                transform: [
                    Translate {
                        x: -addButton.width/2 - d.buttonsInsideOffset
                        y: -addButton.height/2 + d.buttonsInsideOffset
                    },
                    Rotation { angle: -addRotationTransform.angle },
                    Rotation {
                        id: addRotationTransform
                        angle: 135
                        origin.x: addButton.rotationRadius
                    },
                    Translate {
                        x: root.roundedImage ? 0 : addButton.parent.width - 2 * addButton.rotationRadius
                        y: addButton.rotationRadius
                    }
                ]

                type: StatusRoundButton.Type.Secondary

                onClicked: imageCropWorkflow.chooseImageToCrop()
                z: imageCropEditor.z + 1
            }

            ImageCropWorkflow {
                id: imageCropWorkflow

                onImageCropped: {
                    croppedPreview.source = image
                    croppedPreview.setCropRect(cropRect)
                    root.userSelectedImage = true
                }
            }
        }
    }
}
