import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.dateandtime 0.1 as KDT
import org.kde.StoneEX 1.0
import SqlUtils 1.0
import DocumentBuilder 1.0
import ua.nure.makarov.StoneEX 1.0 as Backend

Kirigami.ScrollablePage{
    id: page
    title: thisEvent.name

    property int eventID
    property int selectedCollectionID

    property date dateStart: Date.fromLocaleString(locale, thisEvent.dateStart, "yyyy-mm-dd");
    property date dateEnd: Date.fromLocaleString(locale, thisEvent.dateEnd, "yyyy-mm-dd");

    property double totalExpenses: SqlUtils.countExpenses(eventID)

    function reset(){
        var locale = Qt.locale()
        nameEdit.text = thisEvent.name
        descEdit.text = thisEvent.description
        countryEdit.text = thisEvent.country
        cityEdit.text = thisEvent.city
        addressEdit.text = thisEvent.address
        collectionEdit.currentIndex = collectionEdit.indexOfValue(thisEvent.collection);
        selectedCollectionID = thisEvent.collection
        revenueEdit.text = thisEvent.revenue
        ticketEdit.text = thisEvent.ticket
        openEdit.value = Date.fromLocaleTimeString(locale, thisEvent.timeOpen, "hh:mm:ss")
        closeEdit.value =  Date.fromLocaleTimeString(locale, thisEvent.timeClose, "hh:mm:ss")
        startEdit.selectedDate = Date.fromLocaleString(locale, thisEvent.dateStart, "yyyy-mm-dd")
        endEdit.selectedDate = Date.fromLocaleString(locale, thisEvent.dateEnd, "yyyy-mm-dd")
        linkEdit.text = thisEvent.link

        actionEdit.checked = false
    }

    Component.onCompleted: {
        reset()
    }

    Backend.Event{
        id: thisEvent
        event_id: page.eventID
    }

    actions.left:
        Kirigami.Action {
            id: actionSave
            text: "Save"
            icon.name: "answer"
            visible: actionEdit.checked
            onTriggered: {
                var imagePath = typeof(imageGenPage)=="undefined" ? thisEvent.image : imageGenPage.selectedImageUrl
                SqlUtils.updateEvent(eventID, nameEdit.text, descEdit.text, page.selectedCollectionID,
                                  countryEdit.text, cityEdit.text, addressEdit.text, startEdit.selectedDate.toLocaleDateString(Qt.locale(), "yyyy-MM-dd"),
                                  endEdit.selectedDate.toLocaleDateString(Qt.locale(), "yyyy-MM-dd"), openTime+":00", closeTime+":00",
                                  parseFloat(revenueEdit.text), parseFloat(ticketEdit.text), imagePath)

                thisEvent.event_id = eventID;
                reset()
                actionEdit.checked = false;
            }
        }
    actions.main:
        Kirigami.Action {
            id: actionEdit
            text: "Edit"
            icon.name: "edit-rename"
            visible: !checked
            checkable: true
        }
    actions.right:
        Kirigami.Action {
            id: actionDeny
            text: actionEdit.checked ? "Discard" : "Delete"
            icon.name: actionEdit.checked ? "dialog-cancel" : "delete"
            visible: true
            onTriggered: {
                if(actionEdit.checked){
                    reset()
                    actionEdit.checked = false;
                }
                else
                promptDialog.open()

            }
    }
    actions.contextualActions: [
        Kirigami.Action{
            id: actionPrint
            text: "Form Document"
            iconName: "document-scan"
            visible: !actionEdit.checked
            onTriggered: {
                DocumentBuilder.buildEventDocument(thisEvent.event_id);
            }
        }
    ]

    Kirigami.PromptDialog {
            id: promptDialog
            title: "Delete event"
            subtitle: "This event will be deleted from the database. Forever and ever! (Close to cancel)"

            footer:
            Controls.DelayButton{
                text: "Hold to delete"
                icon.name: "delete"
                delay: 1200
                onActivated: {
                    SqlUtils.deleteEvent(eventID);
                    promptDialog.close()
                    pageStack.layers.pop(1);
                    StonePageModel.refreshModel();
                }
            }
        }

    property string openTime: {
        return openEdit.value.toLocaleTimeString(Qt.locale, "hh:mm:ss")
    }
    property string closeTime: {
        return closeEdit.value.toLocaleTimeString(Qt.locale, "hh:mm:ss")
    }

    property var imageGenPage : {selectedImageUrl = thisEvent.image}

    ColumnLayout{
        id: upperLayout
        Kirigami.InlineMessage{
            id: dateTimeError
            Layout.fillWidth: true
            Layout.fillHeight: true
            type: Kirigami.MessageType.Error
            text: "Date error!"
            visible: false
        }
        Row{
            Kirigami.Heading{
                visible: !actionEdit.checked
                text: thisEvent.name
            }
            Controls.TextField{
                id: nameEdit
                placeholderText: "Enter name"
                text: thisEvent.name
                visible: actionEdit.checked
            }
            Controls.ComboBox{
                id: collectionEdit
                textRole: "display"
                valueRole: "collection_id"
                model: Backend.CollectionViewModel{}
                //onCurrentIndexChanged:
                onActivated: {
                    selectedCollectionID = valueAt(index)
                    console.log(selectedCollectionID);
                }
                visible: actionEdit.checked
            }
        }
    }
    Row{
        id: rowOfAddress
        anchors.top: upperLayout.bottom
        Kirigami.Heading{
            text: thisEvent.country + ", " + thisEvent.city + ", " + thisEvent.address
            visible: !actionEdit.checked
        }
        Controls.TextField{
            id: countryEdit
            placeholderText: "Country"
            validator: RegularExpressionValidator { regularExpression: /[a-zA-Zа-яА-ЯґєїҐЄЇіІʼ` ]+/ }
            visible: actionEdit.checked
        }
        Controls.TextField{
            id: cityEdit
            placeholderText: "City"
            validator: RegularExpressionValidator { regularExpression: /[a-zA-Zа-яА-ЯґєїҐЄЇіІʼ` ]+/ }
            visible: actionEdit.checked
        }
        Controls.TextField{
            id: addressEdit
            placeholderText: "Address"
            visible: actionEdit.checked
        }
        Controls.Button{
            id: imageGenButton
            text: "Generate Image!"
            icon.name: "mark-location"
            onClicked: {
                imageGenPage = Qt.createComponent("qrc:ImageGenPage.qml").createObject(this, {name: nameEdit.text +' ('+ ticketEdit.text + "$)" ,
                                                                                           description: descEdit.text,
                                                                                           hours: page.openTime + '-' + page.closeTime,
                                                                                           dates: startEdit.selectedDate.toLocaleDateString(Qt.locale(), "dd.MM.yyyy") + "-" + endEdit.selectedDate.toLocaleDateString(Qt.locale(), "dd.MM.yyyy"),
                                                                                           address: cityEdit.text + ", " + addressEdit.text});
                pageStack.layers.push(imageGenPage);
                imageGenPage.query = cityEdit.text
            }
        }
    }
    Row{
        id: rowOfDateTime
        anchors.top: rowOfAddress.bottom
        Controls.Label{
            verticalAlignment: Text.AlignBottom
            text: dateStart.toLocaleDateString(locale, "dd MMMM (yyyy)") + "-" + dateEnd.toLocaleDateString(locale, "dd MMMM (yyyy)")
            visible: !actionEdit.checked
        }
        KDT.DateInput{
            id: startEdit
            selectedDate: dateStart
            visible: actionEdit.checked
        }
        Controls.Label{
            text: " to "
            visible: actionEdit.checked
            anchors.verticalCenter: startEdit.verticalCenter
        }
        KDT.DateInput{
            id: endEdit
            selectedDate: dateEnd
            visible: actionEdit.checked
        }

        Controls.Label{
            text: thisEvent.timeOpen.slice(0,5) + " - " + thisEvent.timeClose.slice(0,5)
            visible: !actionEdit.checked
        }
        KDT.TimeInput{
            id: openEdit
            value: Date.fromLocaleTimeString(locale, thisEvent.timeOpen, "hh:mm:ss")
            format: "hh:mm"
            visible: actionEdit.checked
        }
        KDT.TimeInput{
            id: closeEdit
            //text: thisEvent.timeClose
            value: Date.fromLocaleTimeString(locale, thisEvent.timeClose, "hh:mm:ss")
            format: "hh:mm"
            visible: actionEdit.checked
        }
    }
    Row{
        id: rowOfMoney
        anchors.top: rowOfDateTime.bottom

        Controls.Button{
            visible: !actionEdit.checked
            icon.name: "link"
            text: "Further details..."
            onClicked: {
                Qt.openUrlExternally(thisEvent.link);
            }
        }
        Controls.Button{
            visible: !actionEdit.checked
            icon.name: "view-list-details"
            Backend.Collection{
                id: collectionDisplay
                collection_id: thisEvent.collection
            }
            text: "Collection: " + collectionDisplay.name + " (" + SqlUtils.countCollectionMinerals(thisEvent.collection) +  " unique minerals)"
            onClicked: {
                var viewPage = Qt.createComponent("qrc:ViewCollectionPage.qml").createObject(this, {collectionID: thisEvent.collection});
                pageStack.layers.push(viewPage)
            }
        }

        Controls.TextField{
            id: ticketEdit
            placeholderText: "Enter ticket price"
            validator: DoubleValidator{
                bottom: 0
                top: 1000000
                notation: DoubleValidator.StandardNotation
                decimals: 2
            }
            visible: actionEdit.checked
        }
        Controls.TextField{
            id: revenueEdit
            placeholderText: "Enter revenue (if known)"
            validator: DoubleValidator{
                bottom: 0
                top: 1000000
                notation: DoubleValidator.StandardNotation
                decimals: 2
            }
            visible: actionEdit.checked
        }
        Controls.TextField{
            id: linkEdit
            visible: actionEdit.checked
            placeholderText: "https:// Event page link"
        }
    }
    Controls.TextArea{
        id: descEdit
        anchors.top: tableColumn.bottom
        height: (page.height - rowOfAddress.height - rowOfDateTime.height - rowOfMoney.height) *0.4
        Layout.fillWidth: true
        Layout.fillHeight: true
        placeholderText: "Event description"
    }
    Column{
        id: tableColumn
        anchors.top: rowOfMoney.bottom
        Controls.Label{
            text: "Ticket costs " + thisEvent.ticket + "$"
            visible: !actionEdit.checked
        }
        Controls.Label{
            text: "Total revenue: " + thisEvent.revenue + "$" + " Total expenses: " + page.totalExpenses + "$ "
            visible: !actionEdit.checked
        }
        Controls.ProgressBar{
            from: 0
            to: page.totalExpenses
            indeterminate: false
            value:  totalExpenses < thisEvent.revenue ? totalExpenses : thisEvent.revenue
        }
        TableView{
            height: Kirigami.Units.gridUnit * 10
            width: Kirigami.Units.gridUnit * 24
            model: Backend.ExpenseModel{
                id: localExpenseModel
                eventID: thisEvent.event_id
            }

            delegate: Controls.TextField{

                property int itemRow: row
                property int itemCol: column

                readOnly: !actionEdit.checked

                visible: (itemCol != 2 || actionEdit.checked)

                implicitWidth: Kirigami.Units.gridUnit * 8
                implicitHeight: Kirigami.Units.gridUnit * 2
                text: model.display

                Controls.Button{
                    visible: actionEdit.checked
                    anchors.right: parent.right
                    height: parent.height
                    icon.name: "document-save"
                    onClicked: {
                        localExpenseModel.setData(localExpenseModel.index(row, column), parent.text, 4900)
                        localExpenseModel.eventID = thisEvent.event_id
                         page.totalExpenses = SqlUtils.countExpenses(eventID)

                    }
                }
                Controls.Button{
                    visible: actionEdit.checked && itemCol == 2
                    anchors.fill: parent
                    icon.name: "delete"
                    text: "Delete this row"
                    onClicked: {
                        SqlUtils.deleteExpense(thisEvent.event_id, parent.text);
                        localExpenseModel.eventID = thisEvent.event_id;
                        page.totalExpenses = SqlUtils.countExpenses(eventID)
                    }
                }
            }
        }
        Row{
            visible: actionEdit.checked

        Controls.TextField{
            id: expNameEdit
            placeholderText: "Expense name"
        }
        Controls.TextField{
            id: expValEdit
            placeholderText: "value"
            validator: RegularExpressionValidator { regularExpression: /(\d{1,7})([.]\d{1,2})?$/ }
        }
        Controls.Button{
            text: "Insert"
            icon.name: "list-add"
            onClicked: {
                SqlUtils.addExpense(thisEvent.event_id, expNameEdit.text, parseFloat(expValEdit.text));
                localExpenseModel.eventID = thisEvent.event_id
                page.totalExpenses = SqlUtils.countExpenses(eventID)
            }
        }
        }

    }
}
