import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.StoneEX 1.0
import ua.nure.makarov.StoneEX 1.0 as Backend

Kirigami.ScrollablePage{
    id: page
    title: "Collections"

    property string selectCondition: " SELECT * FROM Collections "
    property string nameCondition: ""
    property string descCondition: ""

    property string sortCondition: ""

    property var selectedStones: []

    property string stoneFilter: ""
    property var stoneFilterPage

    function combineConditions(selector) {
        var initial = selector + " WHERE Collection_name LIKE '%" + page.nameCondition + "%' "
        if (descCondition != ""){
            initial += " AND Collection_description LIKE '%" + descCondition + "%' "
        }
        if (selectedStones.length != 0){
            initial += " AND Collection_id IN (SELECT Collection_id FROM \"Stone-Collection\" WHERE Stone_id IN (" + selectedStones   +") )"
        }
        if (stoneFilter != ""){
            if(selectedStones.length != 0){
                initial += " OR "
            }
            else {
                initial += "AND "
            }
            initial += " Collection_id IN( SELECT Collection_id FROM \"Stone-Collection\" WHERE Stone_id IN (" + stoneFilter + ") )"
            console.log(initial);
        }
        return initial
    }

    Kirigami.Dialog{
        id: selectDialog
        title: "Stone selection"
        preferredWidth: Kirigami.Units.gridUnit * 22
        preferredHeight: Kirigami.Units.gridUnit * 20
        ListView{
            id: listik
            anchors.fill: parent
            model: Backend.StoneViewModel{

            }
            delegate: Controls.CheckDelegate{
                implicitWidth: selectDialog.width
                topPadding: Kirigami.Units.smallSpacing * 2
                bottomPadding: Kirigami.Units.smallSpacing * 2
                text: model.display
                checked: false

                onCheckedChanged: {
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

    actions.main: Kirigami.Action {
        iconName: "list-add"
        text: "New collection"
        onTriggered: pageStack.layers.push('qrc:AddCollectionPage.qml')
    }
    actions.right: Kirigami.Action {
        id: actionRefresh
        iconName: "view-refresh"
        text: "Refresh"
        onTriggered: {
            localCollectionModel.refreshModel();
        }
    }



    Backend.CollectionViewModel{
        id: localCollectionModel
    }

    ListView{
        model: localCollectionModel

        orientation: ListView.Vertical
        anchors.top: page
        anchors.bottom: page
        headerPositioning: ListView.OverlayHeader
        header: Item {
            implicitHeight: nameSearch.height
            id: header
            z:3
            Kirigami.SearchField{
                id: nameSearch
                placeholderText: "Search in names..."
                onTextChanged: {
                    page.nameCondition = text
                }
            }
            Kirigami.SearchField{
                id: descSearch
                anchors.left: nameSearch.right
                placeholderText: "Search in Descriptions..."
                onTextChanged: {
                    page.descCondition = text
                }
            }
            Controls.Button{
                id: stoneSelectButton
                anchors.left: descSearch.right
                implicitHeight: descSearch.height
                text: "Select stones..."
                onClicked: selectDialog.open()
            }
            Controls.Button{
                id: stoneSearch
                anchors.left: stoneSelectButton.right
                implicitHeight: descSearch.height
                icon.name: "search"
                text: "Set stone conditions"
                onClicked: {
                    if (typeof(stoneFilterPage)=="undefined"){
                        stoneFilterPage = Qt.createComponent("qrc:StonePage.qml").createObject(this);
                    }
                    pageStack.layers.push(stoneFilterPage);
                }
            }
            Controls.Button{
                id: finder
                anchors.left: stoneSearch.right
                implicitHeight: descSearch.height
                icon.name: "search"
                text: "Find"
                onClicked: {
                    if (typeof(stoneFilterPage)!="undefined"){
                        stoneFilter = stoneFilterPage.combineConditions("SELECT Stone_id FROM Stones")
                    }
                    localCollectionModel.myQuery = combineConditions("SELECT * FROM Collections");
                }
            }
            Controls.Button{
                id: searchResetButton
                anchors.left: finder.right
                implicitHeight: finder.height
                text: "Reset filters"
                icon.name: "edit-reset"
                onClicked: {
                    nameSearch.text = ""
                    descSearch.text = ""
                    stoneFilter = ""
                    stoneFilterPage = undefined
                    listik.model.refreshModel()
                    finder.clicked()
                }
            }
        }
        spacing: Kirigami.Units.smallSpacing
        delegate: Kirigami.AbstractCard{
            showClickFeedback: true
            anchors.horizontalCenter: parent.horizontalCenter
            contentItem:
                Item{
                    implicitWidth: delegateLayout.width
                    implicitHeight: delegateLayout.height

                    ColumnLayout{
                        //flow: GridLayout.TopToBottom
                        id: delegateLayout
                        anchors {
                            left: parent.left
                            top: parent.top
                            right: parent.right
                            //IMPORTANT: never put the bottom margin
                        }
                        //rowSpacing: Kirigami.Units.largeSpacing
                        Kirigami.Heading{
                            text: model.display
                        }
                        Controls.Label{
                            Layout.fillWidth: true
                            text: model.description
                            wrapMode: Text.WrapAnywhere
                            maximumLineCount: 3
                        }
                    }
                }
            onClicked: {
                var viewPage = Qt.createComponent("qrc:ViewCollectionPage.qml").createObject(this, {collectionID: model.collection_id});
                pageStack.layers.push(viewPage)
            }
        }
    }

}
