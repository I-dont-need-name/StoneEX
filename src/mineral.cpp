#include "mineral.h"

Mineral::Mineral()
{

}

int Mineral::getMineral_id() const
{
    return mineral_id;
}

void Mineral::setMineral_id(int newId)
{
    mineral_id = newId;
    QString query = "SELECT * FROM Minerals WHERE Mineral_id=" + QString::number(newId);
    QSqlQuery getter = QSqlQuery(query);
    getter.first();
    QSqlRecord record = getter.record();

    setName(record.value("Mineral_name").toString());
    setDescription(record.value("Mineral_desc").toString());
    setType(record.value("Mineral_type").toString());
    setValue(record.value("Mineral_valuability").toInt());
    setHardness(record.value("Mineral_hardness").toInt());
    emit mineral_idChanged();
}

const QString &Mineral::getName() const
{
    return name;
}

void Mineral::setName(const QString &newName)
{
    if (name == newName)
        return;
    name = newName;
    emit nameChanged();
}

const QString &Mineral::getDescription() const
{
    return description;
}

void Mineral::setDescription(const QString &newDescription)
{
    if (description == newDescription)
        return;
    description = newDescription;
    emit descriptionChanged();
}

const int &Mineral::getValue() const
{
    return value;
}

void Mineral::setValue(const int &newValue)
{
    if (value == newValue)
        return;
    value = newValue;
    emit valueChanged();
}

int Mineral::getHardness() const
{
    return hardness;
}

void Mineral::setHardness(int newHardness)
{
    if (hardness == newHardness)
        return;
    hardness = newHardness;
    emit hardnessChanged();
}

const QString &Mineral::getType() const
{
    return type;
}

void Mineral::setType(const QString &newType)
{
    if (type == newType)
        return;
    type = newType;
    emit typeChanged();
}
