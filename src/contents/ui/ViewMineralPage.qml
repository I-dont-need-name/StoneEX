import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.StoneEX 1.0
import SqlUtils 1.0
import ua.nure.makarov.StoneEX 1.0 as Backend



Kirigami.ScrollablePage{

    property int mineralID

    Backend.Mineral{
        id: thisMineral
        mineral_id: mineralID
    }

    id: page

    /*property string thisMineral.name : thisMineral.name
    property string thisMineral.description : thisMineral.description
    property string thisMineral.type : thisMineral.type
    property string thisMineral.value : thisMineral.value
    property int thisMineral.hardness : thisMineral.hardness */

    property int unsavedChanges: 0


    title: thisMineral.name
    implicitWidth: applicationWindow().width

    Kirigami.PromptDialog {
            id: promptDialog
            title: "Delete Mineral"
            subtitle: "This mineral will be deleted from the database. Forever and ever! (Close to cancel)"

            footer:
            Controls.DelayButton{
                text: "Hold to delete"
                icon.name: "delete"
                delay: 1200
                onActivated: {
                    SqlUtils.deleteMineral(page.mineralID);
                    promptDialog.close()
                    pageStack.layers.pop(1);
                    MineralPageModel.refreshModel();
                }
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

    ColumnLayout{

        Kirigami.InlineMessage{
            id: success
            text: "Changes successfull"
            Layout.fillWidth: true
            visible: false
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

        Kirigami.InlineMessage{
            Layout.fillWidth: true

            visible: unsavedChanges>0

            text: "You have unsaved changes"

            actions: [
                    Kirigami.Action {
                        enabled: unsavedChanges > 0

                        text: qsTr("Save")
                        icon.name: "answer"

                        visible: unsavedChanges >0
                        onTriggered: {

                            if (SqlUtils.updateMineral(page.mineralID, nameEdit.text, descEdit.text, typeEdit.currentText,
                                                valueEdit.currentValue, hardnessEdit.value))
                            {
                                unsavedChanges = 0
                                thisMineral.mineral_id = thisMineral.mineral_id
                                success.visible = true
                            }
                            else failure.visible = true
                        }
                    },
                    Kirigami.Action {
                        enabled: unsavedChanges >0

                        text: qsTr("Reset")
                        icon.name: "list-remove"

                        onTriggered: {

                            nameEdit.text = thisMineral.name
                            descEdit.text = thisMineral.description
                            typeEdit.currentIndex = typeEdit.find(thisMineral.type)
                            hardnessEdit.value = thisMineral.hardness
                            valueEdit.currentIndex = thisMineral.value
                            unsavedChanges = 0
                        }
                    }
            ]
        }

        Layout.fillWidth: true
        Kirigami.Heading{
            id: nameLabel
            text: thisMineral.name
            level: 1
            visible: !actionEdit.checked
        }
        Controls.TextField{
            id: nameEdit
            text: thisMineral.name
            implicitWidth: nameLabel.width*2
            visible: actionEdit.checked
            onTextEdited: page.unsavedChanges +=1
        }

        Controls.Label{
            visible: !actionEdit.checked
            text: {
                switch(thisMineral.value) {
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
        }

        Controls.ComboBox{
            id: valueEdit
            implicitWidth: Kirigami.Units.gridUnit * 12
            textRole: "text"
            valueRole: "value"
            model: ListModel {
                id: model
                ListElement { text: "Недорогоцінний"; value: 0 }
                ListElement { text: "Напівдорогоцінний II порядку"; value: 1 }
                ListElement { text: "Напівдорогоцінний I порядку"; value: 2 }
                ListElement { text: "Дорогоцінний IV порядку"; value: 3 }
                ListElement { text: "Дорогоцінний III порядку"; value: 4 }
                ListElement { text: "Дорогоцінний II порядку"; value: 5 }
                ListElement { text: "Дорогоцінний I порядку"; value: 6 }
            }
            visible: actionEdit.checked
            onActivated: page.unsavedChanges+=1
            Component.onCompleted: {
                currentIndex = indexOfValue(thisMineral.value)
            }
        }
        Controls.Label{
            text: thisMineral.type
            visible: !actionEdit.checked
        }

        Controls.ComboBox{
            id: typeEdit
            editText: thisMineral.type
            implicitWidth: Kirigami.Units.gridUnit * 12
            model: ["Осадовий", "Магматичний", "Магматично-метасоматичний", "Метаморфічний", "Метаморфічно-метосоматичний", "Органічний"]
            onActivated: page.unsavedChanges+=1
            visible: actionEdit.checked
            Component.onCompleted: {
                currentIndex = typeEdit.find(thisMineral.type);
            }
        }

        Controls.Label{
            text:
                if (actionEdit.checked){
                    return "Твердість: "
                }
                else return "Твердість: " + thisMineral.hardness
        }

        Controls.SpinBox{
            id: hardnessEdit
            from: 1
            to: 10
            visible: actionEdit.checked
            value:  thisMineral.hardness
            implicitWidth: Kirigami.Units.gridUnit * 6
            onValueModified: unsavedChanges+=1
        }
        Controls.TextArea{
            id: descEdit
            Layout.fillWidth: true
            text: thisMineral.description
            Layout.minimumWidth: Kirigami.Units.gridUnit * 12
            Layout.minimumHeight: Kirigami.Units.gridUnit * 12
            readOnly: !actionEdit.checked
            onTextChanged: (text != thisMineral.description) ? unsavedChanges+=1 : 0
        }
        Controls.Button{
            text: "Close"
            icon.name: "dialog-close"
            onClicked: {
                pageStack.layers.pop(1);
            }
        }

    }
}
