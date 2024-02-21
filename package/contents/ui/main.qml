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
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: plasmoidItem
    property bool showHidden: plasmoid.configuration.showHidden
    property bool showDevices: plasmoid.configuration.showDevices
    property bool showTimeline: plasmoid.configuration.showTimeline
    property bool showSearches: plasmoid.configuration.showSearches
    property int widgetWidth: plasmoid.configuration.widgetWidth

    compactRepresentation: Kirigami.Icon {
        source: 'folder-favorites'
        width: Kirigami.Units.iconSizes.medium
        height: Kirigami.Units.iconSizes.medium
        active: mouseArea.containsMouse

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: plasmoidItem.expanded = !plasmoidItem.expanded
            hoverEnabled: true
        }
    }

    fullRepresentation: FullRepresentation {}

    preferredRepresentation: compactRepresentation
}
