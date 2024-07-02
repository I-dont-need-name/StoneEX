import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.StoneEX 1.0
import SqlUtils 1.0
import ua.nure.makarov.StoneEX 1.0 as Backend

Kirigami.ScrollablePage{
    id: page
    title: thisCollection.name

    property var selectedStones: []
    property int collectionID

    Backend.Collection{
        id: thisCollection
        collection_id: collectionID
    }

    Kirigami.PromptDialog {
            id: promptDialog
            title: "Delete collection"
            subtitle: "This collection will be deleted from the database. THIS ACTION WILL ALSO DELETE EVENTS WITH THIS COLLECTION! (Close to cancel)"

            footer:
            Controls.DelayButton{
                text: "Hold to delete"
                icon.name: "delete"
                delay: 1200
                onActivated: {
                    if (SqlUtils.deleteCollection(collectionID)){
                        promptDialog.close()
                        pageStack.layers.pop(1);
                    }
                }
            }
        }

    actions: [
        Kirigami.Action {
            id: actionEdit
            text: "Edit"
            icon.name: "edit-rename"
            visible: !checked
            checkable: true
        },

        Kirigami.Action {
            id: actionSave
            text: "Save"
            icon.name: "answer"
            visible: actionEdit.checked
            onTriggered: {
                if (SqlUtils.updateCollection(thisCollection.collection_id, nameEdit.text, descEdit.text)){
                    SqlUtils.purgeCollectionStones(thisCollection.collection_id);
                    SqlUtils.linkCollectionStones(selectedStones, thisCollection.collection_id);
                    actionEdit.checked = false;
                    thisCollection.collection_id = thisCollection.collection_id
                    page.selectedStones = []
                    localStoneModel.refreshModel()
                    uniCounter.text = SqlUtils.countCollectionMinerals(thisCollection.collection_id) + " Unique minerals";
                }
            }
        },

        Kirigami.Action {
            text: actionEdit.checked ? "Discard" : "Delete"
            icon.name: actionEdit.checked ? "dialog-cancel" : "delete"
            visible: true
            onTriggered: {
                if (actionEdit.checked){
                    page.selectedStones = []
                    actionEdit.checked = false

                }
                else    promptDialog.open()
            }
        }
    ]
    Backend.StoneViewModel{
        id: localStoneModel
        property string query: "SELECT * FROM Stones WHERE Stone_id IN (SELECT Stone_id FROM \"Stone-Collection\" WHERE Collection_id =" + collectionID.toString() + ") AND Stone_name LIKE '%" + searcher.text + "%'"
        myQuery: query
    }

    Backend.StoneViewModel{
        id: localAllStoneModel
        myQuery: "SELECT * FROM Stones WHERE Stone_name LIKE '%" + searcher.text + "%'"
    }

    implicitWidth: applicationWindow().width
    ColumnLayout{
        id: layout

        Layout.fillWidth: true
        Layout.fillHeight: true
        anchors.fill: page
        Kirigami.Heading{
            text: thisCollection.name
            visible: !actionEdit.checked
        }
        Controls.TextField {
            id: nameEdit
            placeholderText: "Name"
            text: thisCollection.name
            visible: actionEdit.checked
        }
        Controls.Label{
            text: thisCollection.description
            visible: !actionEdit.checked
        }
        Controls.TextArea{
            id: descEdit
            text: thisCollection.description
            visible: actionEdit.checked
            placeholderText: "Description"
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 12
            Layout.minimumHeight: Kirigami.Units.gridUnit * 8
        }
        Controls.Label{
            id: uniCounter
            text: SqlUtils.countCollectionMinerals(thisCollection.collection_id) + " Unique minerals"
        }
        Kirigami.SearchField{
            id: searcher
            Layout.alignment: Qt.AlignHCenter
            placeholderText: "Search for stones..."
        }
        Controls.Frame{
            Layout.fillWidth: true
            Layout.fillHeight: true
            //anchors.bottom: layout.bottom
            clip: true
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
                        implicitHeight: page.height * 0.8
                        flow: GridView.LeftToRight
                        model: actionEdit.checked ? localAllStoneModel : localStoneModel
                        cellWidth: Kirigami.Units.gridUnit * 13
                        cellHeight: Kirigami.Units.gridUnit * 17
                        delegate:
                            Kirigami.AbstractCard{

                            id: card
                            showClickFeedback: true
                            checkable: actionEdit.checked
                            width: Kirigami.Units.gridUnit * 12
                            height: Kirigami.Units.gridUnit * 16
                            checked: {
                                if(actionEdit.checked && selectedStones.indexOf(model.stoneID) != -1){
                                    return true;
                                }
                                else return false
                            }

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
                                opacity: 0.7
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
                                width: card.width
                                anchors.top: img.bottom
                                wrapMode: Text.WrapAnywhere
                                text: model.description
                                maximumLineCount: 6
                            }
                            Component.onCompleted: {
                                if(searcher.text == "" && selectedStones.indexOf(model.stoneID) == -1 && !actionEdit.checked){
                                    selectedStones.push(model.stoneID);
                                    console.log(selectedStones);
                                }
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
                            onClicked: {
                                if(!actionEdit.checked){
                                    var viewPage = Qt.createComponent("qrc:ViewStonePage.qml").createObject(this, {stoneID: model.stoneID });
                                    pageStack.layers.push(viewPage)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
