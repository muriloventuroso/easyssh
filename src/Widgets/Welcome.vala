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
    public class Welcome : Gtk.Grid {
        construct {
            var welcome = new Granite.Widgets.Welcome ("EasySSH", _("SSH Connection Manager"));
            welcome.append ("document-new", _("Add Connection"), _("Start by adding an SSH connection to EasySSH"));

            add (welcome);

            var button = welcome.get_button_from_index(0);
            button.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NEW_CONN;

        }
    }
}