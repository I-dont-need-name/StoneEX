#include "MineralPageModel.h"

const int MineralPageModel::DescriptionRole = Qt::UserRole+1;
const int MineralPageModel::TypeRole = Qt::UserRole+2;
const int MineralPageModel::ValuabilityRole = Qt::UserRole+3;
const int MineralPageModel::IDRole = Qt::UserRole+4;
const int MineralPageModel::HardnessRole = Qt::UserRole+5;

MineralPageModel::MineralPageModel(){
    myQuery  = "SELECT * FROM Minerals";
    this->setQuery(myQuery);
}

QVariant MineralPageModel::data(const QModelIndex &index, int role) const
{
    if (role == MineralPageModel::DescriptionRole)
    {
        return QVariant(this->record(index.row()).value("Mineral_desc"));
    }
    if (role == Qt::DisplayRole)
    {
        return QVariant(this->record(index.row()).value("Mineral_name"));
    }
    if (role == MineralPageModel::TypeRole)
    {
        return QVariant(this->record(index.row()).value("Mineral_type"));
    }
    if (role == MineralPageModel::ValuabilityRole)
    {
        return (this->record(index.row()).value("Mineral_valuability"));
        /*int valueINT = (this->record(index.row()).value("Mineral_valuability")).toInt();

        switch (valueINT){
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
        } */
    }
    if (role == MineralPageModel::IDRole)
    {
        return QVariant(this->record(index.row()).value("Mineral_id"));
    }
    if (role == MineralPageModel::HardnessRole)
    {
        return QVariant(this->record(index.row()).value("Mineral_hardness"));
    }
    else return QSqlQueryModel::data(index, role);
}

QHash<int, QByteArray> MineralPageModel::roleNames() const
{

    static QHash<int, QByteArray> map{
        {Qt::DisplayRole, "display"},
        {MineralPageModel::DescriptionRole, "description"},
        {MineralPageModel::TypeRole, "type"},
        {MineralPageModel::ValuabilityRole, "valuability"},
        {MineralPageModel::IDRole, "mineralID"},
        {MineralPageModel::HardnessRole, "hardness"}
    };

    return map;
}
