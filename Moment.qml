import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtPositioning 5.3
import QtSensors 5.3
import Esri.ArcGISRuntime 100.5 as Esri
import CyberTracker.Engine 1.0 as CTEngine
import CyberTracker.Controls 1.0 as CTControls

Page {

    property string compassMode: "Compass"
    property string navigationMode: "Navigation"
    property string recenterMode: "Re-Center"
    property string onMode: "On"
    property string stopMode: "Stop"
    property string closeMode: "Close"
    property string currentModeText: stopMode
    property string currentModeImage: "Stop.png"
    property string url: "true"

    Component.onCompleted: {
        autoPanListModel.append({name: compassMode, image: "Compass.png"});
        autoPanListModel.append({name: navigationMode, image: "Navigation.png"});
        autoPanListModel.append({name: recenterMode, image: "Re-Center.png"});
        autoPanListModel.append({name: onMode, image: "On.png"});
        autoPanListModel.append({name: stopMode, image: "Stop.png"});
        autoPanListModel.append({name: closeMode, image: "Close.png"});
    }

    header: CTControls.PageHeader {
        id: headr
        text: "Moment"
        onBackClicked: {
            session.setControlState("Map", "Viewpoint", mapView.currentViewpointExtent.json)
            mapView.grabToImage(function(result) {
                result.saveToFile(session.tempFolder + "/" + session.sighting.rootRecordUid + ".png")
                session.saveSighting()
                session.popPage()
            }, Qt.size(64, 64))
        }
    }

    Connections {
        target: session.sighting
        onFieldValueChanged: {
            buildPoints()
        }
    }

    Esri.SimpleLineSymbol {
        id: symbolPath1
        width: 5
        style: Esri.Enums.SimpleLineSymbolStyleDash
    }

    Esri.SimpleLineSymbol {
        id: symbolPath2
        width: 5
        style: Esri.Enums.SimpleLineSymbolStyleDashDot
    }

    Esri.SimpleFillSymbol {
        id: symbolSource
        color: Qt.rgba(1, 0, 0, 0.5)
        style: Esri.Enums.SimpleFillSymbolStyleSolid
    }

    Esri.SimpleFillSymbol {
        id: symbolTarget
        color: Qt.rgba(1, 0, 0, 0.5)
        style: Esri.Enums.SimpleFillSymbolStyleSolid
    }

    Esri.MapView {
        id: mapView
        anchors.fill: parent

        Esri.Map {
            id: map
            Esri.BasemapImageryWithLabelsVector {}

            onLoadStatusChanged: {
                if (loadStatus === Esri.Enums.LoadStatusLoaded) {
                    var viewpointJson = session.getControlState("Map", "Viewpoint")
                    if (viewpointJson !== undefined) {
                        mapView.setViewpoint(Esri.ArcGISRuntimeEnvironment.createObject("ViewpointExtent", {json: viewpointJson}))
                    }

                    buildPoints()
                }
            }
        }

        onMousePressed: {
            var locationsFieldUids = [ "SourceLocation", "TargetLocation", "InteractionLocation" ]

            var index = grid.stateAsInt
            if (index >= locationsFieldUids.length) return
            var mapPoint = Esri.GeometryEngine.project(mouse.mapPoint, Esri.SpatialReference.createWgs84())
            session.setFieldValue(locationsFieldUids[index], mapPoint.json)
        }

        Esri.GraphicsOverlay {
            Esri.Graphic {
                id: graphicSource
                symbol: symbolSource
            }

            Esri.Graphic {
                id: graphicTarget
                symbol: symbolTarget
            }

            Esri.Graphic {
                id: graphicInteractionSource
                symbol: symbolSource
            }

            Esri.Graphic {
                id: graphicInteractionTarget
                symbol: symbolTarget
            }

            Esri.Graphic {
                id: graphicPath1
                symbol: symbolPath1
            }

            Esri.Graphic {
                id: graphicPath2
                symbol: symbolPath2
            }
        }

        locationDisplay {
                    positionSource: PositionSource {
                    }
                    compass: Compass {}
        }
    }

    function getPointSize(sizeFieldUid) {
        var fieldValue = session.getFieldValue(sizeFieldUid)
        if (fieldValue === undefined) return 0
        return session.getElement(fieldValue).tag.radius * 1600
    }

    function buildPoint(index) {
        switch (index) {
        case 0: createPoint(graphicSource, symbolSource, "SourceAnimal", "SourceSize", "SourceLocation")
                break
        case 1: createPoint(graphicTarget, symbolTarget, "TargetAnimal", "TargetSize", "TargetLocation")
                break;
        case 2: createPoint(graphicInteractionSource, symbolSource, "SourceAnimal", "SourceSize", "InteractionLocation")
                createPoint(graphicInteractionTarget, symbolTarget, "TargetAnimal", "TargetSize", "InteractionLocation")
                break
        }
    }

    function buildPoints() {
        for (var index = 0; index < 3; index++) {
            buildPoint(index)
        }

        createLine(graphicPath1, graphicSource, graphicInteractionSource, "SourceLocation", "InteractionLocation")
        createLine(graphicPath2, graphicTarget, graphicInteractionSource, "TargetLocation", "InteractionLocation")
    }

    function createPoint(graphic, symbol, animalFieldUid, sizeFieldUid, locationFieldUid) {

        var animal = session.getFieldValue(animalFieldUid)
        if (animal === undefined) return

        var pointSize = getPointSize(sizeFieldUid)
        if (pointSize === 0) return

        var location = session.getFieldValue(locationFieldUid)
        if (location === undefined) return

        var point = Esri.ArcGISRuntimeEnvironment.createObject("Point", { json: location })
        symbol.color = session.getElement(animal).color
        symbol.color.a = 0.5

        var bufferInMeters = pointSize
        var buffer = Esri.GeometryEngine.buffer(point, bufferInMeters)
        var resultGraphic = Esri.ArcGISRuntimeEnvironment.createObject("Graphic", { geometry: buffer })
        var bufferGeodesic = Esri.GeometryEngine.bufferGeodetic(point, bufferInMeters, Esri.Enums.LinearUnitIdMeters, NaN, Esri.Enums.geodesicCurveTypeGeodesic)

        graphic.geometry = bufferGeodesic
    }

    function createLine(graphicPath, graphic1, graphic2, locationField1, locationField2, symbol) {
        var location1 = session.getFieldValue(locationField1)
        if (location1 === undefined) return
        var location2 = session.getFieldValue(locationField2)
        if (location2 === undefined) return
        var interactionKind = session.getFieldValue("InteractionKind")
        if (interactionKind === undefined) return

        var point1 = Esri.ArcGISRuntimeEnvironment.createObject("Point", { json: location1 })
        var point2 = Esri.ArcGISRuntimeEnvironment.createObject("Point", { json: location2 })

        var polylineBuilder = Esri.ArcGISRuntimeEnvironment.createObject("PolylineBuilder", {spatialReference: Esri.SpatialReference.createWgs84()});
        polylineBuilder.addPoints([point1, point2]);
        var polyline = polylineBuilder.geometry;

        var maxSegmentLength = 1;
        var unitOfMeasurement = Esri.ArcGISRuntimeEnvironment.createObject("LinearUnit", { linearUnitId: Esri.Enums.LinearUnitIdKilometers });
        var curveType = Esri.Enums.GeodeticCurveTypeGeodesic;
        var pathGeometry = Esri.GeometryEngine.densifyGeodetic(polyline, maxSegmentLength, unitOfMeasurement, curveType);

        graphicPath.geometry = pathGeometry
        graphicPath.symbol.color = session.getElement(interactionKind).color
        graphicPath.symbol.color.a = 0.5
    }

    Component {
        id: animalFieldComponent

        ItemDelegate {
            width: parent.width
            contentItem: RowLayout {
                Rectangle {
                    width: animalLabel.height
                    height: animalLabel.height
                    color: session.getElementColor(modelData.uid)
                }

                Label {
                    id: animalLabel
                    Layout.fillWidth: true
                    wrapMode: Label.WordWrap
                    text: session.getElementName(modelData.uid)
                }
            }
        }
    }

    GridLayout {
        id: grid
        columns: 3
        Layout.fillWidth: true
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        width: parent.width
        columnSpacing: 8

        property int stateAsInt: 0
        property int controlWidth: (parent.width - columnSpacing * 2 - 16) / 3

        CTControls.ComboBox {
            visible: grid.stateAsInt === 0
            Layout.fillWidth: true
            binding: session.newBinding("SourceAnimal")
            defaultDisplayText: "Select animal"
            delegate: animalFieldComponent

        }

        Button {
            visible: grid.stateAsInt === 0
            Layout.fillWidth: true
            onClicked: grid.stateAsInt++
            text: "Source"
        }

        CTControls.ComboBox {
            visible: grid.stateAsInt === 0
            Layout.fillWidth: true
            binding: session.newBinding("SourceSize")
            defaultDisplayText: "Select size"
        }

        CTControls.ComboBox {
            visible: grid.stateAsInt === 1
            Layout.fillWidth: true
            binding: session.newBinding("TargetAnimal")
            defaultDisplayText: "Select animal"
            delegate: animalFieldComponent
        }

        Button {
            visible: grid.stateAsInt === 1
            Layout.fillWidth: true
            onClicked: grid.stateAsInt++
            text: "Target"
        }

        CTControls.ComboBox {
            visible: grid.stateAsInt === 1
            Layout.fillWidth: true
            binding: session.newBinding("TargetSize")
            defaultDisplayText: "Select size"
        }

        CTControls.ComboBox {
            visible: grid.stateAsInt === 2
            Layout.fillWidth: true
            Layout.columnSpan: 2
            binding: session.newBinding("InteractionKind")
            defaultDisplayText: "Select interaction"
        }

        Button {
            visible: grid.stateAsInt === 2
            Layout.fillWidth: true
            onClicked: grid.stateAsInt++
            text: "Interaction"
        }

        Button {
            visible: grid.stateAsInt === 3
            Layout.fillWidth: true
            onClicked: grid.stateAsInt = 0
            text: "Pan and zoom"
        }
    }

    ListView {
        id: autoPanListView
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 10
        }
        visible: false
        width: parent.width
        height: 300
        spacing: 10
        model: ListModel {
            id: autoPanListModel
        }

        delegate: Row {
            id: autopanRow
            anchors.right: parent.right
            spacing: 10

            Text {
                text: name
                font.pixelSize: 25
                color: "black"
                MouseArea {
                    anchors.fill: parent
                    // When an item in the list view is clicked
                    onClicked: {
                        autopanRow.updateAutoPanMode();
                    }
                }
            }

            Image {
                source: image
                width: 40
                height: width
                MouseArea {
                    anchors.fill: parent
                    // When an item in the list view is clicked
                    onClicked: {
                        autopanRow.updateAutoPanMode();
                    }
                }
            }

            // set the appropriate auto pan mode
            function updateAutoPanMode() {
                switch (name) {
                case compassMode:
                    mapView.locationDisplay.autoPanMode = Esri.Enums.LocationDisplayAutoPanModeCompassNavigation;
                    mapView.locationDisplay.start();
                    break;
                case navigationMode:
                    mapView.locationDisplay.autoPanMode = Esri.Enums.LocationDisplayAutoPanModeNavigation;
                    mapView.locationDisplay.start();
                    break;
                case recenterMode:
                    mapView.locationDisplay.autoPanMode = Esri.Enums.LocationDisplayAutoPanModeRecenter;
                    mapView.locationDisplay.start();
                    break;
                case onMode:
                    mapView.locationDisplay.autoPanMode = Esri.Enums.LocationDisplayAutoPanModeOff;
                    mapView.locationDisplay.start();
                    break;
                case stopMode:
                    mapView.locationDisplay.stop();
                    break;
                }

                if (name !== closeMode) {
                    currentModeText = name;
                    currentModeImage = image;
                }

                // hide the list view
                currentAction.visible = true;
                autoPanListView.visible = false;
            }
        }
    }

    Row {
        id: currentAction
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 25
        }
        spacing: 10

        Text {
            text: currentModeText
            font.pixelSize: 25
            color: "black"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentAction.visible = false;
                    autoPanListView.visible = true;
                }
            }
        }

        Image {
            source: currentModeImage
            width: 40
            height: width
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentAction.visible = false;
                    autoPanListView.visible = true;
                }
            }
        }
    }

    Image {
        id: takePicture
        source: "Camera.png"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 90
        anchors.rightMargin: 10
        property bool shownEditPhotoDialog: false
        MouseArea {
            anchors.fill:parent
            onClicked:{
                if (system.desktopPlatform) {
                    nativeUtils.displayImagePicker(qsTr("Choose Image"))
                }
                else {
                    shownEditPhotoDialog = true
                    nativeUtils.displayAlertSheet("", ["Choose Photo", "Take Photo"], true)

                }
            }
        }
    }

    Image {
        id: toNotes
        source: "Notes.png"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 50
        anchors.rightMargin: 10
        MouseArea{
            anchors.fill:parent
            onClicked: {
                session.pushPage(Qt.resolvedUrl("Notes.qml"), { })
            }
        }
    }

}
