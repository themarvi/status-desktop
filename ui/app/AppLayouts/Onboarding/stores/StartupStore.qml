import QtQuick 2.14

QtObject {
    id: root

    property var startupModuleInst: startupModule
    property var currentStartupState: startupModuleInst.currentStartupState
    property var selectedLoginAccount: startupModuleInst.selectedLoginAccount

    function backAction() {
        root.currentStartupState.backAction()
    }

    function doPrimaryAction() {
        root.currentStartupState.doPrimaryAction()
    }

    function doSecondaryAction() {
        root.currentStartupState.doSecondaryAction()
    }

    function doTertiaryAction() {
        root.currentStartupState.doTertiaryAction()
    }

    function showBeforeGetStartedPopup() {
        return root.startupModuleInst.showBeforeGetStartedPopup()
    }

    function beforeGetStartedPopupAccepted() {
        root.startupModuleInst.beforeGetStartedPopupAccepted()
    }

    function generateImage(source, aX, aY, bX, bY) {
        return root.startupModuleInst.generateImage(source, aX, aY, bX, bY)
    }

    function setDisplayName(value) {
        root.startupModuleInst.setDisplayName(value)
    }

    function getDisplayName() {
        return root.startupModuleInst.getDisplayName()
    }

    function setPassword(value) {
        root.startupModuleInst.setPassword(value)
    }

    function getPassword() {
        return root.startupModuleInst.getPassword()
    }

    function getPasswordStrengthScore(password) {
        let userName = root.startupModuleInst.importedAccountAlias
        return root.startupModuleInst.getPasswordStrengthScore(password, userName)
    }

    function validMnemonic(mnemonic) {
        return root.startupModuleInst.validMnemonic(mnemonic)
    }

    function setSelectedLoginAccountByIndex(index) {
        root.startupModuleInst.setSelectedLoginAccountByIndex(index)
    }
}
