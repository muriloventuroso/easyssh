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
    public class ConnectionEditor : Gtk.Grid {

        private ValidatedEntry name_entry;
        private ErrorRevealer name_error_revealer;
        private Gtk.Entry group_entry;
        private Gtk.Entry host_entry;
        private Gtk.Entry port_entry;
        private Gtk.Entry username_entry;
        private Gtk.Entry password_entry;
        private Gtk.Button save_button;
        private Gtk.Button cancel_button;
        private Gtk.Label label;
        public SourceListView sourcelistview  { get; construct; }
        public Host data_host  { get; construct; }

        public ConnectionEditor (SourceListView sourcelistview, Host? data_host) {
            Object (
                margin_start: 22,
                margin_end: 22,
                column_spacing: 22,
                orientation: Gtk.Orientation.VERTICAL,
                valign: Gtk.Align.CENTER,
                expand: true,
                sourcelistview: sourcelistview,
                data_host: data_host
            );
        }

        construct {
            name_entry = new ValidatedEntry ();
            name_entry.hexpand = true;
            name_error_revealer = new ErrorRevealer (".");
            name_error_revealer.label_widget.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR);

            group_entry = new Gtk.Entry ();
            host_entry = new Gtk.Entry ();
            port_entry = new Gtk.Entry ();
            username_entry = new Gtk.Entry ();
            password_entry = new Gtk.Entry ();
            password_entry.visibility = false;

            if(data_host != null){
                name_entry.text = data_host.name;
                name_entry.is_valid = check_name();
                group_entry.text = data_host.group;
                host_entry.text = data_host.host;
                port_entry.text = data_host.port;
                username_entry.text = data_host.username;
                password_entry.text = data_host.password;
            }

            name_entry.changed.connect (() => {
                name_entry.is_valid = check_name ();
                update_save_button ();
            });

            save_button = new Gtk.Button.with_label (_("Save"));
            save_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            save_button.can_default = true;
            save_button.sensitive = false;
            cancel_button  = new Gtk.Button.with_label (_("Cancel"));

            save_button.clicked.connect (save_and_exit);
            cancel_button.clicked.connect (exit);

            var buttons = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            buttons.layout_style = Gtk.ButtonBoxStyle.END;
            buttons.spacing = 6;
            buttons.margin_top = 6;

            buttons.pack_start(cancel_button, false, false, 0);
            buttons.pack_end(save_button, false, false, 0);

            if(data_host == null){
                label = new Gtk.Label(_("Add Connection"));
            }else{
                label = new Gtk.Label(_("Edit Connection"));            
            }
            label.get_style_context ().add_class("h2");
            add (label);
            attach (new Granite.HeaderLabel (_("Name:")), 0, 1, 1, 1);
            attach (name_entry, 0, 2, 1, 1);
            attach (name_error_revealer, 0, 3, 1, 1);
            attach (new Granite.HeaderLabel (_("Group:")), 0, 4, 1, 1);
            attach (group_entry, 0, 5, 1, 1);
            attach (new Granite.HeaderLabel (_("Host:")), 0, 6, 1, 1);
            attach (host_entry, 0, 7, 1, 1);
            attach (new Granite.HeaderLabel (_("Port:")), 0, 8, 1, 1);
            attach (port_entry, 0, 9, 1, 1);
            attach (new Granite.HeaderLabel (_("Username:")), 0, 10, 1, 1);
            attach (username_entry, 0, 11, 1, 1);
            attach (new Granite.HeaderLabel (_("Password:")), 0, 12, 1, 1);
            attach (password_entry, 0, 13, 1, 1);
            attach (buttons, 0, 14, 1, 1);

            update_save_button();
        }

        private bool check_name () {
            string name_entry_text = name_entry.text;
            bool name_is_taken = false;
            if(data_host != null){
                if(name_entry_text != data_host.name){
                    name_is_taken = sourcelistview.hostmanager.exist_host_name (name_entry_text);
                }
            }else{
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

        private void save_and_exit(){
            var host = new Host();
            host.name = name_entry.text;
            host.group = group_entry.text;
            host.host = host_entry.text;
            host.port = port_entry.text;
            host.username = username_entry.text;
            host.password = password_entry.text;

            if(data_host == null){
                sourcelistview.add_host(host);
            }else{
                sourcelistview.edit_host(host);
            }
            
            exit();
        }

        private void exit(){
            sourcelistview.clean_box();
            sourcelistview.restore();
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