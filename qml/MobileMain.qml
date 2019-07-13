/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2019 Emeric Grange - All Rights Reserved
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
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.0
import QtQuick.Window 2.2

import StatusBar 0.1
import com.watchflower.theme 1.0

ApplicationWindow {
    id: applicationWindow
    minimumWidth: 400
    minimumHeight: 640

    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint
    color: Theme.colorBackground
    visible: true

    // Mobile stuff ////////////////////////////////////////////////////////////

    // 1 = Qt::PortraitOrientation, 2 = Qt::LandscapeOrientation
    property int screenOrientation: Screen.primaryOrientation
    property int screenTopPadding: 0

    onScreenOrientationChanged: handleNotches()
    Component.onCompleted: handleNotches()

    function handleNotches() {
        if (typeof quickWindow === "undefined" || !quickWindow) return
        if (Qt.platform !== "ios") return
/*
        var screenPadding = (Screen.height - Screen.desktopAvailableHeight)
        console.log("screen height : " + Screen.height)
        console.log("screen avail  : " + Screen.desktopAvailableHeight)
        console.log("screen padding: " + screenPadding)

        var safeMargins = settingsManager.getSafeAreaMargins(quickWindow)
        console.log("top:" + safeMargins["top"])
        console.log("right:" + safeMargins["right"])
        console.log("bottom:" + safeMargins["bottom"])
        console.log("left:" + safeMargins["left"])
*/
        var safeMargins = settingsManager.getSafeAreaMargins(quickWindow)
        if (Screen.primaryOrientation === 1 && safeMargins["total"] > 0)
            screenTopPadding = 30
        else
            screenTopPadding = 0
    }

    StatusBar {
        theme: Material.Dark
        color: Theme.colorHeaderStatusbar
    }

    MobileHeader {
        id: appHeader
        width: parent.width
        anchors.top: parent.top
    }
/*
    property var appHeader: null
    Loader {
        id: headerLoader
        width: parent.width
        anchors.top: parent.top
        z: 10

        Component.onCompleted: {
            if (settingsManager.getScreenSize() > 7.0) // tablet
                headerLoader.source = "DesktopHeader.qml"
            else // phone
                headerLoader.source = "MobileHeader.qml"
            appHeader = headerLoader.item
        }

        onLoaded: {
            //
            binder.target = headerLoader.item;
        }
    }
    Binding {
        id: binder
        property: "title"
        value: title
    }
    Binding {
        id: binder2
        property: "leftMenuMode"
        value: leftMenuMode
    }
*/
    Drawer {
        id: appDrawer
        width: (Screen.primaryOrientation === 1) ? 0.80 * applicationWindow.width : 0.50 * applicationWindow.width
        height: applicationWindow.height

        MobileDrawer { id: drawerscreen }
    }

    // Events handling /////////////////////////////////////////////////////////

    Connections {
        target: appHeader
        onLeftMenuClicked: {
            if (appContent.state === "DeviceList")
                appDrawer.open()
            else
                appContent.state = "DeviceList"
        }
        onDeviceRefreshButtonClicked: {
            if (currentDevice) {
                deviceManager.updateDevice(currentDevice.deviceAddress)
            }
        }
        onRightMenuClicked: {
            //
        }
    }

    Connections {
        target: Qt.application
        onStateChanged: {
            switch (Qt.application.state) {
            case Qt.ApplicationSuspended:
                //console.log("Qt.ApplicationSuspended")
                deviceManager.refreshDevices_stop();
                break
            case Qt.ApplicationHidden:
                //console.log("Qt.ApplicationHidden")
                deviceManager.refreshDevices_stop();
                break
            case Qt.ApplicationInactive:
                //console.log("Qt.ApplicationInactive")
                break
            case Qt.ApplicationActive:
                //console.log("Qt.ApplicationActive")
                Theme.loadTheme(settingsManager.appTheme)
                deviceManager.refreshDevices_check();
                break
            }
        }
    }

    onClosing: {
        close.accepted = false;
    }

    Timer {
        id: exitTimer
        interval: 3333
        repeat: false
        onRunningChanged: exitWarning.opacity = running
    }

    // QML /////////////////////////////////////////////////////////////////////

    property var currentDevice: null

    FocusScope {
        id: appContent
        anchors.top: appHeader.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        focus: true
        Keys.onBackPressed: {
            if (Qt.platform.os === "android" || Qt.platform.os === "ios") {
                if (appContent.state === "DeviceList") {
                    if (screenDeviceList.selectionList.length !== 0) {
                        screenDeviceList.exitSelectionMode()
                    } else {
                        if (exitTimer.running)
                            Qt.quit()
                        else
                            exitTimer.start()
                    }
                } else if (appContent.state === "Tutorial") {
                    // do nothing
                } else if (appContent.state === "DeviceSensor") {
                    if (screenDeviceSensor.isHistoryMode()) {
                        screenDeviceSensor.resetHistoryMode()
                    } else {
                        appContent.state = "DeviceList"
                    }
                } else if (appContent.state === "DeviceThermo") {
                    if (screenDeviceThermometer.isHistoryMode()) {
                        screenDeviceThermometer.resetHistoryMode()
                    } else {
                        appContent.state = "DeviceList"
                    }
                } else {
                    appContent.state = "DeviceList"
                }
            } else {
                appContent.state = "DeviceList"
            }
        }

        Tutorial {
            anchors.fill: parent
            id: screenTutorial
        }
        DeviceList {
            anchors.fill: parent
            id: screenDeviceList
        }
        DeviceScreen {
            anchors.fill: parent
            id: screenDeviceSensor
        }
        DeviceThermometer {
            anchors.fill: parent
            id: screenDeviceThermometer
        }
        Settings {
            anchors.fill: parent
            id: screenSettings
        }
        About {
            anchors.fill: parent
            id: screenAbout
        }

        // Initial state
        state: deviceManager.areDevicesAvailable() ? "DeviceList" : "Tutorial"

        onStateChanged: {
            screenDeviceList.exitSelectionMode()

            if (state === "DeviceList")
                appHeader.leftMenuMode = "drawer"
            else if (state === "Tutorial")
                appHeader.leftMenuMode = "close"
            else
                appHeader.leftMenuMode = "back"

            if (state === "Tutorial")
                appDrawer.interactive = false;
            else
                appDrawer.interactive = true;
        }

        states: [
            State {
                name: "Tutorial"

                PropertyChanges {
                    target: appHeader
                    title: qsTr("Welcome")
                }
                PropertyChanges {
                    target: screenTutorial
                    enabled: true
                    visible: true
                }
                PropertyChanges {
                    target: screenDeviceList
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceSensor
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenSettings
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "DeviceList"

                PropertyChanges {
                    target: appHeader
                    title: "WatchFlower"
                }
                PropertyChanges {
                    target: screenTutorial
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceList
                    enabled: true
                    visible: true
                }
                PropertyChanges {
                    target: screenDeviceSensor
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenSettings
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "DeviceSensor"

                PropertyChanges {
                    target: appHeader
                    title: currentDevice.deviceName
                }
                PropertyChanges {
                    target: screenTutorial
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceList
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceSensor
                    enabled: true
                    visible: true
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenSettings
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "DeviceThermo"

                PropertyChanges {
                    target: appHeader
                    title: qsTr("Thermometer")
                }
                PropertyChanges {
                    target: screenTutorial
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceList
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceSensor
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    enabled: true
                    visible: true
                }
                PropertyChanges {
                    target: screenSettings
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "Settings"

                PropertyChanges {
                    target: appHeader
                    title: qsTr("Settings")
                }
                PropertyChanges {
                    target: screenTutorial
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceList
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceSensor
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: true
                    enabled: true
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "About"

                PropertyChanges {
                    target: appHeader
                    title: qsTr("About")
                }
                PropertyChanges {
                    target: screenTutorial
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenDeviceList
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceSensor
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    enabled: false
                    visible: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: true
                    enabled: true
                }
            }
        ]
    }

    Rectangle {
        id: exitWarning
        width: exitWarningText.width + 16
        height: exitWarningText.height + 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
        anchors.horizontalCenter: parent.horizontalCenter

        radius: 4
        color: Theme.colorSubText

        opacity: 0
        Behavior on opacity { OpacityAnimator { duration: 333 } }

        Text {
            id: exitWarningText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Press one more time to exit...")
            font.pixelSize: 16
            color: Theme.colorForeground
        }
    }
}
