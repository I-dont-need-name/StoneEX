

#include <QtSql/QSqlQueryModel>
#include <QtSql/QSqlRecord>
#include <QtSql/QSqlQuery>


class EventPageModel: public QSqlQueryModel
{
    Q_OBJECT
    Q_PROPERTY(QString myQuery READ getMyQuery WRITE setMyQuery NOTIFY myQueryChanged)
public:

    EventPageModel();
    static const int EventIDRole;
    static const int CollectionRole;
    static const int DescriptionRole;
    static const int CountryRole;
    static const int CityRole;
    static const int AddressRole;
    static const int DateStartRole;
    static const int DateEndRole;
    static const int TimeOpenRole;
    static const int TimeCloseRole;
    static const int RevenueRole;
    static const int TicketPriceRole;
    static const int LinkRole;
    static const int ImagePathRole;

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
