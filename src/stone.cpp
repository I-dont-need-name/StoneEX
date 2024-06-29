#include "stone.h"
#include "qsqlquery.h"
#include "qsqlrecord.h"
#include "qvariant.h"


Stone::Stone()
{

}

int Stone::getStone_id() const
{
    return stone_id;
}

void Stone::setStone_id(int newStone_id)
{
    stone_id = newStone_id;

    QString query = "SELECT * FROM Stones WHERE Stone_id=" + QString::number(stone_id);
    QSqlQuery getter = QSqlQuery(query);
    getter.first();
    QSqlRecord record = getter.record();

    setName(record.value(1).toString());
    setDescription(record.value(2).toString());
    setColor(record.value(3).toString());
    setOrigin(record.value(4).toString());
    setPrice(record.value(5).toDouble());
    setShape(record.value(6).toString());
    setWeigth(record.value(7).toInt());
    setImage(record.value(8).toString());

    emit stone_idChanged();

}

const QString &Stone::getName() const
{
    return name;
}

void Stone::setName(const QString &newName)
{
    if (name == newName)
        return;
    name = newName;
    emit nameChanged();
}

const QString &Stone::getDescription() const
{
    return description;
}

void Stone::setDescription(const QString &newDescription)
{
    if (description == newDescription)
        return;
    description = newDescription;
    emit descriptionChanged();
}

const QString &Stone::getColor() const
{
    return color;
}

void Stone::setColor(const QString &newColor)
{
    if (color == newColor)
        return;
    color = newColor;
    emit colorChanged();
}

const QString &Stone::getOrigin() const
{
    return origin;
}

void Stone::setOrigin(const QString &newOrigin)
{
    if (origin == newOrigin)
        return;
    origin = newOrigin;
    emit originChanged();
}

double Stone::getPrice() const
{
    return price;
}

void Stone::setPrice(double newPrice)
{
    if (qFuzzyCompare(price, newPrice))
        return;
    price = newPrice;
    emit priceChanged();
}

const QString &Stone::getShape() const
{
    return shape;
}

void Stone::setShape(const QString &newShape)
{
    if (shape == newShape)
        return;
    shape = newShape;
    emit shapeChanged();
}

int Stone::getWeigth() const
{
    return weigth;
}

void Stone::setWeigth(int newWeigth)
{
    if (weigth == newWeigth)
        return;
    weigth = newWeigth;
    emit weigthChanged();
}

const QString &Stone::getImage() const
{
    return image;
}

void Stone::setImage(const QString &newImage)
{
    if (image == newImage)
        return;
    image = newImage;
    emit imageChanged();
}
