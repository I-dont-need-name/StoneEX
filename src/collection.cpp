#include "collection.h"

Collection::Collection()
{

}

const QString &Collection::getName() const
{
    return name;
}

void Collection::setName(const QString &newName)
{
    if (name == newName){
        return;
    }
    name = newName;
    Q_EMIT nameChanged();
}

const QString &Collection::getDescription() const
{
    return description;
}

void Collection::setDescription(const QString &newDescription)
{
    if (description == newDescription)
        return;
    description = newDescription;
    Q_EMIT descriptionChanged();
}

int Collection::getCollection_id() const
{
    return collection_id;
}

void Collection::setCollection_id(int newCollection_id)
{
    collection_id = newCollection_id;

    QSqlQuery getter = QSqlQuery(QString::fromUtf8("SELECT * FROM Collections WHERE Collection_id=") + QString::number(newCollection_id) );
    getter.first();
    QSqlRecord results = getter.record();

    setName(results.value(QString::fromUtf8("Collection_name")).toString());
    setDescription(results.value(QString::fromUtf8("Collection_description")).toString());
    Q_EMIT collection_idChanged();
}
