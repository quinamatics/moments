import QtQuick 2.9
import QtQuick.Window 2.2
import helloworld.FileIO 1.0

Rectangle {
    width: 360
    height: 360
    Text {
        id: myText
        text: "Hello World"
        anchors.centerIn: parent
    }

    FileIO {
        id: myFile
        source: "test.csv"
        onError: console.log(msg)
    }

    Component.onCompleted: {
        console.log( "WRITE"+ myFile.write("TEST,lion,kenya"));
        myText.text =  myFile.read();
    }
}
