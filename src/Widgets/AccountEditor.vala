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
    public class AccountEditor : Gtk.ScrolledWindow {

        private ValidatedEntry name_entry;
        private ErrorRevealer name_error_revealer;
        private Gtk.Entry username_entry;
        private Gtk.Entry password_entry;
        private Gtk.Button save_button;
        private Gtk.Button cancel_button;
        private Gtk.Button remove_button;
        private Gtk.CheckButton change_password;
        private Gtk.FileChooserButton identityfile_chooser;
        private Gtk.Label label;
        public SourceListView sourcelistview { get; construct; }
        public Account data_account { get; construct; }
        public bool duplicate {get; construct; }

        public AccountEditor (SourceListView sourcelistview, Account? data_account, bool duplicate = false) {
            Object (
                sourcelistview: sourcelistview,
                data_account: data_account,
                margin_start: 20,
                margin_end: 20,
                duplicate: duplicate
            );
        }

        construct {
            var grid = new Gtk.Grid ();
            grid.column_spacing = 22;
            grid.orientation = Gtk.Orientation.VERTICAL;

            grid.get_style_context ().add_class("grid-account-editor");
            add(grid);
            name_entry = new ValidatedEntry ();
            name_entry.hexpand = true;
            name_error_revealer = new ErrorRevealer (".");
            name_error_revealer.label_widget.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR);
            name_entry.changed.connect (() => {
                name_entry.is_valid = check_name ();
                update_save_button ();
            });
            username_entry = new Gtk.Entry ();
            password_entry = new Gtk.Entry ();
            password_entry.visibility = false;
            var label_password = new Granite.HeaderLabel (_("Password:"));
            change_password = new Gtk.CheckButton.with_label (_("Change Password to Identity File"));

            save_button = new Gtk.Button.with_label (_("Save"));
            save_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            save_button.can_default = true;
            save_button.sensitive = false;
            cancel_button  = new Gtk.Button.with_label (_("Cancel"));
            remove_button  = new Gtk.Button.with_label (_("Remove"));
            remove_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

            save_button.clicked.connect (save_and_exit);
            cancel_button.clicked.connect (exit);
            remove_button.clicked.connect (remove_account);

            var buttons = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            buttons.layout_style = Gtk.ButtonBoxStyle.END;
            buttons.spacing = 6;
            buttons.margin_top = 6;
            buttons.margin_bottom = 30;

            buttons.add(cancel_button);
            if(data_account != null) {
                if(duplicate == false){
                    buttons.add(remove_button);
                }
            }
            buttons.pack_end(save_button, false, false, 0);

            
            label = new Gtk.Label(null);
            label.get_style_context ().add_class("h2");
            grid.add (label);
            grid.attach (new Granite.HeaderLabel (_("Name:")), 0, 1, 1, 1);
            grid.attach (name_entry, 0, 2, 1, 1);
            grid.attach (name_error_revealer, 0, 3, 1, 1);
            grid.attach (new Granite.HeaderLabel (_("Username:")), 0, 10, 1, 1);
            grid.attach (username_entry, 0, 11, 1, 1);

            grid.attach (label_password, 0, 12, 1, 1);
            grid.attach (password_entry, 0, 13, 1, 1);
            
            identityfile_chooser = new Gtk.FileChooserButton (_("Select Identity File"), Gtk.FileChooserAction.OPEN);
            grid.attach (identityfile_chooser, 0, 13, 1, 1);
            identityfile_chooser.hide();
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
            grid.attach (change_password, 0, 14, 1, 1);

            grid.attach (buttons, 0, 18, 1, 1);
            update_save_button();
            show_all ();
            if(data_account == null) {
                label.label = _("Add Account");
            } else {
                if(duplicate == false){
                    label.label = _("Edit Account");
                }else{
                    label.label = _("Duplicate Account");
                }
                name_entry.text = data_account.name;
                name_entry.is_valid = check_name();
                password_entry.text = data_account.password;
                username_entry.text = data_account.username;
                if(data_account.identity_file != ""){
                    var file_uri = "file://" + data_account.identity_file.replace("%20", " ");
                    print(file_uri);
                    identityfile_chooser.set_uri(file_uri);
                    password_entry.hide();
                    change_password.active = true;
                    label_password.label = _("Identity File:");
                    identityfile_chooser.show();
                }else{
                    identityfile_chooser.hide();
                }
            }
        }

        private bool check_name () {
            string name_entry_text = name_entry.text;
            bool name_is_taken = false;
            if(data_account != null) {
                if(name_entry_text != data_account.name) {
                    name_is_taken = sourcelistview.accountmanager.exist_account_name (name_entry_text);
                }else{
                    if(duplicate == true){
                        name_is_taken = sourcelistview.accountmanager.exist_account_name (name_entry_text);
                    }
                }
            } else {
                name_is_taken = sourcelistview.accountmanager.exist_account_name (name_entry_text);
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
            var account = new Account();
            account.name = name_entry.text.replace(" ", "-");
            account.username = username_entry.text;
            if(change_password.active){
                account.identity_file = identityfile_chooser.get_uri().replace("file://", "");
                account.password = "";
            }else{
                account.identity_file = "";
                account.password = password_entry.text;
            }

            if(data_account == null) {
                account = sourcelistview.add_account(account);
            } else {
                if(duplicate == false){
                    account = sourcelistview.edit_account(data_account.name, account);
                }else{
                    account = sourcelistview.add_account(account);
                }
            }
            sourcelistview.restore_accounts();
            destroy();
        }

        private void exit() {
            sourcelistview.clean_box();
            sourcelistview.restore_accounts();
        }

        private void remove_account() {
            if(data_account != null){
                sourcelistview.remove_acc(data_account.name);
                sourcelistview.clean_box();
                sourcelistview.restore_accounts();
            }

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
