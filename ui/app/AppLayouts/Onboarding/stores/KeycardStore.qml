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

    function checkKeycardPin(pin) {
        return root.keycardModule.checkKeycardPin(pin)
    }

    function checkRepeatedKeycardPinCurrent(pin) {
        return root.keycardModule.checkRepeatedKeycardPinCurrent(pin)
    }

    function checkRepeatedKeycardPin(pin) {
        return root.keycardModule.checkRepeatedKeycardPin(pin)
    }

    function shouldExitKeycardFlow() {
        return root.keycardModule.shouldExitKeycardFlow()
    }

    function backClicked() {
        root.keycardModule.backClicked()
    }

    function getSeedPhrase() {
        return root.keycardModule.getSeedPhrase()
    }

    function nextState() {
        return root.keycardModule.nextState()
    }
}
