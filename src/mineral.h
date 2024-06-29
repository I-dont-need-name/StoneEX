#ifndef MINERAL_H
#define MINERAL_H

#include "qobjectdefs.h"
#include "qqml.h"
#include <QString>
#include <QSqlRecord>
#include <QSqlQuery>
#include <QVariant>
#include <QString>

class Mineral : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    Mineral();

    int getMineral_id() const;
    void setMineral_id(int newId);

    const QString &getName() const;
    void setName(const QString &newName);

    const QString &getDescription() const;
    void setDescription(const QString &newDescription);

    const int &getValue() const;
    void setValue(const int &newValue);

    int getHardness() const;
    void setHardness(int newHardness);

    const QString &getType() const;
    void setType(const QString &newType);

signals:
    void mineral_idChanged();
    void nameChanged();
    void descriptionChanged();
    void valueChanged();
    void hardnessChanged();
    void typeChanged();

private:
    int mineral_id;
    QString name;
    QString description;
    int value;
    int hardness;
    QString type;
    Q_PROPERTY(int mineral_id READ getMineral_id WRITE setMineral_id NOTIFY mineral_idChanged)
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString description READ getDescription WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(int value READ getValue WRITE setValue NOTIFY valueChanged)
    Q_PROPERTY(int hardness READ getHardness WRITE setHardness NOTIFY hardnessChanged)
    Q_PROPERTY(QString type READ getType WRITE setType NOTIFY typeChanged)
};

#endif // MINERAL_H
