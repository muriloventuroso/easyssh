/*
* Copyright (c) 2019 Murilo Venturoso
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
            hosts_filechooser.set_current_folder (settings.hosts_folder.replace ("%20", " "));
            hosts_filechooser.file_set.connect (() => {
                settings.hosts_folder = hosts_filechooser.get_uri().split(":")[1].replace ("%20", " ");
            });
            var color = Gdk.RGBA();
            color.parse(settings.terminal_background_color);
            var terminal_background_color_button = new Gtk.ColorButton.with_rgba (color);

            terminal_background_color_button.color_set.connect (() => {
                settings.terminal_background_color = terminal_background_color_button.rgba.to_string();
            });

            var terminal_font_button = new Gtk.FontButton.with_font(settings.terminal_font);
            terminal_font_button.use_font = true;
            terminal_font_button.use_size = true;
            terminal_font_button.font_set.connect(() => {
                settings.terminal_font = terminal_font_button.get_font();
            });

            var restore_hosts_switch = new Gtk.Switch();
            restore_hosts_switch.halign = Gtk.Align.START;
            restore_hosts_switch.valign = Gtk.Align.CENTER;
            restore_hosts_switch.set_active(settings.restore_hosts);
            restore_hosts_switch.notify["active"].connect (() => {
                settings.restore_hosts = restore_hosts_switch.active;
            });

            var sync_ssh_switch = new Gtk.Switch();
            sync_ssh_switch.halign = Gtk.Align.START;
            sync_ssh_switch.valign = Gtk.Align.CENTER;
            sync_ssh_switch.set_active(settings.sync_ssh_config);
            sync_ssh_switch.notify["active"].connect (() => {
                settings.sync_ssh_config = sync_ssh_switch.active;
            });
            #if WITH_GPG
            var encrypt_data_switch = new Gtk.Switch();
            encrypt_data_switch.halign = Gtk.Align.START;
            encrypt_data_switch.valign = Gtk.Align.CENTER;
            encrypt_data_switch.set_active(settings.encrypt_data);
            encrypt_data_switch.notify["active"].connect (() => {
                settings.encrypt_data = encrypt_data_switch.active;
            });
            #endif

            var use_dark_theme = new Gtk.Switch ();
            use_dark_theme.halign = Gtk.Align.START;
            use_dark_theme.valign = Gtk.Align.CENTER;
            use_dark_theme.active = settings.use_dark_theme;
            use_dark_theme.notify["active"].connect (() => { settings.use_dark_theme = use_dark_theme.active; });

            var general_grid = new Gtk.Grid ();
            general_grid.column_spacing = 12;
            general_grid.row_spacing = 6;
            general_grid.attach (new Granite.HeaderLabel (_("Hosts Configuration Folder:")), 0, 0, 1, 1);
            general_grid.attach (hosts_filechooser, 1, 0, 1, 1);

            general_grid.attach (new Granite.HeaderLabel (_("Restore Opened Hosts:")), 0, 1, 1, 1);
            general_grid.attach (restore_hosts_switch, 1, 1, 1, 1);

            general_grid.attach (new Granite.HeaderLabel (_("Sync SSH Config:")), 0, 2, 1, 1);
            general_grid.attach (sync_ssh_switch, 1, 2, 1, 1);

            #if WITH_GPG
            general_grid.attach (new Granite.HeaderLabel (_("Encrypt data:")), 0, 4, 1, 1);
            general_grid.attach (encrypt_data_switch, 1, 4, 1, 1);
            #endif
            var appearance_grid = new Gtk.Grid ();

            appearance_grid.attach (new Granite.HeaderLabel (_("Terminal Background Color:")), 0, 0, 1, 1);
            appearance_grid.attach (terminal_background_color_button, 1, 0, 1, 1);

            appearance_grid.attach (new Granite.HeaderLabel (_("Terminal Font:")), 0, 1, 1, 1);
            appearance_grid.attach (terminal_font_button, 1, 1, 1, 1);

            appearance_grid.attach (new Granite.HeaderLabel (_("Use Dark Theme:")), 0, 2, 1, 1);
            appearance_grid.attach (use_dark_theme, 1, 2, 1, 1);

            main_stack = new Gtk.Stack ();
            main_stack.margin = 6;
            main_stack.margin_bottom = 18;
            main_stack.margin_top = 24;
            main_stack.add_titled (general_grid, "general", _("General"));
            main_stack.add_titled (appearance_grid, "appearance", _("Appearance"));

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