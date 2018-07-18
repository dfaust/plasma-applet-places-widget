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
    property real mediumSpacing: 1.5*units.smallSpacing
    property real textHeight: theme.defaultFont.pixelSize + theme.smallestFont.pixelSize + units.smallSpacing
    property real itemHeight: Math.max(units.iconSizes.medium, textHeight)

    Layout.minimumWidth: widgetWidth
    Layout.minimumHeight: (itemHeight + 2*mediumSpacing) * listView.count

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
        id: placesNoHidden
        sourceModel: placesSource.models.places
        filterRole: 'hidden'
        filterRegExp: 'false'
    }
    
    property var placesMaybeHidden : {
        if (showHidden) {
            return placesSource.models.places
        } else {
            return placesNoHidden
        }
    }

    PlasmaCore.SortFilterModel {
        id: placesNoTimeline
        sourceModel: placesMaybeHidden
        filterRole: 'url'
        filterRegExp: '^(?!timeline:).*$'
    }
    
    property var placesMaybeTimeline : {
        if (showTimeline) {
            return placesMaybeHidden
        } else {
            return placesNoTimeline
        }
    }
    
    PlasmaCore.SortFilterModel {
        id: placesNoSearch
        sourceModel: placesMaybeTimeline
        filterRole: 'url'
        filterRegExp: '^(?!search:).*$'
    }
    
    property var placesMaybeSearch : {
        if (showSearch) {
            return placesMaybeTimeline
        } else {
            return placesNoSearch
        }
    }
    
    
    PlasmaCore.SortFilterModel {
        id: placesNoDevice
        sourceModel: placesMaybeSearch
        filterRole: 'isDevice'
        filterRegExp: 'false'
    }
    
    PlasmaCore.SortFilterModel {
        id: placesNoFstabDevice
        sourceModel: placesMaybeSearch
        
        filters: [
            AnyOf {
                ValueFilter {
                    roleName: 'isDevice'
                    value: false
                }
                ValueFilter {
                    roleName: 'setupNeeded'
                    value: true
                }
                ValueFilter {
                    roleName: 'fixedDevice'
                    value: false
                }
                ValueFilter {
                    roleName: 'fixedDevice'
                    value: null
                }
                RegExpFilter {
                    roleName: 'path'
                    pattern: '^/media/.*$'
                }
            }
        ]
    }
    
    property var placesMaybeDevice  : {
        if (showDevice == 1) {
            return placesNoDevice
        } else {
            if (showDevice == 2) {
                return placesNoFstabDevice
            } else {
                return placesMaybeSearch
            }
        }
    }

    
    property var currentModel: {
        return placesMaybeDevice
    }

    PlasmaExtras.ScrollArea {
        anchors.fill: parent
        
        ListView {
            id: listView
            anchors.fill: parent

            model: currentModel

            highlight: PlasmaComponents.Highlight {}
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
                            height: units.iconSizes.medium
                            width: height
                            anchors.verticalCenter: parent.verticalCenter

                            PlasmaCore.IconItem {
                                anchors.fill: parent
                                source: model['decoration']
                                active: isHovered
                            }
                        }

                        Column {
                            width: ejectIcon.visible ? parent.width - units.iconSizes.medium * 1.8 - mediumSpacing : parent.width - units.iconSizes.medium - mediumSpacing
                            height: textHeight
                            spacing: 0
                            anchors.verticalCenter: parent.verticalCenter

                            PlasmaComponents.Label {
                                text: model['display']
                                width: parent.width
                                height: theme.defaultFont.pixelSize
                                elide: Text.ElideRight
                            }
                            Item {
                                width: 1
                                height: units.smallSpacing
                            }
                            PlasmaComponents.Label {
                                text: model['url'].toString().replace('file://', '')
                                font.pointSize: theme.smallestFont.pointSize
                                opacity: isHovered ? 1.0 : 0.6
                                width: parent.width
                                height: theme.smallestFont.pixelSize
                                elide: Text.ElideRight

                                Behavior on opacity { NumberAnimation { duration: units.shortDuration * 3 } }
                            }
                        }
                    }

                    PlasmaCore.IconItem {
                        id: ejectIcon
                        source: 'media-eject'
                        height: units.iconSizes.medium * 0.8
                        width: height
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: mediumSpacing
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
