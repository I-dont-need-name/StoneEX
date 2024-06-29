#ifndef COLLECTIONPAGEMODEL_H
#define COLLECTIONPAGEMODEL_H


#include "qobjectdefs.h"
#include "QSqlQueryModel"
#include "qsqlquery.h"

class CollectionPageModel : public QSqlQueryModel
{
    Q_OBJECT
    Q_PROPERTY(QString myQuery READ getMyQuery WRITE setMyQuery NOTIFY myQueryChanged)
public:
    CollectionPageModel();
    static const int DescriptionRole;
    static const int IDRole;

    using QSqlQueryModel::data;
    QVariant data(const QModelIndex &index, int role) const override;
    using QSqlQueryModel::roleNames;
    QHash<int, QByteArray> roleNames() const override;

    const QString getMyQuery(){
        return myQuery;
    }

    void setMyQuery(QString New){
        beginResetModel();
        this->setQuery(New);
        myQuery = New;
        endResetModel();
    }

    QString myQuery;

public slots:

    Q_INVOKABLE void refreshModel()
    {
        beginResetModel();
        QString query = this->query().executedQuery();
        this->setQuery(query);
        endResetModel();
    };

signals:
    void myQueryChanged();
};

#endif // COLLECTIONPAGEMODEL_H
