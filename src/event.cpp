#include "event.h"
#include "qsqlrecord.h"

#include <QtSql/QSqlQuery>
#include <QVariant>

event::event(QObject *parent)
    : QObject{parent}
{

}

int event::getEvent_id() const
{
    return event_id;
}

void event::setEvent_id(int newEvent_id)
{
    /*if (event_id == newEvent_id)
        return; */
    event_id = newEvent_id;

    QSqlQuery getter;

    getter.prepare("SELECT * FROM Events WHERE Event_id = :id");

    getter.bindValue(":id", event_id);

    getter.exec();
    getter.first();
    QSqlRecord record = getter.record();



    setName(record.value("Event_name").toString());
    setDescription(record.value("Event_description").toString());
    setCollection(record.value("Event_collection").toInt());

    setDateStart(record.value("Event_date_start").toString());
    setDateEnd(record.value("Event_date_end").toString());

    setTimeOpen (record.value("Event_time_open").toString());
    setTimeClose (record.value("Event_time_close").toString());

    setCountry(record.value("Event_country").toString());
    setCity(record.value("Event_city").toString());
    setAddress(record.value("Event_address").toString());

    setRevenue(record.value("Event_revenue").toDouble());
    setTicket(record.value("Event_ticket").toDouble());

    setLink (record.value("Event_link").toString());

    setTotalExp(record.value("TotalExp").toDouble());

    setImage (record.value("Event_image").toString());

    emit event_idChanged();
}

QString event::getName() const
{
    return name;
}

void event::setName(const QString &newName)
{
    if (name == newName)
        return;
    name = newName;
    emit nameChanged();
}

QString event::getDescription() const
{
    return description;
}

void event::setDescription(const QString &newDescription)
{
    if (description == newDescription)
        return;
    description = newDescription;
    emit descriptionChanged();
}

QString event::getCountry() const
{
    return country;
}

void event::setCountry(const QString &newCountry)
{
    if (country == newCountry)
        return;
    country = newCountry;
    emit countryChanged();
}

QString event::getCity() const
{
    return city;
}

void event::setCity(const QString &newCity)
{
    if (city == newCity)
        return;
    city = newCity;
    emit cityChanged();
}

QString event::getAddress() const
{
    return address;
}

void event::setAddress(const QString &newAddress)
{
    if (address == newAddress)
        return;
    address = newAddress;
    emit addressChanged();
}

QString event::getDateStart() const
{
    return dateStart;
}

void event::setDateStart(const QString &newDateStart)
{
    if (dateStart == newDateStart)
        return;
    dateStart = newDateStart;
    emit dateStartChanged();
}

QString event::getDateEnd() const
{
    return dateEnd;
}

void event::setDateEnd(const QString &newDateEnd)
{
    if (dateEnd == newDateEnd)
        return;
    dateEnd = newDateEnd;
    emit dateEndChanged();
}

QString event::getTimeOpen() const
{
    return timeOpen;
}

void event::setTimeOpen(const QString &newTimeOpen)
{
    if (timeOpen == newTimeOpen)
        return;
    timeOpen = newTimeOpen;
    emit timeOpenChanged();
}

QString event::getTimeClose() const
{
    return timeClose;
}

void event::setTimeClose(const QString &newTimeClose)
{
    if (timeClose == newTimeClose)
        return;
    timeClose = newTimeClose;
    emit timeCloseChanged();
}

double event::getRevenue() const
{
    return revenue;
}

void event::setRevenue(double newRevenue)
{
    if (qFuzzyCompare(revenue, newRevenue))
        return;
    revenue = newRevenue;
    emit revenueChanged();
}

double event::getTicket() const
{
    return ticket;
}

void event::setTicket(double newTicket)
{
    if (qFuzzyCompare(ticket, newTicket))
        return;
    ticket = newTicket;
    emit ticketChanged();
}

QString event::getLink() const
{
    return link;
}

void event::setLink(const QString &newLink)
{
    if (link == newLink)
        return;
    link = newLink;
    emit linkChanged();
}

QString event::getImage() const
{
    return image;
}

void event::setImage(const QString &newImage)
{
    if (image == newImage)
        return;
    image = newImage;
    emit imageChanged();
}

int event::getCollection() const
{
    return collection;
}

void event::setCollection(int newCollection)
{
    if (collection == newCollection)
        return;
    collection = newCollection;
    emit collectionChanged();
}

double event::getTotalExp() const
{
    return totalExp;
}

void event::setTotalExp(double newTotalExp)
{
    if (qFuzzyCompare(totalExp, newTotalExp))
        return;
    totalExp = newTotalExp;
    emit totalExpChanged();
}
