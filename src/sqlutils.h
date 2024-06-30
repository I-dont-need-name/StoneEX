#ifndef SQLUTILS_H
#define SQLUTILS_H

#undef QT_NO_CAST_FROM_ASCII

#include <QQmlEngine>
#include "qobject.h"

class SqlUtils : public QObject
{
    Q_OBJECT
public:
    explicit SqlUtils(QObject *parent = nullptr);

    static QObject *qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);

    Q_INVOKABLE static int getLatestRowId();
    Q_INVOKABLE static int getMaxStonePrice();

    Q_INVOKABLE static void addMineral(QString name, QString desc, QString type, int valuability, int hardness);
    Q_INVOKABLE static bool updateMineral(int id, QString name, QString desc, QString type, int valuability, int hardness);
    Q_INVOKABLE static void deleteMineral(int id);

    Q_INVOKABLE static bool addStone(QString name, QString desc, QString color, QString origin, double price, QString shape, int weight, QString imagePath);
    Q_INVOKABLE static bool linkStoneToMineral(int Stone_id, int Mineral_id);
    Q_INVOKABLE static bool linkStoneMinerals(QVariantList mineral_ids, int stone_id);
    Q_INVOKABLE static bool updateStone(int id, QString name, QString desc, QString color, QString origin, double price, QString shape, int weight, QString imagePath, QVariantList mineral_ids);
    Q_INVOKABLE static void deleteStone(int id);
    Q_INVOKABLE static bool purgeStoneMinerals(int id);

    Q_INVOKABLE static bool addCollection(QString name, QString description);
    Q_INVOKABLE static bool updateCollection(int id, QString name, QString description);
    Q_INVOKABLE static bool purgeCollectionStones(int id);
    Q_INVOKABLE static bool linkCollectionToStone(int collection_id, int stone_id);
    Q_INVOKABLE static bool linkCollectionStones(QVariantList stone_ids, int collection_id);
    Q_INVOKABLE static bool deleteCollection(int collectionID);

    Q_INVOKABLE static bool addEvent(QString name, QString desc, int collectionID,
                                     QString country, QString city, QString address,
                                     QString dateStart, QString dateEnd, QString timeOpen,
                                     QString timeClose, double revenue, double ticket, QString image);


    Q_INVOKABLE static bool updateEvent(int event_id, QString name, QString desc, int collectionID,
                                     QString country, QString city, QString address,
                                     QString dateStart, QString dateEnd, QString timeOpen,
                                     QString timeClose, double revenue, double ticket, QString image);

    Q_INVOKABLE static bool deleteEvent(int event_id);

    Q_INVOKABLE static bool addExpense(int event_id, QString expenseName, double expenseValue);
    Q_INVOKABLE static bool deleteExpense(int event_id, QString expenseName);

    Q_INVOKABLE static double countExpenses(int event_id);

    Q_INVOKABLE static int countStoneEvents(int stone_id);

    Q_INVOKABLE static int countCollectionMinerals(int collection_id);

    Q_INVOKABLE static QString getLastError();

private:

};

#endif // SQLUTILS_H
