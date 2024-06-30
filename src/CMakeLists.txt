# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: 2022 illusion <vladyslav.makarov1@nure.ua>

add_executable(stoneex
    main.cpp
    about.cpp
    app.cpp

    StonePageModel.h
    StonePageModel.cpp

    MineralPageModel.h
    MineralPageModel.cpp

    CollectionPageModel.h
    CollectionPageModel.cpp

    EventPageModel.h
    EventPageModel.cpp

    ExpenseModel.h
    ExpenseModel.cpp

    InternetImageModel.h
    InternetImageModel.cpp

    sqlutils.h
    sqlutils.cpp

    DocumentBuilder.h
    DocumentBuilder.cpp

    stone.h
    stone.cpp

    mineral.h
    mineral.cpp

    collection.h
    collection.cpp

    event.h
    event.cpp

    resources.qrc)

qt_add_qml_module(kweather
    URI "ua.nure.makarov.StoneEX"
    VERSION 1.0
    QML_FILES
    "contents/ui/About.qml"
    "contents/ui/AddEventPage.qml"
    "contents/ui/AddStonePage.qml"
    "contents/ui/DoubleSpinBox.qml"
    "contents/ui/ImageGenPage.qml"
    "contents/ui/MineralPage.qml"
    "contents/ui/ViewCollectionPage.qml"
    "contents/ui/ViewMineralPage.qml"
    "contents/ui/AddCollectionPage.qml"
    "contents/ui/AddMineralPage.qml"
    "contents/ui/CollectionPage.qml"
    "contents/ui/EventPage.qml"
    "contents/ui/main.qml"
    "contents/ui/StonePage.qml"
    "contents/ui/ViewEventPage.qml"
    SOURCES
    StonePageModel.h
    StonePageModel.cpp

    MineralPageModel.h
    MineralPageModel.cpp

    CollectionPageModel.h
    CollectionPageModel.cpp

    EventPageModel.h
    EventPageModel.cpp

    ExpenseModel.h
    ExpenseModel.cpp

    InternetImageModel.h
    InternetImageModel.cpp

    sqlutils.h
    sqlutils.cpp

    DocumentBuilder.h
    DocumentBuilder.cpp

    stone.h
    stone.cpp

    mineral.h
    mineral.cpp

    collection.h
    collection.cpp

    event.h
    event.cpp
    DEPENDENCIES
    QtCore
)


target_link_libraries(stoneex
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::PrintSupport
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Svg
    Qt6::Sql
    Qt6::Xml
    KF6::I18n
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui)

if (ANDROID)
    kirigami_package_breeze_icons(ICONS
        list-add
        help-about
        application-exit
        applications-graphics
    )

    ecm_add_android_apk(stoneex ANDROID_DIR ${CMAKE_SOURCE_DIR}/android)

endif()

kconfig_add_kcfg_files(stoneex GENERATE_MOC stoneexconfig.kcfgc)
install(TARGETS stoneex ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
