#include "DocumentBuilder.h"
#include "qsqlquery.h"
#include "qsqlrecord.h"
#include <QDateTime>
#include <QVariant>
#include <QtPrintSupport/QtPrintSupport>
#include <QFileDialog>
#include <QDomDocument>
#include <QDomElement>

#undef QT_NO_CAST_FROM_ASCII


DocumentBuilder::DocumentBuilder(QObject *parent) : QObject{parent}
{}

QObject *DocumentBuilder::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    return new DocumentBuilder;
}

void DocumentBuilder::buildStoneDocument(int stone_id)
{
    // Запит на отримання інформації про камінь
    QSqlQuery getter;
    getter.prepare(QString::fromUtf8("SELECT Stone_name, Stone_description, Stone_color, Stone_origin, Stone_shape, Stone_weight FROM Stones WHERE Stone_id=:id"));
    getter.bindValue(":id", stone_id);

    //Назви колонок
    QString columns[] = {"Опис:", "Колір:", "Походження:", "Форма/огранка:", "Вага:"};

    //Значення цінностей мінералів
    QString valuabilies[] = {"Недорогоцінний", "Напівдорогоцінний II порядку", "Напівдорогоцінний I порядку", "Дорогоцінний IV порядку", "Дорогоцінний III порядку", "Дорогоцінний II порядку", "Дорогоцінний I порядку"};


    if (!getter.exec()){
        return;
    }
    getter.first();

    QDomDocument doc = QDomDocument("html");

    QDomElement table = doc.createElement("table");
    table.setAttribute("bordercolor", "\"FF000000\"");
    table.setAttribute("border", "2");

    QDomElement heading = doc.createElement("h1");
    QDomText headingContent = doc.createTextNode(getter.record().value("Stone_name").toString());
    heading.appendChild(headingContent);

    doc.appendChild(heading);


    //Ітерація по всім колонкам

    for(int  i =1; i < getter.record().count(); i++){
        QDomElement tr = doc.createElement("tr");

        QDomElement td1 = doc.createElement("td");
        QDomElement td2 = doc.createElement("td");

        QDomText td1Content = doc.createTextNode("td");
        QDomText td2Content = doc.createTextNode("td");

        //td1Content.setNodeValue(columns[i]);
        //td2Content.setNodeValue(getter.record().value(i-1).toString());

        td1Content.setNodeValue(columns[i-1]);
        td2Content.setNodeValue(getter.record().value(i).toString());

        td1.appendChild(td1Content);
        td2.appendChild(td2Content);

        tr.appendChild(td1);
        tr.appendChild(td2);

        table.appendChild(tr);
    }

    //Додаємо таблицю з даним  документ

    doc.appendChild(table);
    QString stroka = doc.toString();

    //Лейбл "Включає наступні мінерали"

    //Таблиця з інформацією про мінерали
    QDomElement mineralTable = doc.createElement("table");

    mineralTable.setAttribute("bordercolor", "\"FF000000\"");
    mineralTable.setAttribute("border", "2");


    //Запит на отримання мінералів

    QSqlQuery mineralGetter;
    mineralGetter.prepare("SELECT Mineral_name, Mineral_valuability, Mineral_desc FROM MINERALS WHERE Mineral_id IN (SELECT Mineral_id FROM \"Stone-Minerals\" WHERE Stone_id=:stone_id)");
    mineralGetter.bindValue(":stone_id", stone_id);

    if(mineralGetter.exec() && !mineralGetter.record().isEmpty()){
        QDomElement MineralLabel = doc.createElement("h1");
        QDomText MineralLabelContent = doc.createTextNode("Включає наступні мінерали:");
        MineralLabel.appendChild(MineralLabelContent);

        doc.appendChild(MineralLabel);

        while(mineralGetter.next()){
            QDomElement tr = doc.createElement("tr");

            QDomElement td1 = doc.createElement("td");
            QDomElement td2 = doc.createElement("td");
            QDomElement td3 = doc.createElement("td");

            QDomText td1Content = doc.createTextNode("td");
            QDomText td2Content = doc.createTextNode("td");
            QDomText td3Content = doc.createTextNode("td");

            td1Content.setNodeValue(mineralGetter.record().value(0).toString());
            td2Content.setNodeValue(valuabilies[mineralGetter.record().value(1).toInt()]);
            td3Content.setNodeValue(mineralGetter.record().value(2).toString());

            td1.appendChild(td1Content);
            td2.appendChild(td2Content);
            td3.appendChild(td3Content);

            tr.appendChild(td1);
            tr.appendChild(td2);
            tr.appendChild(td3);

            mineralTable.appendChild(tr);
        }

    }

    doc.appendChild(mineralTable);

    QDomText dateStamp = doc.createTextNode("\n Станом на " + QDateTime::currentDateTime().toString("dd.MM.yyyy hh:mm"));
    doc.appendChild(dateStamp);

    toPDF(doc);
    return;
}

