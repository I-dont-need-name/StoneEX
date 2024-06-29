#ifndef MINERALPAGEMODEL_H
#define MINERALPAGEMODEL_H

#include <QtSql/QSqlQueryModel>
#include <QtSql/QSqlRecord>
#include <QtSql/QSqlQuery>

class MineralPageModel: public QSqlQueryModel
{
   Q_OBJECT
   Q_PROPERTY(QString myQuery READ getMyQuery WRITE setMyQuery NOTIFY myQueryChanged)

public:

    MineralPageModel();
    static const int DescriptionRole;
    static const int TypeRole;
    static const int ValuabilityRole;
    static const int IDRole;
    static const int HardnessRole;

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
        this->setQuery(this->query().lastQuery());
        endResetModel();
    };

signals:
    void myQueryChanged();

private:

};

#endif // MINERALPAGEMODEL_H
