#include "StonePageModel.h"

#undef QT_NO_CAST_FROM_ASCII
#undef QT_NO_CAST_FROM_BYTEARRAY
#undef QT_RESTRICTED_CAST_FROM_ASCII

const int StonePageModel::DescriptionRole = Qt::UserRole+1;
const int StonePageModel::PriceRole = Qt::UserRole+2;
const int StonePageModel::ImagePathRole = Qt::UserRole+3;
const int StonePageModel::StoneIDRole = Qt::UserRole+4;

StonePageModel::StonePageModel(){
    QString str = "SELECT * FROM STONES";
    myQuery = str;
    this->setQuery(str);
}

QVariant StonePageModel::data(const QModelIndex &index, int role) const
{
    if (role == StonePageModel::StoneIDRole)
    {
        return QVariant(this->record(index.row()).value("Stone_id"));
    }
    if (role == StonePageModel::DescriptionRole)
    {
        return QVariant(this->record(index.row()).value("Stone_description"));
    }
    if (role == Qt::DisplayRole)
    {
        return QVariant(this->record(index.row()).value("Stone_name"));
    }
    if (role == StonePageModel::PriceRole)
    {
        return QVariant(this->record(index.row()).value("Stone_price"));
    }
    if (role == StonePageModel::ImagePathRole)
    {
        return QVariant(this->record(index.row()).value("Stone_image"));
    }
    else return QSqlQueryModel::data(index, role);

}

QHash<int, QByteArray> StonePageModel::roleNames() const
{
  //  QHash<int, QByteArray> mappings = QSqlQueryModel::roleNames();
  //  mappings.insert(150, "description");


    static QHash<int, QByteArray> map{
        {Qt::DisplayRole, "display"},
        {StonePageModel::DescriptionRole, "description"},
        {StonePageModel::PriceRole, "price"},
        {StonePageModel::ImagePathRole, "imagePath"},
        {StonePageModel::StoneIDRole, "stoneID"}

    };

    return map;
}


