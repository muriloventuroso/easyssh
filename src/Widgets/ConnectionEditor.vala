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
    public class ConnectionEditor : Gtk.ScrolledWindow {

        private ValidatedEntry name_entry;
        private ErrorRevealer name_error_revealer;
        private Gtk.Entry group_entry;
        private Gtk.Entry host_entry;
        private Gtk.Entry port_entry;
        private Gtk.Entry username_entry;
        private Gtk.Entry password_entry;
        private Gtk.Entry extra_arguments;
        private Gtk.TextView ssh_config_entry;
        private Gtk.ColorButton terminal_background_color_button;
        private Gtk.FontButton terminal_font_button;
        private Gtk.Button save_button;
        private Gtk.Button cancel_button;
        private Gtk.Button advanced_button;
        private Gtk.Label label;
        private Gtk.ListBox list_tunnels;
        private Gee.ArrayList<string> array_tunnels;
        private Gtk.CheckButton change_password;
        private Gtk.FileChooserButton identityfile_chooser;
        private Gtk.RadioButton set_credentials;
        private Gtk.RadioButton set_account;
        private Gtk.Revealer revealer_credentials;
        private Gtk.Revealer revealer_accounts;
        private Gtk.ComboBoxText accounts_box;
        public SourceListView sourcelistview { get; construct; }
        public Host data_host { get; construct; }
        public bool duplicate {get; construct; }

        public ConnectionEditor (SourceListView sourcelistview, Host? data_host, bool duplicate = false) {
            Object (
                sourcelistview: sourcelistview,
                data_host: data_host,
                margin_start: 20,
                margin_end: 20,
                duplicate: duplicate
            );
        }

        construct {
            var grid = new Gtk.Grid ();
            grid.column_spacing = 22;
            grid.orientation = Gtk.Orientation.VERTICAL;

            grid.get_style_context ().add_class("grid-connection-editor");
            add(grid);
            name_entry = new ValidatedEntry ();
            name_entry.hexpand = true;
            name_error_revealer = new ErrorRevealer (".");
            name_error_revealer.label_widget.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR);

            Gtk.Box box_btn_credentials = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box_btn_credentials.margin_top = 6;
            box_btn_credentials.margin_bottom = 6;
            box_btn_credentials.set_spacing(6);
            set_credentials = new Gtk.RadioButton.with_label_from_widget (null, _("Set Credentials"));
            box_btn_credentials.pack_start (set_credentials, false, false, 0);
            set_credentials.toggled.connect (toggled_btn_credentials);

            set_account = new Gtk.RadioButton.with_label_from_widget (set_credentials, _("Choose Account"));
            box_btn_credentials.pack_start (set_account, false, false, 0);
            set_account.toggled.connect (toggled_btn_credentials);

            revealer_credentials = new Gtk.Revealer();
            revealer_credentials.set_reveal_child(true);
            revealer_accounts = new Gtk.Revealer();
            revealer_accounts.set_reveal_child(false);

            group_entry = new Gtk.Entry ();
            host_entry = new Gtk.Entry ();
            port_entry = new Gtk.Entry ();
            username_entry = new Gtk.Entry ();
            password_entry = new Gtk.Entry ();
            password_entry.visibility = false;
            var ssh_config_scroll = new Gtk.ScrolledWindow (null, null);
            ssh_config_scroll.set_vexpand (true);
            ssh_config_scroll.set_hexpand (true);
            ssh_config_entry = new Gtk.TextView ();
            ssh_config_entry.left_margin = 10;
            ssh_config_entry.top_margin = 10;
            ssh_config_scroll.add (ssh_config_entry);
            var label_password = new Granite.HeaderLabel (_("Password:"));
            extra_arguments = new Gtk.Entry ();
            accounts_box = new Gtk.ComboBoxText ();
            var count = 0;
            foreach(var account in sourcelistview.accountmanager.get_accounts()){
                accounts_box.append_text(account.name);
                if(data_host != null && data_host.account == account.name) {
                    accounts_box.active = count;
                }
                count += 1;
            }


            var color = Gdk.RGBA ();
            string terminal_font;
            if(data_host != null) {
                name_entry.text = data_host.name;
                name_entry.is_valid = check_name();
                group_entry.text = data_host.group;
                host_entry.text = data_host.host;
                port_entry.text = data_host.port;
                username_entry.text = data_host.username;
                password_entry.text = data_host.password;
                extra_arguments.text = data_host.extra_arguments;
                color.parse(data_host.color);
                terminal_font = data_host.font;
                if(data_host.account != ""){
                    set_account.set_active (true);
                    revealer_credentials.set_reveal_child(false);
                    revealer_accounts.set_reveal_child(true);
                }
            } else {
                color.parse(Application.settings.get_string ("terminal-background-color"));
                terminal_font = Application.settings.get_string ("terminal-font");
            }

            terminal_background_color_button = new Gtk.ColorButton.with_rgba (color);
            terminal_font_button = new Gtk.FontButton.with_font(terminal_font);
            terminal_font_button.use_font = true;
            terminal_font_button.use_size = true;
            name_entry.changed.connect (() => {
                name_entry.is_valid = check_name ();
                update_save_button ();
            });

            identityfile_chooser = new Gtk.FileChooserButton (_("Select Identity File"), Gtk.FileChooserAction.OPEN);
            change_password = new Gtk.CheckButton.with_label (_("Change Password to Identity File"));

            save_button = new Gtk.Button.with_label (_("Save"));
            save_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            save_button.can_default = true;
            save_button.sensitive = false;
            cancel_button  = new Gtk.Button.with_label (_("Cancel"));
            cancel_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            advanced_button = new Gtk.ToggleButton.with_label (_("Advanced"));

            save_button.clicked.connect (save_and_exit);
            cancel_button.clicked.connect (exit);

            var buttons = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            buttons.layout_style = Gtk.ButtonBoxStyle.END;
            buttons.spacing = 6;
            buttons.margin_top = 6;
            buttons.margin_bottom = 30;

            buttons.pack_start(advanced_button, false, false, 0);
            buttons.add(cancel_button);
            buttons.pack_end(save_button, false, false, 0);

            var box_credentials = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            box_credentials.pack_start(new Granite.HeaderLabel (_("Username:")), true, true, 0);
            box_credentials.pack_start(username_entry, true, true, 0);
            box_credentials.pack_start(label_password, true, true, 0);
            box_credentials.pack_end(change_password, true, true, 0);
            box_credentials.pack_start(password_entry, true, true, 0);
            box_credentials.pack_start(identityfile_chooser, true, true, 0);

            revealer_credentials.add(box_credentials);

            var box_accounts = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            box_accounts.pack_start(accounts_box, true, true, 0);
            revealer_accounts.add(box_accounts);


            if(data_host == null) {
                label = new Gtk.Label(_("Add Connection"));
            } else {
                if(duplicate == false){
                    label = new Gtk.Label(_("Edit Connection"));
                }else{
                    label = new Gtk.Label(_("Duplicate Connection"));
                }
            }
            label.get_style_context ().add_class("h2");
            grid.add (label);
            grid.attach (new Granite.HeaderLabel (_("Name:")), 0, 1, 1, 1);
            grid.attach (name_entry, 0, 2, 1, 1);
            grid.attach (name_error_revealer, 0, 3, 1, 1);
            grid.attach (new Granite.HeaderLabel (_("Group:")), 0, 4, 1, 1);
            grid.attach (group_entry, 0, 5, 1, 1);
            grid.attach (new Granite.HeaderLabel (_("Host:")), 0, 6, 1, 1);
            grid.attach (host_entry, 0, 7, 1, 1);
            grid.attach (new Granite.HeaderLabel (_("Port:")), 0, 8, 1, 1);
            grid.attach (port_entry, 0, 9, 1, 1);
            grid.attach (box_btn_credentials, 0, 10, 1, 1);
            grid.attach (revealer_credentials, 0, 11, 1, 1);
            grid.attach (revealer_accounts, 0, 12, 1, 1);

            change_password.toggled.connect (() => {
                if (change_password.active) {
                    password_entry.hide();
                    label_password.label = _("Identity File:");
                    identityfile_chooser.show();
                } else {
                    password_entry.show();
                    label_password.label = _("Password:");
                    identityfile_chooser.hide();
                }

            });
            if(Application.settings.get_boolean ("sync-ssh-config")){
                ssh_config_entry.set_vexpand(true);
                ssh_config_entry.buffer.text = sourcelistview.get_host_ssh_config (data_host.name);
                grid.attach (new Granite.HeaderLabel (_("SSH Config:")), 0, 13, 2, 1);
                grid.attach (ssh_config_scroll, 0, 14, 1, 1);

                host_entry.key_release_event.connect (() => {
                    var text_config = ssh_config_entry.buffer.text.split("\n");
                    var new_config = "";
                    var change = false;
                    foreach (string l in text_config) {
                        if(l == ""){
                            continue;
                        }
                        var new_line = l + "\n";
                        if(l.length >= 8){
                            if(l.substring(0, 8) == "HostName"){
                                new_line = "HostName " + host_entry.get_text() + "\n";
                                change = true;
                            }
                        }
                        new_config += new_line;
                    }
                    if(change == false){
                        new_config += "HostName " + host_entry.get_text() + "\n";
                    }
                    ssh_config_entry.buffer.text = new_config;
                });

                username_entry.key_release_event.connect (() => {
                    var text_config = ssh_config_entry.buffer.text.split("\n");
                    var new_config = "";
                    var change = false;
                    foreach (string l in text_config) {
                        if(l == ""){
                            continue;
                        }
                        var new_line = l + "\n";
                        if(l.length >= 4){
                            if(l.substring(0, 4) == "User"){
                                new_line = "User " + username_entry.get_text() + "\n";
                                change = true;
                            }
                        }
                        new_config += new_line;
                    }
                    if(change == false){
                        new_config += "User " + username_entry.get_text() + "\n";
                    }
                    ssh_config_entry.buffer.text = new_config;
                });

                port_entry.key_release_event.connect (() => {
                    var text_config = ssh_config_entry.buffer.text.split("\n");
                    var new_config = "";
                    var change = false;
                    foreach (string l in text_config) {
                        if(l == ""){
                            continue;
                        }
                        var new_line = l + "\n";
                        if(l.length >= 4){
                            if(l.substring(0, 4) == "Port"){
                                new_line = "Port " + port_entry.get_text() + "\n";
                                change = true;
                            }
                        }
                        new_config += new_line;
                    }
                    if(change == false){
                        new_config += "Port " + port_entry.get_text() + "\n";
                    }
                    ssh_config_entry.buffer.text = new_config;
                });

                identityfile_chooser.file_set.connect (() => {
                    var text_config = ssh_config_entry.buffer.text.split("\n");
                    var new_config = "";
                    var change = false;
                    foreach (string l in text_config) {
                        if(l == ""){
                            continue;
                        }
                        var new_line = l + "\n";
                        if(l.length >= 12){
                            if(l.substring(0, 12) == "IdentityFile"){
                                new_line = "IdentityFile " + identityfile_chooser.get_uri().replace("file://", "") + "\n";
                                change = true;
                            }
                        }
                        new_config += new_line;
                    }
                    if(change == false){
                        new_config += "IdentityFile " + identityfile_chooser.get_uri().replace("file://", "") + "\n";
                    }
                    ssh_config_entry.buffer.text = new_config;
                });
            }
            var revealer = new Gtk.Revealer();

            var box_advanced = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box_advanced.get_style_context ().add_class("box-advanced");

            var separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
            var label_advanced = new Gtk.Label(_("Advanced"));
            label_advanced.get_style_context ().add_class("title-advanced");
            label_advanced.set_alignment(0, 0);
            box_advanced.pack_start(separator, false, false, 12);
            box_advanced.pack_start(label_advanced, false, false, 0);

            var appearance_grid = new Gtk.Grid ();
            appearance_grid.attach (new Granite.HeaderLabel (_("Terminal Background Color:")), 0, 1, 1, 1);
            appearance_grid.attach (terminal_background_color_button, 0, 2, 1, 1);
            var clean_color  = new Gtk.Button.from_icon_name ("edit-clear");
            clean_color.clicked.connect(() => {
                var n_color = Gdk.RGBA ();
                n_color.parse(Application.settings.get_string ("terminal-background-color"));
                terminal_background_color_button.set_rgba(n_color);
            });
            appearance_grid.attach_next_to (clean_color, terminal_background_color_button, Gtk.PositionType.RIGHT, 1, 1);
            appearance_grid.attach (new Granite.HeaderLabel (_("Terminal Font:")), 0, 3, 1, 1);
            appearance_grid.attach (terminal_font_button, 0, 4, 1, 1);
            var clean_font  = new Gtk.Button.from_icon_name ("edit-clear");
            clean_font.clicked.connect(() => {
                terminal_font_button.set_font(Application.settings.get_string ("terminal-font"));
            });
            appearance_grid.attach_next_to (clean_font, terminal_font_button, Gtk.PositionType.RIGHT, 1, 1);
            var tunnels_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            var add_tunnel_grid = new Gtk.Grid ();
            add_tunnel_grid.column_spacing = 5;
            list_tunnels = new Gtk.ListBox();
            array_tunnels = new Gee.ArrayList<string>();
            if(data_host != null) {
                string[] lines = data_host.tunnels.split (",");
                foreach (unowned string str in lines) {
                    if(str != ""){
                        var row = new Gtk.ListBoxRow ();
                        array_tunnels.insert(0, str);
                        row.add(new Gtk.Label (str));
                        list_tunnels.insert (row, 0);
                    }
                }
            }

            var other_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            other_box.pack_start (new Granite.HeaderLabel (_("Extra Arguments:")), false, false, 0);
            other_box.pack_start (extra_arguments, false, false, 0);

            var scroll_tunnels = new Gtk.ScrolledWindow(null, null);
            scroll_tunnels.set_min_content_height(80);

            scroll_tunnels.add(list_tunnels);
            list_tunnels.set_vexpand (true);
            list_tunnels.set_hexpand (true);
            var grid_tunnels = new Gtk.Grid();
            grid_tunnels.get_style_context ().add_class("list-tunnels");
            var button_remove_tunnel = new Gtk.Button.with_label (_("Remove")) {
                sensitive = false
            };
            button_remove_tunnel.clicked.connect(() => {
                var row = list_tunnels.get_selected_row();
                if (row == null) {
                    return;
                }

                var index_row = row.get_index();
                array_tunnels.remove_at(index_row);
                list_tunnels.remove(row);
            });
            grid_tunnels.attach(scroll_tunnels, 0, 0, 1, 4);
            grid_tunnels.attach_next_to(button_remove_tunnel, scroll_tunnels, Gtk.PositionType.RIGHT, 1, 1);

            tunnels_box.pack_start (new Granite.HeaderLabel (_("Forwarded Ports:")), false, false, 0);
            tunnels_box.pack_start (grid_tunnels, false, false, 0);

            tunnels_box.pack_start (new Granite.HeaderLabel (_("Add new forwarded port")), false, false, 0);
            tunnels_box.pack_start (add_tunnel_grid, false, false, 0);
            add_tunnel_grid.attach (new Granite.HeaderLabel (_("Source Port:")), 0, 0, 1, 1);
            var source_port_entry = new Gtk.Entry ();
            add_tunnel_grid.attach (source_port_entry, 1, 0, 1, 1);
            add_tunnel_grid.attach (new Granite.HeaderLabel (_("Destination:")), 2, 0, 1, 1);
            var destination_entry = new Gtk.Entry ();
            add_tunnel_grid.attach (destination_entry, 3, 0, 1, 1);

            var hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            var button_local = new Gtk.RadioButton.with_label_from_widget (null, _("Local"));

            var button_remote = new Gtk.RadioButton.from_widget (button_local);
            button_remote.set_label (_("Remote"));

            hbox.pack_start(button_local, false, false, 0);
            hbox.pack_start(button_remote, false, false, 0);
            add_tunnel_grid.attach (hbox, 4, 0, 2, 1);

            var button_add_tunnel = new Gtk.Button.with_label (_("Add Tunnel"));
            button_add_tunnel.clicked.connect(() => {
                var source_port = source_port_entry.text;
                var destination = destination_entry.text;
                var local = button_local.get_active ();
                var type_tunnel = "R";
                if(local == true) {
                    type_tunnel = "L";
                }
                var string_tunnel = "-" + type_tunnel + " " + source_port + ":" + destination;
                var row = new Gtk.ListBoxRow ();
                array_tunnels.insert(0, string_tunnel);
                row.add(new Gtk.Label (string_tunnel));
                list_tunnels.insert (row, 0);
                source_port_entry.text = "";
                destination_entry.text = "";
                list_tunnels.show_all ();
            });
            source_port_entry.notify["text"].connect (() => {
                button_add_tunnel.sensitive = (
                        (source_port_entry.text_length > 0) && (destination_entry.text_length > 0)
                );
            });
            destination_entry.notify["text"].connect (() => {
                button_add_tunnel.sensitive = (
                        (source_port_entry.text_length > 0) && (destination_entry.text_length > 0)
                );
            });
            list_tunnels.row_selected.connect ((row) => {
                button_remove_tunnel.sensitive = (row != null);
            });

            add_tunnel_grid.attach (button_add_tunnel, 6, 0, 1, 1);

            var main_stack = new Gtk.Stack ();
            main_stack.add_titled (appearance_grid, "appearance", _("Appearance"));
            main_stack.add_titled (tunnels_box, "tunnels", _("Tunnels"));
            main_stack.add_titled (other_box, "other", _("Other"));

            var main_stackswitcher = new Gtk.StackSwitcher ();
            main_stackswitcher.set_stack (main_stack);
            main_stackswitcher.halign = Gtk.Align.CENTER;
            box_advanced.pack_start(main_stackswitcher, false, false, 0);
            box_advanced.pack_start(main_stack, false, false, 0);
            revealer.add(box_advanced);
            grid.attach (revealer, 0, 15, 1, 1);
            advanced_button.bind_property ("active", revealer, "reveal-child");

            grid.attach (buttons, 0, 16, 1, 1);
            update_save_button();
            show_all ();
            if(data_host == null) {
                identityfile_chooser.hide();
            }else{
                if(data_host.identity_file != ""){
                    var file_uri = "file://" + data_host.identity_file.replace("%20", " ");
                    identityfile_chooser.set_uri(file_uri);
                    password_entry.hide();
                    change_password.active = true;
                    label_password.label = _("Identity File:");
                }else{
                    identityfile_chooser.hide();
                }
            }
        }

        private void toggled_btn_credentials (Gtk.ToggleButton button) {
            if(set_credentials.get_active() == true){
                revealer_accounts.set_reveal_child(false);
                revealer_credentials.set_reveal_child(true);
            }else{
                revealer_credentials.set_reveal_child(false);
                revealer_accounts.set_reveal_child(true);
            }
        }

        private bool check_name () {
            string name_entry_text = name_entry.text;
            bool name_is_taken = false;
            if(data_host != null) {
                if(name_entry_text != data_host.name) {
                    name_is_taken = sourcelistview.hostmanager.exist_host_name (name_entry_text);
                }else{
                    if(duplicate == true){
                        name_is_taken = sourcelistview.hostmanager.exist_host_name (name_entry_text);
                    }
                }
            } else {
                name_is_taken = sourcelistview.hostmanager.exist_host_name (name_entry_text);
            }

            if (name_entry_text == "") {
                name_error_revealer.reveal_child = false;
                name_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, null);
            } else if (!name_is_taken) {
                name_error_revealer.reveal_child = false;
                name_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "process-completed-symbolic");
                return true;
            } else {
                if (name_is_taken) {
                    name_error_revealer.label = _("Name is already taken");
                }

                name_error_revealer.reveal_child = true;
                name_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "process-error-symbolic");
            }

            return false;
        }

        private void save_and_exit() {
            var host = new Host();
            host.name = name_entry.text.replace(" ", "-");
            host.group = group_entry.text;
            host.host = host_entry.text;
            host.port = port_entry.text;

            if(set_credentials.get_active() == false){
                var account_name = accounts_box.get_active_text ();
                host.account = account_name;
                var account = sourcelistview.accountmanager.get_account_by_name(host.account);
                host.username = account.username;
                host.password = account.password;
                host.identity_file = account.identity_file;
            }else{
                host.account = "";
                host.username = username_entry.text;
                if(change_password.active){
                    host.identity_file = identityfile_chooser.get_uri().replace("file://", "");
                    host.password = "";
                }else{
                    host.identity_file = "";
                    host.password = password_entry.text;
                }
            }
            host.color = terminal_background_color_button.rgba.to_string();
            host.font = terminal_font_button.get_font();
            host.extra_arguments = extra_arguments.text;
            if(Application.settings.get_boolean ("sync-ssh-config")){
                host.ssh_config = ssh_config_entry.buffer.text;
            }
            var count = 0;
            var tunnels = "";
            list_tunnels.@foreach (() => {
                tunnels += "," + array_tunnels.get(count);
                count ++;
            });
            host.tunnels = tunnels;
            if(host.port == null || host.port == "") {
                host.port = "22";
            }

            if(data_host == null) {
                host = sourcelistview.add_host(host);
            } else {
                if(duplicate == false){
                    host = sourcelistview.edit_host(data_host.name, host);
                }else{
                    host = sourcelistview.add_host(host);
                }
            }
            var item = sourcelistview.source_list.selected;
            sourcelistview.source_list.selected = null;
            sourcelistview.source_list.selected = item;
            destroy();
        }

        private void exit() {
            var item = sourcelistview.source_list.selected;
            if(item == null) {
                sourcelistview.restore();
            } else {
                sourcelistview.source_list.selected = null;
                sourcelistview.source_list.selected = item;
            }
            destroy();
        }

        private void update_save_button () {
            if (name_entry.is_valid) {
                save_button.sensitive = true;
                save_button.has_default = true;
            } else {
                save_button.sensitive = false;
            }
        }

        private class ValidatedEntry : Gtk.Entry {
            public bool is_valid { get; set; default = false; }
        }
    }
}
