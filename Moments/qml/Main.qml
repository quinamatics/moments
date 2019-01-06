import VPlayApps 1.0
import VPlay 2.0
import QtQuick 2.0
import QtLocation 5.6
import QtPositioning 5.6
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0


App {
  NavigationStack {

    Page {
      title: "Select New Animal"
      readonly property color greyBackgroundColor: Qt.rgba(238/256.0, 238/256.0, 238/256.0, 1)
      id: page

      Rectangle {
          id: rect
          width: Screen.width
          height: Screen.height
          visible: true

          ListModel {
              id: mapModel
          }
          property var countArray: [0,0,0,0,0,0,0]
          //First or Second Page
          property bool actionPage: false
          //First Page Variables
          property int speciesColor: 0
          property int speciesSize: 0
          property int speciesName: 0
          //Second Page
          //Single Action Variables
          property bool singleAction: false
          property int currIndex: -1
          //Double Action Variables
          property int instigatorIndex: -1
          property int receiverIndex: -1
          property bool instigator : true
          property int chosenAction: 0
          //Loading Moments
          property int momentLoad: 0


          Text{
              x: 0
              y: 527
              z: 2
              width: 141
              height: 27
              font.family: "Lato"
              font.pointSize: 11;
              text: "Moments-Brandon Zhu"
              color: "white"
              }


          AppMap {
              id: map
              anchors.fill: parent
              zoomLevel: 15
              center: QtPositioning.coordinate(-1.3123, 35.194466)

              plugin: Plugin {
                name: "mapbox"
                // configure your own map_id and access_token here
                parameters: [  PluginParameter {
                    name: "mapbox.mapping.map_id"
                    value: "mapbox.satellite"
                  },
                  PluginParameter {
                    name: "mapbox.access_token"
                    value: "pk.eyJ1IjoiZ3R2cGxheSIsImEiOiJjaWZ0Y2pkM2cwMXZqdWVsenJhcGZ3ZDl5In0.6xMVtyc0CkYNYup76iMVNQ"
                  },
                  PluginParameter {
                    name: "mapbox.mapping.highdpi_tiles"
                    value: true
                  }]
              }

              showUserPosition: true

              MapItemView {
                  id: mapList
                  model: mapModel
                  delegate: MapCircle {
                    id: dot
                    radius: r
                    color: c
                    opacity: o
                    property string species: s
                    property string givenAction: giv
                    property string receivedAction: recv

                    property int selectedIndex: index


                    property double endLat: eLat
                    property double endLong: eLong
                    center {
                         latitude: lat
                         longitude: longi
                    }
                    layer.enabled:true

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: {
                            if(!rect.actionPage){
                                deleteDot.visible = true;
                                page.title = "Delete"
                                deleteDot.toDelete = parent.selectedIndex;
                            }
                            else{
                               rect.currIndex = parent.selectedIndex
                               if(rect.singleAction){
                                   page.title = "Selected " + dot.species + ". Choose New Location"
                               }
                               else{
                                   if(rect.instigator){
                                       rect.instigatorIndex = parent.selectedIndex;
                                       page.title = "Selected " + dot.species + ". Choose Receiving Animal"

                                       rect.instigator = false
                                   }
                                   else{

                                       rect.receiverIndex = parent.selectedIndex;
                                       page.title = "Selected Receiving Animal: "+ dot.species + ". Select Action"
                                       rect.instigator = true
                                   }
                               }
                            }
                        }
                    }
                  }
              }

              ListModel {
                  id: newMapModel
              }

              MapItemView {
                  id: newMapList
                  model: newMapModel
                  delegate: MapCircle {
                    id: newDot
                    radius: newr
                    color: newc
                    opacity: 0.5
                    center {
                         latitude: newlat
                         longitude: newlongi
                    }
                   }
              }


              MouseArea {
                  anchors.fill: parent
                  onClicked: {

                      var coord = map.toCoordinate(Qt.point(mouse.x,mouse.y))
                      function altColor(i) {
                          var color = ["black", "red", "green", "blue", "magenta", "steelblue", "yellow"];
                          return color[i];
                      }
                      function altRadii(i){
                          var radii = [2, 4, 7, 12, 20, 40, 80, 160];
                          return radii[i];
                      }
                      function altSpecies(i){
                          var spec = ["Topi", "Lion", "Elephant", "Hartebeest", "Zebra", "Gazelle","Warthog"];
                          rect.countArray[i]++;
                          return spec[i]+rect.countArray[i];
                      }
                      function altAction(i){
                          var act = ["Predation","Scavenging","Food Competition","Parasite","Physical Competition"];
                          return act[i];
                      }

                      if(!rect.actionPage){
                          mapModel.append({lat : coord.latitude, longi: coord.longitude, c: altColor(rect.speciesColor), r: altRadii(rect.speciesSize), s: altSpecies(rect.speciesName)
                                          ,giv: "", recv: "", eLat: -1, eLong: -1});
                          page.title = "Select New Animal or Move To Action Stage"
                      }
                      else{
                          if(rect.singleAction){

                              page.title = "Saved Single Action"
                              mapModel.set(rect.currIndex,{eLat : coord.latitude, eLong: coord.longitude});
                              newMapModel.append({newlat: mapModel.get(rect.currIndex).eLat, newlongi: mapModel.get(rect.currIndex).eLong,
                                                     newr: mapModel.get(rect.currIndex).r, newc: mapModel.get(rect.currIndex).c});

                          }
                          else{


                              mapModel.set(rect.instigatorIndex,{giv: (mapModel.get(rect.instigatorIndex).giv+", "+altAction(rect.chosenAction)),eLat: coord.latitude, eLong: coord.longitude});
                              mapModel.set(rect.receiverIndex, {recv: (mapModel.get(rect.receiverIndex).recv+", "+altAction(rect.chosenAction)),eLat: coord.latitude, eLong: coord.longitude});


                              newMapModel.append({newlat: mapModel.get(rect.instigatorIndex).eLat, newlongi: mapModel.get(rect.instigatorIndex).eLong,
                                                     newr: mapModel.get(rect.instigatorIndex).r, newc: mapModel.get(rect.instigatorIndex).c});
                              newMapModel.append({newlat: coord.latitude, newlongi: coord.longitude,
                                         newr: mapModel.get(rect.receiverIndex).r, newc: mapModel.get(rect.receiverIndex).c});
                              page.title = "Finished. Select New Interaction"
                          }
                      }

                  }
              }
          }

          Rectangle {
                  id: taskbar
                  x: 0
                  y: 550
                  width: parent.width
                  height: 60
                  anchors.bottomMargin: 0
                  color: page.greyBackgroundColor

                  IconButton {
                      id: userLoc
                      y: 16
                      width: 44
                      height: 36
                      anchors.bottomMargin: 15
                      icon: IconType.locationarrow
                      anchors.left: parent.left
                    anchors.bottom: parent.bottom

                    enabled: map.userPositionAvailable

                    size: dp(26)

                    onClicked: {
                      map.zoomToUserPosition()
                    }
                  }

                  IconButton {
                    id: deleteDot
                    y: 16
                    width: 44
                    height: 36
                    anchors.leftMargin: 60
                    anchors.bottomMargin: 15
                    icon: IconType.trash
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    visible: false

                    size: dp(26)
                    property int toDelete: 0
                    onClicked: {
                      if(!rect.actionPage){
                          mapModel.remove(toDelete,1)
                          page.title = "Item Deleted"
                            deleteDot.visible = false;
                      }
                    }
                  }

                  IconButton {
                      id: takePicture
                      y: 16
                      width: 44
                      height: 36
                      anchors.leftMargin: 119
                      anchors.bottomMargin: 15
                      icon: IconType.camera
                      anchors.left: parent.left
                      anchors.bottom: parent.bottom


                      size: dp(26)
                      property bool shownEditPhotoDialog: false
                      x: 120
                      onClicked: {
                          page.title = "Take Picture"
                          if (system.desktopPlatform) {
                               nativeUtils.displayImagePicker(qsTr("Choose Image"))
                          }
                          else {
                             // Probably better use a QML styled dialog?
                             shownEditPhotoDialog = true
                             nativeUtils.displayAlertSheet("", ["Choose Photo", "Take Photo"], true)

                          }
                          page.title = "Picture Saved"

                        }

                        Connections {
                            target: nativeUtils
                            onAlertSheetFinished: {
                            if (takePicture.shownEditPhotoDialog) {
                                 if (index == 0)
                                        nativeUtils.displayImagePicker(qsTr("Choose Image")) // Choose image
                                 else if (index == 1)
                                        nativeUtils.displayCameraPicker("Take Photo") // Take from Camera
                                        takePicture.shownEditPhotoDialog = false
                                 }
                            }
                      }

                  }
                  AppText{
                      id: aptext
                      color: "#ffffff"
                      x: 32

                      y: -230
                      width: 509
                      height: 30
                      text: ""
                  }
                  IconButton {
                      id: saveMoment
                      y: 9
                      width: 44
                      height: 36
                      anchors.leftMargin: 300
                      anchors.bottomMargin: 15
                      icon: IconType.save
                      anchors.left: parent.left
                      anchors.bottom: parent.bottom

                      visible: (rect.actionPage) ? true: false

                      size: dp(26)
                      onClicked: {

                          var jsonString2= "";
                          var tm1 = new Date().toLocaleString(Qt.locale,"MM-dd-yyyy");
                          //var tm1 = Qt.formatDateTime(new Date(), "yyMMddHHMMss");
                          for(var i = 0; i < mapModel.count; i++){
                               jsonString2= JSON.stringify(mapModel.get(i));
                               localStorage.setValue("mmt_"+tm1+"_"+i,jsonString2);
                          }
                          var dotstr="";
                          for(var i = 0; i < mapModel.count; i++)
                                dotstr = dotstr+"\n"+localStorage.getValue("mmt_"+tm1+"_"+i);

                          var ts=localStorage.getValue("moments");
                          localStorage.setValue("moments","");
                          localStorage.setValue("moments",ts+","+tm1+"_"+mapModel.count);

                          page.title = "Moment "+tm1+" Saved";
                          aptext.text = "moment: "+dotstr;
                    }
                  }


                  Rectangle {
                      id:loadBox
                      property variant items: [1, 2, 3, 4, 5,6,7,8,9,10]

                      signal comboClicked;
                      x: 230
                      y: 12
                      width: 45
                      height: 30;
                      z: 0
                      smooth:true;

                      Rectangle {
                          id:chosenMoment
                          x: 0
                          y: 0
                          radius:4;
                          width:parent.width;
                          height:loadBox.height;
                          color: "lightblue"
                          smooth:true;

                          IconButton {
                              id: loadMoment
                              icon: IconType.arrowup
                              anchors.verticalCenter: parent.verticalCenter
                              anchors.horizontalCenter: parent.horizontalCenter

                           }
                          MouseArea {

                              anchors.fill: parent
                              anchors.bottomMargin: 0
                              onClicked: {
                                  loadBox.state = loadBox.state==="dropDown"?"":"dropDown"
                              }
                          }
                      }
                      Rectangle {
                          id:loadDropDown
                          width:loadBox.width;
                          height:0;
                          clip:true;
                          radius:4;
                          anchors.bottom: chosenMoment.top;
                          anchors.margins: 2;
                          color: "lightblue"

                          ListView {
                              id:loadListView
                              height:500;
                              model: loadBox.items
                              currentIndex: 0
                              delegate: Item{
                                  width:loadBox.width;
                                  height: loadBox.height;


                                  Text {
                                      text: modelData
                                      anchors.top: parent.top;
                                      anchors.left: parent.left;
                                      anchors.margins: 5;

                                  }
                                  MouseArea {
                                      anchors.fill: parent;
                                      onClicked: {
                                          //Clear Moment
                                          //localStorage.setValue("moments","");
                                          mapModel.clear();
                                          loadBox.state = ""
                                          loadListView.currentIndex = index;
                                          page.title = "Loaded Moment " + modelData;
                                          layer.enabled = false
                                          var i = parseInt(modelData);
                                          var mmtstr=localStorage.getValue("moments");
                                          var mmts = mmtstr.split(',');   // dropdown list, can select moments (from 1 to many)
                                          var m=mmts[i].split('_');      // now seledt moment #2
                                          page.title = "Loaded Moment "+m[0]
                                          var elat=0;
                                          var elong=0;
                                          for(var j = 0; j < m[1]; j++){
                                               var dot = JSON.parse(localStorage.getValue("mmt_"+m[0]+"_"+j));
                                               if(dot.eLat != 0)   elat=dot.eLat
                                               if(dot.eLong != 0)  elong=dot.eLong
                                               mapModel.append({lat : dot.lat, longi: dot.longi, c: dot.c, r: dot.r, s: dot.s, o: 1 });
                                               mapModel.append({lat : elat, longi: elong, c: dot.c, r: dot.r, s: dot.s, o: 0.5 });

                                          }

                                      }
                                  }
                              }
                          }
                      }


                      states: State {
                          name: "dropDown";
                          PropertyChanges { target: loadDropDown; height:30*loadBox.items.length }
                      }

                      transitions: Transition {
                          NumberAnimation { target: loadDropDown; properties: "height"; easing.type: Easing.OutExpo; duration: 1000 }
                      }
                  }

                  IconButton {
                      id: goToInteractions
                      y: 16
                      width: 44
                      height: 36
                      anchors.leftMargin: 300
                      anchors.bottomMargin: 15
                      icon: IconType.caretright
                      anchors.left: parent.left
                      anchors.bottom: parent.bottom

                      size: dp(26)
                      onClicked:{
                          if(!rect.actionPage){
                              rect.actionPage = true;
                              visible = false;
                              page.title = "Select Single Action or Interaction"
                              loadBox.visible = false;
                              deleteDot.visible = false;
                              comboBox.visible = false;
                              sizeComboBox.visible = false;
                              actionComboBox.visible = true;
                          }

                      }


                  }

                  // Drop a shadow on bottom of header
                  Rectangle {
                    anchors.top: parent.top
                    width: parent.width
                    height: dp(5)

                    gradient: Gradient {
                      GradientStop { position: 0.0; color: "#33000000" }
                      GradientStop { position: 1.0; color: "transparent" }
                    }
                  }

                }

          Rectangle {
              id:comboBox
              property variant items: ["Red-Lion", "Green-Elephant", "Blue-Hartebeest", "Magenta-Zebra", "S. Blue-Gazelle", "Yellow-Warthog", "Black-Topi"]

              signal comboClicked;
              x: 0
              y: 0
              width: 141
              height: 30;
              z: 0
              smooth:true;

              Rectangle {
                  id:chosenItem
                  radius:4;
                  width:parent.width;
                  height:comboBox.height;
                  color: "#1ca5d1"
                  smooth:true;
                  Text {
                      anchors.top: parent.top;
                      anchors.margins: 8;
                      id:chosenItemText
                      x: 11
                      y: 5
                      color: "#ffffff"
                      text:"Select Species";
                      anchors.topMargin: 5
                      anchors.left: parent.left
                      anchors.leftMargin: 5
                      font.family: "Lato"
                      font.pointSize: 11;
                      smooth:true
                  }

                  MouseArea {
                      width: 400
                      height: 30
                      anchors.rightMargin: 0
                      anchors.leftMargin: 0
                      anchors.topMargin: 0
                      anchors.bottomMargin: 0
                      anchors.fill: parent;
                      onClicked: {
                          comboBox.state = comboBox.state==="dropDown"?"":"dropDown"
                      }
                  }
              }

              Rectangle {
                  id:dropDown
                  width:comboBox.width;
                  height:0;
                  clip:true;
                  radius:4;
                  anchors.top: chosenItem.bottom;
                  anchors.margins: 2;
                  color: "lightblue"

                  ListView {
                      id:listView
                      height:500;
                      model: comboBox.items
                      currentIndex: 0
                      delegate: Item{
                          width:comboBox.width;
                          height: comboBox.height;


                          Text {
                              text: modelData
                              anchors.top: parent.top;
                              anchors.left: parent.left;
                              anchors.margins: 5;

                          }
                          MouseArea {
                              anchors.fill: parent;
                              onClicked: {
                                  comboBox.state = ""
                                  chosenItemText.text = modelData;
                                  listView.currentIndex = index;
                                  rect.speciesColor = (index+1);
                                  rect.speciesName = (index+1);
                                  page.title = "Select Herd Size"
                              }
                          }
                      }
                  }
              }


              states: State {
                  name: "dropDown";
                  PropertyChanges { target: dropDown; height:30*comboBox.items.length }
              }

              transitions: Transition {
                  NumberAnimation { target: dropDown; properties: "height"; easing.type: Easing.OutExpo; duration: 1000 }
              }
          }

          Rectangle {
              id:sizeComboBox
              property variant items: ["1", "2", "3-5", "6-9", "10-49", "50-99", "100-499", "500+"]

              signal comboClicked;
              x: 234
              y: 0
              width: 141
              height: 30;
              z: 0
              smooth:true;

              Rectangle {
                  id:chosenSize
                  radius:4;
                  width:parent.width;
                  height:sizeComboBox.height;
                  color: "#1ca5d1"
                  smooth:true;
                  Text {
                      anchors.top: parent.top;
                      anchors.margins: 8;
                      id:chosenSizeText
                      x: 11
                      y: 5
                      color: "#ffffff"
                      text:"Select Size";
                      anchors.topMargin: 5
                      anchors.left: parent.left
                      anchors.leftMargin: 28
                      font.family: "Lato"
                      font.pointSize: 11;
                      smooth:true
                  }

                  MouseArea {
                      width: 400
                      height: 30
                      anchors.rightMargin: 0
                      anchors.leftMargin: 0
                      anchors.topMargin: 0
                      anchors.bottomMargin: 0
                      anchors.fill: parent;
                      onClicked: {
                          sizeComboBox.state = sizeComboBox.state==="dropDown"?"":"dropDown"
                      }
                  }
              }

              Rectangle {
                  id:sizeDropDown
                  width:sizeComboBox.width;
                  height:0;
                  clip:true;
                  radius:4;
                  anchors.top: chosenSize.bottom;
                  anchors.margins: 2;
                  color: "lightblue"

                  ListView {
                      id:sizeListView
                      height:500;
                      model: sizeComboBox.items
                      currentIndex: 0
                      delegate: Item{
                          width:sizeComboBox.width;
                          height: sizeComboBox.height;


                          Text {
                              text: modelData
                              anchors.top: parent.top;
                              anchors.left: parent.left;
                              anchors.margins: 5;

                          }
                          MouseArea {
                              anchors.fill: parent;
                              onClicked: {
                                  sizeComboBox.state = ""
                                  chosenSizeText.text = modelData;
                                  sizeListView.currentIndex = index;
                                  rect.speciesSize = index;
                                  page.title = "Select Location"
                              }
                          }
                      }
                  }
              }


              states: State {
                  name: "dropDown";
                  PropertyChanges { target: sizeDropDown; height:30*sizeComboBox.items.length }
              }

              transitions: Transition {
                  NumberAnimation { target: sizeDropDown; properties: "height"; easing.type: Easing.OutExpo; duration: 1000 }
              }
          }

          Storage {
            id: localStorage
          }

          AppImage{

              id: singleActionButton
              x: 317
              y: 0
              width: 58
              height: 54
              visible: (rect.actionPage)? true: false
              source: "../assets/single.png"
              layer.enabled: false
              layer.effect: glowEffect

              Component {
                   id: glowEffect
                   Glow { radius: 10; samples: 17; color: Qt.rgba(1,1,0,0.5) }
              }

              MouseArea{
                  anchors.fill: parent
                  onClicked:{
                      rect.singleAction = true
                      singleActionButton.layer.enabled = true
                      page.title = "Select Animal"
                      interactionButton.layer.enabled = false
                  }
              }
           }

          AppImage{

              id: interactionButton
              x: 324
              y: 60
              width: 51
              height: 49
              visible: (rect.actionPage)? true: false
              source: "../assets/double.png"
              layer.enabled: false
              layer.effect: gloEffect

              Component {
                   id: gloEffect
                   Glow { radius: 16; samples: 17; color: Qt.rgba(1,1,0,0.5) }
              }

              MouseArea{
                  anchors.fill: parent
                  onClicked:{
                      rect.singleAction = false
                      interactionButton.layer.enabled = true
                      page.title = "Select Initiator Animal"
                      singleActionButton.layer.enabled = false
                  }
              }
           }

          Rectangle {
              id:actionComboBox
              property variant items: ["Predation", "Scavenging", "Food Competition", "Parasite", "Physical Competition"]

              signal comboClicked;
              x: 0
              y: 0
              width: 141
              height: 30;
              z: 0
              smooth:true;
              visible: false;

              Rectangle {
                  id:actionItem
                  radius:4;
                  width:parent.width;
                  height:actionComboBox.height;
                  color: "#1ca5d1"
                  smooth:true;
                  Text {
                      anchors.top: parent.top;
                      anchors.margins: 8;
                      id:actionText
                      x: 11
                      y: 5
                      color: "#ffffff"
                      text:"Select Action";
                      anchors.topMargin: 5
                      anchors.left: parent.left
                      anchors.leftMargin: 3
                      font.family: "Lato"
                      font.pointSize: 9;
                      smooth:true
                  }

                  MouseArea {
                      width: 400
                      height: 30
                      anchors.rightMargin: 0
                      anchors.leftMargin: 0
                      anchors.topMargin: 0
                      anchors.bottomMargin: 0
                      anchors.fill: parent;
                      onClicked: {
                          actionComboBox.state = actionComboBox.state==="dropDown"?"":"dropDown"
                      }
                  }
              }

              Rectangle {
                  id:actionDropDown
                  width:actionComboBox.width;
                  height:0;
                  clip:true;
                  radius:4;
                  anchors.top: actionItem.bottom;
                  anchors.margins: 2;
                  color: "lightblue"

                  ListView {
                      id:actionList
                      height:500;
                      model: actionComboBox.items
                      currentIndex: 0
                      delegate: Item{
                          width:actionComboBox.width;
                          height: actionComboBox.height;


                          Text {
                              text: modelData
                              anchors.top: parent.top;
                              anchors.left: parent.left;
                              anchors.margins: 5;

                          }
                          MouseArea {
                              anchors.fill: parent;
                              onClicked: {
                                  actionComboBox.state = ""
                                  actionText.text = modelData;
                                  actionList.currentIndex = index;
                                  rect.chosenAction = index;
                                  page.title = "Select Action Location"
                              }
                          }
                      }
                  }
              }


              states: State {
                  name: "dropDown";
                  PropertyChanges { target: actionDropDown; height:30*actionComboBox.items.length }
              }

              transitions: Transition {
                  NumberAnimation { target: actionDropDown; properties: "height"; easing.type: Easing.OutExpo; duration: 1000 }
              }
          }
      }//Rectangle
    }
  }
}
