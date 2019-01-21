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

        private Gtk.Dialog? preferences_dialog = null;
        public Gtk.UIManager ui { get; private set; }
        private Gtk.Clipboard clipboard;
        private Gtk.Clipboard primary_selection;
        private EasySSH.Settings settings;
        private string default_filemanager = "";
        private SearchToolbar search_toolbar;
        private Gtk.Revealer search_revealer;
        private HeaderBar header;
        private bool is_fullscreen = false;
        public Gtk.Application application { get; construct; }

        public const string ACTION_PREFIX = "win.";
        public const string ACTION_CLOSE_TAB = "action-close-tab";
        public const string ACTION_FULLSCREEN = "action-fullscreen";
        public const string ACTION_NEW_TAB = "action-new-tab";
        public const string ACTION_NEXT_TAB = "action-next-tab";
        public const string ACTION_PREVIOUS_TAB = "action-previous-tab";
        public const string ACTION_COPY = "action-copy";
        public const string ACTION_COPY_LAST_OUTPUT = "action-copy-last-output";
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
        public Gtk.ActionGroup main_actions;
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

        private const string ui_string = """
            <ui>
            <popup name="AppMenu">
                <menuitem name="Copy" action="Copy"/>
                <menuitem name="Paste" action="Paste"/>
                <menuitem name="Select All" action="Select All"/>
                <menuitem name="Show in File Browser" action="Show in File Browser"/>
            </popup>
            </ui>
        """;

        private SourceListView sourcelist;

        public MainWindow (Gtk.Application application) {
            Object (
                application: application,
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
            settings = EasySSH.Settings.get_default();
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.use_dark_theme;
            settings.notify["use-dark-theme"].connect (
                () => {
                    Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.use_dark_theme;
            });

            actions = new SimpleActionGroup ();
            actions.add_action_entries (action_entries, this);
            insert_action_group ("win", actions);

            /* Actions and UIManager */
            main_actions = new Gtk.ActionGroup ("MainActionGroup");
            main_actions.set_translation_domain ("com.github.muriloventuroso.easyssh");
            main_actions.add_actions (main_entries, this);

            clipboard = Gtk.Clipboard.get (Gdk.Atom.intern ("CLIPBOARD", false));
            update_context_menu ();
            clipboard.owner_change.connect (update_context_menu);

            primary_selection = Gtk.Clipboard.get (Gdk.Atom.intern ("PRIMARY", false));

            set_application(application);
            foreach (var action in action_accelerators.get_keys ()) {
                application.set_accels_for_action (ACTION_PREFIX + action, action_accelerators[action].to_array ());
            }

            ui = new Gtk.UIManager ();

            try {
                ui.add_ui_from_string (ui_string, -1);
            } catch (Error e) {
                error ("Couldn't load the UI: %s", e.message);
            }

            Gtk.AccelGroup accel_group = ui.get_accel_group ();
            add_accel_group (accel_group);

            ui.insert_action_group (main_actions, 0);
            ui.ensure_update ();

            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
            default_theme.add_resource_path ("/com/github/muriloventuroso/easyssh");

            header = new HeaderBar ();
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
            var grid = new Gtk.Grid ();
            grid.attach (search_revealer, 0, 0, 1, 1);
            grid.attach (sourcelist, 0, 1, 1, 1);
            add (grid);

            set_titlebar (header);

            load_settings();

            this.delete_event.connect (
                () => {
                    save_settings ();
                    return false;
                });

            get_default_filemanager ();

            settings.notify["sync-ssh-config"].connect (
                () => {
                    sourcelist.load_ssh_config ();
                    sourcelist.save_hosts ();
            });
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

        private void get_default_filemanager () {
            var stdout = "";
            var stderr = "";
            var result = Process.spawn_command_line_sync ("xdg-mime query default inode/directory",
                                    out stdout,
                                    out stderr,
                                    null);
            if(result==false) {
                print(stderr + "\n");
                return;
            }
            var filename = stdout;

            var res = Process.spawn_command_line_sync ("cat /usr/share/applications/" + filename,
                                    out stdout,
                                    out stderr,
                                    null);
            if(res==false) {
                print(stderr + "\n");
                return;
            }
            var lines = stdout.split("\n");
            var filemanager = "";
            foreach (string line in lines) {
                var split_line = line.split("=");
                if(split_line[0] == "Exec") {
                    filemanager = split_line[1].replace("%U", "");
                    break;
                }
            }
            if(filemanager != "") {
                default_filemanager = filemanager;
            }
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

            settings.hosts = opened_hosts;

        }

        private void restore_hosts() {
            for (int i = 0; i < settings.hosts.length; i++) {
                var entry = settings.hosts[i];
                var host_split = entry.split(",");
                var qtd_hosts = host_split[host_split.length - 1];
                var name_host = string.joinv(",", host_split[0:host_split.length - 1]);
                sourcelist.restore_hosts(name_host, int.parse(qtd_hosts));
            }
        }

        private void load_settings () {
            if (settings.window_maximized) {
                this.maximize ();
                this.set_default_size (1024, 720);
            } else {
                this.set_default_size (settings.window_width, settings.window_height);
            }
            this.move (settings.pos_x, settings.pos_y);
            if(settings.restore_hosts == true) {
                restore_hosts();
            }

        }

        private void save_settings () {
            if(settings.restore_hosts == true) {
                save_opened_hosts();
            }
            settings.window_maximized = this.is_maximized;

            if (!settings.window_maximized) {
                int x, y, width, height;
                this.get_position (out x, out y);
                this.get_size (out width, out height);
                settings.pos_x = x;
                settings.pos_y = y;
                settings.window_height = height;
                settings.window_width = width;
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

        private void update_context_menu () {
            clipboard.request_targets (update_context_menu_cb);
        }

        private void update_context_menu_cb (Gtk.Clipboard clipboard_, Gdk.Atom[]? atoms) {
            bool can_paste = false;

            if (atoms != null && atoms.length > 0)
                can_paste = Gtk.targets_include_text (atoms) || Gtk.targets_include_uri (atoms);

            main_actions.get_action ("Paste").set_sensitive (can_paste);
        }
        public void action_edit_conn (string name) {
            sourcelist.edit_conn(name);
        }
        public void action_remove_conn (string name) {
            sourcelist.remove_conn(name);
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
            if(default_filemanager == "") {
                return;
            }
            var command = "sftp://" + current_terminal.host.username + "@" + current_terminal.host.host + ":" + current_terminal.host.port;
            Process.spawn_command_line_async (default_filemanager + " " + command);
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
                header.search_button.tooltip_markup = Granite.markup_accel_tooltip (
                    {"Escape", "<Ctrl><Shift>f"},
                    _("Hide find bar")
                );
                search_toolbar.grab_focus ();
            } else {
                action_accelerators.remove_all(ACTION_SEARCH_NEXT);
                action_accelerators.remove_all(ACTION_SEARCH_PREVIOUS);
                header.search_button.tooltip_markup = Granite.markup_accel_tooltip (
                    {"<Ctrl><Shift>f"},
                    _("Find…")
                );
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

        const Gtk.ActionEntry[] main_entries = {
            { "Copy", null, N_("Copy"), "<Control><Shift>c", null, action_copy },
            { "Paste", null, N_("Paste"), "<Control><Shift>v", null, action_paste },
            { "Select All", null, N_("Select All"), "<Control><Shift>a", null, action_select_all },
            { "Show in File Browser", null, N_("Show in File Browser"), "<Control><Shift>e", null, action_open_in_files }
        };

        public GLib.SimpleAction? get_simple_action (string action) {
            return actions.lookup_action (action) as GLib.SimpleAction;
        }
    }

}