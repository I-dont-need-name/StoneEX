import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.StoneEX 1.0
import ua.nure.makarov.StoneEX 1.0 as Backend

Kirigami.ScrollablePage{
    id: page
    title: "Minerals"

    property string selectCondition: "SELECT * FROM Minerals"
    property string nameCondition: ""
    property string descCondition: ""
    property string typeCondition: ""

    property int valueConditionMin: 0
    property int valueConditionMax: 6

    property int hardnessConditionMin: 1
    property int hardnessConditionMax: 10

    property string sortCondition

    function combineConditions(selectCondition) {
        var initial = selectCondition + " WHERE Mineral_name LIKE '%" + nameCondition + "%' "
        if (descCondition != ""){
            initial += "AND Mineral_desc LIKE '%" + descCondition + "%' "
        }
        if(typeCondition != ""){
            initial += " AND Mineral_type LIKE '%" + typeCondition + "%' "
        }

        if(valueConditionMin == valueConditionMax){
            initial += " AND Mineral_valuability=" + valueConditionMin
        }
        else{
            if(valueConditionMin > 0){
                initial += " AND Mineral_valuability>=" + valueConditionMin
            }
            if(valueConditionMax < 6){
                initial += " AND Mineral_valuability<=" + valueConditionMax
            }
        }
        if(hardnessConditionMin == hardnessConditionMax){
            initial += " AND Mineral_hardness=" + hardnessConditionMin
        }
        else{
            if(hardnessConditionMin > 1){
                initial += " AND Mineral_hardness>=" + hardnessConditionMin
            }
            if(hardnessConditionMax < 10){
                initial += " AND Mineral_hardness<=" + hardnessConditionMax
            }
        }
        if (sortCondition != ""){
            initial += sortCondition
        }

        console.log(initial);
        return initial;
    }

    function valueToString(value){
        switch (value){
            case 0:
                return "Недорогоцінний"
            case 1:
                return "Напівдорогоцінний II п."
            case 2:
                return "Напівдорогоцінний I п."
            case 3:
                return "Дорогоцінний IV п."
            case 4:
                return "Дорогоцінний III п."
            case 5:
                return "Дорогоцінний II п."
            case 6:
                return "Дорогоцінний I п."
            default:
                return value
        }
    }

    Backend.MineralViewModel{
        id: localMineralModel
    }

    actions.main: Kirigami.Action {
        iconName: "list-add"
        text: "Add Mineral"
        onTriggered: pageStack.layers.push('qrc:AddMineralPage.qml')
    }
    actions.right: Kirigami.Action {
        id: actionRefresh
        iconName: "view-refresh"
        text: "Refresh"
        onTriggered: {
            localMineralModel.refreshModel();
        }
    }

    ListView
    {
        id: mineralListView
        interactive: true

        spacing: 30
        clip: false
        header: Kirigami.ItemViewHeader {
            id: listHeader
            minimumHeight: Kirigami.Units.gridUnit * 8
            backgroundImage.source: "res/stone.png"
            title: page.title
            Kirigami.SearchField{
                id: nameSearch
                placeholderText: "Look in names"
                onTextChanged: {
                    nameCondition = text
                }

            }
            Kirigami.SearchField{
                id: descSearch
                anchors.left: nameSearch.right
                placeholderText: "Look in descriptions"
                onTextChanged: {
                    descCondition = text
                }
            }
            Controls.ComboBox{
                anchors.left: typeSearch.right
                id: sortSearch
                model: [
                            "↓Назва",
                            "↓Цінність",
                            "↑Цінність"
                        ]
                onCurrentIndexChanged: {
                    switch(currentIndex){
                        case 0:
                            sortCondition = " ORDER BY Mineral_name"
                            break
                        case 1:
                            sortCondition = " ORDER BY Mineral_valuability DESC"
                            break
                        case 2:
                            sortCondition = " ORDER BY Mineral_valuability"
                            break;
                        default:
                            sortCondition = ""
                    }
                }
            }
            Controls.Button{
                id: finder
                anchors.left: sortSearch.right
                implicitHeight: sortSearch.height
                text: "Find"
                icon.name: "search"
                onClicked: {
                    console.log(combineConditions())
                    localMineralModel.myQuery = combineConditions("SELECT * FROM Minerals")
                }
            }
            Controls.ComboBox{
                //anchors.top: nameSearch.bottom
                anchors.left: descSearch.right
                id: typeSearch
                model: ["Тип (не обрано)", "Осадовий", "Магматичний", "Магматично-метасоматичний", "Метаморфічний", "Метаморфічно-метосоматичний", "Органічний"]
                onCurrentIndexChanged:{
                    if (currentIndex != 0){
                        typeCondition = textAt(currentIndex);
                        console.log(combineConditions())
                    }
                    else {
                        typeCondition = "";
                        console.log(combineConditions())
                    }
                }
            }
            Controls.Label{
                id: hardnessLabel
                anchors.top: nameSearch.bottom
                anchors.left: parent.left
                text: "Hardness: " + Math.ceil(hardnessSearch.first.value) + " to " + Math.ceil(hardnessSearch.second.value);
            }
            Controls.RangeSlider{
                id: hardnessSearch

                anchors.top: hardnessLabel.bottom
                anchors.left: parent.left
                stepSize: 1.0
                from: 1.0
                to: 10.0
                first.value: 1
                second.value: 10
                snapMode: Controls.RangeSlider.SnapAlways

                first.onValueChanged: {
                    hardnessConditionMin = Math.ceil(first.value)
                }
                second.onValueChanged: {
                    hardnessConditionMax = Math.ceil(second.value)
                }

            }
            Controls.Label{
                id: valueLabel
                width: descSearch.width
                anchors.top: descSearch.bottom
                anchors.left: hardnessSearch.right
                text: valueToString(Math.ceil(valueSearch.first.value)) + " - " + valueToString(Math.ceil(valueSearch.second.value));
            }
            Controls.RangeSlider{
                id: valueSearch

                anchors.top: valueLabel.bottom
                anchors.left: hardnessSearch.right
                stepSize: 1.0
                from: 0
                to: 6
                first.value: 0
                second.value: 6
                snapMode: Controls.RangeSlider.SnapAlways

                first.onValueChanged: {
                    valueConditionMin = Math.ceil(first.value)
                }
                second.onValueChanged: {
                    valueConditionMax = Math.ceil(second.value)
                }
            }
            Controls.Button{
                id: searchResetButton
                anchors.right: finder.right
                anchors.top: descSearch.bottom
                text: "Reset filters"
                icon.name: "edit-reset"
                onClicked: {
                    nameSearch.text = ""
                    descSearch.text = ""
                    typeSearch.currentIndex = 0
                    hardnessSearch.first.value = 1
                    hardnessSearch.second.value = 10
                    valueSearch.first.value = 0
                    valueSearch.second.value = 6
                    finder.clicked()
                }
            }
        }

        headerPositioning: ListView.OverlayHeader

        model: localMineralModel

        delegate: Kirigami.AbstractCard {
           width: parent.width * 0.95
           anchors.horizontalCenter: parent.horizontalCenter

           clip: true
           contentItem:
            Item {
                id: item
                implicitHeight: delegateLayout.height
                implicitWidth: delegateLayout.width

                property var mineralID: model.mineralID
                property string mineralName: model.display
                property string mineralDesc: model.description
                property string mineralType: model.type
                property string mineralValue: model.valuability
                property int mineralHard: model.hardness

                //console.log: mineralID;
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

                        ColumnLayout {

                            GridLayout{
                                columnSpacing: Kirigami.Units.largeSpacing
                                Kirigami.Heading {
                                    level: 2
                                    text: item.mineralName
                                }
                                Rectangle{
                                    implicitHeight:  txtVal.contentHeight
                                    implicitWidth: txtVal.contentWidth
                                    radius: 3
                                    color:"steelblue"
                                    Text{
                                        id: txtVal
                                        anchors.centerIn: parent
                                        text: {
                                            switch(model.valuability) {
                                              case 0:
                                                  return "Недорогоцінний";
                                              case 1:
                                                  return "Напівдорогоцінне II порядку";
                                              case 2:
                                                  return "Напівдорогоцінне I порядку";
                                              case 3:
                                                  return "Дорогоцінне IV порядку";
                                              case 4:
                                                  return "Дорогоцінне III порядку";
                                              case 5:
                                                  return "Дорогоцінне II порядку";
                                              case 6:
                                                  return "Дорогоцінне I порядку";
                                              }
                                        }
                                        color: Kirigami.Theme.textColor
                                    }
                                }
                                Rectangle{
                                    implicitHeight:  txtType.contentHeight
                                    implicitWidth: txtType.contentWidth
                                    radius: 3
                                    color: Kirigami.Theme.linkBackgroundColor
                                    Text{
                                        id: txtType
                                        anchors.centerIn: parent
                                        text: item.mineralType
                                        color: Kirigami.Theme.textColor
                                    }
                                }
                                Rectangle{
                                    implicitHeight:  txtHard.contentHeight
                                    implicitWidth: txtHard.contentWidth
                                    radius: 3
                                    color: Kirigami.Theme.alternateBackgroundColor
                                    Text{
                                        id: txtHard
                                        anchors.centerIn: parent
                                        text: item.mineralHard
                                        color: Kirigami.Theme.textColor
                                    }
                                }
                            }
                            Kirigami.Separator {
                                Layout.fillWidth: true
                                //Layout.columnSpan: 2
                            }
                            Controls.Label {
                                Layout.fillWidth: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                maximumLineCount: 3
                                text: item.mineralDesc

                            }

                        }
                        Controls.Button {
                            Layout.alignment: Qt.AlignRight|Qt.AlignVCenter
                            Layout.columnSpan: 1
                            text: "Show more"
                            onClicked: {
                                var viewPage = Qt.createComponent("qrc:ViewMineralPage.qml").createObject(this, {mineralID: item.mineralID });
                                pageStack.layers.push(viewPage)
                            }
                        }
                    }
                }

            }
       }
}

