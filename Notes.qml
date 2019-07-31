import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import CyberTracker.Controls 1.0 as CTControls
import CyberTracker.Engine 1.0 as CTEngine

Page {
    property string bindingUid: "Note"
    property int fontPixelSize: 24
    property CTEngine.Binding __binding

    Component.onCompleted: {
        __binding = session.newBinding(session.rootRecordUid, bindingUid)
        titleLabel.text = __binding.elementName
        editText.placeholderText = session.getElementName(__binding.field.hintElementUid)
        if (__binding.field.multiLine) {
            editText.visible = false
            editMemo.binding = __binding
            editMemo.visible = true
            editMemo.forceActiveFocus()
        } else {
            editMemo.visible = false
            editText.binding = __binding
            editText.visible = true
            editText.forceActiveFocus()
        }
    }

    onFontPixelSizeChanged: {
        editMemo.font.pixelSize = fontPixelSize
        editText.font.pixelSize = fontPixelSize
    }

    header: CTControls.PageHeader {
        id: titleLabel
        menuIcon: AppShared.resolveProjectFile(session.project.uid, "ClearNote.svg")
        menuVisible: true
        onBackClicked: {
            Qt.inputMethod.hide()
            session.popPage()
        }

        onMenuClicked: {
            editMemo.text = ""
            editText.text = ""
        }
    }

    CTControls.EditText {
        id: editText
        x: 10
        y: 10
        width: parent.width - 20
        visible: false
    }

    CTControls.EditMemo {
        id: editMemo
        anchors.fill: parent
        anchors.margins: 10
        visible: false
    }
}
