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
    public class Preferences : Granite.Dialog {
        public signal void sync_settings_changed ();

        public Preferences (Gtk.Window parent) {
            Object (
                border_width: 6,
                title: _("Preferences"),
                transient_for: parent
            );
        }

        construct {
            var infobar = new Gtk.InfoBar () {
                message_type = Gtk.MessageType.INFO,
                margin_bottom = 12
            };
            var restart_label = new Gtk.Label(_("Restart to apply changes"));
            infobar.get_content_area ().add (restart_label);
            infobar.add_button (_("Quit App"), Gtk.ResponseType.ACCEPT);
            infobar.response.connect ((response_id) => {
                ((GLib.Application) GLib.Application.get_default ()).activate_action ("quit", null);
            });

            var restart_revealer = new Gtk.Revealer ();
            restart_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);
            restart_revealer.add (infobar);
            restart_revealer.set_reveal_child (false);
            var hosts_filechooser = new Gtk.FileChooserButton (_("Select Hosts Configuration Folder…"), Gtk.FileChooserAction.SELECT_FOLDER);
            hosts_filechooser.hexpand = true;
            hosts_filechooser.set_current_folder (Application.settings.get_string ("hosts-folder").replace ("%20", " "));
            hosts_filechooser.file_set.connect (() => {
                Application.settings.set_string ("hosts-folder", hosts_filechooser.get_uri().split(":")[1].replace ("%20", " "));
            });
            var color = Gdk.RGBA();
            color.parse(Application.settings.get_string ("terminal-background-color"));
            var terminal_background_color_button = new Gtk.ColorButton.with_rgba (color);

            terminal_background_color_button.color_set.connect (() => {
                Application.settings.set_string ("terminal-background-color", terminal_background_color_button.rgba.to_string());
            });

            var terminal_font_button = new Gtk.FontButton.with_font(Application.settings.get_string ("terminal-font"));
            terminal_font_button.use_font = true;
            terminal_font_button.use_size = true;
            terminal_font_button.font_set.connect(() => {
                Application.settings.set_string ("terminal-font", terminal_font_button.get_font());
            });

            var restore_hosts_switch = new Gtk.Switch();
            restore_hosts_switch.halign = Gtk.Align.START;
            restore_hosts_switch.valign = Gtk.Align.CENTER;
            restore_hosts_switch.set_active(Application.settings.get_boolean ("restore-hosts"));
            restore_hosts_switch.notify["active"].connect (() => {
                Application.settings.set_boolean ("restore-hosts", restore_hosts_switch.active);
            });

            var scrollback_lines_input = new Gtk.Entry();
            scrollback_lines_input.text = Application.settings.get_string ("scrollback-lines");
            scrollback_lines_input.changed.connect (() => {
                Application.settings.set_string ("scrollback-lines", scrollback_lines_input.text);
                restart_revealer.set_reveal_child(true);
            });
            var scrollback_help = new Gtk.Label(_("0 to disable. -1 to unlimited"));
            scrollback_help.halign = Gtk.Align.START;
            scrollback_help.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

            var sync_ssh_switch = new Gtk.Switch();
            sync_ssh_switch.halign = Gtk.Align.START;
            sync_ssh_switch.valign = Gtk.Align.CENTER;
            sync_ssh_switch.set_active(Application.settings.get_boolean ("sync-ssh-config"));
            sync_ssh_switch.notify["active"].connect (() => {
                Application.settings.set_boolean ("sync-ssh-config", sync_ssh_switch.active);
                sync_settings_changed ();
            });

            var audible_bell_switch = new Gtk.Switch();
            audible_bell_switch.halign = Gtk.Align.START;
            audible_bell_switch.valign = Gtk.Align.CENTER;
            audible_bell_switch.set_active(Application.settings.get_boolean ("audible-bell"));
            audible_bell_switch.notify["active"].connect (() => {
                Application.settings.set_boolean ("audible-bell", audible_bell_switch.active);
                restart_revealer.set_reveal_child(true);
            });
            #if WITH_GPG
            var encrypt_data_switch = new Gtk.Switch();
            encrypt_data_switch.halign = Gtk.Align.START;
            encrypt_data_switch.valign = Gtk.Align.CENTER;
            encrypt_data_switch.set_active(Application.settings.get_boolean ("encrypt-data"));
            encrypt_data_switch.notify["active"].connect (() => {
                Application.settings.set_boolean ("encrypt-data", encrypt_data_switch.active);
            });
            #endif

            var use_dark_theme = new Gtk.Switch ();
            use_dark_theme.halign = Gtk.Align.START;
            use_dark_theme.valign = Gtk.Align.CENTER;
            use_dark_theme.active = Application.settings.get_boolean ("use-dark-theme");
            use_dark_theme.notify["active"].connect (() => {
                Application.settings.set_boolean ("use-dark-theme", use_dark_theme.active);
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = use_dark_theme.active;
            });

            var hosts_label = new Gtk.Label (_("Hosts Configuration Folder:")) {
                halign = Gtk.Align.END
            };

            var scrollback_label = new Gtk.Label (_("Scrollback lines:")) {
                halign = Gtk.Align.END
            };

            var restore_hosts_label = new Gtk.Label (_("Restore Opened Hosts:")) {
                halign = Gtk.Align.END
            };

            var sync_ssh_label = new Gtk.Label (_("Sync SSH Config:")) {
                halign = Gtk.Align.END
            };

            var audible_bell_label = new Gtk.Label (_("Audible Bell:")) {
                halign = Gtk.Align.END
            };

            var general_grid = new Gtk.Grid ();
            general_grid.column_spacing = 12;
            general_grid.row_spacing = 6;

            general_grid.attach (hosts_label, 0, 0, 1, 1);
            general_grid.attach (hosts_filechooser, 1, 0, 1, 1);

            general_grid.attach (scrollback_label, 0, 1, 1, 1);
            general_grid.attach (scrollback_lines_input, 1, 1, 1, 1);
            general_grid.attach (scrollback_help, 1, 2, 1, 1);

            general_grid.attach (restore_hosts_label, 0, 3, 1, 1);
            general_grid.attach (restore_hosts_switch, 1, 3, 1, 1);

            general_grid.attach (sync_ssh_label, 0, 4, 1, 1);
            general_grid.attach (sync_ssh_switch, 1, 4, 1, 1);

            general_grid.attach (audible_bell_label, 0, 5, 1, 1);
            general_grid.attach (audible_bell_switch, 1, 5, 1, 1);

            #if WITH_GPG
            var enctypt_data_label = new Gtk.Label (_("Encrypt data:")) {
                halign = Gtk.Align.END
            };

            general_grid.attach (enctypt_data_label, 0, 6, 1, 1);
            general_grid.attach (encrypt_data_switch, 1, 6, 1, 1);
            #endif


            var terminal_background_color_label = new Gtk.Label (_("Terminal Background Color:")) {
                halign = Gtk.Align.END
            };

            var terminal_font_label = new Gtk.Label (_("Terminal Font:")) {
                halign = Gtk.Align.END
            };

            var use_dark_theme_label = new Gtk.Label (_("Use Dark Theme:")) {
                halign = Gtk.Align.END
            };

            var appearance_grid = new Gtk.Grid ();
            appearance_grid.column_spacing = 12;
            appearance_grid.row_spacing = 6;

            appearance_grid.attach (terminal_background_color_label, 0, 0, 1, 1);
            appearance_grid.attach (terminal_background_color_button, 1, 0, 1, 1);

            appearance_grid.attach (terminal_font_label, 0, 1, 1, 1);
            appearance_grid.attach (terminal_font_button, 1, 1, 1, 1);

            appearance_grid.attach (use_dark_theme_label, 0, 2, 1, 1);
            appearance_grid.attach (use_dark_theme, 1, 2, 1, 1);

            var main_stack = new Gtk.Stack ();
            main_stack.margin = 12;
            main_stack.add_titled (general_grid, "general", _("General"));
            main_stack.add_titled (appearance_grid, "appearance", _("Appearance"));

            var main_stackswitcher = new Gtk.StackSwitcher ();
            main_stackswitcher.set_stack (main_stack);
            main_stackswitcher.halign = Gtk.Align.CENTER;

            var main_grid = new Gtk.Grid ();
            main_grid.attach (restart_revealer, 0, 0, 1, 1);
            main_grid.attach (main_stackswitcher, 0, 1, 1, 1);
            main_grid.attach (main_stack, 0, 2, 1, 1);

            get_content_area ().add (main_grid);

            var close_button = new Gtk.Button.with_label (_("Close"));
            close_button.clicked.connect (() => {
                destroy ();
            });

            add_action_widget (close_button, 0);
        }



    }
}