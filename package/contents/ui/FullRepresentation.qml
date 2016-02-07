/*
 * Copyright 2016  Daniel Faust <hessijames@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.5
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    Layout.minimumWidth: widgetWidth
    Layout.minimumHeight: (units.iconSizes.medium + 15) * listView.count - 5

    Layout.maximumWidth: Layout.minimumWidth
    Layout.maximumHeight: Layout.minimumHeight

    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight

    PlasmaCore.DataSource {
        id: placesSource
        engine: 'places'
        connectedSources: 'places'
    }

    PlasmaCore.SortFilterModel {
        id: placesHiddenFilterModel
        sourceModel: placesSource.models.places
        filterRole: 'hidden'
        filterRegExp: 'false'
    }

    PlasmaCore.SortFilterModel {
        id: placesDeviceFilterModel
        sourceModel: placesSource.models.places
        filterRole: 'isDevice'
        filterRegExp: 'false'
    }

    PlasmaCore.SortFilterModel {
        id: placesHiddenDevicesFilterModel
        sourceModel: placesHiddenFilterModel
        filterRole: 'isDevice'
        filterRegExp: 'false'
    }

    property var currentModel: {
        if (!showHidden && !showDevices) {
            return placesHiddenDevicesFilterModel
        } else if (!showHidden) {
            return placesHiddenFilterModel
        } else if (!showDevices) {
            return placesDeviceFilterModel
        } else {
            return placesSource.models.places
        }
    }

    PlasmaExtras.ScrollArea {
        anchors.fill: parent
        
        ListView {
            id: listView
            anchors.fill: parent
            spacing: 5

            model: currentModel

            highlight: PlasmaComponents.Highlight {}
            highlightMoveDuration: 0
            highlightResizeDuration: 0

            delegate: Item {
                id: placeItem
                width: parent.width
                height: units.iconSizes.medium + 10

                property bool isHovered: false
                property bool isEjectHovered: false

                MouseArea {
                    id: container
                    anchors.fill: parent

                    hoverEnabled: true
                    onEntered: {
                        listView.currentIndex = index
                        isHovered = true
                    }
                    onExited: {
                        isHovered = false
                    }

                    onClicked: {
                        if (model['url'] == '') {
                            var service = placesSource.serviceForSource('places')
                            var operation = service.operationDescription('Setup Device')
                            operation.placeIndex = model['placeIndex']
                            var serviceJob = service.startOperationCall(operation)
                            serviceJob.finished.connect(function (job) {
                                if (!job.error) {
                                    Qt.openUrlExternally(model['url'])
                                }
                            })
                        } else {
                            Qt.openUrlExternally(model['url'])
                        }
                    }

                    RowLayout {
                        x: 5
                        y: 5

                        PlasmaCore.IconItem {
                            source: model['decoration']
                            height: units.iconSizes.medium
                            width: height
                            active: isHovered
                        }

                        ColumnLayout {
                            spacing: 0

                            PlasmaComponents.Label {
                                text: model['display']
                            }
                            PlasmaComponents.Label {
                                text: model['url'].toString().replace('file://', '')
                                font.pointSize: theme.smallestFont.pointSize
                                opacity: isHovered ? 1.0 : 0.6

                                Behavior on opacity { NumberAnimation { duration: units.shortDuration * 3 } }
                            }
                        }
                    }

                    PlasmaCore.IconItem {
                        source: 'media-eject'
                        height: units.iconSizes.medium * 0.8
                        width: height
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 5
                        active: isEjectHovered
                        visible: (model['isDevice'] === true && model['url'] != '' && isHovered)

                        MouseArea {
                            anchors.fill: parent

                            hoverEnabled: true
                            onEntered: {
                                isEjectHovered = true
                            }
                            onExited: {
                                isEjectHovered = false
                            }

                            onClicked: {
                                var service = placesSource.serviceForSource('places')
                                var operation = service.operationDescription('Teardown Device')
                                operation.placeIndex = model['placeIndex']
                                service.startOperationCall(operation)
                            }
                        }
                    }
                }
            }
        }
    }
}
