/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: 2022 illusion <vladyslav.makarov1@nure.ua>
*/

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QtQml>

#include "about.h"
#include "app.h"
#include "version-stoneex.h"
#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <QtSql/QSqlDatabase>
#include <QQuickStyle>

#include "StonePageModel.h"
#include "MineralPageModel.h"
#include "EventPageModel.h"
#include "CollectionPageModel.h"
#include "InternetImageModel.h"
#include "ExpenseModel.h"

#include "sqlutils.h"
#include "DocumentBuilder.h"

#include "mineral.h"
#include "stone.h"
#include "collection.h"
#include "event.h"

#include <QObject>

#include "stoneexconfig.h"


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("KDE"));
    QCoreApplication::setApplicationName(QStringLiteral("StoneEX"));

    KAboutData aboutData(
                         // The program name used internally.
                         QStringLiteral("StoneEX"),
                         // A displayable program name string.
                         i18nc("@title", "StoneEX"),
                         // The program version string.
                         QStringLiteral(STONEEX_VERSION_STRING),
                         // Short description of what the app does.
                         i18n("Application Description"),
                         // The license this code is released under.
                         KAboutLicense::GPL,
                         // Copyright Statement.
                         i18n("(c) 2022"));
    aboutData.addAuthor(i18nc("@info:credit", "illusion"),
                        i18nc("@info:credit", "Author Role"),
                        QStringLiteral("vladyslav.makarov1@nure.ua"),
                        QStringLiteral("https://yourwebsite.com"));
    KAboutData::setApplicationData(aboutData);

    QQmlApplicationEngine engine;

    auto config = StoneEXConfig::self();

    qmlRegisterSingletonInstance("org.kde.StoneEX", 1, 0, "Config", config);

    AboutType about;
    qmlRegisterSingletonInstance("org.kde.StoneEX", 1, 0, "AboutType", &about);

    App application;
    qmlRegisterSingletonInstance("org.kde.StoneEX", 1, 0, "App", &application);

    QQuickStyle::setStyle("material");

    QSqlDatabase localDB = QSqlDatabase::addDatabase("QSQLITE");

    localDB.setDatabaseName("LAB_1");
    localDB.open();

    QSqlQuery enableForeignKeys = QSqlQuery("PRAGMA foreign_keys = ON");

    StonePageModel* stonepagemodel = new StonePageModel();

    MineralPageModel* mineralpagemodel = new MineralPageModel();

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    engine.rootContext()->setContextProperty("StonePageModel", stonepagemodel);
    engine.rootContext()->setContextProperty("MineralPageModel", mineralpagemodel);

    qmlRegisterType<MineralPageModel>("ua.nure.makarov.StoneEX", 1, 0, "MineralViewModel");
    qmlRegisterType<StonePageModel>("ua.nure.makarov.StoneEX", 1, 0, "StoneViewModel");
    qmlRegisterType<CollectionPageModel>("ua.nure.makarov.StoneEX", 1, 0, "CollectionViewModel");
    qmlRegisterType<EventPageModel>("ua.nure.makarov.StoneEX", 1, 0, "EventViewModel");    
    qmlRegisterType<InternetImageModel>("ua.nure.makarov.StoneEX", 1, 0, "InternetImageModel");
    qmlRegisterType<EXpenseModel>("ua.nure.makarov.StoneEX", 1, 0, "ExpenseModel");

    qmlRegisterType<Mineral>("ua.nure.makarov.StoneEX", 1, 0, "Mineral");
    qmlRegisterType<Stone>("ua.nure.makarov.StoneEX", 1, 0, "Stone");
    qmlRegisterType<Collection>("ua.nure.makarov.StoneEX", 1, 0, "Collection");
    qmlRegisterType<event>("ua.nure.makarov.StoneEX", 1, 0, "Event");

    //qmlRegisterType<DocumentBuilder>("ua.nure.makarov.StoneEX", 1, 0, "DocumentBuilder");

    qmlRegisterSingletonType<DocumentBuilder>("DocumentBuilder", 1, 0, "DocumentBuilder", &DocumentBuilder::qmlInstance);
    qmlRegisterSingletonType<SqlUtils>("SqlUtils", 1, 0, "SqlUtils", &SqlUtils::qmlInstance);


    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
