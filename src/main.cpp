/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include <QtGlobal>
#include <QTranslator>
#include <QLibraryInfo>
#include <QVersionNumber>

#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QSurfaceFormat>

#include <statusbar.h>
#include <singleapplication.h>

#include "utils_app.h"
#include "utils_screen.h"
#include "settingsmanager.h"
#include "systraymanager.h"
#include "macosdockmanager.h"
#include "notificationmanager.h"
#include "devicemanager.h"
#include "demomode.h"

/* ************************************************************************** */

int main(int argc, char *argv[])
{
    // Arguments parsing ///////////////////////////////////////////////////////

    bool start_minimized = false;
    bool refresh_only = false;
    bool background_service = false;
    for (int i = 1; i < argc; i++)
    {
        if (argv[i])
        {
            //qDebug() << "> arg >" << argv[i];

            if (QString::fromLocal8Bit(argv[i]) == "--start-minimized")
                start_minimized = true;
            if (QString::fromLocal8Bit(argv[i]) == "--service")
                background_service = true;
            if (QString::fromLocal8Bit(argv[i]) == "--refresh")
                refresh_only = true;
        }
    }

    // Background service application //////////////////////////////////////////

    if (background_service || refresh_only)
    {
        SettingsManager *sm = SettingsManager::getInstance();
        SystrayManager *st = SystrayManager::getInstance();
        NotificationManager *nm = NotificationManager::getInstance();
        DeviceManager *dm = new DeviceManager;

        if (!sm || !st || !nm || !dm)
            return EXIT_FAILURE;

        // Refresh data in the background, without starting the UI, then exit
        if (refresh_only)
        {
            //QCoreApplication
            if (dm->areDevicesAvailable())
            {
                dm->refreshDevices_check();
                return EXIT_SUCCESS;
            }
        }
        if (background_service)
        {
            //QAndroidService app(argc, argv);
            // TODO
            //return app.exec();
        }

        return EXIT_SUCCESS;
    }

    // GUI application /////////////////////////////////////////////////////////

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

#if defined(Q_OS_LINUX)
    // NVIDIA suspend&resume hack
    if (QLibraryInfo::version() >= QVersionNumber(5, 13, 0))
    {
        auto format = QSurfaceFormat::defaultFormat();
        format.setOption(QSurfaceFormat::ResetNotification);
        QSurfaceFormat::setDefaultFormat(format);
    }
#endif

    SingleApplication app(argc, argv);

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    // Application icon
    QIcon appIcon(":/assets/logos/watchflower.svg");
    app.setWindowIcon(appIcon);
#endif

    // Application name
    app.setApplicationName("WatchFlower");
    app.setApplicationDisplayName("WatchFlower");
    app.setOrganizationName("WatchFlower");
    app.setOrganizationDomain("WatchFlower");

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    // Keep the StatusBar the same color as the splashscreen until UI starts
    StatusBar sb;
    sb.setColor("#fff");

    // Set QML material theme
    //QQuickStyle::setStyle("material");
#endif

#ifdef DEMO_MODE
    // DEMO mode, with fake data and fixed config
    app.setApplicationName("WatchFlower_demo");
    setup_demo_mode();
#endif

#ifndef DEMO_MODE
    // i18n
    QTranslator qtTranslator;
    qtTranslator.load("qt_" + QLocale::system().name(), QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    app.installTranslator(&qtTranslator);

    QTranslator appTranslator;
    appTranslator.load(":/i18n/watchflower.qm");
    app.installTranslator(&appTranslator);
#endif // DEMO_MODE

    // Init WatchFlower components
    SettingsManager *sm = SettingsManager::getInstance();
    SystrayManager *st = SystrayManager::getInstance();
    NotificationManager *nm = NotificationManager::getInstance();
    DeviceManager *dm = new DeviceManager;

    if (!sm || !st || !nm || !dm)
    {
        qWarning() << "Cannot init WatchFlower components!";
        return EXIT_FAILURE;
    }

    UtilsScreen *utilsScreen = new UtilsScreen();
    UtilsApp *utilsApp = UtilsApp::getInstance();

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(FORCE_MOBILE_UI)
    qmlRegisterType<StatusBar>("StatusBar", 0, 1, "StatusBar");
#endif

    qmlRegisterSingletonType(QUrl("qrc:/qml/ThemeEngine.qml"), "ThemeEngine", 1, 0, "Theme");

    // Then we start the UI
    QQmlApplicationEngine engine;
    QQmlContext *engine_context = engine.rootContext();
    engine_context->setContextProperty("deviceManager", dm);
    engine_context->setContextProperty("settingsManager", sm);
    engine_context->setContextProperty("systrayManager", st);
    engine_context->setContextProperty("utilsApp", utilsApp);
    engine_context->setContextProperty("utilsScreen", utilsScreen);
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined (FORCE_MOBILE_UI)
    engine.load(QUrl(QStringLiteral("qrc:/qml/MobileMain.qml")));
#else
    engine.load(QUrl(QStringLiteral("qrc:/qml/DesktopMain.qml")));
#endif

    if (engine.rootObjects().isEmpty())
    {
        qWarning() << "Cannot init QmlApplicationEngine!";
        return EXIT_FAILURE;
    }

    // QQuickWindow must be valid at this point
    QQuickWindow *window = qobject_cast<QQuickWindow *>(engine.rootObjects().value(0));
    engine_context->setContextProperty("quickWindow", window);

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    // Set systray?
    st->initSettings(&app, window);
    if (sm->getSysTray())
    {
        st->initSystray();
        st->installSystray();
    }

    // Start minimized?
    if (start_minimized || sm->getMinimized())
    {
        window->setVisibility(QWindow::Minimized);
    }
#endif

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS) && !defined(FORCE_MOBILE_UI)
#if defined(Q_OS_LINUX)
    // GNOME hack for the mysterious disappearences of the tray icon...
    // Or just use gnome-shell-extension-appindicator instead of TopIcon Plus (sorry)...
    //QObject::connect(&app, &SingleApplication::instanceStarted, st, &SystrayManager::REinstallSystray);
#endif
    QObject::connect(&app, &SingleApplication::instanceStarted, window, &QQuickWindow::show);
    QObject::connect(&app, &SingleApplication::instanceStarted, window, &QQuickWindow::raise);
#endif

#if defined(Q_OS_MACOS)
    MacOSDockManager *dockIconHandler = MacOSDockManager::getInstance();
    QObject::connect(dockIconHandler, &MacOSDockManager::dockIconClicked, window, &QQuickWindow::show);
    QObject::connect(dockIconHandler, &MacOSDockManager::dockIconClicked, window, &QQuickWindow::raise);
#endif

    return app.exec();
}

/* ************************************************************************** */
