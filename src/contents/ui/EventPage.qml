import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.dateandtime 1.0 as KDT
import org.kde.StoneEX 1.0
import ua.nure.makarov.StoneEX 1.0 as Backend
import SqlUtils 1.0

Kirigami.ScrollablePage{
    id: page
    property string externalCondition: ""
    title: "Events"
    property string selectCondition: " SELECT * FROM Events"
    property string nameCondition: ""
    property string descCondition: ""

    property string startCondition: ""
    property string endCondition: ""

    property string collectionFilter: ""
    property var collectionFilterPage

    property var selectedCollections : []
    property string sortCondition: ""


    function combineConditions(selector) {
        var initial = selector + " WHERE Event_name LIKE '%" + nameCondition + "%' "
        if (descCondition != ""){
            initial += "AND Event_description LIKE '%" + descCondition + "%' "
        }
        if(startCondition!=""){
            initial += " AND DATE(Event_date_start) >= DATE('" + startCondition + "') ";
        }
        if(endCondition!=""){
            initial += " AND DATE(Event_date_end) <= DATE('" + endCondition + "') ";
        }
        if (externalCondition != ""){
            initial += " AND " + externalCondition
        }
        if (selectedCollections.length != 0){
            initial += " AND Event_collection IN (" + selectedCollections  +")"
        }
        if (collectionFilter != ""){
            if (selectedCollections.length != 0){
                initial += " OR "
            }
            else {
                initial += " AND "
            }
            initial += " Event_id IN( SELECT Event_id FROM Events WHERE Event_collection IN (" + collectionFilter + ") ) "
            console.log(initial);
        }
        if (sortCondition != ""){
            initial += sortCondition
        }

        console.log(initial);
        return initial;
    }


    Kirigami.Dialog{
        id: selectDialog
        title: "Collection selection"
        preferredWidth: Kirigami.Units.gridUnit * 22
        preferredHeight: Kirigami.Units.gridUnit * 20
        ListView{
            id: listik
            anchors.fill: parent
            model: Backend.CollectionViewModel{

            }
            delegate: Controls.CheckDelegate{
                implicitWidth: selectDialog.width
                topPadding: Kirigami.Units.smallSpacing * 2
                bottomPadding: Kirigami.Units.smallSpacing * 2
                text: model.display
                checked: false

                onCheckedChanged: {
                    if (this.checked && selectedCollections.indexOf(model.collection_id) == -1){
                        selectedCollections.push(model.collection_id);
                        console.log(selectedCollections);
                    }
                    else if (!checked) {
                         selectedStones.forEach(element => {
                                                  if (element == model.collection_id){
                                                        var index = selectedCollections.indexOf(element);
                                                        selectedCollections.splice(index, 1);
                                                        console.log(selectedCollections);
                                                      }
                                                  });
                    }

                }
            }
        }
    }

    Backend.EventViewModel{
        id: localEventModel
        myQuery: externalCondition == "" ? "SELECT * FROM Events" : ("SELECT * FROM Events WHERE " + externalCondition)
    }

    actions.main: Kirigami.Action {
        iconName: "list-add"
        text: "Add Event"
        onTriggered: pageStack.layers.push('qrc:AddEventPage.qml')
    }
    actions.right: Kirigami.Action {
        id: actionRefresh
        iconName: "view-refresh"
        text: "Refresh"
        onTriggered: {
            localEventModel.refreshModel();

        }
    }

    ListView
    {
        id: eventListView
        interactive: true
        spacing: 30
        implicitHeight: page.height *0.5

        //headerPositioning: ListView.Pull

        header:
            Item {
                        implicitHeight: nameSearch.height + startSearchButton.height
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
                            id: collectionSearch
                            anchors.left: descSearch.right
                            implicitHeight: descSearch.height
                            icon.name: "search"
                            text: "Set collection conditions"
                            onClicked: {
                                if (typeof(collectionFilterPage)=="undefined"){
                                    collectionFilterPage = Qt.createComponent("qrc:CollectionPage.qml").createObject(this);
                                }
                                pageStack.layers.push(collectionFilterPage);
                            }
                        }
                        Controls.Button{
                            anchors.top: nameSearch.bottom
                            id: startSearchButton
                            text: "From:..."
                            KDT.DatePopup{
                                id: startSearch
                                onAccepted: {
                                    startSearchButton.text="From: " + selectedDate.toLocaleDateString(Qt.locale() ,"dd.MM.yyyy");
                                    startCondition = selectedDate.toLocaleDateString(Qt.locale() ,"yyyy-MM-dd");
                                }
                            }
                            onClicked: {
                                startSearch.open()
                            }
                        }
                        Controls.Button{
                            id: endSearchButton
                            anchors.top: nameSearch.bottom
                            anchors.left: startSearchButton.right
                            text: "To:..."
                            KDT.DatePopup{
                                id: endSearch
                                onAccepted: {
                                    endSearchButton.text="To: " + selectedDate.toLocaleDateString(Qt.locale() ,"dd.MM.yyyy");
                                    endCondition = selectedDate.toLocaleDateString(Qt.locale() ,"yyyy-MM-dd");
                                }
                            }
                            onClicked: {
                                endSearch.open()
                            }
                        }
                        Controls.Button{
                            id: searchResetButton
                            anchors.top: nameSearch.bottom
                            anchors.left: sortSearch.right
                            implicitHeight: endSearchButton.height
                            text: "Reset filters"
                            icon.name: "edit-reset"
                            onClicked: {
                                nameSearch.text = ""
                                descSearch.text = ""
                                sortSearch.currentIndex=0
                                startSearchButton.text = "From:..."
                                endSearchButton.text = "To:..."
                                collectionFilter = ""
                                collectionFilterPage = undefined
                                selectedCollections = []
                                listik.model.refreshModel()
                                finder.clicked()
                            }
                        }
                        Controls.Button{
                            id: collectionSelector
                            anchors.left: collectionSearch.right
                            implicitHeight: descSearch.height
                            text: "Select collections"
                            onClicked: {
                                selectDialog.open()
                            }
                        }
                        Controls.Button{
                            id: finder
                            anchors.left: collectionSelector.right
                            implicitHeight: descSearch.height
                            icon.name: "search"
                            text: "Find"
                            onClicked: {
                                if (typeof(collectionFilterPage)!="undefined"){
                                    collectionFilter = collectionFilterPage.combineConditions("SELECT Collection_id FROM Collections")
                                }
                                localEventModel.myQuery = combineConditions("SELECT * FROM Events");
                            }
                        }
                        Controls.ComboBox{
                            id: sortSearch
                            anchors.left: endSearchButton.right
                            anchors.top: descSearch.bottom
                            model: [
                                        "↓Назва",
                                        "↓Дата початку",
                                        "↑Дата початку",
                                        "↓Прибуток",
                                        "↑Прибуток",
                                        "Найприбутковіша виставка",
                                        "Найменш прибуткова виставка"
                                    ]
                            onCurrentIndexChanged: {
                                switch(currentIndex){
                                    case 0:
                                        sortCondition = " ORDER BY Event_name"
                                        break
                                    case 1:
                                        sortCondition = " ORDER BY DATE(Event_date_start) DESC"
                                        break
                                    case 2:
                                        sortCondition = " ORDER BY DATE(Event_date_start) ASC"
                                        break
                                    case 3:
                                        sortCondition = " ORDER BY Event_revenue DESC"
                                        break;
                                    case 4:
                                        sortCondition = " ORDER BY Event_revenue ASC"
                                        break;
                                    case 5:
                                        localEventModel.myQuery = "SELECT *,
                                                                    (Event_revenue-(SELECT SUM(Expense_value)
                                                                        FROM Expenses exp WHERE exp.Event_id=e.Event_id)) net
                                                                FROM Events e
                                                                WHERE net=(
                                                                    SELECT MAX(TotalExp)
                                                                    FROM
                                                                        (SELECT (Event_revenue-SUM(Expense_value)) TotalExp
                                                                        FROM Expenses exp2
                                                                            INNER JOIN Events e2 ON exp2.Event_id=e2.Event_id
                                                                        GROUP BY e2.Event_id))"
                                        break;
                                    case 6:
                                        localEventModel.myQuery = "SELECT *,
                                                                    (Event_revenue-(SELECT SUM(Expense_value)
                                                                        FROM Expenses exp WHERE exp.Event_id=e.Event_id)) net
                                                                FROM Events e
                                                                WHERE net=(
                                                                    SELECT MIN(TotalExp)
                                                                    FROM
                                                                        (SELECT (Event_revenue-SUM(Expense_value)) TotalExp
                                                                        FROM Expenses exp2
                                                                            INNER JOIN Events e2 ON exp2.Event_id=e2.Event_id
                                                                        GROUP BY e2.Event_id))"
                                        break;
                                    default:
                                        sortCondition = ""
                                }
                            }
                        }
                    }
        model: localEventModel

        delegate:   Kirigami.AbstractCard{
            id: card

            showClickFeedback: true
            width: page.width * 0.9
            height: imgRect.height + descLabel.height
            implicitHeight: delegateLayout.height
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true

            ColumnLayout{
                id:delegateLayout
                width: card.width
                anchors.top: card.top

                Rectangle{
                    id: nameHeader
                    color: "#BB000000"
                    height: nameLabel.height * 1.2
                    //width: card.width
                    Layout.fillWidth: true
                    radius: 3
                    z: 1
                    Kirigami.Heading{
                        id: nameLabel
                        text: model.display
                        color: "white"
                        z: 2
                    }
                    Rectangle {
                        id: collectionRect
                        anchors.right: nameHeader.right
                        color: "#AAffdd60"
                        implicitWidth: collectionLabel.width
                        implicitHeight: nameHeader.height
                        Controls.Label{
                            id: collectionLabel
                            anchors.verticalCenter: parent.verticalCenter
                            Backend.Collection{
                                id: delegateCollection
                                collection_id: model.collection_id
                            }
                            text: delegateCollection.name
                        }
                    }
                }
            Rectangle{
                id: imgRect
                color: "transparent"
                //width: card.width
                Layout.fillWidth: true
                anchors.top: nameHeader.top
                anchors.topMargin: 3
                clip: true
                height: {
                    if (img.status == Image.Error || img.status == Image.Null){
                        return nameHeader.height + infoHeader.height
                    }
                    else return Kirigami.Units.gridUnit * 10
                }
            Image {
                //anchors.top: card.top
                //anchors.margins: 3
                cache: true
                anchors.fill: parent
                id: img
                source: model.image
                /*height: {
                    if (status == Image.Error || status == Image.Null || status == Image.Loading){
                        return nameHeader.height + infoHeader.height
                    }
                    else return Kirigami.Units.gridUnit * 10
                } */
                //width: source == "" ? 0 : card.width
                //sourceSize.width: card.width
                Layout.fillWidth: true
                fillMode: Image.PreserveAspectCrop
                Rectangle{
                    id: infoHeader
                    color: "#99000000"
                    anchors.bottom: img.bottom
                    height: nameLabel.height * 1.4
                    width: card.width
                    //opacity: 0.6
                    z: 1
                    Rectangle{
                        id: addressRect
                        color: "#6262ff"
                        radius: 3
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: addressLabel.width
                        implicitHeight: addressLabel.height
                        Controls.Label{
                            id: addressLabel
                            text: model.country + ", " + model.city + ", " + model.address
                        }
                    }
                    Rectangle{
                        id: datesRect
                        anchors.left: addressRect.right
                        anchors.margins: Kirigami.Units.smallSpacing
                        color: "#72ff62"
                        radius: 3
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: datesLabel.width
                        implicitHeight: datesLabel.height
                        Controls.Label{
                            property var locale: Qt.locale()
                            property date start: Date.fromLocaleString(locale, model.dateStart, "yyyy-mm-dd")
                            property date end: Date.fromLocaleString(locale, model.dateEnd, "yyyy-mm-dd")
                            id: datesLabel
                            color: "#1e1e27"
                            text: start.toLocaleDateString(locale, "dd MMMM") + "-" + end.toLocaleDateString(locale, "dd MMMM (yyyy)")
                        }

                    }
                    Rectangle{
                        id: timesRect
                        anchors.left: datesRect.right
                        anchors.margins: Kirigami.Units.smallSpacing
                        color: "#BB6022"
                        radius: 3
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: timesLabel.width
                        implicitHeight: timesLabel.height
                        Controls.Label{
                            property var locale: Qt.locale()
                            property date open: Date.fromLocaleTimeString(locale, model.timeOpen, "hh:mm:ss")
                            property date close: Date.fromLocaleTimeString(locale, model.timeClose, "hh:mm:ss")
                            id: timesLabel
                            text: open.toLocaleTimeString(locale, "H:mm") + "-" + close.toLocaleTimeString(locale, "H:mm")
                        }
                    }
                    Rectangle{
                        id: ticketRect
                        anchors.left: timesRect.right
                        anchors.margins: Kirigami.Units.smallSpacing
                        color: "steelblue"
                        radius: 3
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: ticketLabel.width
                        implicitHeight: ticketLabel.height
                        Controls.Label{
                            id: ticketLabel
                            text: model.ticketPrice + "$ "
                        }
                        MouseArea{
                            anchors.fill: ticketRect
                            onClicked: {
                                console.log(model.link)
                                Qt.openUrlExternally(model.link)
                            }
                        }
                    }
                    Rectangle{
                        id: revenueRect
                        anchors.left: ticketRect.right
                        anchors.margins: Kirigami.Units.smallSpacing
                        color: "#22BB55"
                        radius: 3
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: revenueLabel.width
                        implicitHeight: revenueLabel.height
                        Controls.Label{
                            id: revenueLabel
                            text: model.revenue + "$ "
                        }
                    }
                }
            }
            }
                Controls.Label {
                    id: descLabel
                    anchors.top: imgRect.bottom
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    wrapMode: Text.WordWrap
                    text: model.description
                    maximumLineCount: 5
                }
            }
            onClicked: {
                var viewPage = Qt.createComponent("qrc:ViewEventPage.qml").createObject(this, {eventID: model.event_id});
                pageStack.layers.push(viewPage)
            }
        }
    }
}
