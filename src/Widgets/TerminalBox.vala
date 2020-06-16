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
    public class TerminalBox : Gtk.ScrolledWindow {

        public Host dataHost { get; construct; }
        private bool send_password;
        private bool open_dialog;
        private bool logged;
        public Granite.Widgets.DynamicNotebook notebook { get; construct; }
        public TerminalWidget term;
        public MainWindow window { get; construct; }
        public Granite.Widgets.Tab tab {get; set;}
        private bool unread_changes;
        private EasySSH.Settings settings;
        public bool ssh { get; construct; }

        public TerminalBox (Host host, Granite.Widgets.DynamicNotebook notebook, MainWindow window, bool ssh) {
            Object (
                dataHost: host,
                notebook: notebook,
                window: window,
                ssh: ssh
            );
        }

        construct {
            settings = EasySSH.Settings.get_default();
            open_dialog = false;
            unread_changes = false;
            send_password = false;
            logged = false;
            term = new TerminalWidget(window, dataHost, ssh);
            try{
                term.set_scrollback_lines(long.parse(settings.scrollback_lines));
            }catch(Error e){
                term.set_scrollback_lines(-1);
            }


                term.set_audible_bell(settings.audible_bell);


            term.active_shell ();
            if(ssh){
                term.contents_changed.connect(on_change_terminal);
                start_connection();
            }

            add(term);

            set_vadjustment(term.get_vadjustment());
        }

        public void set_selected (){
            unread_changes = false;
        }

        public void start_connection() {
            var builder = new StringBuilder ();
            if(settings.sync_ssh_config == false){
                builder.append("ssh " + dataHost.username + "@" + dataHost.host);
                if(dataHost.port != ""){
                    builder.append(" -p " + dataHost.port);
                }
                if(dataHost.identity_file != "" && dataHost.identity_file != null) {
                    builder.append(" -i " + dataHost.identity_file);
                }
                string[] lines = dataHost.tunnels.split (",");
                foreach (unowned string str in lines) {
                    if(str != ""){
                        builder.append(" " + str);
                    }
                }
                if(dataHost.extra_arguments != null && dataHost.extra_arguments != ""){
                    builder.append(" " + dataHost.extra_arguments);
                }
                builder.append("\n");
            } else {
                builder.append("ssh ");
                builder.append(dataHost.name.split(",")[0]);
                builder.append("\n");
            }
            var cmd = builder.str;
            #if UBUNTU_BIONIC_PATCHED_VTE
                term.feed_child(cmd, cmd.length);
            #else
                term.feed_child(cmd.to_utf8 ());
            #endif
        }

        public void add_badge (){
            #if UNITY_SUPPORT
            var entry = Unity.LauncherEntry.get_for_desktop_id ("com.github.muriloventuroso.easyssh.desktop");
            entry.count_visible = true;
            entry.count = entry.count + 1;
            #endif
            unread_changes = true;
            dataHost.item.icon = new GLib.ThemedIcon ("mail-mark-important");
            tab.icon = new GLib.ThemedIcon ("mail-mark-important");
        }
        public void remove_badge (){
            #if UNITY_SUPPORT
            var entry = Unity.LauncherEntry.get_for_desktop_id ("com.github.muriloventuroso.easyssh.desktop");
            if(entry.count_visible == true){
                entry.count = entry.count - 1;
                if(entry.count == 0){
                    entry.count_visible = false;
                }
            }
            #endif
            unread_changes = false;
            dataHost.item.icon = null;
            tab.icon = null;
        }

        public void on_change_terminal (Vte.Terminal terminal) {
            string? res = terminal.get_text(null, null);
            if(res != null) {
                string[] lines = res.split("\n");
                string[] ret = {};
                if(term != window.current_terminal && unread_changes == false) {
                    add_badge ();
                }
                foreach (unowned string str in lines) {
                    if(str != "") {
                        ret += str;
                    }

                }
                if (ret.length > 2 && "closed." in ret[ret.length - 2] && "$" in ret[ret.length - 1]) {
                    if(":~$" in ret[ret.length - 1]){
                    }else{
                        if(open_dialog == false) {
                            alert_error("closed", tab);
                        }
                    }
                }else if (ret.length > 2 && "Connection timed out" in ret[ret.length - 2] && "$" in ret[ret.length - 1]) {
                    var tab = notebook.get_tab_by_widget(this);
                    if(open_dialog == false) {
                        alert_error(ret[ret.length - 2], tab);
                    }
                }else if (ret.length > 2 && "refused" in ret[ret.length - 2] && "$" in ret[ret.length - 1]) {
                    var tab = notebook.get_tab_by_widget(this);
                    if(open_dialog == false) {
                        alert_error_retry(ret[ret.length - 2], tab);
                    }
                }else if (ret.length > 2 && "Broken pipe" in ret[ret.length - 2] && "$" in ret[ret.length - 1]) {
                    var tab = notebook.get_tab_by_widget(this);
                    if(open_dialog == false) {
                        alert_error(ret[ret.length - 2], tab);
                    }
                }else if (ret.length > 2 && "No route to host" in ret[ret.length - 2] && "$" in ret[ret.length - 1]) {
                    var tab = notebook.get_tab_by_widget(this);
                    if(open_dialog == false) {
                        alert_error_retry(ret[ret.length - 2], tab);
                    }
                }else if (ret.length > 2 && ":~$" in ret[ret.length - 2]) {
                    logged = true;
                }else if (ret.length > 2 && "Permission denied, please try again." in ret[ret.length - 2] && logged == false) {
                    var tab = notebook.get_tab_by_widget(this);
                    if(open_dialog == false) {
                        alert_error(ret[ret.length - 2], tab);
                    }
                }else if (ret.length > 3 && "yes/no" in ret[ret.length - 1]) {
                    var tab = notebook.get_tab_by_widget(this);
                    if(open_dialog == false) {
                        var message = string.joinv("\n", ret[ret.length - 3:ret.length]);
                        alert_figerprint(message, tab);
                    }
                }else if(ret.length > 0 && "password:" in ret[ret.length - 1]) {
                    if(send_password == false) {
                        term_send_password();
                        send_password = true;
                    }
                }

            }
        }

        private void term_send_password() {
            var cmd = dataHost.password + "\n";
            #if UBUNTU_BIONIC_PATCHED_VTE
                term.feed_child(cmd, cmd.length);
            #else
                term.feed_child(cmd.to_utf8 ());
            #endif
        }

        private void term_send(string cmd) {
            var n_cmd = cmd + "\n";
            #if UBUNTU_BIONIC_PATCHED_VTE
                term.feed_child(n_cmd, cmd.length);
            #else
                term.feed_child(n_cmd.to_utf8 ());
            #endif
        }

        private void remove_tab(Granite.Widgets.Tab tab) {
            notebook.remove_tab(tab);
        }

        private void alert_error_retry (string error, Granite.Widgets.Tab? tab) {
            open_dialog = true;
            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Connection Error. Retry?"), error, "dialog-warning", Gtk.ButtonsType.NONE);

            var no_button = new Gtk.Button.with_label (_("No"));
            message_dialog.add_action_widget (no_button, Gtk.ResponseType.CANCEL);

            var yes_button = new Gtk.Button.with_label (_("Yes"));
            yes_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            message_dialog.add_action_widget (yes_button, Gtk.ResponseType.ACCEPT);

            message_dialog.show_all ();
            if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                start_connection();
            } else {
                remove_tab(tab);
            }

            open_dialog = false;
            message_dialog.destroy ();
        }
        private void alert_error (string error, Granite.Widgets.Tab? tab) {
            open_dialog = true;
            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Connection Error."), error, "dialog-warning", Gtk.ButtonsType.NONE);

            var close_button = new Gtk.Button.with_label (_("Close"));
            message_dialog.add_action_widget (close_button, Gtk.ResponseType.CLOSE);

            var ok_button = new Gtk.Button.with_label (_("Ok"));
            message_dialog.add_action_widget (ok_button, Gtk.ResponseType.OK);

            var retry_button = new Gtk.Button.with_label (_("Retry"));
            retry_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            message_dialog.add_action_widget (retry_button, Gtk.ResponseType.ACCEPT);

            message_dialog.show_all ();
            var response = message_dialog.run ();
            if (response == Gtk.ResponseType.ACCEPT) {
                start_connection();
            }else if(response == Gtk.ResponseType.CLOSE){
                remove_tab(tab);
            }
            open_dialog = false;
            message_dialog.destroy ();
        }

        private void alert_figerprint (string description, Granite.Widgets.Tab? tab) {
            open_dialog = true;
            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Fingerprint"), description, "dialog-information", Gtk.ButtonsType.NONE);

            var no_button = new Gtk.Button.with_label (_("No"));
            message_dialog.add_action_widget (no_button, Gtk.ResponseType.CANCEL);

            var yes_button = new Gtk.Button.with_label (_("Yes"));
            yes_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            message_dialog.add_action_widget (yes_button, Gtk.ResponseType.ACCEPT);

            message_dialog.show_all ();
            if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                term_send("yes\n");
            } else {
                term_send("no\n");
                remove_tab(tab);
            }

            open_dialog = false;
            message_dialog.destroy ();
        }


    }
}