#ifndef STONEPAGEMODEL_H
#define STONEPAGEMODEL_H

#include <QtSql/QSqlQueryModel>
#include <QtSql/QSqlRecord>
#include <QtSql/QSqlQuery>


class StonePageModel: public QSqlQueryModel
{
    Q_OBJECT
    Q_PROPERTY(QString myQuery READ getMyQuery WRITE setMyQuery NOTIFY myQueryChanged)
public:

    StonePageModel();
    static const int DescriptionRole;
    static const int PriceRole;
    static const int OriginRole;
    static const int ImagePathRole;
    static const int StoneIDRole;

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
#endif //STONEPAGEMODEL_H
