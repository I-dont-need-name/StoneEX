#ifndef COLLECTION_H
#define COLLECTION_H
#include "qobject.h"
#include "qobjectdefs.h"
#include <QSqlQuery>
#include <QSqlRecord>
#include <QVariant>

class Collection : public QObject
{
    Q_OBJECT
public:
    Collection();

    const QString &getName() const;
    void setName(const QString &newName);

    const QString &getDescription() const;
    void setDescription(const QString &newDescription);

    int getCollection_id() const;
    void setCollection_id(int newCollection_id);

Q_SIGNALS:
    void nameChanged();
    void descriptionChanged();

    void collection_idChanged();

private:
    int collection_id;
    QString name;
    QString description;
    Q_PROPERTY(QString description READ getDescription WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(int collection_id READ getCollection_id WRITE setCollection_id NOTIFY collection_idChanged)
};

#endif // COLLECTION_H
