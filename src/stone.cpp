#include "stone.h"
#include "qsqlquery.h"
#include "qsqlrecord.h"
#include "qvariant.h"
#include <QObject>

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

    QString query = QString::fromUtf8("SELECT * FROM Stones WHERE Stone_id=") + QString::number(stone_id);
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

    Q_EMIT stone_idChanged();

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
    Q_EMIT nameChanged();
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
    Q_EMIT descriptionChanged();
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
    Q_EMIT colorChanged();
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
    Q_EMIT originChanged();
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
    Q_EMIT priceChanged();
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
    Q_EMIT shapeChanged();
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
    Q_EMIT weigthChanged();
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
    Q_EMIT imageChanged();
}
