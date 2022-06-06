import QtQuick 2.13

QtObject {
    id: root

    property var keycardModule

    function startKeycardFlow() {
        root.keycardModule.startKeycardFlow()
    }

    function cancelFlow() {
        root.keycardModule.cancelFlow()
    }
}
