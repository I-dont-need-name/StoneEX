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

target_link_libraries(stoneex
    Qt5::Core
    Qt5::Gui
    Qt5::Widgets
    Qt5::PrintSupport
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    Qt5::Sql
    Qt5::Xml
    KF5::I18n
    KF5::CoreAddons
    KF5::ConfigCore
    KF5::ConfigGui)

if (ANDROID)
    kirigami_package_breeze_icons(ICONS
        list-add
        help-about
        application-exit
        applications-graphics
    )
endif()

kconfig_add_kcfg_files(stoneex GENERATE_MOC stoneexconfig.kcfgc)
install(TARGETS stoneex ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
