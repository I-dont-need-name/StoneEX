#ifndef INTERNETIMAGEMODEL_H
#define INTERNETIMAGEMODEL_H

#undef QT_NO_CAST_FROM_ASCII

#include <QAbstractListModel>

class InternetImageModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit InternetImageModel(QObject *parent = nullptr);

    static const int ImageURLRole;

    QString getQuery() const;
    void setQuery(const QString &newQuery);
    QStringList getUrls() const;
    void setUrls(const QStringList &newUrls);

    using QAbstractListModel::data;
    QVariant data(const QModelIndex &index, int role) const override;
    using QAbstractListModel::roleNames;
    QHash<int, QByteArray> roleNames() const override;

    int rowCount(const QModelIndex &parent) const override;


Q_SIGNALS:
    void queryChanged();
    void urlsChanged();

private:
    QString query;
    QStringList urls;
    Q_PROPERTY(QString query READ getQuery WRITE setQuery NOTIFY queryChanged)
    Q_PROPERTY(QStringList urls READ getUrls WRITE setUrls NOTIFY urlsChanged)


};

#endif // INTERNETIMAGEMODEL_H
