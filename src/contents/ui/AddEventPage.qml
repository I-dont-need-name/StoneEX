import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.dateandtime 0.1 as KDT
import org.kde.StoneEX 1.0
import SqlUtils 1.0
import ua.nure.makarov.StoneEX 1.0 as Backend

Kirigami.ScrollablePage{
    id: page
    title: "Add Event"
    property int selectedCollectionID

    property string openTime: {
        var hours = openEdit.hours;
        var minutes = openEdit.minutes;
        if(minutes < 10){
            minutes  = '0' + minutes
        }
        if(hours < 10){
            hours  = '0' + hours
        }
        return hours + ':' + minutes
    }
    property string closeTime: {
        var hours = closeEdit.hours;
        var minutes = closeEdit.minutes;
        if (closeEdit.pm && hours != 12) {
            hours += 12
        }
        if(hours < 10){
            hours  = '0' + hours
        }
        if(minutes < 10){
            minutes  = '0' + minutes
        }
        return hours + ':' + minutes
    }

    property var imageGenPage
    //implicitWidth: applicationWindow().width
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
            Controls.TextField{
                id: nameEdit
                placeholderText: "Enter name"
            }
            Controls.ComboBox{
                editable: false
                textRole: "display"
                valueRole: "collection_id"
                model: Backend.CollectionViewModel{}
                //onCurrentIndexChanged:
                onActivated: {
                    selectedCollectionID = valueAt(index)
                    console.log(selectedCollectionID);
                }
            }
        }
    }
    Row{
        id: rowOfAddress
        anchors.top: upperLayout.bottom
        Controls.TextField{
            id: countryEdit
            placeholderText: "Country"
            validator: RegularExpressionValidator { regularExpression: /[a-zA-Zа-яА-ЯґєїҐЄЇіІʼ` ]+/ }
        }
        Controls.TextField{
            id: cityEdit
            placeholderText: "City"
            validator: RegularExpressionValidator { regularExpression: /[a-zA-Zа-яА-ЯґєїҐЄЇіІʼ` ]+/ }
        }
        Controls.TextField{
            id: addressEdit
            placeholderText: "Address"
        }
        Controls.Button{
            id: imageGenButton
            text: "Generate Image!"
            icon.name: "mark-location"
            onClicked: {
                imageGenPage = Qt.createComponent("qrc:ImageGenPage.qml").createObject(this, {name: nameEdit.text +' ('+ ticketEdit.text + "$)" ,
                                                                                           description: descEdit.text,
                                                                                           hours: page.openTime + '-' + page.closeTime,
                                                                                           dates: startButton.text.slice(7)+ "-" + endButton.text.slice(4),
                                                                                           address: cityEdit.text + ", " + addressEdit.text});
                pageStack.layers.push(imageGenPage);
                imageGenPage.query = cityEdit.text
            }
        }
    }
    Row{
        id: rowOfDateTime
        anchors.top: rowOfAddress.bottom
        Controls.Button{
            id: startButton
            text: "Date of start..."
            onClicked: {
                startEdit.open()
            }
            KDT.DatePopup{
                id: startEdit
                onAccepted: {
                    startButton.text="start: " + selectedDate.toLocaleDateString(Qt.locale() ,"dd.MM.yyyy");
                    if (selectedDate > endEdit.selectedDate){
                        dateTimeError.visible = true;
                    }
                    else {dateTimeError.visible = false}
                }
            }


        }

        Controls.Button{
            id: endButton
            text: "Date of end..."
            onClicked: {
                endEdit.open()
            }
            KDT.DatePopup{
                id: endEdit
                onAccepted: {
                    endButton.text="end: " + selectedDate.toLocaleDateString(Qt.locale(), "dd.MM.yyyy");
                    if (selectedDate < startEdit.selectedDate){
                        dateTimeError.visible = true;
                    }
                    else {dateTimeError.visible = false}
                }
            }

        }
        KDT.TimePicker{
            id: openEdit
            width: page.width *0.3
            height: page.height *0.4
        }
        KDT.TimePicker{
            id: closeEdit
            width: page.width *0.3
            height: page.height *0.4
        }
    }
    Row{
        id: rowOfMoney
        anchors.top: rowOfDateTime.bottom
        Controls.TextField{
            id: ticketEdit
            placeholderText: "Enter ticket price"
            validator: RegularExpressionValidator { regularExpression: /(\d{1,5})([.]\d{1,2})?$/ }
        }

        Controls.TextField{
            id: revenueEdit
            placeholderText: "Enter revenue (if known)"
            validator: RegularExpressionValidator { regularExpression: /(\d{1,7})([.]\d{1,2})?$/ }
        }
        Controls.TextField{
            placeholderText: "https:// Event page link"
        }
    }
    Controls.TextArea{
        id: descEdit
        anchors.top: rowOfMoney.bottom
        height: (page.height - rowOfAddress.height - rowOfDateTime.height - rowOfMoney.height) *0.6
        Layout.fillWidth: true
        Layout.fillHeight: true
        placeholderText: "Event description"
    }
    Controls.Button{
        anchors.top: descEdit.bottom
        anchors.right: descEdit.right
        text: "Add"
        enabled: (!dateTimeError.visible * nameEdit.text.length * descEdit.text.length * countryEdit.text.length * cityEdit.text.length * addressEdit.text.length)
        icon.name: "list-add"
        onClicked: {
            SqlUtils.addEvent(nameEdit.text, descEdit.text, page.selectedCollectionID,
                              countryEdit.text, cityEdit.text, addressEdit.text, startEdit.selectedDate.toLocaleDateString(Qt.locale(), "yyyy-MM-dd"),
                              endEdit.selectedDate.toLocaleDateString(Qt.locale(), "yyyy-MM-dd"), openTime+":00", closeTime+":00",
                              parseFloat(revenueEdit.text), parseFloat(ticketEdit.text), page.imageGenPage.selectedImageUrl);
            page.title = SqlUtils.getLastError()
        }
    }
}
