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
    public class MainWindow : Gtk.Window {

        private Preferences preferences_dialog = null;
        public Gtk.Menu menu { get; private set; }
        private Gtk.Clipboard clipboard;
        private Gtk.Clipboard primary_selection;
        private SearchToolbar search_toolbar;
        private Gtk.Grid grid;
        private Gtk.Revealer search_revealer;
        public HeaderBar header;
        private bool is_fullscreen = false;
        public Gtk.Application app { get; construct; }
        public int64 count_badge = 0;

        public const string ACTION_PREFIX = "win.";
        public const string ACTION_CLOSE_TAB = "action-close-tab";
        public const string ACTION_FULLSCREEN = "action-fullscreen";
        public const string ACTION_NEW_TAB = "action-new-tab";
        public const string ACTION_NEXT_TAB = "action-next-tab";
        public const string ACTION_PREVIOUS_TAB = "action-previous-tab";
        public const string ACTION_COPY = "action-copy";
        public const string ACTION_COPY_LAST_OUTPUT = "action-copy-last-output";
        public const string ACTION_LOCAL_CONN = "action_local_conn";
        public const string ACTION_NEW_CONN = "action_new_conn";
        public const string ACTION_NEW_ACCOUNT = "action_new_account";
        public const string ACTION_PREFERENCES = "action_preferences";
        public const string ACTION_PASTE = "action-paste";
        public const string ACTION_SEARCH = "action-search";
        public const string ACTION_SEARCH_NEXT = "action-search-next";
        public const string ACTION_SEARCH_PREVIOUS = "action-search-previous";
        public const string ACTION_SELECT_ALL = "action-select-all";
        public const string ACTION_OPEN_IN_FILES = "action-open-in-files";
        public const string ACTION_SCROLL_TO_LAST_COMMAND = "action-scroll-to-las-command";
        public const string ACTION_CLOSE_TABS = "action-scroll-to-las-command";

        public SimpleActionGroup actions { get; construct; }
        public TerminalWidget current_terminal { get; set; default = null; }

        private static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        private const ActionEntry[] action_entries = {
            { ACTION_CLOSE_TAB, action_close_tab },
            { ACTION_FULLSCREEN, action_fullscreen },
            { ACTION_NEW_TAB, action_new_tab },
            { ACTION_NEXT_TAB, action_next_tab },
            { ACTION_PREVIOUS_TAB, action_previous_tab },
            { ACTION_COPY, action_copy },
            { ACTION_COPY_LAST_OUTPUT, action_copy_last_output },
            { ACTION_LOCAL_CONN, action_local_conn },
            { ACTION_NEW_CONN, action_new_conn },
            { ACTION_NEW_ACCOUNT, action_new_account },
            { ACTION_PREFERENCES, action_preferences },
            { ACTION_PASTE, action_paste },
            { ACTION_SEARCH, action_search, null, "false" },
            { ACTION_SEARCH_NEXT, action_search_next },
            { ACTION_SEARCH_PREVIOUS, action_search_previous },
            { ACTION_SELECT_ALL, action_select_all },
            { ACTION_OPEN_IN_FILES, action_open_in_files },
            { ACTION_SCROLL_TO_LAST_COMMAND, action_scroll_to_last_command },
            { ACTION_CLOSE_TABS, action_close_tabs }
        };

        public SourceListView sourcelist;

        public MainWindow (Gtk.Application application) {
            Object (
                app: application,
                icon_name: "com.github.muriloventuroso.easyssh",
                resizable: true,
                title: _("EasySSH"),
                window_position: Gtk.WindowPosition.CENTER
            );
        }

        static construct {
            action_accelerators[ACTION_CLOSE_TAB] = "<Control><Shift>w";
            action_accelerators[ACTION_FULLSCREEN] = "F11";
            action_accelerators[ACTION_NEW_TAB] = "<Control><Shift>t";
            action_accelerators[ACTION_NEXT_TAB] = "<Control><Shift>Right";
            action_accelerators[ACTION_PREVIOUS_TAB] = "<Control><Shift>Left";
            action_accelerators[ACTION_COPY] = "<Control><Shift>c";
            action_accelerators[ACTION_COPY_LAST_OUTPUT] = "<Alt>c";
            action_accelerators[ACTION_PASTE] = "<Control><Shift>v";
            action_accelerators[ACTION_SEARCH] = "<Control><Shift>f";
            action_accelerators[ACTION_SELECT_ALL] = "<Control><Shift>a";
            action_accelerators[ACTION_OPEN_IN_FILES] = "<Control><Shift>e";
            action_accelerators[ACTION_SCROLL_TO_LAST_COMMAND] = "<Alt>Up";
        }

        construct {
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = Application.settings.get_boolean ("use-dark-theme");

            actions = new SimpleActionGroup ();
            actions.add_action_entries (action_entries, this);
            insert_action_group ("win", actions);

            clipboard = Gtk.Clipboard.get (Gdk.Atom.intern ("CLIPBOARD", false));
            clipboard.owner_change.connect (update_context_menu);

            primary_selection = Gtk.Clipboard.get (Gdk.Atom.intern ("PRIMARY", false));

            set_application (app);

            foreach (var action in action_accelerators.get_keys ()) {
                app.set_accels_for_action (ACTION_PREFIX + action, action_accelerators[action].to_array ());
            }

            var open_in_file_manager_menuitem = new Gtk.MenuItem () {
                action_name = ACTION_PREFIX + ACTION_OPEN_IN_FILES
            };
            var open_in_file_manager_menuitem_label = new Granite.AccelLabel.from_action_name (
                _("Show in File Browser"), open_in_file_manager_menuitem.action_name
            );
            open_in_file_manager_menuitem.add (open_in_file_manager_menuitem_label);

            var copy_menuitem = new Gtk.MenuItem () {
                action_name = ACTION_PREFIX + ACTION_COPY
            };
            var copy_menuitem_label = new Granite.AccelLabel.from_action_name (_("Copy"), copy_menuitem.action_name);
            copy_menuitem.add (copy_menuitem_label);

            var paste_menuitem = new Gtk.MenuItem () {
                action_name = ACTION_PREFIX + ACTION_PASTE
            };
            var paste_menuitem_label = new Granite.AccelLabel.from_action_name (_("Paste"), paste_menuitem.action_name);
            paste_menuitem.add (paste_menuitem_label);

            var select_all_menuitem = new Gtk.MenuItem () {
                action_name = ACTION_PREFIX + ACTION_SELECT_ALL
            };
            var select_all_menuitem_label = new Granite.AccelLabel.from_action_name (_("Select All"), select_all_menuitem.action_name);
            select_all_menuitem.add (select_all_menuitem_label);

            menu = new Gtk.Menu ();
            menu.append (open_in_file_manager_menuitem);
            menu.append (new Gtk.SeparatorMenuItem ());
            menu.append (copy_menuitem);
            menu.append (paste_menuitem);
            menu.append (select_all_menuitem);
            menu.insert_action_group ("win", actions);

            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
            default_theme.add_resource_path ("/com/github/muriloventuroso/easyssh");

            header = new HeaderBar (this);
            var header_context = header.get_style_context ();
            header_context.add_class ("titlebar");
            header_context.add_class ("default-decoration");
            header_context.add_class (Gtk.STYLE_CLASS_FLAT);

            var context = get_style_context ();
            context.add_class ("easyssh");
            context.add_class ("rounded");
            context.add_class ("flat");

            search_toolbar = new SearchToolbar (this);

            search_revealer = new Gtk.Revealer ();
            search_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);
            search_revealer.add (search_toolbar);
            search_revealer.set_reveal_child (false);

            sourcelist = new SourceListView(this);
            grid = new Gtk.Grid ();
            grid.attach (search_revealer, 0, 0, 1, 1);
            grid.attach (sourcelist, 0, 1, 1, 1);

            add (grid);

            set_titlebar (header);

            load_settings();
            get_simple_action (ACTION_COPY).set_enabled (false);

            this.delete_event.connect (
                () => {
                    save_settings ();
                    return false;
                }
            );

            sourcelist.host_edit_clicked.connect ((name) => {
                sourcelist.edit_conn(name);
            });
            sourcelist.host_remove_clicked.connect ((name) => {
                sourcelist.remove_conn(name);
            });
            sourcelist.host_duplicate_clicked.connect ((name) => {
                sourcelist.duplicate_conn(name);
            });
            sourcelist.account_edit_clicked.connect ((name) => {
                sourcelist.edit_acc(name);
            });
            sourcelist.account_remove_clicked.connect ((name) => {
                sourcelist.remove_acc(name);
            });
            sourcelist.account_duplicate_clicked.connect ((name) => {
                sourcelist.duplicate_acc(name);
            });
        }

        public void finish_construction () {
            sourcelist.source_list_accounts.hide();
            sourcelist.welcome_accounts.hide();
        }

        private TerminalBox? get_term_widget (Granite.Widgets.Tab tab) {
            if(Type.from_instance(tab.page).name() == "EasySSHConnection") {
                return null;
            } else {
                return (TerminalBox)tab.page;
            }
        }

        private void save_opened_hosts () {
            string[] opened_hosts = {};
            var notebooks = sourcelist.hostmanager.get_notebooks();
            for(int a = 0; a < notebooks.size; a++) {
                var notebook = notebooks[a];
                var count = 0;
                var location = "";
                notebook.tabs.foreach ((tab) => {
                    var term = get_term_widget (tab);
                    if (term == null) {
                        return;
                    }

                    location = term.dataHost.name;
                    count += 1;
                });
                if(count > 0) {
                    opened_hosts += location + "," + count.to_string();
                }
            }

            Application.settings.set_strv ("hosts", opened_hosts);

        }

        private void restore_hosts() {
            var hosts = Application.settings.get_strv ("hosts");
            for (int i = 0; i < hosts.length; i++) {
                var entry = hosts[i];
                var host_split = entry.split(",");
                var qtd_hosts = host_split[host_split.length - 1];
                var name_host = string.joinv(",", host_split[0:host_split.length - 1]);
                sourcelist.restore_hosts(name_host, int.parse(qtd_hosts));
            }
        }

        private void load_settings () {
            if (Application.settings.get_boolean ("window-maximized")) {
                this.maximize ();
                this.set_default_size (1024, 720);
            } else {
                this.set_default_size (Application.settings.get_int ("window-width"), Application.settings.get_int ("window-height"));
            }
            this.move (Application.settings.get_int ("pos-x"), Application.settings.get_int ("pos-y"));
            if(Application.settings.get_boolean ("restore-hosts")) {
                restore_hosts();
            }

        }

        private void save_settings () {
            if(Application.settings.get_boolean ("restore-hosts")) {
                save_opened_hosts();
            }
            Application.settings.set_boolean ("window-maximized", this.is_maximized);

            if (!this.is_maximized) {
                int x, y, width, height;
                this.get_position (out x, out y);
                this.get_size (out width, out height);
                Application.settings.set_int ("pos-x", x);
                Application.settings.set_int ("pos-y", y);
                Application.settings.set_int ("window-height", height);
                Application.settings.set_int ("window-width", width);
            }
        }

        void on_get_text (Gtk.Clipboard board, string? intext) {

            if (board == primary_selection) {
                current_terminal.paste_primary ();
            } else {
                current_terminal.paste_clipboard ();
            }
        }
        public bool handle_primary_selection_copy_event () {
            if (current_terminal.get_has_selection ()) {
                current_terminal.copy_primary ();
                primary_selection.request_text (on_get_text);
                return true;
            }

            return false;
        }

        public void update_context_menu () {
            clipboard.request_targets (update_context_menu_cb);
        }

        private void update_context_menu_cb (Gtk.Clipboard clipboard_, Gdk.Atom[]? atoms) {
            bool can_paste = false;

            if (atoms != null && atoms.length > 0) {
                can_paste = Gtk.targets_include_text (atoms) || Gtk.targets_include_uri (atoms);
            }

            get_simple_action (ACTION_PASTE).set_enabled (can_paste);
        }

        public void add_badge(){
            count_badge += 1;
            Granite.Services.Application.set_badge_visible.begin (true, (obj, res) => {
                try {
                    Granite.Services.Application.set_badge_visible.end (res);
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
            Granite.Services.Application.set_badge.begin (count_badge, (obj, res) => {
                try {
                    Granite.Services.Application.set_badge.end (res);
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
        }
        public void remove_badge(){
            if(count_badge <= 0){
                return;
            }
            count_badge -= 1;
            Granite.Services.Application.set_badge.begin (count_badge, (obj, res) => {
                try {
                    Granite.Services.Application.set_badge.end (res);
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
            
            if(count_badge == 0){
                Granite.Services.Application.set_badge_visible.begin (false, (obj, res) => {
                    try {
                        Granite.Services.Application.set_badge_visible.end (res);
                    } catch (GLib.Error e) {
                        critical (e.message);
                    }
                });
            }
            
        }
        public void action_edit_conn (string name) {
            sourcelist.edit_conn(name);
        }
        public void action_remove_conn (string name) {
            sourcelist.remove_conn(name);
        }
        private void action_local_conn () {
            sourcelist.local_conn();
        }
        private void action_new_conn () {
            sourcelist.new_conn();
        }
        private void action_new_account () {
            sourcelist.new_acc();
        }
        public void action_edit_account (string name) {
            sourcelist.edit_acc(name);
        }
        public void action_remove_account (string name) {
            sourcelist.remove_acc(name);
        }
        private void action_preferences () {
            if (preferences_dialog == null) {
                preferences_dialog = new Preferences (this);
                preferences_dialog.show_all ();

                preferences_dialog.sync_settings_changed.connect (() => {
                    sourcelist.load_ssh_config ();
                    sourcelist.save_hosts ();
                });

                preferences_dialog.destroy.connect (() => {
                    preferences_dialog = null;
                });
            }

            preferences_dialog.present ();
        }

        void action_copy () {
            if (current_terminal.uri != null && ! current_terminal.get_has_selection ())
                clipboard.set_text (current_terminal.uri,
                                    current_terminal.uri.length);
            else
                current_terminal.copy_clipboard ();
        }

        void action_paste () {
            clipboard.request_text (on_get_text);
        }

        void action_select_all () {
            current_terminal.select_all ();
        }
        void action_open_in_files () {
            try {
                Gtk.show_uri_on_window (this, "sftp://%s@%s:%s".printf (
                    current_terminal.host.username, current_terminal.host.host, current_terminal.host.port
                ), 0);
            } catch (Error e) {
                warning (e.message);
            }
        }

        void action_search () {
            var search_action = (SimpleAction) actions.lookup_action (ACTION_SEARCH);
            var search_state = search_action.get_state ().get_boolean ();

            search_action.set_state (!search_state);
            search_revealer.set_reveal_child (header.search_button.active);

            if (header.search_button.active) {
                action_accelerators[ACTION_SEARCH_NEXT] = "<Control>g";
                action_accelerators[ACTION_SEARCH_NEXT] = "<Control>Down";
                action_accelerators[ACTION_SEARCH_PREVIOUS] = "<Control><Shift>g";
                action_accelerators[ACTION_SEARCH_PREVIOUS] = "<Control>Up";
                search_toolbar.grab_focus ();
            } else {
                action_accelerators.remove_all(ACTION_SEARCH_NEXT);
                action_accelerators.remove_all(ACTION_SEARCH_PREVIOUS);
                search_toolbar.clear ();
                current_terminal.grab_focus ();
            }

            string [] next_accels = new string [] {};
            if (!action_accelerators[ACTION_SEARCH_NEXT].is_empty) {
                next_accels = action_accelerators[ACTION_SEARCH_NEXT].to_array ();
            }

            string [] prev_accels = new string [] {};
            if (!action_accelerators[ACTION_SEARCH_NEXT].is_empty) {
                prev_accels = action_accelerators[ACTION_SEARCH_PREVIOUS].to_array ();
            }

            application.set_accels_for_action (
                ACTION_PREFIX + ACTION_SEARCH_NEXT,
                next_accels
            );
            application.set_accels_for_action (
                ACTION_PREFIX + ACTION_SEARCH_PREVIOUS,
                prev_accels
            );
        }

        void action_search_next () {
            if (header.search_button.active) {
                search_toolbar.next_search ();
            }
        }

        void action_search_previous () {
            if (header.search_button.active) {
                search_toolbar.previous_search ();
            }
        }

        void action_copy_last_output () {
            string output = current_terminal.get_last_output ();
            Gtk.Clipboard.get_default (Gdk.Display.get_default ()).set_text (output, output.length);
        }

        void action_scroll_to_last_command () {
            current_terminal.scroll_to_last_command ();
            /* Repeated presses are ignored */
            get_simple_action (ACTION_SCROLL_TO_LAST_COMMAND).set_enabled (false);
        }

        void action_close_tab () {
            if(current_terminal != null){
                current_terminal.tab.close ();
            }
        }

        void action_new_tab () {
            sourcelist.new_tab_request();
        }

        void action_next_tab () {
            if(current_terminal != null){
                current_terminal.host.notebook.next_page ();
            }
        }

        void action_previous_tab () {
            if(current_terminal != null){
                current_terminal.host.notebook.previous_page ();
            }
        }

        void action_fullscreen () {
            if (is_fullscreen) {
                unfullscreen ();
                is_fullscreen = false;
            } else {
                fullscreen ();
                is_fullscreen = true;
            }
        }

        void action_close_tabs() {
            foreach(var notebook in sourcelist.hostmanager.get_notebooks()){
                notebook.tabs.foreach((tab) => {
                    Idle.add(()=> {
                        tab.close();
                        return false;
                    });
                });

            }
        }

        public GLib.SimpleAction? get_simple_action (string action) {
            return actions.lookup_action (action) as GLib.SimpleAction;
        }
    }

}