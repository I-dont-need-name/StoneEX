#ifndef DOCUMENTBUILDER_H
#define DOCUMENTBUILDER_H

#undef QT_NO_CAST_FROM_ASCII

#include <QQmlEngine>
#include <qobject.h>
#include <QDomDocument>

class DocumentBuilder : public QObject
{
    Q_OBJECT
public:

    explicit DocumentBuilder(QObject *parent = nullptr);

    static QObject *qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);

    Q_INVOKABLE static void buildStoneDocument(int stone_id);
    Q_INVOKABLE static void buildEventDocument(int event_id);
    static void toPDF(QDomDocument doc);
};

#endif // DOCUMENTBUILDER_H
