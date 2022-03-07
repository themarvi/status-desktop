pragma Singleton

import QtQuick 2.13
import utils 1.0

QtObject {
    id: root
    property var profileSectionModuleInst: profileSectionModule
    property var profileModule:  profileSectionModuleInst.profileModule
    property var onBoardingModul: onboardingModule

    property url profImgUrl: ""
    property real profImgAX: 0.0
    property real profImgAY: 0.0
    property real profImgBX: 0.0
    property real profImgBY: 0.0

    property bool showBeforeGetStartedPopup: true

    function importMnemonic(mnemonic) {
        onBoardingModul.importMnemonic(mnemonic)
    }

    function setCurrentAccountAndDisplayName(selectedAccountIdx, displayName) {
        onBoardingModul.setDisplayName(displayName)
        onBoardingModul.setSelectedAccountByIndex(selectedAccountIdx)
    }

    function saveImage() {
        return root.profileModule.upload(root.profImgUr, root.profImgAX, root.profImgAY, root.profImgBX, root.profImgBY);
    }

    function uploadImage(source, aX, aY, bX, bY) {
        root.profImgUrl = source;
        root.profImgAX = aX;
        root.profImgAY = aY;
        root.profImgBX = bX;
        root.profImgBY = bY;
    }

    function removeImage() {
        return root.profileModule.remove();
    }

    function finishCreatingAccount(pass) {
        root.onBoardingModul.storeSelectedAccountAndLogin(pass);
    }

    function storeToKeyChain(pass) {
        mainModule.storePassword(pass);
    }

    property ListModel accountsSampleData: ListModel {
        ListElement {
            username: "Ferocious Herringbone Sinewave2"
            identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAg0lEQVR4nOzXwQmAMBAFURV7sQybsgybsgyr0QYUlE1g+Mw7ioQMe9lMQwhDaAyhMYTGEJqYkPnrj/t5XE/ft2UdW1yken7MRAyhMYTGEBpDaAyhKe9JbzvSX9WdLWYihtAYQuMLkcYQGkPUScxEDKExhMYQGkNoDKExhMYQmjsAAP//ZfIUZgXTZXQAAAAASUVORK5CYII="
            address: "0x123456789009876543211234567890"
        }
        ListElement {
            username: "Another Account"
            identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAg0lEQVR4nOzXwQmAMBAFURV7sQybsgybsgyr0QYUlE1g+Mw7ioQMe9lMQwhDaAyhMYTGEJqYkPnrj/t5XE/ft2UdW1yken7MRAyhMYTGEBpDaAyhKe9JbzvSX9WdLWYihtAYQuMLkcYQGkPUScxEDKExhMYQGkNoDKExhMYQmjsAAP//ZfIUZgXTZXQAAAAASUVORK5CYII="
            address: "0x123456789009876543211234567890"
        }
    }
}
