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

    setName(record.value(QString::fromUtf8("Mineral_name")).toString());
    setDescription(record.value(QString::fromUtf8("Mineral_desc")).toString());
    setType(record.value(QString::fromUtf8("Mineral_type")).toString());
    setValue(record.value(QString::fromUtf8("Mineral_valuability")).toInt());
    setHardness(record.value(QString::fromUtf8("Mineral_hardness")).toInt());
    Q_EMIT mineral_idChanged();
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
    Q_EMIT nameChanged();
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
    Q_EMIT descriptionChanged();
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
    Q_EMIT valueChanged();
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
    Q_EMIT hardnessChanged();
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
    Q_EMIT typeChanged();
}
