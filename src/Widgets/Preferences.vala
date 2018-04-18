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
    public class Preferences : Gtk.Dialog {
        private Gtk.Stack main_stack;

        Settings settings;


        public Preferences (Gtk.Window? parent) {
            Object (
                border_width: 5,
                deletable: false,
                resizable: false,
                title: _("Preferences"),
                transient_for: parent
            );

        }

        construct {

            settings = Settings.get_default ();
            var hosts_filechooser = new Gtk.FileChooserButton (_("Select Hosts Configuration Folder…"), Gtk.FileChooserAction.SELECT_FOLDER);
            hosts_filechooser.hexpand = true;
            hosts_filechooser.set_current_folder (settings.hosts_folder);
            hosts_filechooser.file_set.connect (() => {
                settings.hosts_folder = hosts_filechooser.get_uri().split(":")[1];
            });
            var color = Gdk.RGBA();
            color.parse(settings.terminal_background_color);
            var terminal_background_color_button = new Gtk.ColorButton.with_rgba (color);

            terminal_background_color_button.color_set.connect (() => {
                settings.terminal_background_color = terminal_background_color_button.rgba.to_string();
            });

            var terminal_font_button = new Gtk.FontButton.with_font(settings.terminal_font);
            terminal_font_button.font_set.connect(() => {
                settings.terminal_font = terminal_font_button.get_font();
            });

            var general_grid = new Gtk.Grid ();
            general_grid.column_spacing = 12;
            general_grid.row_spacing = 6;
            general_grid.attach (new Granite.HeaderLabel (_("Hosts Configuration Folder:")), 0, 0, 1, 1);
            general_grid.attach (hosts_filechooser, 1, 0, 1, 1);

            general_grid.attach (new Granite.HeaderLabel (_("Terminal Background Color:")), 0, 1, 1, 1);
            general_grid.attach (terminal_background_color_button, 1, 1, 1, 1);

            general_grid.attach (new Granite.HeaderLabel (_("Terminal Font:")), 0, 2, 1, 1);
            general_grid.attach (terminal_font_button, 1, 2, 1, 1);


            main_stack = new Gtk.Stack ();
            main_stack.margin = 6;
            main_stack.margin_bottom = 18;
            main_stack.margin_top = 24;
            main_stack.add_titled (general_grid, "general", _("General"));

            var main_stackswitcher = new Gtk.StackSwitcher ();
            main_stackswitcher.set_stack (main_stack);
            main_stackswitcher.halign = Gtk.Align.CENTER;

            var main_grid = new Gtk.Grid ();
            main_grid.attach (main_stackswitcher, 0, 0, 1, 1);
            main_grid.attach (main_stack, 0, 1, 1, 1);

            get_content_area ().add (main_grid);

            var close_button = new Gtk.Button.with_label (_("Close"));
            close_button.clicked.connect (() => {
                destroy ();
            });

            add_action_widget (close_button, 0);
        }

    }
}