/*
* Copyright (c) 2018 Murilo Venturoso
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Murilo Venturoso <muriloventuroso@gmail.com>
*/

namespace EasySSH {
    public class HeaderBar : Gtk.HeaderBar {


        public HeaderBar () {
                Object (
                    has_subtitle: false,
                    show_close_button: true
                );
            }
        construct {

            Gtk.ToolButton new_conn = new Gtk.ToolButton (new Gtk.Image.from_icon_name ("document-new", Gtk.IconSize.MENU), null);

            new_conn.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NEW_CONN;
            new_conn.tooltip_text = _("Create a new connection");

            Gtk.ToolButton settings_button = new Gtk.ToolButton (new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.MENU), null);

            settings_button.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_PREFERENCES;
            settings_button.tooltip_text = _("Preferences");

            pack_start(new_conn);
            pack_end(settings_button);

        }

    }
}