import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.StoneEX 1.0
import ua.nure.makarov.StoneEX 1.0 as Backend
import SqlUtils 1.0

Kirigami.ScrollablePage{
    id: page
    property string externalCondition: ""
    title: "Stones"
    property string selectCondition: " SELECT * FROM Stones "
    property string nameCondition: ""
    property string descCondition: ""
    property string colorCondition: ""
    property string originCondition: ""

    property int priceMax: SqlUtils.getMaxStonePrice();
    property int priceConditionMin: 0
    property int priceConditionMax: priceMax

    property var selectedMinerals: []
    property string mineralFilter: ""

    property var mineralFilterPage

    onIsCurrentPageChanged: {
        if(isCurrentPage){
            localStoneModel.refreshModel()
        }
    }

    function combineConditions(selector) {
        var initial = selector + " WHERE Stone_name LIKE '%" + page.nameCondition + "%' "
        if (descCondition != ""){
            initial += "AND Stone_description LIKE '%" + descCondition + "%' "
        }
        if(colorCondition != ""){
            initial += " AND Stone_color LIKE '%" + colorCondition + "%' "
        }
        if(originCondition != ""){
            initial += " AND Stone_origin LIKE '%" + originCondition + "%' "
        }
        if(priceConditionMin == priceConditionMax){
            initial += " AND Stone_price=" + priceConditionMin
        }
        else{
            if(priceConditionMin > 0){
                initial += " AND Stone_price>=" + priceConditionMin
            }
            if(priceConditionMax < priceMax){
                initial += " AND Stone_price<=" + priceConditionMax
            }
        }
        if (selectedMinerals.length != 0){
            var cond = " AND Stone_id IN (SELECT Stone_id FROM \"Stone-Minerals\" WHERE Mineral_id IN (" + selectedMinerals + ") )"
            console.log(cond)
            initial += cond;

        }
        if (mineralFilter != ""){
            if(selectedMinerals.length != 0) {
                initial += " OR "
            }
            else{
                initial += " AND "
            }
            initial += " Stone_id IN( SELECT Stone_id FROM \"Stone-Minerals\" WHERE Mineral_id IN (" + mineralFilter + ") )"
            console.log(initial);
        }

        console.log(initial);
        return initial;
    }

    Kirigami.Dialog {
            id: selectDialog
            title: "Mineral selection"
            preferredWidth: Kirigami.Units.gridUnit * 22
            preferredHeight: Kirigami.Units.gridUnit * 20
            ListView{
                implicitHeight: selectDialog.height
                implicitWidth: selectDialog.width
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
                                                            console.log(selectedMinerals);
                                                          }
                                                      });
                        }
                    }
                }

            }
    }

    Backend.StoneViewModel{
        id: localStoneModel
        myQuery: "SELECT * FROM Stones"
    }
    actions: [
        Kirigami.Action {
            icon.name: "list-add"
            text: "Add stone"
            onTriggered: pageStack.layers.push('qrc:AddStonePage.qml')
        },

        Kirigami.Action {
            id: actionRefresh
            icon.name: "view-refresh"
            text: "Refresh"
            onTriggered: {
                localStoneModel.refreshModel();
            }
        }
    ]
    ListView
    {
        id: stoneListView
        interactive: true
        spacing: 30
        z:1

        //headerPositioning: ListView.OverlayHeader

        header: Kirigami.InlineViewHeader {
            id: listHeader
            z: 3
            //backgroundImage.source: "res/stone.png"
            //backgroundImage.fillMode: Image.PreserveAspectCrop
            //minimumHeight: Kirigami.Units.gridUnit * 6
            height: Kirigami.Units.gridUnit * 8
            text: "Stones"

            Kirigami.SearchField{
                id: nameSearch
                anchors.top: parent.top
                placeholderText: "Look in names"
                onEditingFinished: {
                    page.nameCondition = text
                }
            }
            Kirigami.SearchField{
                id: descSearch
                anchors.left: nameSearch.right
                anchors.top: parent.top
                placeholderText: "Look in descriptions"
                onEditingFinished: {
                    descCondition = text
                }
            }
            Kirigami.SearchField{
                id: colorSearch
                anchors.left: descSearch.right
                anchors.top: parent.top
                placeholderText: "Look through colors"
                onEditingFinished: {
                    colorCondition = text
                }
            }
            Kirigami.SearchField{
                id: originSearch
                anchors.left: colorSearch.right
                anchors.top: parent.top
                placeholderText: "Find stones from..."
                onEditingFinished: {
                    originCondition = text
                }
            }
            Kirigami.Heading{
                id: priceLabel
                fontSizeMode: Text.Fit
                anchors.top: nameSearch.bottom
                anchors.left: parent.left
                text: "Price: "
            }
            Controls.TextField{
                id: minPriceSearch
                anchors.top: nameSearch.bottom
                anchors.left: priceLabel.right
                text: Math.ceil(priceSearchRange.first.value)
                implicitWidth: nameSearch.width - priceLabel.width
                validator: DoubleValidator{
                    bottom: 0
                    notation: DoubleValidator.StandardNotation
                    decimals: 2
                }
                onEditingFinished: {
                    priceSearchRange.first.value = parseFloat(text);
                }
            }
            Controls.RangeSlider{
                id: priceSearchRange
                anchors.top: nameSearch.bottom
                anchors.left: minPriceSearch.right
                implicitWidth: descSearch.width
                from: 0
                stepSize: 15
                to: page.priceMax
                first.value: 0
                second.value: page.priceMax
                snapMode: Controls.RangeSlider.SnapAlways

                first.onValueChanged: {
                    page.priceConditionMin = Math.ceil(first.value);
                    console.log(priceConditionMin)
                }
                second.onValueChanged: {
                    page.priceConditionMax = Math.ceil(second.value)
                    console.log(priceConditionMax)
                }
            }

            Controls.TextField{
                id: maxPriceSearch
                anchors.top: nameSearch.bottom
                implicitWidth: priceSearchRange.width * 0.6
                anchors.left: priceSearchRange.right
                text: Math.ceil(priceSearchRange.second.value)
                validator: DoubleValidator{
                    bottom: 0
                    notation: DoubleValidator.StandardNotation
                    decimals: 2
                }
                 onEditingFinished: {
                    priceSearchRange.second.value = parseFloat(text);
                }
            }
            Controls.Button{
                id: overusedFinder
                anchors.left: maxPriceSearch.right
                anchors.top: nameSearch.bottom
                text: "Show overused Stones"
                onClicked: {
                    localStoneModel.myQuery = "SELECT Stone_id, Stone_name, Stone_description, Stone_origin, Stone_price, Stone_color, Stone_weight, Stone_shape, Stone_image,
                                                (SELECT COUNT (Event_id)
                                                    FROM \"Stone-Collection\" sc
                                                        INNER JOIN Events e ON e.Event_collection=sc.Collection_id
                                                    WHERE sc.Stone_id=s.Stone_id) occurences
                                                FROM Stones s
                                                WHERE occurences=
                                                    (SELECT MAX(ocs)
                                                    FROM
                                                        (SELECT COUNT(e2.Event_id) ocs
                                                        FROM \"Stone-Collection\" sc2
                                                            INNER JOIN Events e2 ON e2.Event_collection=sc2.Collection_id
                                                            INNER JOIN Stones s2 ON sc2.Stone_id=s2.Stone_id
                                                        GROUP BY s2.Stone_id)	)
                                                GROUP BY Stone_id";

                }
            }
            Controls.Button{
                id: underusedFinder
                anchors.left: overusedFinder.right
                anchors.top: nameSearch.bottom
                text: "Show underused stones"
                onClicked: {
                    localStoneModel.myQuery = "SELECT Stone_id, Stone_name, Stone_description, Stone_origin, Stone_price, Stone_color, Stone_weight, Stone_shape, Stone_image,
                                                (SELECT COUNT (Event_id)
                                                    FROM \"Stone-Collection\" sc
                                                        INNER JOIN Events e ON e.Event_collection=sc.Collection_id
                                                    WHERE sc.Stone_id=s.Stone_id) occurences
                                                FROM Stones s
                                                WHERE occurences=
                                                    (SELECT MIN(ocs)
                                                    FROM
                                                        (SELECT COUNT(e2.Event_id) ocs
                                                        FROM \"Stone-Collection\" sc2
                                                            INNER JOIN Events e2 ON e2.Event_collection=sc2.Collection_id
                                                            INNER JOIN Stones s2 ON sc2.Stone_id=s2.Stone_id
                                                        GROUP BY s2.Stone_id)	)
                                                GROUP BY Stone_id";

                }
            }
            Kirigami.Heading{
                id: mineralLabel
                fontSizeMode: Text.Fit

                anchors.margins: Kirigami.Units.smallSpacing
                anchors.top: priceLabel.bottom
                anchors.left: parent.left
                anchors.verticalCenter: mineralSelectionButton.verticalCenter
                text: "Minerals:"
            }
            Controls.Button{
                id: mineralSelectionButton
                anchors.top: priceLabel.bottom
                anchors.margins:  Kirigami.Units.largeSpacing
                anchors.left: mineralLabel.right
                implicitWidth: priceLabel.width + minPriceSearch.width - mineralLabel.width - Kirigami.Units.largeSpacing
                text: "Select.."
                onClicked: selectDialog.open()
            }
            Controls.Button{
                id: mineralConditionButton
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.top: priceLabel.bottom
                anchors.left: mineralSelectionButton.right
                implicitWidth: priceSearchRange.width - Kirigami.Units.largeSpacing
                text: "Set condition.."
                onClicked: {
                    if (typeof(mineralFilterPage) == "undefined"){
                        mineralFilterPage =  Qt.createComponent("qrc:MineralPage.qml").createObject(this);
                    }
                    pageStack.layers.push(mineralFilterPage);

                }
            }
            Controls.Button{
                id: finder
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.top: priceLabel.bottom
                anchors.left: mineralConditionButton.right
                text: "Find"
                icon.name: "search"
                onClicked: {
                    if (typeof(mineralFilterPage) != "undefined"){
                        page.mineralFilter = mineralFilterPage.combineConditions("SELECT Mineral_id FROM Minerals");
                    }
                    localStoneModel.myQuery = combineConditions("SELECT * FROM Stones");
                }
            }
            Controls.Button{
                id: searchResetButton
                anchors.left: finder.right
                anchors.top: priceLabel.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                implicitHeight: finder.height
                text: "Reset filters"
                icon.name: "edit-reset"
                onClicked: {
                    nameSearch.text = ""
                    descSearch.text = ""
                    colorSearch.text = ""
                    originSearch.text = ""
                    priceSearchRange.first.value = 0
                    priceSearchRange.second.value = SqlUtils.getMaxStonePrice()
                    mineralFilterPage = undefined
                    mineralFilter = ""
                    selectedMinerals = []
                    listik.model.refreshModel()
                    finder.clicked()
                }
            }
        }

        model: localStoneModel

        delegate: Kirigami.AbstractCard {

            width: parent.width * 0.95
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true

            contentItem: Item {

                id: item

                property int stoneID: model.stoneID
                implicitWidth: delegateLayout.implicitWidth
                implicitHeight: delegateLayout.implicitHeight
                GridLayout {
                    id: delegateLayout
                    anchors {
                        left: parent.left
                        top: parent.top
                        right: parent.right
                        //IMPORTANT: never put the bottom margin
                    }
                    rowSpacing: Kirigami.Units.largeSpacing
                    columnSpacing: Kirigami.Units.largeSpacing
                    columns: width > Kirigami.Units.gridUnit * 20 ? 4 : 2

                    Kirigami.Icon {
                        source: model.imagePath
                        Layout.fillHeight: true
                        Layout.maximumHeight: Kirigami.Units.iconSizes.Huge * 2
                        Layout.preferredWidth: height
                        }
                        ColumnLayout {
                            Kirigami.Heading {
                                level: 2
                                text: model.display
                            }
                            Kirigami.Separator {
                                Layout.fillWidth: true
                            }
                            Controls.Label {
                                Layout.fillWidth: true
                                wrapMode: Text.WrapAnywhere
                                maximumLineCount: 3
                                text: model.description

                            }
                            Controls.Label {
                                wrapMode: Text.WordWrap
                                text: model.price + "$"
                            }

                        }
                        Controls.Button {
                            Layout.alignment: Qt.AlignRight|Qt.AlignVCenter
                            Layout.columnSpan: 2
                            text: "Show more"
                            onClicked: {
                                var viewPage = Qt.createComponent("qrc:ViewStonePage.qml").createObject(this, {stoneID: item.stoneID });
                                pageStack.layers.push(viewPage)
                            }
                        }
                    }
                }

            }
       }
}
