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
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    property real mediumSpacing: 1.5 * Kirigami.Units.smallSpacing
    property real textHeight: Kirigami.Theme.defaultFont.pixelSize + Kirigami.Theme.smallFont.pixelSize + Kirigami.Units.smallSpacing
    property real itemHeight: Math.max(Kirigami.Units.iconSizes.medium, textHeight)

    Layout.minimumWidth: widgetWidth
    Layout.minimumHeight: (itemHeight + 2*mediumSpacing) * listView.count

    Layout.maximumWidth: Layout.minimumWidth
    Layout.maximumHeight: Layout.minimumHeight

    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight

    Plasma5Support.DataSource {
        id: placesSource
        engine: 'places'
        connectedSources: ['places']
    }

    KItemModels.KSortFilterProxyModel {
        id: placesHiddenFilterModel
        sourceModel: placesSource.models.places
        filterRoleName: 'hidden'
        filterRegularExpression: showHidden ? RegExp('') : RegExp('false')
    }

    KItemModels.KSortFilterProxyModel {
        id: placesDeviceFilterModel
        sourceModel: placesHiddenFilterModel
        filterRoleName: 'isDevice'
        filterRegularExpression: showDevices ? RegExp('') : RegExp('false')
    }

    KItemModels.KSortFilterProxyModel {
        id: placesDeviceUrlFilterModel
        sourceModel: placesDeviceFilterModel
        filterRoleName: 'url'
        filterRegularExpression: showDevices ? RegExp('') : RegExp('^(?!(mtp|kdeconnect)).*')
    }

    KItemModels.KSortFilterProxyModel {
        id: placesTimelineFilterModel
        sourceModel: placesDeviceUrlFilterModel
        filterRoleName: 'url'
        filterRegularExpression: showTimeline ? RegExp('') : RegExp('^(?!(timeline|recentlyused)).*')
    }

    KItemModels.KSortFilterProxyModel {
        id: placesSearchesFilterModel
        sourceModel: placesTimelineFilterModel
        filterRoleName: 'url'
        filterRegularExpression: showSearches ? RegExp('') : RegExp('^(?!search).*')
    }

    KItemModels.KSortFilterProxyModel {
        id: placesBlankFilterModel
        sourceModel: placesSearchesFilterModel
        filterRoleName: 'display'
        filterRegularExpression: RegExp('.+')
    }

    PlasmaComponents.ScrollView {
        anchors.fill: parent

        ListView {
            id: listView
            anchors.fill: parent

            model: placesBlankFilterModel

            highlight: PlasmaExtras.Highlight {}
            highlightMoveDuration: 0
            highlightResizeDuration: 0

            delegate: Item {
                width: parent.width
                height: itemHeight + 2*mediumSpacing

                property bool isHovered: false
                property bool isEjectHovered: false

                MouseArea {
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
                                    plasmoid.expanded = false
                                    Qt.openUrlExternally(model['url'])
                                }
                            })
                        } else {
                            plasmoid.expanded = false
                            Qt.openUrlExternally(model['url'])
                        }
                    }

                    Row {
                        x: mediumSpacing
                        y: mediumSpacing
                        width: parent.width - 2*mediumSpacing
                        height: itemHeight
                        spacing: mediumSpacing

                        Item { // Hack - since setting the dimensions of PlasmaCore.IconItem won't work
                            height: Kirigami.Units.iconSizes.medium
                            width: height
                            anchors.verticalCenter: parent.verticalCenter

                            Kirigami.Icon {
                                anchors.fill: parent
                                source: model['decoration']
                                active: isHovered
                            }
                        }

                        Column {
                            width: ejectIcon.visible ? parent.width - Kirigami.Units.iconSizes.medium * 1.8 - mediumSpacing : parent.width - Kirigami.Units.iconSizes.medium - mediumSpacing
                            height: textHeight
                            spacing: 0
                            anchors.verticalCenter: parent.verticalCenter

                            PlasmaComponents.Label {
                                text: model['display']
                                width: parent.width
                                height: Kirigami.Theme.defaultFont.pixelSize
                                elide: Text.ElideRight
                            }
                            Item {
                                width: 1
                                height: Kirigami.Units.smallSpacing
                            }
                            PlasmaComponents.Label {
                                text: model['url'].toString().replace('file://', '')
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                                opacity: isHovered ? 1.0 : 0.6
                                width: parent.width
                                height: Kirigami.Theme.smallFont.pixelSize
                                elide: Text.ElideRight

                                Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration * 3 } }
                            }
                        }
                    }

                    Kirigami.Icon {
                        id: ejectIcon
                        source: 'media-eject'
                        height: Kirigami.Units.iconSizes.medium * 0.8
                        width: height
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: mediumSpacing
                        active: isEjectHovered
                        visible: (model['isDevice'] === true && model['fixedDevice'] === false && model['url'] != '' && isHovered)

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
