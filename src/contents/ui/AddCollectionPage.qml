import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.StoneEX 1.0
import SqlUtils 1.0
import ua.nure.makarov.StoneEX 1.0 as Backend

Kirigami.ScrollablePage{
    id: page
    title: "Add collection"

    property var selectedStones: []

    Backend.StoneViewModel{
        id: localStoneModel
    }

    implicitWidth: applicationWindow().width
    ColumnLayout{
        id: layout

        Layout.fillWidth: true
        Layout.fillHeight: true
        anchors.fill: page
        Controls.Label{
            text: "Enter name"
        }
        Controls.TextField {
            id: nameEdit
            placeholderText: "Name"
        }
        Controls.Label{
            text: "Enter description: "
        }
        Controls.TextArea{
            id: descEdit
            placeholderText: "Description"
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 12
            Layout.minimumHeight: Kirigami.Units.gridUnit * 8
        }
        Kirigami.SearchField{
            Layout.alignment: Qt.AlignHCenter
            placeholderText: "Search for stones..."
            onAccepted: localStoneModel.myQuery = "SELECT * FROM Stones WHERE Stone_name LIKE '%" + text + "%'"
        }
        Controls.Frame{
            Layout.fillWidth: true
            Layout.fillHeight: true
            //anchors.bottom: layout.bottom
            Controls.ScrollView{
                id: scroller
                Layout.fillWidth: true
                Layout.fillHeight: true
                //height: Kirigami.Units.gridUnit *12
                Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
                //Controls.ScrollBar.vertical.policy: Controls.ScrollBar.AlwaysOn
                //Controls.ScrollBar.horizontal.interactive: true
                //Controls.ScrollBar.vertical.interactive: true
                Column{
                    GridView{
                        id: grid
                        width: page.width
                        Layout.fillHeight: true
                        implicitHeight: Kirigami.Units.gridUnit *22
                        flow: GridView.LeftToRight
                        model: localStoneModel
                        cellWidth: Kirigami.Units.gridUnit * 13
                        cellHeight: Kirigami.Units.gridUnit * 17
                        delegate:
                            Kirigami.AbstractCard{

                            id: card
                            showClickFeedback: true
                            checkable: true
                            width: Kirigami.Units.gridUnit * 12
                            height: Kirigami.Units.gridUnit * 16
                            //clip: true
                            Kirigami.Heading{
                                text: model.display
                                color: "white"
                                z: 4
                            }
                            Rectangle{
                                color: card.checked ? Kirigami.Theme.highlightColor : "black"
                                height: card.height * 0.1
                                width: card.width
                                radius: 3
                                opacity: 0.6
                                z: 3
                            }

                            Image {
                                anchors.top: card.top
                                anchors.margins: 3
                                id: img
                                source: model.imagePath
                                height: card.height * 0.6
                                width: card.width
                                fillMode: Image.PreserveAspectCrop
                                z: 2
                            }
                            Controls.Label {
                                clip: true
                                height: card.height - img.height -3
                                width: card.width
                                anchors.top: img.bottom
                                wrapMode: Text.WrapAnywhere
                                text: model.description
                            }
                            onCheckedChanged:{
                                if (this.checked && selectedStones.indexOf(model.stoneID) == -1){
                                    selectedStones.push(model.stoneID);
                                    console.log(selectedStones);
                                }
                                else if (!checked) {
                                     selectedStones.forEach(element => {
                                                              if (element == model.stoneID){
                                                                    var index = selectedStones.indexOf(element);
                                                                    selectedStones.splice(index, 1);
                                                                    console.log(selectedStones);
                                                                  }
                                                              });
                                }
                            }
                        }
                    }
                }
            }
        }
        Controls.Button{
            id: addButton
            text: "Add"
            icon.name: "list-add"
            enabled:  nameEdit.text.length * descEdit.text.length
            onClicked: {
                if (SqlUtils.addCollection(nameEdit.text, descEdit.text)){
                    var thisCollectionID = SqlUtils.getLatestRowId();
                    SqlUtils.linkCollectionStones(selectedStones, thisCollectionID)
                    pageStack.layers.pop(1);
                }
            }
        }
    }
}
