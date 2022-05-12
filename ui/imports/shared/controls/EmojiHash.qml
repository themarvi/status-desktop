import QtQuick 2.13
import StatusQ.Core.Utils 0.1 as StatusQUtils
import utils 1.0

Item {
    id: root

    property string publicKey
    property size size: Qt.size(14, 14)
    property bool supersampling: true
    readonly property size effectiveSize: supersampling ? Qt.size(size.width * 2, size.height * 2) : emojiSize
    
    implicitWidth: text.implicitWidth * text.scale
    implicitHeight: text.implicitHeight * text.scale

    Text {
        id: text
        anchors.centerIn: parent
        scale: supersampling ? 0.5 : 1
        font.hintingPreference: Font.PreferNoHinting
        renderType: Text.NativeRendering
        font.pointSize: 1 // make sure there is no padding for emojis due to 'style: "vertical-align: top"'
        text: {
            const emojiHash = Utils.getEmojiHashAsJson(root.publicKey);
            const emojiHashFirstLine = emojiHash.splice(0, 7).join('');
            const emojiHashSecondLine = emojiHash.join('');
            const sizeString = `${effectiveSize.width}x${effectiveSize.height}`;
            return StatusQUtils.Emoji.parse(emojiHashFirstLine, sizeString) + "<br>" +
                StatusQUtils.Emoji.parse(emojiHashSecondLine, sizeString)
        }
}
}
