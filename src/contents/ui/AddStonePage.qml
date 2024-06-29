import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.StoneEX 1.0
import SqlUtils 1.0

Kirigami.ScrollablePage{
    id: page
    clip: true
    title: "Add stone"
    implicitWidth: applicationWindow().width

    property var selectedMinerals: []

    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        folder: shortcuts.home
        onAccepted: {
            console.log("You chose: " + fileDialog.fileUrl)

            preview.source = fileDialog.fileUrl.toString()
        }
        onRejected: {
            console.log("Canceled")
        }
    }


    Kirigami.Dialog {
            id: selectDialog
            title: "Mineral selection"
            preferredWidth: Kirigami.Units.gridUnit * 22
            preferredHeight: Kirigami.Units.gridUnit * 20
            ListView{
                implicitHeight: selectDialog.height
                implicitWidth: selectDialog.width*0.5
                id: listik
                model: MineralPageModel
                delegate: Controls.CheckDelegate{

                    implicitWidth: selectDialog.width
                    topPadding: Kirigami.Units.smallSpacing * 2
                    bottomPadding: Kirigami.Units.smallSpacing * 2
                    text: model.display
                    checked: false
                    onCheckedChanged: {
                        if (this.checked && selectedMinerals.indexOf(model.mineralID) == -1){
                            selectedMinerals.push(model.mineralID);
                            console.log(selectedMinerals);
                        }
                        else if (!checked) {
                             selectedMinerals.forEach(element => {
                                                      if (element == model.mineralID){
                                                            var index = selectedMinerals.indexOf(element);
                                                            selectedMinerals.splice(index, 1);

                                                          }
                                                      });
                        }
                    }
                }

            }
    }

    GridLayout{
        id: layout
        //Layout.fillWidth: true
        columns: 2
        rows: 14
        flow: GridLayout.TopToBottom
        Controls.Label{
            text: "Enter name"
        }
        Controls.TextField {
            id: nameEdit
            placeholderText: "Name"
        }
        Controls.Label{
            text: "Color:"

        }
        Controls.TextField{
            id: colorEdit
            placeholderText: "Color"
            implicitWidth: Kirigami.Units.gridUnit * 12
            validator: RegularExpressionValidator { regularExpression: /[a-zA-Zа-яА-ЯґєїҐЄЇіІʼ` ]+/ }
        }
        Controls.Label{
            text: "Origin:"
        }
        Controls.TextField{
            id: originEdit
            implicitWidth: Kirigami.Units.gridUnit * 12
            placeholderText: "Place of origin"
        }
        Controls.Label{
            text: "Price"
        }

        Controls.TextField{
            id: priceEdit
            placeholderText: "Price in dollars"
            validator: RegularExpressionValidator { regularExpression: /(\d{1,7})([.]\d{1,2})?$/ }
        }
        Controls.Label{
            text: "Weight"
        }

        Controls.SpinBox{
            id: weightEdit
            from: 0
            to: 9999
        }
        Controls.Label{
            text: "Shape"
        }

        Controls.TextField{
            id: shapeEdit
            placeholderText: "Shape"
        }

        Controls.Label{
            text: "Minerals"
        }
        Controls.Button{
            text: "Edit selection"
            onClicked: {
                selectDialog.open()
            }
        }

        Image {
            Layout.rowSpan: 10
            id: preview
            sourceSize.height: 512
            sourceSize.width: 512
            source: "qrc:/res/stone.png"
        }
        Controls.Button{
            anchors.horizontalCenter: preview.horizontalCenter
            Layout.column: 3
            text: "Select image"
            onClicked:{
                fileDialog.open()
            }
            icon.name: "insert-image"
        }

        /*ListView{
            id: mineralListView
            orientation: ListView.Horizontal
            model: 15
            spacing: 30
            Controls.ScrollBar.horizontal:  Controls.ScrollBar {
                    active: true
            }
            implicitWidth: parent.width
            implicitHeight: Kirigami.Units.gridUnit * 4
            delegate: Rectangle{
                id: del
                color: "steelblue"
                width: Kirigami.Units.gridUnit * 6
                height: Kirigami.Units.gridUnit * 2
                Controls.Label {
                    id: nameLable
                    text: modelData + " Mineral"
                }
            }
        } */


        }
    Controls.TextArea{

        id: descEdit
        anchors.top: layout.bottom
        height: Kirigami.Units.gridUnit * 12
        Kirigami.FormData.label: "Description"
        placeholderText: "Enter description here"
        Layout.minimumWidth: Kirigami.Units.gridUnit * 12
    }
    Controls.Button{
        anchors.top: descEdit.bottom
        anchors.margins: Kirigami.Units.gridUnit
        width: page.width *0.5
        text: "Add"
        enabled: nameEdit.text.length * colorEdit.text.length * originEdit.text.length * descEdit.text.length * shapeEdit.text.length
        icon.name: "list-add"
        onClicked: {
            SqlUtils.addStone(nameEdit.text, descEdit.text, colorEdit.text, originEdit.text, parseFloat(priceEdit.text), shapeEdit.text, weightEdit.value, fileDialog.fileUrl);
            var stone_id = SqlUtils.getLatestRowId();
            for(var i =0; i < selectedMinerals.length; i++){
                SqlUtils.linkStoneToMineral(stone_id, selectedMinerals[i]);
            }
            pageStack.layers.pop(1);
        }
    }
}
