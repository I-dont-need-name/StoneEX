#include "sqlutils.h"
#include "qsqlrecord.h"
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>

SqlUtils::SqlUtils(QObject *parent)
    : QObject{parent}
{

}

QObject *SqlUtils::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    return new SqlUtils;
}


void SqlUtils::addMineral(QString name, QString desc, QString type, int valuability, int hardness)
{
    QString queryString = "INSERT INTO Minerals(Mineral_name, Mineral_desc, Mineral_type, Mineral_valuability, Mineral_hardness) VALUES ('"
            + name + "', '"
            + desc + "', '"
            + type + "', '"
            + QString::number(valuability) + "', "
            + QString::number(hardness) + ")";
    QSqlQuery addQuery = QSqlQuery(queryString);
}

bool SqlUtils::updateMineral(int id, QString name, QString desc, QString type, int valuability, int hardness)
{
    QSqlQuery updateQuery;
    updateQuery.prepare("UPDATE Minerals SET Mineral_name=:name, Mineral_desc=:description, Mineral_type=:type, Mineral_valuability=:valuability, Mineral_hardness=:hardness WHERE Mineral_id=:id");
    updateQuery.bindValue(":name", name);
    updateQuery.bindValue(":description", desc);
    updateQuery.bindValue(":type", type);
    updateQuery.bindValue(":valuability", valuability);
    updateQuery.bindValue(":hardness", hardness);
    updateQuery.bindValue(":id", id);
    return updateQuery.exec();
}

void SqlUtils::deleteMineral(int id)
{
    QString queryString = "DELETE FROM Minerals WHERE Mineral_id=" +  QString::number(id);

    QSqlQuery deleteSingleMineralStones;
    deleteSingleMineralStones.prepare("DELETE FROM Stones WHERE Stone_id IN( SELECT Stone_id FROM \"Stone-Minerals\" sm WHERE (SELECT COUNT(Mineral_id) FROM \"Stone-Minerals\" sm2 WHERE sm2.Stone_id=sm.Stone_id)=1 AND Mineral_id=:id)");
    deleteSingleMineralStones.bindValue(":id", id);
    deleteSingleMineralStones.exec();
    QSqlQuery deleteQuery = QSqlQuery(queryString);
}

bool SqlUtils::linkStoneToMineral(int Stone_id, int Mineral_id)
{
    QSqlQuery inserter;
    inserter.prepare("INSERT INTO \"Stone-Minerals\" SELECT " + QString::number(Stone_id) + "," + QString::number(Mineral_id));
    return inserter.exec();
}

int SqlUtils::getLatestRowId()
{
    QSqlQuery getStoneId = QSqlQuery("SELECT last_insert_rowid()");
    getStoneId.first();
    return getStoneId.record().value(0).toInt();
}

int SqlUtils::getMaxStonePrice()
{
    QSqlQuery getter = QSqlQuery("SELECT MAX(Stone_price) FROM Stones");
    getter.first();
    return getter.record().value(0).toInt();
}

bool SqlUtils::addStone(QString name, QString desc, QString color, QString origin, double price, QString shape, int weight, QString imagePath)
{
    QSqlQuery addQuery;
    addQuery.prepare("INSERT INTO Stones(Stone_name, Stone_description, Stone_color, Stone_origin, Stone_price, Stone_shape, Stone_weight, Stone_image) VALUES (:name, :description, :color, :origin, :price, :shape, :weight, :image)");
    addQuery.bindValue(":name", name);
    addQuery.bindValue(":description", desc);
    addQuery.bindValue(":color", color);
    addQuery.bindValue(":origin", origin);
    addQuery.bindValue(":price", price);
    addQuery.bindValue(":shape", shape);
    addQuery.bindValue(":weight", weight);
    addQuery.bindValue(":image", imagePath);
    return addQuery.exec();
}

