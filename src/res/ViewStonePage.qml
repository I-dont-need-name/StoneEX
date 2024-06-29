import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.StoneEX 1.0
import SqlUtils 1.0
import DocumentBuilder 1.0
import ua.nure.makarov.StoneEX 1.0 as Backend
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.15 as Effects

Kirigami.ScrollablePage{

    id: page
    property bool unsavedChanges: false
    property int stoneID
    property var selectedMinerals: []
    title: thisStone.name
    verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn
    actions.left:
        Kirigami.Action{
        id: actionPrint
        text: "Form Document"
        iconName: "document-scan"
        visible: true
        onTriggered: {
            DocumentBuilder.buildStoneDocument(stoneID)
        }
    }


    actions.main:
        Kirigami.Action {
            id: actionEdit
            text: "Edit"
            iconName: "edit-rename"
            visible: true
            checkable: true
        }
    actions.right:
        Kirigami.Action {
            text: "Delete"
            iconName: "delete"
            visible: true
            onTriggered: {
                promptDialog.open()
            }
        }

    actions.contextualActions: [
        Kirigami.Action{
            id: actionFeaturedEvents
            text: "Is featured in " + SqlUtils.countStoneEvents(thisStone.stone_id) + " events"
            iconName: "view-calendar"
            onTriggered: {
                var viewPage = Qt.createComponent("qrc:EventPage.qml").createObject(this, {externalCondition: " Event_collection IN (SELECT collection_id FROM \"Stone-Collection\" WHERE Stone_id= " + thisStone.stone_id +") ",
                                                                                         title: "Events with " + thisStone.name});
                pageStack.layers.push(viewPage);
            }
        }
    ]


    Kirigami.PromptDialog {
            id: promptDialog
            title: "Delete Stone"
            subtitle: "This stone will be deleted from the database. Forever and ever! (Close to cancel)"

            footer:
            Controls.DelayButton{
                id: deleteHolder
                text: "Hold to delete"
                icon.name: "delete"
                delay: 1200
                onActivated: {
                    SqlUtils.deleteStone(thisStone.stone_id);
                    promptDialog.close()
                    pageStack.layers.pop(1);
                }
            }
        }

    onIsCurrentPageChanged: {
        if(isCurrentPage){
            thisStone.stone_id = thisStone.stone_id;
            localMineralModel.refreshModel();
            console.log(title)
            console.log(thisStone.name)
            console.log(thisStone)
            if(thisStone.name === ""){
                console.log("taki null");
                deleteHolder.activated();
                console.log("innit?");
            }
        }
    }

    Kirigami.Dialog {
            id: selectDialog
            title: "Mineral selection"
            preferredWidth: Kirigami.Units.gridUnit * 16
            ListView{
                model: MineralPageModel
                delegate: Controls.CheckDelegate{
                    property int res: selectedMinerals.indexOf(model.mineralID)
                    checked: {
                        if (res > -1){
                            return true
                        }
                        else return false
                    }
                    Layout.fillWidth: true
                    implicitWidth: parent.width
                    topPadding: Kirigami.Units.smallSpacing * 2
                    bottomPadding: Kirigami.Units.smallSpacing * 2
                    text: model.display
                    onCheckedChanged: {
                        if (this.checked && selectedMinerals.indexOf(model.mineralID) == -1){
                            selectedMinerals.push(model.mineralID);
                            console.log(selectedMinerals);
                            page.unsavedChanges = true
                        }
                        else if (!checked && selectedMinerals.indexOf(model.mineralID) != -1 && selectedMinerals.length==1){
                            checked = true
                            console.log(selectedMinerals);
                        }
                        else if (!checked) {
                             selectedMinerals.forEach(element => {
                                                      if (element == model.mineralID){
                                                            var index = selectedMinerals.indexOf(element);
                                                            selectedMinerals.splice(index, 1);
                                                            page.unsavedChanges = true
                                                            console.log(selectedMinerals);
                                                          }
                                                      });
                        }
                    }
                }
            }
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        folder: shortcuts.home
        onAccepted: {
            console.log("You chose: " + fileDialog.fileUrl)
            preview.source = fileDialog.fileUrl.toString()
            onTextEdited: page.unsavedChanges = true
        }
        onRejected: {
            console.log("Canceled")
        }
    }

    Backend.Stone{
        id: thisStone
        stone_id: stoneID
    }

    Backend.MineralViewModel{
        id: localMineralModel
        myQuery: "SELECT * FROM Minerals WHERE Mineral_id IN (SELECT Mineral_id FROM \"Stone-Minerals\" WHERE Stone_id=" + parseInt(stoneID) + ")";
    }

    Kirigami.InlineMessage{
        id: saveNotifier
        Layout.fillWidth: true

        visible: page.unsavedChanges

        text: "You have unsaved changes"

        actions: [
                Kirigami.Action {
                    enabled: unsavedChanges > 0

                    text: qsTr("Save")
                    icon.name: "answer"

                    visible: unsavedChanges >0
                    onTriggered: {
                        //POSSIBLE BUG IN FRAMEWORK, && CONDITION SAYS "NOT A FUNCTION"
                        if (SqlUtils.updateStone(thisStone.stone_id,
                                nameEdit.text, descEdit.text, colorEdit.text, originEdit.text,
                                parseFloat(priceEdit.text), shapeEdit.text, weightEdit.value, preview.source, page.selectedMinerals))
                        {
                            success.visible = true;
                            unsavedChanges = false;
                            thisStone.stone_id = thisStone.stone_id
                            localMineralModel.refreshModel();
                        }
                        else failure.visible = true
                    }
                },
                Kirigami.Action {
                    enabled: unsavedChanges >0

                    text: qsTr("Reset")
                    icon.name: "list-remove"

                    onTriggered: {

                        nameEdit.text = thisStone.name
                        descEdit.text = thisStone.description
                        colorEdit.text = thisStone.color
                        originEdit.text = thisStone.origin
                        weightEdit.value = thisStone.weigth
                        priceEdit.text = thisStone.price
                        shapeEdit.shape = thisStone.shape
                        preview.source = thisStone.image
                        page.unsavedChanges = false;
                    }
                }
        ]
    }

    Kirigami.InlineMessage{
        id: success
        text: "Changes successfull"
        Layout.fillWidth: true
        visible: false
        anchors.top: saveNotifier.bottom
        type: Kirigami.MessageType.Positive
        showCloseButton: true

    }

    Kirigami.InlineMessage{
        id: failure
        text: "Mistakes were made..."
        Layout.fillWidth: true
        visible: false
        type: Kirigami.MessageType.Error
        showCloseButton: true

    }


    GridLayout{
        anchors.top: success.bottom
        id: layout
        columns: 2
        rows:  14
        flow: GridLayout.TopToBottom
        //rowSpacing: Kirigami.Units.smallSpacing


        Kirigami.Heading{
            text: thisStone.name

        }
        Controls.TextField {
            id: nameEdit
            placeholderText: "Name"
            text: thisStone.name
            visible: actionEdit.checked
            onTextEdited: {
                if(text != thisStone.name){
                    page.unsavedChanges = true
                }
            }
        }
        Controls.Label{
            text: "Color: " + thisStone.color
        }
        Controls.TextField{
            id: colorEdit
            placeholderText: "Color"
            text: thisStone.color
            visible: actionEdit.checked
            onTextEdited: {
                if(text != thisStone.color){
                    page.unsavedChanges = true
                }
            }
        }
        Controls.Label{
            text: "Origin: " + thisStone.origin
        }
        Controls.TextField{
            id: originEdit
            implicitWidth: Kirigami.Units.gridUnit * 12
            placeholderText: "Place of origin"
            text: thisStone.origin
            visible: actionEdit.checked
            onTextEdited: {
                if(text != thisStone.origin){
                    page.unsavedChanges = true
                }
            }
        }
        Controls.Label{
            text: "Price: " + thisStone.price + "$"
        }

        Controls.TextField{
            id: priceEdit
            placeholderText: "Price in dollars"
            visible: actionEdit.checked
            text: thisStone.price
            onTextEdited: {page.unsavedChanges = true}
            validator: RegularExpressionValidator { regularExpression: /(\d{1,5})([.]\d{1,2})?$/ }
        }
        Controls.Label{
            text: "Weight: " + thisStone.weigth + " carat"
        }

        Controls.SpinBox{
            id: weightEdit
            from: 0
            to: 9999
            visible: actionEdit.checked
            value: thisStone.weigth
            onValueModified:  {page.unsavedChanges = true}
        }
        Controls.Label{
            text:  "Shape: " + thisStone.shape
        }

        Controls.TextField{
            id: shapeEdit
            placeholderText: "Shape"
            text: thisStone.shape
            visible: actionEdit.checked
            onTextEdited: {page.unsavedChanges = true}
        }



        Image {

            Layout.rowSpan: 14
            id: preview
            Layout.column: 1
            sourceSize.height: 512
            sourceSize.width: 512
            width: 512
            height: 512
            source: thisStone.image

            MouseArea{
                id: imageClicker
                anchors.fill: preview
                enabled: actionEdit.checked

                onClicked: {
                    fileDialog.open()
                }
                Rectangle{
                    id: imageOverlay
                    color: "gray"
                    anchors.fill: parent
                    visible: actionEdit.checked
                    opacity: 0.6
                }
                Kirigami.Icon{
                    id: imageIcon
                    source: "insert-image"
                    anchors.centerIn: parent
                    visible: actionEdit.checked
                    opacity: 1
                }
            }
        }
    }
    Controls.Frame{
        id: mineralFrame
        anchors.top: layout.bottom

        //Layout.rowSpan: 6
        //Layout.columnSpan: 2
        //Layout.fillWidth: true
        //Layout.fillHeight: true
        //Layout.row: actionEdit.checked ? 8 : 6
        //Layout.column: actionEdit.checked ? 1 : 0
        implicitHeight: Kirigami.Units.gridUnit * 6
        ListView{
            clip: true
            anchors.fill: parent
            id: mineralList
            interactive: true
            //height:del.height
            width: page.width
            model: localMineralModel
            spacing: Kirigami.Units.largeSpacing
            orientation: ListView.Horizontal
            delegate: Rectangle{
                property string value: model.valuability
                clip: true
                layer.enabled: true
                color: {
                    if (value == 0){
                        return "#889a79"
                    }
                    if (value > 0 && value < 3){
                        return "#6e9a67"
                    }
                    if (value >= 3){
                        return "orange"
                    }
                }
                implicitHeight: parent.height
                implicitWidth: nameHeading.width * 2
                radius: 6
                Component.onCompleted: {
                    if(selectedMinerals.indexOf(model.mineralID) == -1){
                        selectedMinerals.push(model.mineralID);
                        console.log(selectedMinerals);
                    }
                }
                Kirigami.Heading{
                    id: nameHeading
                    text: model.display
                    layer.enabled: true
                    layer.effect: Effects.DropShadow {
                        transparentBorder: true
                        horizontalOffset: 1
                        verticalOffset: 1
                    }
                }

                Text{
                    id: descLabel
                    anchors.top: nameHeading.bottom
                    wrapMode: Text.WrapAnywhere
                    text: model.description
                    width : parent.width
                    height: parent.height
                }

                MouseArea{
                    anchors.fill: parent
                    enabled: !actionEdit.checked
                    onClicked: {
                        console.log("clicked")
                        var viewPage = Qt.createComponent("qrc:ViewMineralPage.qml").createObject(this, {mineralID: model.mineralID });
                        pageStack.layers.push(viewPage)
                    }
                }
            }


            Rectangle{
                color: "gray"
                visible: actionEdit.checked
                anchors.fill: mineralList
                opacity: 0.8
            }
            Controls.Button{
                text: "Change selected minerals"
                visible: actionEdit.checked
                icon.name: "document-edit"
                anchors.centerIn: mineralList
                onClicked: {
                    selectDialog.open()
                }
            }
        }
    }
    Controls.TextArea{
        anchors.top: mineralFrame.bottom
        anchors.margins: Kirigami.Units.smallSpacing
        id: descEdit
        text: thisStone.description
        implicitHeight: Kirigami.Units.gridUnit * 6
        readOnly: !actionEdit.checked
        onTextChanged: {
            if(text != thisStone.description){
                page.unsavedChanges = true
            }
        }
    }
}
