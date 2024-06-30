#include "CollectionPageModel.h"
#include "qsqlrecord.h"

const int CollectionPageModel::DescriptionRole = Qt::UserRole+1;
const int CollectionPageModel::IDRole = Qt::UserRole+2;

CollectionPageModel::CollectionPageModel()
{
    QString str = QString::fromUtf8("SELECT * FROM Collections");
    this->setQuery(str);


}

QVariant CollectionPageModel::data(const QModelIndex &index, int role) const
{
    if (role == CollectionPageModel::DescriptionRole)
    {
        return QVariant(this->record(index.row()).value(QString::fromUtf8("Collection_description")));
    }
    if (role == CollectionPageModel::IDRole)
    {
        return QVariant(this->record(index.row()).value(QString::fromUtf8("Collection_id")));
    }
    if (role == Qt::DisplayRole)
    {
        return QVariant(this->record(index.row()).value(QString::fromUtf8("Collection_name")));

    }
    else return QSqlQueryModel::data(index, role);

}

QHash<int, QByteArray> CollectionPageModel::roleNames() const
{

    static QHash<int, QByteArray> map{
        {Qt::DisplayRole, "display"},
        {CollectionPageModel::DescriptionRole, "description"},
        {CollectionPageModel::IDRole, "collection_id"}
    };

    return map;
}


