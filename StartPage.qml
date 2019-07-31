import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import CyberTracker.Engine 1.0 as CTEngine
import CyberTracker.Controls 1.0 as CTControls

Page {
    id: startPage

    Component.onCompleted: session.persistPageStack = false
    header: CTControls.PageHeader {
        text: "Moments History"
        onBackClicked: session.popPage()
        menuVisible: true
        menuIcon: AppShared.resolveProjectFile(session.project.uid, "NewSighting.svg")
        onMenuClicked: {
            session.newSighting()
            session.pushPage(Qt.resolvedUrl("Moment.qml"), { } )
        }
    }

    function getFieldValueElementName(sighting, fieldUid) {
        var fieldValue = sighting.getFieldValue(sighting.rootRecordUid, fieldUid)
        return session.getElementName(fieldValue)
    }

    ColumnLayout {
        anchors.fill: parent
        ListView {
            id: listView
            Layout.fillHeight: true
            Layout.fillWidth: true
            highlightFollowsCurrentItem: true

            model: session.buildSightingListModel(listView)

            delegate: SwipeDelegate {
                id: swipeDelegate
                property int selectedIndex: index
                width: parent.width
                highlighted: ListView.isCurrentItem
                contentItem: RowLayout {
                    Image {
                        source: Qt.resolvedUrl(session.tempUrl + "/" + modelData.rootRecordUid + ".png")
                        cache: false
                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Label.WordWrap
                        text: "Time Recorded: " + Qt.formatDateTime(modelData.createdDateTime, "ddd yyyy-MM-dd hh:mm:ss") +
                              "\nSource: " + getFieldValueElementName(modelData, "SourceAnimal") +
                              ", Target: " + getFieldValueElementName(modelData, "TargetAnimal") +
                              "\nInteraction: " + getFieldValueElementName(modelData, "InteractionKind")
                    }
                }

                ListView.onRemove: SequentialAnimation {
                    PropertyAction {
                        target: swipeDelegate
                        property: "ListView.delayRemove"
                        value: true
                    }
                    NumberAnimation {
                        target: swipeDelegate
                        property: "height"
                        to: 0
                    }
                    PropertyAction {
                        target: swipeDelegate;
                        property: "ListView.delayRemove";
                        value: false
                    }
                }

                swipe.right: Label {
                    id: deleteLabel
                    text: qsTr("Delete")
                    color: "black"
                    verticalAlignment: Label.AlignVCenter
                    padding: 12
                    height: parent.height
                    anchors.right: parent.right

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            session.deleteSighting(modelData.rootRecordUid)
                            listView.model.remove(swipeDelegate.selectedIndex,1)
                        }
                    }
                }

                onClicked: {
                    listView.currentIndex = model.index
                    session.loadSighting(modelData.rootRecordUid)
                    session.pushPage(Qt.resolvedUrl("Moment.qml"), { } )
                }
            }

            Connections {
                target: session
                onSightingSaved: {
                    var newModel = session.buildSightingListModel(listView)
                    listView.model = newModel
//                    for (var i = 0; i < newModel.count; i++) {
//                        var sighting = newModel.get(i)
//                        if (sighting.rootRecordUid === recordUid) {
//                            listView.currentIndex = i
//                            break
//                        }
//                    }
                }
            }
        }

        Button {
            id: exportButton
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom
            text: "Export to CSV"

            function decodeLocation(o) {
                return o.x + "," + o.y
            }

            function saveFile(fileUrl, text) {
                var request = new XMLHttpRequest();
                request.open("PUT", fileUrl, false);
                request.send(text);
                return request.status;
            }

            onClicked: {
                var model = session.buildSightingListModel(listView)
                var csvText = ""
                for (var i = 0; i < model.count; i++) {
                    var sighting = model.get(i)
                    var result = ""

                    result = result + Qt.formatDateTime(sighting.createdDateTime, "ddd yyyy-MM-dd hh:mm:ss")
                    result = result + sighting.getFieldValue(sighting.rootRecordUid, "InteractionKind") + ","
                    result = result + decodeLocation(sighting.getFieldValue(sighting.rootRecordUid, "InteractionLocation")) + ","
                    result = result + sighting.getFieldValue(sighting.rootRecordUid, "SourceAnimal") + ","
                    result = result + sighting.getFieldValue(sighting.rootRecordUid, "SourceSize") + ","
                    result = result + decodeLocation(sighting.getFieldValue(sighting.rootRecordUid, "SourceLocation")) + ","
                    result = result + sighting.getFieldValue(sighting.rootRecordUid, "TargetAnimal") + ","
                    result = result + sighting.getFieldValue(sighting.rootRecordUid, "TargetSize") + ","
                    result = result + decodeLocation(sighting.getFieldValue(sighting.rootRecordUid, "TargetLocation")) + ","
                    result = result + sighting.getFieldValue(sighting.rootRecordUid, "Note")
                    csvText = csvText + result + "\n"
                }

                var path = QLabs.StandardPaths.writableLocation(QLabs.StandardPaths.DocumentsLocation)
                saveFile(path + "/test.csv", csvText)
            }
        }
    }
}
