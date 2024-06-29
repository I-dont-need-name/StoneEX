import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.StoneEX 1.0
import SqlUtils 1.0

Kirigami.ScrollablePage{
    id: page
    clip:true
    title: "Add mineral"
    implicitWidth: applicationWindow().width
    ColumnLayout{
        Layout.fillWidth: true
        Controls.Label{
            text: "Enter name"
        }
        Controls.TextField {
            id: nameEdit
            placeholderText: "Name"
        }
        Controls.Label{
            text: "Select type"
        }
        Controls.ComboBox{
            id: typeEdit
            implicitWidth: Kirigami.Units.gridUnit * 12
            model: ["Осадовий", "Магматичний", "Магматично-метасоматичний", "Метаморфічний", "Метаморфічно-метосоматичний", "Органічний"]
        }
        Controls.Label{
            text: "Select valuability"
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
        }
        /*Controls.ComboBox{
            id: subvalueEdit
            visible: !(valueEdit.currentText == "Недорогоцінний")
            implicitWidth: Kirigami.Units.gridUnit * 12
            model: switch (valueEdit.currentText)
                   {
                        case "Дорогоцінний":
                            return ["1 порядку", "2 порядку", "3 порядку", "4 порядку"];
                        case "Напівдорогоцінний":
                            return ["1 порядку", "2 порядку"];
                    }
        } */
        Controls.Label{
            text: "Select hardness"
        }

        Controls.SpinBox{
            id: hardnessEdit
            from: 1
            to: 10
            value:  1
            implicitWidth: Kirigami.Units.gridUnit * 6
        }
        Controls.TextArea{
            id: descEdit
            Kirigami.FormData.label: "Description"
            Layout.fillWidth: true
            placeholderText: "Enter description here"
            Layout.minimumWidth: Kirigami.Units.gridUnit * 12
            Layout.minimumHeight: Kirigami.Units.gridUnit * 12
        }
        Controls.Button{
            text: "Add"
            enabled: (nameEdit.text.length * descEdit.text.length)
            icon.name: "list-add"
            onClicked: {
                SqlUtils.addMineral(nameEdit.text, descEdit.text, typeEdit.currentText,
                                    valueEdit.currentValue, hardnessEdit.value);
                pageStack.layers.pop(1);
                MineralPageModel.refreshModel();
            }
        }

    }
}
