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
import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    property alias cfg_showHidden: showHidden.checked
    property alias cfg_showDevices: showDevices.checked
    property alias cfg_showTimeline: showTimeline.checked
    property alias cfg_showSearches: showSearches.checked
    property alias cfg_widgetWidth: widgetWidth.value

    property var mediumSpacing: 1.5*units.smallSpacing

    GridLayout {
        columns: 2

        CheckBox {
            id: showHidden
            text: i18n('Show hidden places')
            Layout.columnSpan: 2
        }

        CheckBox {
            id: showDevices
            text: i18n('Show devices')
            Layout.columnSpan: 2
        }

        CheckBox {
            id: showTimeline
            text: i18n('Show recently used')
            Layout.columnSpan: 2
        }

        CheckBox {
            id: showSearches
            text: i18n('Show searches')
            Layout.columnSpan: 2
        }

        Label {
            text: i18n('Widget width:')
        }

        SpinBox {
            id: widgetWidth
            minimumValue: units.iconSizes.medium + 2*mediumSpacing
            maximumValue: 1000
            decimals: 0
            stepSize: 10
            suffix: ' px'
        }
    }
}
