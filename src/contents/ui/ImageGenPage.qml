import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.StoneEX 1.0
import ua.nure.makarov.StoneEX 1.0 as Backend
//import QtGraphicalEffects 1.15 as Effects
import QtQuick.Dialogs as Dialogs

Kirigami.Page{
    id: page
    title: "Media image search + generator"

    Dialogs.FileDialog{
        id: saveDialog
        //selectExisting: false
        //selectMultiple: false
        nameFilters: [ "Image files (*.jpg *.png, *.jpeg)", "All files (*)" ]
        onAccepted: {
            poster.grabToImage(function (result) {
                        var path = saveDialog.fileUrl.toString();
                        path = path.slice(7);
                        console.log(path);
                        result.saveToFile(path);
                    });
        }
        onRejected: {}
    }

    property string query;
    property string selectedImageUrl;
    property string name: "";
    property string description;
    property string hours: "";
    property string dates: "";
    property string address: "";


    actions: [
        Kirigami.Action{
            text: "Save Image"
            icon.name: "viewimage"
            onTriggered: {
                saveDialog.open()
            }
        }
    ]
    Backend.InternetImageModel{
        id: localImageModel
        query: page.query
    }
    Kirigami.SearchField{
        id: customSearch
        anchors.top: imageScrollView.top
        placeholderText: "Try another query"
        onEditingFinished: {
            page.query = text
        }
        z: 4
    }
        Controls.ScrollView{
            clip: true
            id: imageScrollView
            height: page.height*0.4
            width: page.width * 0.9
            Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOn
            ListView{
                id: imageSearchList

                interactive: true

                orientation: ListView.Horizontal
                anchors.fill: parent
                model: localImageModel
                delegate: Image {
                    id: img
                    source: model.imageURL
                    height: imageSearchList.height
                    width: page.width*0.4
                    fillMode: Image.PreserveAspectFit
                    MouseArea{
                        onClicked:{
                            selectedImageUrl=model.imageURL
                            poster.visible = true
                        }
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                    }
                }
        }
    }
    Image{
        id: poster
        visible: false
        anchors.top: imageScrollView.bottom
        source: selectedImageUrl
        Layout.fillWidth: true
        height: page.height*0.5
        Kirigami.Heading{
            id: nameHeading
            anchors.top: parent.top
            text: name
            z:5
        }
        Rectangle{
            id: upperGradient
            anchors.fill: nameHeading
            width: nameHeading.width * 1.4
            gradient: Gradient{
                orientation: Gradient.Horizontal
                GradientStop { position: 0.1; color: "black" }
                GradientStop { position: 0.8; color: "#94000000" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
        Rectangle{
            anchors.right: parent.right
            anchors.bottom: lowerGradient.top
            height: addressLabel.height * 1.2
            width: addressLabel.width *1.3

            gradient: Gradient{
                orientation: Gradient.Horizontal
                GradientStop { position: 1.0; color: "black" }
                GradientStop { position: 0.1; color: "#94000000" }
                GradientStop { position: 0.0; color: "transparent" }
            }
            Kirigami.Heading{
                anchors.right: parent.right
                id: addressLabel
                color: "#dfdfdf"
                text: address
                horizontalAlignment: Text.AlignRight
            }
        }
        Rectangle{
            id: lowerGradient
            anchors.bottom: parent.bottom
            width: parent.width
            height: parent.height*0.5
            gradient: Gradient{
                GradientStop { position: 0.0; color: "transparent" }
                //GradientStop { position: 0.6; color: "transparent" }
                GradientStop { position: 0.2; color: "#94000000" }
                GradientStop { position: 1.0; color: "black" }
            }
            Controls.Label{
                color: "white"
                verticalAlignment: Text.AlignBottom
                wrapMode: Text.WordWrap
                anchors.fill: parent
                text: description
                style: Text.Outline
                styleColor: "#33000000"
            }
        }
        Column{
            anchors.top: parent.top
            anchors.margins: upperGradient.height
            Rectangle{
                anchors.top: upperGradient.bottom
                height: datesLabel.height * 2
                width: datesLabel.width * 2
                gradient: Gradient{
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "black" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                Kirigami.Heading{
                    id: datesLabel
                    color: "#dfdfdf"
                    text: dates
                }
            }
            Rectangle{
                height: hoursLabel.height * 2
                width: hoursLabel.width * 2

                gradient: Gradient{
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "black" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                Kirigami.Heading{
                    id: hoursLabel
                    color: "#dfdfdf"
                    text: hours
                }
            }
        }
    }
}

