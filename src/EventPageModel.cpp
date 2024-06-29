#include "EventPageModel.h"


const int EventPageModel::DescriptionRole = Qt::UserRole+1;;
const int EventPageModel::CountryRole = Qt::UserRole+2;
const int EventPageModel::CityRole = Qt::UserRole+3;
const int EventPageModel::AddressRole= Qt::UserRole+4;
const int EventPageModel::DateStartRole = Qt::UserRole+5;
const int EventPageModel::DateEndRole = Qt::UserRole+6;
const int EventPageModel::TimeOpenRole = Qt::UserRole+7;
const int EventPageModel::TimeCloseRole = Qt::UserRole+8;
const int EventPageModel::RevenueRole = Qt::UserRole+9;
const int EventPageModel::TicketPriceRole = Qt::UserRole+10;
const int EventPageModel::LinkRole = Qt::UserRole+11;
const int EventPageModel::EventIDRole = Qt::UserRole+12;
const int EventPageModel::CollectionRole = Qt::UserRole+13;
const int EventPageModel::ImagePathRole = Qt::UserRole+14;

EventPageModel::EventPageModel(){
    QString str = "SELECT * FROM Events";
    myQuery = str;
    this->setQuery(str);
}

QVariant EventPageModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case Qt::DisplayRole:
        return QVariant(this->record(index.row()).value("Event_name"));

    case EventPageModel::DescriptionRole:
        return QVariant(this->record(index.row()).value("Event_description"));

    case EventPageModel::CountryRole:
        return QVariant(this->record(index.row()).value("Event_country"));

    case EventPageModel::CityRole:
        return QVariant(this->record(index.row()).value("Event_city"));

    case EventPageModel::AddressRole:
        return QVariant(this->record(index.row()).value("Event_address"));

    case EventPageModel::DateStartRole:
        return QVariant(this->record(index.row()).value("Event_date_start"));

    case EventPageModel::DateEndRole:
        return QVariant(this->record(index.row()).value("Event_date_end"));

    case EventPageModel::TimeOpenRole:
        return QVariant(this->record(index.row()).value("Event_time_open"));

    case EventPageModel::TimeCloseRole:
        return QVariant(this->record(index.row()).value("Event_time_close"));

    case EventPageModel::RevenueRole:
        return QVariant(this->record(index.row()).value("Event_revenue"));

    case EventPageModel::TicketPriceRole:
        return QVariant(this->record(index.row()).value("Event_ticket"));

    case EventPageModel::LinkRole:
        return QVariant(this->record(index.row()).value("Event_link"));

    case EventPageModel::EventIDRole:
        return QVariant(this->record(index.row()).value("Event_id"));

    case EventPageModel::ImagePathRole:
        return QVariant(this->record(index.row()).value("Event_image"));

    case EventPageModel::CollectionRole:
        return QVariant(this->record(index.row()).value("Event_collection"));

    default:
        return QSqlQueryModel::data(index, role);
    }
}

QHash<int, QByteArray> EventPageModel::roleNames() const
{
    static QHash<int, QByteArray> map{

        {EventPageModel::EventIDRole, "event_id"},
        {Qt::DisplayRole, "display"},
        {EventPageModel::DescriptionRole, "description"},
        {EventPageModel::CountryRole, "country"},
        {EventPageModel::CityRole, "city"},
        {EventPageModel::AddressRole, "address"},
        {EventPageModel::AddressRole, "address"},
        {EventPageModel::DateStartRole, "dateStart"},
        {EventPageModel::DateEndRole, "dateEnd"},
        {EventPageModel::TimeOpenRole, "timeOpen"},
        {EventPageModel::TimeCloseRole, "timeClose"},
        {EventPageModel::RevenueRole, "revenue"},
        {EventPageModel::TicketPriceRole, "ticketPrice"},
        {EventPageModel::LinkRole, "link"},
        {EventPageModel::CollectionRole, "collection_id"},
        {EventPageModel::ImagePathRole, "image"},
    };

    return map;
}


