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
    public class Tab : Granite.Widgets.Tab {
        public Tab (string? label = null, GLib.Icon? icon = null, Gtk.Widget? page = null) {
            base (label, icon, page);
        }

        construct {
            var rename_m = new Gtk.MenuItem.with_label (_("Rename"));
            menu.append (rename_m);
            menu.show_all ();

            rename_m.activate.connect (() => rename_tab () );
        }

        private void rename_tab() {
            var description = _("Set new tab name");
            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Rename Tab"), description, "edit", Gtk.ButtonsType.NONE);
            var name_entry = new Gtk.Entry ();
            name_entry.show ();
            name_entry.set_activates_default(true);
            message_dialog.custom_bin.add(name_entry);
            var no_button = new Gtk.Button.with_label (_("Cancel"));
            message_dialog.add_action_widget (no_button, Gtk.ResponseType.CANCEL);

            var yes_button = new Gtk.Button.with_label (_("Send"));
            yes_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            yes_button.can_default = true;
            message_dialog.add_action_widget (yes_button, Gtk.ResponseType.OK);
            message_dialog.set_default_response(Gtk.ResponseType.OK);
            message_dialog.set_type_hint(Gdk.WindowTypeHint.DIALOG);
            message_dialog.show_all ();
            if (message_dialog.run () == Gtk.ResponseType.OK) {
                label = name_entry.text;
            }
            message_dialog.destroy ();
        }

    }
}