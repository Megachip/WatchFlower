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

import QtQuick 2.9

import ThemeEngine 1.0

Rectangle {
    id: rectangleHeader
    color: Theme.colorHeader
    width: 720
    height: 64
    z: 10

    signal backButtonClicked()

    signal deviceRefreshButtonClicked()
    signal deviceDataButtonClicked()
    signal deviceHistoryButtonClicked()
    signal deviceSettingsButtonClicked()

    signal refreshButtonClicked()
    signal rescanButtonClicked()
    signal plantsButtonClicked()
    signal settingsButtonClicked()
    signal aboutButtonClicked()
    signal exitButtonClicked()

    function setActiveDeviceData() {
        menuDeviceData.selected = true
        menuDeviceHistory.selected = false
        menuDeviceSettings.selected = false
    }
    function setActiveDeviceHistory() {
        menuDeviceData.selected = false
        menuDeviceHistory.selected = true
        menuDeviceSettings.selected = false
    }
    function setActiveDeviceSettings() {
        menuDeviceData.selected = false
        menuDeviceHistory.selected = false
        menuDeviceSettings.selected = true
    }

    function setActiveMenu() {
        if (appContent.state === "Tutorial") {
            title.text = qsTr("Welcome")
            menu.visible = false

            buttonBack.source = "qrc:/assets/menus/menu_close.svg"
        } else {
            title.text = "WatchFlower"
            menu.visible = true

            if (appContent.state === "DeviceList") {
                buttonBack.source = "qrc:/assets/menus/menu_logo_large.svg"
            } else {
                buttonBack.source = "qrc:/assets/menus/menu_back.svg"
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ImageSvg {
        id: buttonBack
        width: 24
        height: 24
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        visible: (source != "qrc:/assets/menus/menu_logo_large.svg" || rectangleHeader.width >= 560)
        source: "qrc:/assets/menus/menu_logo_large.svg"
        color: Theme.colorHeaderContent

        MouseArea {
            anchors.rightMargin: -8
            anchors.leftMargin: -8
            anchors.bottomMargin: -8
            anchors.topMargin: -8
            anchors.fill: parent

            onPressed: {
                buttonBack.anchors.topMargin += 2
                buttonBack.anchors.leftMargin += 2
                buttonBack.width -= 4
                buttonBack.height -= 4
            }
            onReleased: {
                buttonBack.anchors.topMargin -= 2
                buttonBack.anchors.leftMargin -= 2
                buttonBack.width += 4
                buttonBack.height += 4
            }
            onClicked: backButtonClicked()
        }
    }

    Text {
        id: title
        anchors.left: parent.left
        anchors.leftMargin: 56
        anchors.verticalCenter: parent.verticalCenter

        visible: (rectangleHeader.width >= 560)
        text: "WatchFlower"
        font.bold: true
        font.pixelSize: Theme.fontSizeHeader
        color: Theme.colorHeaderContent
    }

    Row {
        id: menu
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: buttonExit.visible ? 8 : 0

        spacing: 8
        visible: true

        ////////////

        ItemImageButton {
            id: buttonRefresh
            width: 36
            height: 36
            anchors.verticalCenter: parent.verticalCenter

            visible: (deviceManager.bluetooth && ((appContent.state === "DeviceSensor") || (appContent.state === "DeviceThermo")))
            source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
            iconColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight
            onClicked: deviceRefreshButtonClicked()

            NumberAnimation on rotation {
                id: refreshAnimation
                duration: 2000
                from: 0
                to: 360
                loops: Animation.Infinite
                running: currentDevice.updating
                alwaysRunToEnd: true
                easing.type: Easing.Linear
            }
        }
        Item { // spacer
            width: 12
            height: 12
            anchors.verticalCenter: parent.verticalCenter
            visible: (appContent.state === "DeviceThermo")
        }

        Row {
            id: menuDevice
            spacing: 0

            visible: (appContent.state === "DeviceSensor")

            ItemMenuButton {
                id: menuDeviceData
                width: 64
                height: 64
                colorBackground: Theme.colorHeaderHighlight
                colorHighlight: Theme.colorHeaderHighlight
                colorContent: Theme.colorHeaderContent
                source: "qrc:/assets/icons_material/baseline-insert_chart_outlined-24px.svg"
                onClicked: deviceDataButtonClicked()
            }
            ItemMenuButton {
                id: menuDeviceHistory
                width: 64
                height: 64
                colorBackground: Theme.colorHeaderHighlight
                colorHighlight: Theme.colorHeaderHighlight
                colorContent: Theme.colorHeaderContent
                source: "qrc:/assets/icons_material/baseline-date_range-24px.svg"
                onClicked: deviceHistoryButtonClicked()
            }
            ItemMenuButton {
                id: menuDeviceSettings
                width: 64
                height: 64
                colorBackground: Theme.colorHeaderHighlight
                colorHighlight: Theme.colorHeaderHighlight
                colorContent: Theme.colorHeaderContent
                source: "qrc:/assets/icons_material/baseline-iso-24px.svg"
                onClicked: deviceSettingsButtonClicked()
            }
        }

        ////////////

        ItemImageButton {
            id: buttonRefreshAll
            width: 36
            height: 36
            anchors.verticalCenter: parent.verticalCenter

            visible: (deviceManager.bluetooth && menuMain.visible)

            source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
            iconColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight
            onClicked: refreshButtonClicked()

            NumberAnimation on rotation {
                id: refreshAllAnimation
                duration: 2000
                from: 0
                to: 360
                loops: Animation.Infinite
                running: deviceManager.refreshing
                alwaysRunToEnd: true
                easing.type: Easing.Linear
            }
        }
        ItemImageButton {
            id: buttonRescan
            width: 36
            height: 36
            anchors.verticalCenter: parent.verticalCenter

            visible: (deviceManager.bluetooth && menuMain.visible)

            source: "qrc:/assets/icons_material/baseline-search-24px.svg"
            iconColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight
            onClicked: rescanButtonClicked()

            SequentialAnimation on opacity {
                id: rescanAnimation
                loops: Animation.Infinite
                running: deviceManager.scanning
                onStopped: buttonRescan.opacity = 1;

                PropertyAnimation { to: 0.33; duration: 750; }
                PropertyAnimation { to: 1; duration: 750; }
            }
        }

        Row {
            id: menuMain
            spacing: 0
            visible: (appContent.state === "DeviceList" ||
                      appContent.state === "Settings" ||
                      appContent.state === "About")

            ItemMenuButton {
                id: menuPlants
                width: 64
                height: 64
                selected: (appContent.state === "DeviceList")
                colorBackground: Theme.colorHeaderHighlight
                colorHighlight: Theme.colorHeaderHighlight
                colorContent: Theme.colorHeaderContent
                source: "qrc:/assets/logos/watchflower_tray_dark.svg"
                onClicked: plantsButtonClicked()
            }
            ItemMenuButton {
                id: menuSettings
                width: 64
                height: 64
                selected: (appContent.state === "Settings")
                colorBackground: Theme.colorHeaderHighlight
                colorHighlight: Theme.colorHeaderHighlight
                colorContent: Theme.colorHeaderContent
                source: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                onClicked: settingsButtonClicked()
            }
            ItemMenuButton {
                id: menuAbout
                width: 64
                height: 64
                selected: (appContent.state === "About")
                colorBackground: Theme.colorHeaderHighlight
                colorHighlight: Theme.colorHeaderHighlight
                colorContent: Theme.colorHeaderContent
                source: "qrc:/assets/menus/menu_infos.svg"
                onClicked: aboutButtonClicked()
            }
        }

        ////////////////
/*
        ItemImageButton {
            id: buttonExit
            width: 48
            height: 48
            anchors.verticalCenter: parent.verticalCenter

            visible: (rectangleHeader.width >= 720)
            iconColor: Theme.colorHeaderContent
            source: (settingsManager.systray) ? "qrc:/assets/icons_material/duotone-minimize-24px.svg" : "qrc:/assets/icons_material/duotone-exit_to_app-24px.svg"
            onClicked: (settingsManager.systray) ? applicationWindow.hide(): utilsApp.appExit()
        }
*/
    }
}
