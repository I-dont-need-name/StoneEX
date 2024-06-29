#ifndef EVENT_H
#define EVENT_H

#include <QObject>

class event : public QObject
{
    Q_OBJECT
public:
    explicit event(QObject *parent = nullptr);

    int getEvent_id() const;
    void setEvent_id(int newEvent_id);
    QString getName() const;
    void setName(const QString &newName);
    QString getDescription() const;
    void setDescription(const QString &newDescription);
    QString getCountry() const;
    void setCountry(const QString &newCountry);
    QString getCity() const;
    void setCity(const QString &newCity);
    QString getAddress() const;
    void setAddress(const QString &newAddress);
    QString getDateStart() const;
    void setDateStart(const QString &newDateStart);
    QString getDateEnd() const;
    void setDateEnd(const QString &newDateEnd);
    QString getTimeOpen() const;
    void setTimeOpen(const QString &newTimeOpen);
    QString getTimeClose() const;
    void setTimeClose(const QString &newTimeClose);
    double getRevenue() const;
    void setRevenue(double newRevenue);
    double getTicket() const;
    void setTicket(double newTicket);
    QString getLink() const;
    void setLink(const QString &newLink);
    QString getImage() const;
    void setImage(const QString &newImage);

    int getCollection() const;
    void setCollection(int newCollection);

    double getTotalExp() const;
    void setTotalExp(double newTotalExp);

signals:

    void event_idChanged();
    void nameChanged();
    void descriptionChanged();
    void countryChanged();
    void cityChanged();
    void addressChanged();
    void dateStartChanged();
    void dateEndChanged();
    void timeOpenChanged();
    void timeCloseChanged();
    void revenueChanged();
    void ticketChanged();
    void linkChanged();
    void imageChanged();

    void collectionChanged();

    void totalExpChanged();

private:

    int event_id;
    QString name;
    QString description;

    int collection;

    QString country;
    QString city;
    QString address;

    QString dateStart;
    QString dateEnd;

    QString timeOpen;
    QString timeClose;

    double revenue;
    double ticket;

    double totalExp;

    QString link;
    QString image;

    Q_PROPERTY(int event_id READ getEvent_id WRITE setEvent_id NOTIFY event_idChanged)
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString description READ getDescription WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QString country READ getCountry WRITE setCountry NOTIFY countryChanged)
    Q_PROPERTY(QString city READ getCity WRITE setCity NOTIFY cityChanged)
    Q_PROPERTY(QString address READ getAddress WRITE setAddress NOTIFY addressChanged)
    Q_PROPERTY(QString dateStart READ getDateStart WRITE setDateStart NOTIFY dateStartChanged)
    Q_PROPERTY(QString dateEnd READ getDateEnd WRITE setDateEnd NOTIFY dateEndChanged)
    Q_PROPERTY(QString timeOpen READ getTimeOpen WRITE setTimeOpen NOTIFY timeOpenChanged)
    Q_PROPERTY(QString timeClose READ getTimeClose WRITE setTimeClose NOTIFY timeCloseChanged)
    Q_PROPERTY(double revenue READ getRevenue WRITE setRevenue NOTIFY revenueChanged)
    Q_PROPERTY(double ticket READ getTicket WRITE setTicket NOTIFY ticketChanged)
    Q_PROPERTY(QString link READ getLink WRITE setLink NOTIFY linkChanged)
    Q_PROPERTY(QString image READ getImage WRITE setImage NOTIFY imageChanged)
    Q_PROPERTY(int collection READ getCollection WRITE setCollection NOTIFY collectionChanged)
    Q_PROPERTY(double totalExp READ getTotalExp WRITE setTotalExp NOTIFY totalExpChanged)
};
#endif // EVENT_H
