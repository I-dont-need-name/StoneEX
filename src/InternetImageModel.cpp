#include "InternetImageModel.h"
#include "qeventloop.h"
#include "qnetworkaccessmanager.h"
#include "qnetworkreply.h"
#include "qregularexpression.h"

const int InternetImageModel::ImageURLRole = Qt::UserRole+1;

InternetImageModel::InternetImageModel(QObject *parent)
    : QAbstractListModel{parent}
{

}

QString InternetImageModel::getQuery() const
{
    return query;
}

void InternetImageModel::setQuery(const QString &newQuery)
{
    if (query == newQuery)
        return;
    query = newQuery;
    emit queryChanged();

    // АЛГОРИТМ ДІСТАВАННЯ ЗОБРАЖЕНЬ З Сайту Wikimedia (медіа-сховище вікіпедії). Регекси, костилі і молитви
    QNetworkAccessManager manager;
    QString adress("https://commons.wikimedia.org/w/index.php?search=CUSTOMQUERY&title=Special:MediaSearch&go=Go&type=image");

    //підставляємо наш запит
    adress.replace("CUSTOMQUERY", query);
    //замінюємо пробіли шоб нормально шукало
    adress.replace(' ', "%20");

    QUrl url(adress);

    QNetworkRequest request(url);
    QNetworkReply *reply(manager.get(request));
    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit );
    loop.exec();

    //записуємо HTML-код сторінки в QString
    QString ret = QString::fromStdString(reply->readAll().toStdString());

    //Цей вираз дістає із результатів посилання на перегляд окремих картинок, але це перегляд всередині сайту а не посилання напряму на картинку
    QRegularExpression regex("(?<=href=\")(.*)(?=\")");

    QStringList links;

    //Витягнемо посилання за допомогою виразу
    QRegularExpressionMatchIterator match = regex.globalMatch(ret);

    while (match.hasNext()){
        links.append(match.next().captured());
    }

    //Це щось типу фільтру, наприклад тут ми вказуємо що хочемо бачити тільки .jpg картинки
    //і те що хочемо відсіювати результати з "russi" в назві файлу.
    //це іноді допомагає позбутись фотографій що стосуються поточної війни для міст в Україні

    for (int i =0; i < links.size(); i++){
        QString cur = links.at(i);

        if( !cur.contains(".jpg") || cur.contains("russi", Qt::CaseInsensitive)){
            links.removeAt(i);
            i = i-1;
        }
    }

    //Тепер із цих посилань треба дістати посилання на самі файли

    QStringList ImageLinks;

    regex.setPattern("(?<=.jpg\" src=\")(.*)(?=\" decoding)");


    for(int i = 0; i < links.size(); i++){

        request.setUrl(links.at(i));
        reply = manager.get(request);

        QEventLoop loop;
        QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit );
        loop.exec();

        ret = QString::fromStdString( reply->readAll().toStdString());

        QRegularExpressionMatchIterator match2 = regex.globalMatch(ret);

        QStringList ThisImageLinks;

        while (match2.hasNext()){
            ThisImageLinks.append(match2.next().captured());
        }

        int limit = ThisImageLinks.size() > 10 ? 10 : ThisImageLinks.size();
        for (int i =0; i < ThisImageLinks.size(); i++){

            QString cur = ThisImageLinks.at(i);

            if(cur.contains(".jpeg") || cur.contains(".jpg")){

            }
            else {
                ThisImageLinks.removeAt(i);
                i = -1;
            }
        }
        ImageLinks.append(ThisImageLinks.at(0));

    }
    beginResetModel();
    this->urls = ImageLinks;
    endResetModel();
}

QStringList InternetImageModel::getUrls() const
{
    return urls;
}

void InternetImageModel::setUrls(const QStringList &newUrls)
{
    if (urls == newUrls)
        return;
    urls = newUrls;
    emit urlsChanged();
}

QVariant InternetImageModel::data(const QModelIndex &index, int role) const
{
    if(role == ImageURLRole){
        return urls.at(index.row());
    }
    else return 0;
}

QHash<int, QByteArray> InternetImageModel::roleNames() const
{
    return QHash<int, QByteArray>{
      {InternetImageModel::ImageURLRole, "imageURL"}
    };
}

int InternetImageModel::rowCount(const QModelIndex &parent) const
{
    return urls.length();
}