bool SqlUtils::updateStone(int id, QString name,  QString desc, QString color, QString origin, double price, QString shape, int weight, QString imagePath, QVariantList mineral_ids)
{
    QSqlQuery updateQuery;
    updateQuery.prepare("UPDATE Stones SET Stone_name=:name, Stone_description=:description, Stone_color=:color, Stone_origin=:origin, Stone_price=:price, Stone_shape=:shape, Stone_weight=:weight, Stone_image=:image WHERE Stone_id=:id");
    updateQuery.bindValue(":name", name);
    updateQuery.bindValue(":description", desc);
    updateQuery.bindValue(":color", color);
    updateQuery.bindValue(":origin", origin);
    updateQuery.bindValue(":price", price);
    updateQuery.bindValue(":shape", shape);
    updateQuery.bindValue(":weight", weight);
    updateQuery.bindValue(":image", imagePath);
    updateQuery.bindValue(":id", id);

    bool mineralOps = purgeStoneMinerals(id) && linkStoneMinerals(mineral_ids, id);
    return updateQuery.exec() && mineralOps;
}

void SqlUtils::deleteStone(int id)
{
    QString queryString = "DELETE FROM Stones WHERE Stone_id=" +  QString::number(id);
    QSqlQuery deleteQuery = QSqlQuery(queryString);
}

bool SqlUtils::purgeStoneMinerals(int id)
{
    QSqlQuery purger;
    purger.prepare("DELETE FROM \"Stone-Minerals\" WHERE Stone_id=" + QString::number(id));
    return purger.exec();
}

bool SqlUtils::addCollection(QString name, QString description)
{
    QSqlQuery adder;
    adder.prepare("INSERT INTO Collections (Collection_name, Collection_description) VALUES (:name, :description)");
    adder.bindValue(":name", name);
    adder.bindValue(":description", description);
    return adder.exec();
}

bool SqlUtils::updateCollection(int id, QString name, QString description)
{
    QSqlQuery updater;
    updater.prepare("UPDATE Collections SET Collection_name=:name, Collection_description=:description WHERE Collection_id=:id");
    updater.bindValue(":id", id);
    updater.bindValue(":name", name);
    updater.bindValue(":description", description);
    return updater.exec();
}

bool SqlUtils::purgeCollectionStones(int id)
{
    QSqlQuery purger;
    purger.prepare("DELETE FROM \"Stone-Collection\" WHERE Collection_id=:id");
    purger.bindValue(":id", id);
    return purger.exec();
}

bool SqlUtils::linkCollectionToStone(int collection_id, int stone_id)
{
    QSqlQuery adder;
    adder.prepare("INSERT INTO \"Stone-Collection\" SELECT :stone_id, :collection_id");
    adder.bindValue(":stone_id", stone_id);
    adder.bindValue(":collection_id", collection_id);
    return adder.exec();
}

bool SqlUtils::linkCollectionStones(QVariantList stone_ids, int collection_id)
{
    bool result = false;
    for (QVariant stone_id : stone_ids){
        result = linkCollectionToStone(collection_id, stone_id.toInt());
    }
    return result;
}

bool SqlUtils::deleteCollection(int collectionID)
{
    QSqlQuery deleter;
    deleter.prepare("DELETE FROM Collections WHERE Collection_id=:id");
    deleter.bindValue(":id", collectionID);

    return deleter.exec();
}

bool SqlUtils::addEvent(QString name, QString desc, int collectionID, QString country, QString city, QString address, QString dateStart, QString dateEnd, QString timeOpen, QString timeClose, double revenue, double ticket, QString image)
{
    QSqlQuery adder;
    adder.prepare("INSERT INTO Events(Event_name, Event_description,"
                  " Event_collection, Event_country, Event_city,"
                  " Event_address, Event_date_start, Event_date_end,"
                  " Event_time_open, Event_time_close, Event_revenue,"
                  " Event_ticket, Event_image) "
                  "VALUES"
                  " (:name, :description,"
                  " :collection, :country, :city,"
                  " :address, :date_start, :date_end,"
                  " :time_open, :time_close, :revenue,"
                  " :ticket, :image)");

    adder.bindValue(":name", name);
    adder.bindValue(":description", desc);
    adder.bindValue(":collection", collectionID);
    adder.bindValue(":country", country);
    adder.bindValue(":city", city);
    adder.bindValue(":address", address);
    adder.bindValue(":date_start", dateStart);
    adder.bindValue(":date_end", dateEnd);
    adder.bindValue(":time_open", timeOpen);
    adder.bindValue(":time_close", timeClose);
    adder.bindValue(":revenue", revenue);
    adder.bindValue(":ticket", ticket);
    adder.bindValue(":image", image);
    return adder.exec();
}

