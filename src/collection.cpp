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
    emit nameChanged();
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
    emit descriptionChanged();
}

int Collection::getCollection_id() const
{
    return collection_id;
}

void Collection::setCollection_id(int newCollection_id)
{
    collection_id = newCollection_id;

    QSqlQuery getter = QSqlQuery("SELECT * FROM Collections WHERE Collection_id=" + QString::number(newCollection_id) );
    getter.first();
    QSqlRecord results = getter.record();

    setName(results.value("Collection_name").toString());
    setDescription(results.value("Collection_description").toString());
    emit collection_idChanged();
}
