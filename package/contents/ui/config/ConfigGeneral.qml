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
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_showHidden: showHidden.checked
    property alias cfg_showDevices: showDevices.checked
    property alias cfg_showTimeline: showTimeline.checked
    property alias cfg_showSearches: showSearches.checked
    property alias cfg_widgetWidth: widgetWidth.value

    property var mediumSpacing: 1.5 * Kirigami.Units.smallSpacing

    CheckBox {
        id: showHidden
        Kirigami.FormData.label: i18n('Places:')
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

    SpinBox {
        id: widgetWidth
        Kirigami.FormData.label: i18n('Widget width:')
        from: Kirigami.Units.iconSizes.medium + 2 * mediumSpacing
        to: 1000
        stepSize: 10
        textFromValue: function(value) { return value + ' px'; }
        valueFromText: function(text) { return Number(text.remove(RegExp(' px$'))); }
    }
}