bool SqlUtils::updateEvent(int event_id, QString name, QString desc, int collectionID, QString country, QString city, QString address, QString dateStart, QString dateEnd, QString timeOpen, QString timeClose, double revenue, double ticket, QString image)
{
    QSqlQuery updater;
    updater.prepare("UPDATE Events SET Event_name=:name, Event_description=:description,"
                  " Event_collection=:collection, Event_country=:country, Event_city=:city,"
                  " Event_address=:address, Event_date_start=:date_start, Event_date_end=:date_end,"
                  " Event_time_open=:time_open, Event_time_close=:time_close, Event_revenue=:revenue,"
                  " Event_ticket=:ticket, Event_image=:image WHERE Event_id=:id");

    updater.bindValue(":id", event_id);
    updater.bindValue(":name", name);
    updater.bindValue(":description", desc);
    updater.bindValue(":collection", collectionID);
    updater.bindValue(":country", country);
    updater.bindValue(":city", city);
    updater.bindValue(":address", address);
    updater.bindValue(":date_start", dateStart);
    updater.bindValue(":date_end", dateEnd);
    updater.bindValue(":time_open", timeOpen);
    updater.bindValue(":time_close", timeClose);
    updater.bindValue(":revenue", revenue);
    updater.bindValue(":ticket", ticket);
    updater.bindValue(":image", image);

    updater.exec();

    QString query = updater.lastError().nativeErrorCode();
    return 0;
}

bool SqlUtils::deleteEvent(int event_id)
{
    QSqlQuery deleter;
    deleter.prepare("DELETE FROM Events WHERE Event_id=:id");
    deleter.bindValue(":id", event_id);
    return deleter.exec();
}

bool SqlUtils::addExpense(int event_id, QString expenseName, double expenseValue)
{
    QSqlQuery inserter;
    inserter.prepare("INSERT INTO Expenses(Event_id, Expense_name, Expense_value) VALUES (:id, :name, :value)");
    inserter.bindValue(":id", event_id);
    inserter.bindValue(":name", expenseName);
    inserter.bindValue(":value", expenseValue);
    return inserter.exec();
}

bool SqlUtils::deleteExpense(int event_id, QString expenseName)
{
    QSqlQuery deleter;
    deleter.prepare("DELETE FROM Expenses WHERE Event_id=:id AND Expense_name=:name");
    deleter.bindValue(":id", event_id);
    deleter.bindValue(":name", expenseName);
    return deleter.exec();
}

double SqlUtils::countExpenses(int event_id)
{
    QSqlQuery counter;
    counter.prepare("SELECT SUM(Expense_value) FROM Expenses WHERE Event_id=:id");
    counter.bindValue(":id", event_id);
    counter.exec();
    counter.first();
    double result = counter.record().value(0).toDouble();
    return result;
}

int SqlUtils::countStoneEvents(int stone_id)
{
    QSqlQuery counter;
    counter.prepare("SELECT COUNT(Event_id) FROM Events WHERE Event_collection IN "
                    "(SELECT collection_id FROM \"Stone-Collection\" WHERE Stone_id=:id)");
    counter.bindValue(":id", stone_id);
    counter.exec();
    counter.first();
    return counter.value(0).toInt();
}

int SqlUtils::countCollectionMinerals(int collection_id)
{
    QSqlQuery counter;
    counter.prepare("SELECT COUNT(DISTINCT Mineral_id) c FROM Minerals WHERE Mineral_id IN"
                    "(SELECT Mineral_id FROM \"Stone-Minerals\" WHERE Stone_id IN ("
                        "SELECT Stone_id FROM \"Stone-Collection\" WHERE Collection_id=:id)) ");
    counter.bindValue(":id", collection_id);
    counter.exec();
    counter.first();
    return counter.value(0).toInt();
}

QString SqlUtils::getLastError()
{
    QSqlQuery query;
    QString error = query.lastError().nativeErrorCode();
    return error;
}

bool SqlUtils::linkStoneMinerals(QVariantList mineral_ids, int stone_id)
{
    bool result = false;
    if (mineral_ids.length()==0){
        return true;
    }
    for (const QVariant &mineral_id : mineral_ids){
        result = linkStoneToMineral(stone_id, mineral_id.toInt());
    }
    return result;
}
