#ifndef EXPENSEMODEL_H
#define EXPENSEMODEL_H

#undef QT_NO_CAST_FROM_ASCII

#include <QtSql/QSqlQueryModel>
#include <QtSql/QSqlRecord>
#include <QtSql/QSqlQuery>

class EXpenseModel : public QSqlQueryModel
{
    Q_OBJECT
public:
    explicit EXpenseModel(QObject *parent = nullptr);


    QVariant data(const QModelIndex &index, int role) const override;

    QHash<int, QByteArray> roleNames() const override;

    int rowCount(const QModelIndex &parent) const override;

    int columnCount(const QModelIndex &parent) const override;



    QString getMyQuery() const;
    void setMyQuery(const QString &newMyQuery);

    int getEventID() const;
    void setEventID(int newEventID);

Q_SIGNALS:
    void myQueryChanged();

    void eventIDChanged();

private:
    QString myQuery;
    Q_PROPERTY(QString myQuery READ getMyQuery WRITE setMyQuery NOTIFY myQueryChanged)

    int EventID;
    Q_PROPERTY(int eventID READ getEventID WRITE setEventID NOTIFY eventIDChanged)

    // QAbstractItemModel interface
public:
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
};

#endif // EXPENSEMODEL_H