//Функція що генерує документ зі списком експонатів виставки
void DocumentBuilder::buildEventDocument(int event_id)
{
    QSqlQuery getter;
    getter.prepare("SELECT Event_name, Event_description, Event_collection, Event_country, Event_city, Event_address, Event_date_start, Event_date_end, Event_time_open, Event_time_close FROM Events WHERE Event_id=:id");
    getter.bindValue(":id", event_id);

    if(!getter.exec()){
        return;
    }
    else {
        getter.first();
    }
    QDomDocument doc = QDomDocument("html");

    QDomElement heading = doc.createElement("h1");
    QDomText headingContent = doc.createTextNode(getter.record().value("Event_name").toString());
    heading.appendChild(headingContent);

    doc.appendChild(heading);

    QDomText descText = doc.createTextNode(getter.record().value("Event_description").toString());

    QString startString = QDateTime::fromString(getter.record().value("Event_date_start").toString(), "yyyy-MM-dd").toString("dd MMMM yyyy");
    QString endString = QDateTime::fromString(getter.record().value("Event_date_end").toString(), "yyyy-MM-dd").toString("dd MMMM yyyy");

    QDomElement dateLabel = doc.createElement("h4");
    QDomText dateContent = doc.createTextNode("з " + startString + " по " + endString);
    dateLabel.appendChild(dateContent);
    heading.appendChild(headingContent);

    QDomText t1 = doc.createTextNode("\n Список експонатів на виставці:");

    doc.appendChild(descText);
    doc.appendChild(dateLabel);
    doc.appendChild(t1);

    int collection_id = getter.record().value("Event_collection").toInt();

    QSqlQuery listGetter;
    listGetter.prepare("SELECT Stone_name FROM Stones WHERE Stone_id in (SELECT Stone_id FROM \"Stone-Collection\" WHERE Collection_id=:id)");
    listGetter.bindValue(":id", collection_id);

    QDomElement table = doc.createElement("table");
    table.setAttribute("bordercolor", "\"FF000000\"");
    table.setAttribute("border", "1");

    if(!listGetter.exec()){
        return;
    }
    else {
        while (listGetter.next()){
            QDomElement tr = doc.createElement("tr");

            QDomElement td = doc.createElement("td");
            td.appendChild(doc.createTextNode(listGetter.record().value(0).toString()));

            tr.appendChild(td);

            table.appendChild(tr);
        }
    }
    doc.appendChild(table);

    QDomText dateStamp = doc.createTextNode("\n Станом на " + QDateTime::currentDateTime().toString("dd.MM.yyyy hh:mm"));
    doc.appendChild(dateStamp);

    toPDF(doc);
    return;
}

//Функція, що переводить документ в пдф файл
void DocumentBuilder::toPDF(QDomDocument doc)
{
    QString fileName = QFileDialog::getSaveFileName((QWidget* )0, "Export PDF", QString(), "*.pdf");
    if (QFileInfo(fileName).suffix().isEmpty()) { fileName.append(".pdf"); }

    QPrinter printer(QPrinter::PrinterResolution);
    printer.setOutputFormat(QPrinter::PdfFormat);
    printer.setPageSize(QPageSize::A4);
    printer.setOutputFileName(fileName);

    printer.setPageMargins(QMarginsF(30, 10 ,10 ,10), QPageLayout::Millimeter);

    QTextDocument printable;
    printable.setHtml(doc.toString());
    //printable.setPageSize(printer.pageRect().size());
    printable.print(&printer);
    return;
}
