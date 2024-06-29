#ifndef STONE_H
#define STONE_H
#include "qobject.h"
#include "qobjectdefs.h"
#include <QString>

class Stone : public QObject
{
    Q_OBJECT
public:
    Stone();

    int getStone_id() const;
    void setStone_id(int newStone_id);
    const QString &getName() const;
    void setName(const QString &newName);
    const QString &getDescription() const;
    void setDescription(const QString &newDescription);
    const QString &getColor() const;
    void setColor(const QString &newColor);
    const QString &getOrigin() const;
    void setOrigin(const QString &newOrigin);
    double getPrice() const;
    void setPrice(double newPrice);
    const QString &getShape() const;
    void setShape(const QString &newShape);
    int getWeigth() const;
    void setWeigth(int newWeigth);
    const QString &getImage() const;
    void setImage(const QString &newImage);

signals:
    void stone_idChanged();
    void nameChanged();
    void descriptionChanged();
    void colorChanged();
    void originChanged();
    void priceChanged();
    void shapeChanged();
    void weigthChanged();
    void imageChanged();

private:
    int stone_id;
    QString name;
    QString description;
    QString color;
    QString origin;
    double price;
    QString shape;
    int weigth;
    QString image;

    Q_PROPERTY(int stone_id READ getStone_id WRITE setStone_id NOTIFY stone_idChanged)
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString description READ getDescription WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QString color READ getColor WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(QString origin READ getOrigin WRITE setOrigin NOTIFY originChanged)
    Q_PROPERTY(double price READ getPrice WRITE setPrice NOTIFY priceChanged)
    Q_PROPERTY(QString shape READ getShape WRITE setShape NOTIFY shapeChanged)
    Q_PROPERTY(int weigth READ getWeigth WRITE setWeigth NOTIFY weigthChanged)
    Q_PROPERTY(QString image READ getImage WRITE setImage NOTIFY imageChanged)
};

#endif // STONE_H
