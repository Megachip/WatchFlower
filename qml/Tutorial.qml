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
import QtGraphicalEffects 1.0
import com.watchflower.theme 1.0

Rectangle {
    width: 480
    height: 640
    anchors.fill: parent

    color: Theme.colorHeader

    property string goBackTo: "DeviceList"

    function reopen(goBackScreen) {
        tutorialPages.currentIndex = 0
        appContent.state = "Tutorial"
        goBackTo = goBackScreen
    }

    SwipeView {
        id: tutorialPages
        anchors.fill: parent
        anchors.bottomMargin: 48

        currentIndex: 0
        onCurrentIndexChanged: {
            if (currentIndex < 0) currentIndex = 0
            if (currentIndex > 2) {
                currentIndex = 0 // reset
                appContent.state = goBackTo
            }
        }

        ////////

        Item {
            id: page1

            Column {
                id: column
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 32

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("<b>WatchFlower</b> is a plant monitoring application for Xiaomi / MiJia '<b>Flower Care</b>' and '<b>Ropot</b>' Bluetooth devices.")
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: 18
                    color: Theme.colorHeaderContent
                    horizontalAlignment: Text.AlignHCenter
                }
                Image {
                    width: tutorialPages.width * 0.8
                    anchors.horizontalCenter: parent.horizontalCenter

                    source: "qrc:/assets/devices/welcome-devices.svg"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("It also works great with a couple of <b>thermometers</b>!")
                    color: Theme.colorHeaderContent
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
            }
        }

        Item {
            id: page2

            Column {
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 32

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("To start using WatchFlower, you'll need to <b>scan for compatible devices</b> near you.")
                    color: Theme.colorHeaderContent
                    font.pixelSize: 18
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                }
                Image {
                    //width: tutorialPages.width * 0.8
                    height: tutorialPages.height / 2.5
                    anchors.horizontalCenter: parent.horizontalCenter

                    source: "qrc:/assets/devices/welcome-bluetooth-searching.svg"
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("Once the scanning process is done, the devices found will appear in the <b>main screen</b>. From there, you can <b>rescan</b> for new devices at any time, or <b>delete</b> the ones you don't want anymore.")
                    font.pixelSize: 18
                    color: Theme.colorHeaderContent
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Item {
            id: page3

            Column {
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 32

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("Once devices are <b>paired</b>, the application will periodically <b>sync</b> their datas.<br>Click on devices to access <b>detailed infos</b>, <b>graphs</b> and <b>historical datas</b>.")
                    color: Theme.colorHeaderContent
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                }
                Image {
                    width: tutorialPages.width * 0.8
                    anchors.horizontalCenter: parent.horizontalCenter

                    source: "qrc:/assets/devices/welcome-app-connected.svg"
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("You can also configure devices <b>location</b>, <b>name associated plants</b>, and set settings like <b>optimal water level</b> and other <b>limits</b> that apply to each sensors datas.")
                    color: Theme.colorHeaderContent
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                }
            }
        }
    }

    ////////

    Text {
        id: pagePrevious
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.verticalCenter: pageIndicator.verticalCenter

        visible: (tutorialPages.currentIndex != 0)

        text: qsTr("Previous")
        color: Theme.colorHeaderContent
        font.bold: true
        font.pixelSize: 16

        Behavior on opacity { OpacityAnimator { duration: 100 } }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.opacity = 0.8
            onExited: parent.opacity = 1
            onClicked: tutorialPages.currentIndex--
        }
    }

    Text {
        id: pageNext
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.verticalCenter: pageIndicator.verticalCenter

        text: (tutorialPages.currentIndex === 2) ? qsTr("Allright!") : qsTr("Next")
        color: Theme.colorHeaderContent
        font.bold: true
        font.pixelSize: 16

        Behavior on opacity { OpacityAnimator { duration: 100 } }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.opacity = 0.8
            onExited: parent.opacity = 1
            onClicked: tutorialPages.currentIndex++
        }
    }

    PageIndicator {
        id: pageIndicator
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16

        count: 3
        currentIndex: tutorialPages.currentIndex

        delegate: Rectangle {
            implicitWidth: 12
            implicitHeight: 12

            radius: width / 2
            color: Theme.colorHeaderContent

            opacity: index === pageIndicator.currentIndex ? 0.95 : pressed ? 0.7 : 0.45

            Behavior on opacity { OpacityAnimator { duration: 100 } }
        }
    }
}
