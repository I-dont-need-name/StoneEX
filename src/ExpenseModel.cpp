#include "ExpenseModel.h"
#include "qsqlerror.h"
#include "qsqlrecord.h"
#include <QVariant>

#undef QT_NO_CAST_FROM_ASCII

EXpenseModel::EXpenseModel(QObject *parent)
    : QSqlQueryModel{parent}
{
    setQuery("SELECT * FROM Expenses");
}

QVariant EXpenseModel::data(const QModelIndex &index, int role) const
{
    if (role == Qt::DisplayRole && (index.column()== 0 || index.column()== 2) ){
        return QVariant(this->record(index.row()).value("Expense_name"));
    }
    if (role == Qt::DisplayRole && index.column()== 1){
        return QVariant(this->record(index.row()).value("Expense_value"));
    }
    else return QSqlQueryModel::data(index, role);
}

QHash<int, QByteArray> EXpenseModel::roleNames() const
{
    return QHash<int, QByteArray>{
        {Qt::DisplayRole, "display"},
        {Qt::EditRole, "edit"}
    };
}

int EXpenseModel::rowCount(const QModelIndex &parent) const
{
    return QSqlQueryModel::rowCount();
}

int EXpenseModel::columnCount(const QModelIndex &parent) const
{
    return 3;
}

QString EXpenseModel::getMyQuery() const
{
    return myQuery;
}

void EXpenseModel::setMyQuery(const QString &newMyQuery)
{
    myQuery = newMyQuery;
    beginResetModel();
    this->setQuery(myQuery);
    endResetModel();
    Q_EMIT myQueryChanged();
}

int EXpenseModel::getEventID() const
{
    return EventID;
}

void EXpenseModel::setEventID(int newEventID)
{
    EventID = newEventID;
    this->setMyQuery("SELECT Expense_name, Expense_value FROM Expenses WHERE Event_id=" + QString::number(EventID));
    Q_EMIT eventIDChanged();
}

bool EXpenseModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(role == 4900){
        QString expenseName = this->record(index.row()).value("Expense_name").toString();
        QString columnName = this->record(index.row()).fieldName(index.column());
        QSqlQuery updater;
        updater.prepare("UPDATE Expenses SET "+ columnName    + "=:NewValue WHERE Event_id=:id AND Expense_name=:ExpName");
        //updater.bindValue(":ColumnName", columnName);
        updater.bindValue(":id", EventID);
        updater.bindValue(":ExpName", expenseName);
        if(columnName == "Expense_name"){
            updater.bindValue(":NewValue", value.toString());
        }
        else{
            updater.bindValue(":NewValue", value.toInt());
        }


        /*if(columnName == "Expense_value"){
            query = "UPDATE Expenses SET "
                    +  columnName + "=" + value.toString() +
                    " WHERE Event_id= " + QString::number(EventID)
                    + " AND Expense_name='" + expenseName + "'";
        }
        else {
            query = "UPDATE Expenses SET "
                    +  columnName + "=" + value.toString() +
                    " WHERE Event_id= " + QString::number(EventID)
                    + " AND Expense_name='" + expenseName + "'";
        }
        updater.prepare(query); */
       // updater.bindValue(":COLUMNNAME", columnName);
       // updater.bindValue(":NEWVALUE", value.toString());
        //updater.bindValue(":eventID", this->EventID);
        //updater.bindValue(":expenseNAME", expenseName);


        //QString err = updater.lastError().text();
        return updater.exec();
    }
    return 0;
}
