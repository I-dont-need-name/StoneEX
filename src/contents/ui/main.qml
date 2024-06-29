// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2022 illusion <vladyslav.makarov1@nure.ua>

import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.StoneEX 1.0

Kirigami.ApplicationWindow {

    id: root

    title: "World of Stones"

    minimumWidth: Kirigami.Units.gridUnit * 38
    minimumHeight: Kirigami.Units.gridUnit * 36
    //pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.Breadcrumb
    onClosing: App.saveWindowGeometry(root)
    onWidthChanged: saveWindowGeometryTimer.restart()
    onHeightChanged: saveWindowGeometryTimer.restart()
    onXChanged: saveWindowGeometryTimer.restart()
    onYChanged: saveWindowGeometryTimer.restart()

    Component.onCompleted: {App.restoreWindowGeometry(root)
    //pageStack.layers.push("StonePage.qml");

    }

    // This timer allows to batch update the window size change to reduce
    // the io load and also work around the fact that x/y/width/height are
    // changed when loading the page and overwrite the saved geometry from
    // the previous session. (Було в темплейті)
    Timer {
        id: saveWindowGeometryTimer
        interval: 1000
        onTriggered: App.saveWindowGeometry(root)
    }

    property int counter: 0

    globalDrawer: Kirigami.GlobalDrawer {
        title: i18n("StoneEX")
        titleIcon: "applications-graphics"
        isMenu: false
        actions: [
            Kirigami.Action {
                text: i18n("Events")
                icon.name: "tag-events"
                onTriggered: {
                    pageStack.layers.pop(-1)
                }
            },
            Kirigami.Action {
                text: i18n("Stones")
                icon.name: "view-list-icons"
                onTriggered: {
                    pageStack.layers.push('qrc:StonePage.qml')
                }
            },
            Kirigami.Action {
                text: i18n("Minerals")
                icon.name: "view-list-icons"
                onTriggered: {
                    pageStack.layers.push('qrc:MineralPage.qml')
                }
            },
            Kirigami.Action {
                text: i18n("Collections")
                icon.name: "view-list-symbolic"
                onTriggered: {
                    pageStack.layers.push('qrc:CollectionPage.qml')
                }
            },
            Kirigami.Action {
                text: i18n("Quit")
                icon.name: "application-exit"
                onTriggered: Qt.quit()
            }
        ]
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    pageStack.initialPage: "qrc:EventPage.qml"
}
