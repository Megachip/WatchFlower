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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.7
import QtQuick.Controls 2.0

import com.watchflower.theme 1.0

Rectangle {
    id: rectangleSettings
    width: 480
    height: 640
    color: Theme.colorMaterialLightGrey
    anchors.fill: parent

    Rectangle {
        id: rectangleSettingsTitle
        height: 80
        color: Theme.colorMaterialDarkGrey
        border.width: 0

        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        Text {
            id: textTitle
            color: Theme.colorTitles
            text: qsTr("Settings")
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 12
            font.bold: true
            font.pixelSize: 26
        }

        Text {
            id: textSubtitle
            text: qsTr("Change persistent settings here!")
            font.pixelSize: 16
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 14
        }
    }

    Rectangle {
        id: rectangleSettingsContent
        height: 238
        color: "#00000000"

        anchors.top:rectangleSettingsTitle.bottom
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        SpinBox {
            id: spinBox_update
            width: 128
            height: 40
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: text_update.verticalCenter
            from: 30
            stepSize: 30
            to: 120
            value: settingsManager.interval

            onValueChanged: { settingsManager.interval = value }
        }

        Text {
            id: text_update
            height: 40
            anchors.left: parent.left
            anchors.leftMargin: 12

            verticalAlignment: Text.AlignVCenter
            text: qsTr("Update interval in minutes")
            anchors.top: text_bluetooth.bottom
            anchors.topMargin: 8
            font.pixelSize: 16
        }

        Text {
            id: text_unit
            height: 40
            anchors.top: text_update.bottom
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 12

            text: qsTr("Temperature unit")
            font.pixelSize: 16
            verticalAlignment: Text.AlignVCenter
        }

        ThemedRadioButton {
            id: radioDelegateCelsius
            height: 40
            text: qsTr("°C")
            anchors.right: radioDelegateFahrenheit.left
            anchors.rightMargin: 0
            anchors.verticalCenter: text_unit.verticalCenter
            font.pixelSize: 16

            checked: {
                if (settingsManager.tempunit === 'C') {
                    radioDelegateCelsius.checked = true
                    radioDelegateFahrenheit.checked = false
                } else {
                    radioDelegateCelsius.checked = false
                    radioDelegateFahrenheit.checked = true
                }
            }

            onCheckedChanged: {
                if (checked == true)
                    settingsManager.tempunit = 'C'
            }
        }

        ThemedRadioButton {
            id: radioDelegateFahrenheit
            height: 40
            text: qsTr("°F")
            anchors.verticalCenterOffset: 0
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: text_unit.verticalCenter
            font.pixelSize: 16

            checked: {
                if (settingsManager.tempunit === 'F') {
                    radioDelegateCelsius.checked = false
                    radioDelegateFahrenheit.checked = true
                } else {
                    radioDelegateFahrenheit.checked = false
                    radioDelegateCelsius.checked = true
                }
            }

            onCheckedChanged: {
                if (checked === true)
                    settingsManager.tempunit = 'F'
            }
        }

        Text {
            id: text_graph
            height: 40
            text: qsTr("Preferred graph")
            font.pixelSize: 16
            verticalAlignment: Text.AlignVCenter
            anchors.top: text_unit.bottom
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 12
        }

        ComboBox {
            id: comboBox_view
            model: ListModel {
                id: cbItemsView
                ListElement { text: qsTr("daily"); }
                ListElement { text: qsTr("hourly"); }
            }
            Component.onCompleted: {
                currentIndex = find(settingsManager.graphview)
                if (currentIndex === -1) { currentIndex = 0 }
            }
            property bool cbinit: false
            width: 100
            anchors.right: comboBox_data.left
            anchors.rightMargin: 12
            anchors.verticalCenter: text_graph.verticalCenter
            onCurrentIndexChanged: {
                if (cbinit)
                    settingsManager.graphview = cbItemsView.get(currentIndex).text
                else
                    cbinit = true
            }
        }

        ComboBox {
            id: comboBox_data
            anchors.top: comboBox_view.top
            anchors.topMargin: 0
            model: ListModel {
                id: cbItemsData
                ListElement { text: qsTr("hygro"); }
                ListElement { text: qsTr("temp"); }
                ListElement { text: qsTr("luminosity"); }
                ListElement { text: qsTr("conductivity"); }
            }
            Component.onCompleted: {
                currentIndex = find(settingsManager.graphdata)
                if (currentIndex === -1) { currentIndex = 0 }
            }
            property bool cbinit: false
            width: 100
            anchors.verticalCenter: text_graph.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 12
            onCurrentIndexChanged: {
                if (cbinit)
                    settingsManager.graphdata = cbItemsData.get(currentIndex).text
                else
                    cbinit = true
            }
        }

        ThemedSwitch {
            id: switch_notifiations
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: text_notifications.verticalCenter

            checked: settingsManager.notifications
            onCheckedChanged: { settingsManager.notifications = checked }
        }

        Text {
            id: text_bluetooth
            height: 40
            text: qsTr("Launch bluetooth with the app")
            verticalAlignment: Text.AlignVCenter
            anchors.top: text_notifications.bottom
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.leftMargin: 12
            font.pixelSize: 16
        }

        Text {
            id: text_notifications
            height: 40
            text: qsTr("Enable notifications")
            anchors.left: parent.left
            anchors.leftMargin: 12
            verticalAlignment: Text.AlignVCenter
            anchors.top: parent.top
            anchors.topMargin: 8
            font.pixelSize: 16
        }

        ThemedSwitch {
            id: switch_bluetooth
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: text_bluetooth.verticalCenter

            checked: settingsManager.bluetooth
            onCheckedChanged: { settingsManager.bluetooth = checked }
        }
    }

    Rectangle {
        id: rectangleReset
        height: 44
        width: 300
        color: Theme.colorRed
        radius: 22
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: rectangleSettingsContent.bottom
        anchors.topMargin: 24

        property bool weAreBlinking: false

        function startTheBlink() {
            if (weAreBlinking === true) {
                settingsManager.resetSettings()
                stopTheBlink()
            } else {
                weAreBlinking = true
                timerReset.start()
                blinkReset.start()
                textReset.text = qsTr("!!! Click again to confirm !!!")
            }
        }
        function stopTheBlink() {
            weAreBlinking = false
            timerReset.stop()
            blinkReset.stop()
            textReset.text = qsTr("Reset sensors & datas!")
            rectangleReset.color = Theme.colorRed
        }

        SequentialAnimation on color {
            id: blinkReset
            running: false
            loops: Animation.Infinite
            ColorAnimation { from: Theme.colorRed; to: Theme.colorOrange; duration: 1000 }
            ColorAnimation { from: Theme.colorOrange; to: Theme.colorRed; duration: 1000 }
        }

        Timer {
            id: timerReset
            interval: 4000
            running: false
            repeat: false
            onTriggered: {
                rectangleReset.stopTheBlink()
            }
        }

        Text {
            id: textReset
            anchors.fill: parent
            color: "#ffffff"
            text: qsTr("Reset sensors & datas!")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.bold: false
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 18
        }
        MouseArea {
            anchors.fill: parent

            onClicked: {
                rectangleReset.startTheBlink()
            }
        }
    }
}