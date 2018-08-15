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
            get_style_context ().add_class ("default-decoration");
            Gtk.ToolButton new_conn = new Gtk.ToolButton (new Gtk.Image.from_icon_name ("document-new-symbolic", Gtk.IconSize.SMALL_TOOLBAR), null);

            new_conn.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NEW_CONN;
            new_conn.tooltip_text = _("Create a new connection");

            var preferences_menuitem = new Gtk.MenuItem.with_label (_("Preferences"));
            preferences_menuitem.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_PREFERENCES;
            var menu = new Gtk.Menu ();
            menu.append (preferences_menuitem);
            menu.show_all ();

            Gtk.MenuButton settings_button = new Gtk.MenuButton ();
            settings_button.image = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            settings_button.popup = menu;
            settings_button.tooltip_text = _("Menu");
            settings_button.valign = Gtk.Align.CENTER;

            pack_start(new_conn);
            pack_end(settings_button);

        }

    }
}