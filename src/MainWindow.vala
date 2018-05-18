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
        private string? default_filemanager = null;

        public const string ACTION_PREFIX = "win.";
        public const string ACTION_NEW_CONN = "action_new_conn";
        public const string ACTION_EDIT_CONN = "action_edit_conn";
        public const string ACTION_REMOVE_CONN = "action_remove_conn";
        public const string ACTION_PREFERENCES = "action_preferences";

        public SimpleActionGroup actions { get; construct; }
        public Gtk.ActionGroup main_actions;
        public TerminalWidget current_terminal { get; set; default = null; }

        private const ActionEntry[] action_entries = {
            { ACTION_NEW_CONN, action_new_conn },
            { ACTION_EDIT_CONN, action_edit_conn },
            { ACTION_REMOVE_CONN, action_remove_conn },
            { ACTION_PREFERENCES, action_preferences },
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

        construct {
            settings = EasySSH.Settings.get_default();

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

            var header = new HeaderBar ();
            var header_context = header.get_style_context ();
            header_context.add_class ("titlebar");
            header_context.add_class ("default-decoration");
            header_context.add_class (Gtk.STYLE_CLASS_FLAT);

            var context = get_style_context ();
            context.add_class ("easyssh");
            context.add_class ("rounded");
            context.add_class ("flat");

            set_titlebar (header);

            sourcelist = new SourceListView(this);
            add (sourcelist);

            load_settings();

            this.delete_event.connect (
                () => {
                    save_settings ();
                    return false;
                });

            key_press_event.connect ((e) => {
                switch (e.keyval) {
                    case Gdk.Key.Escape:
                        return true;
                }
                return false;
            });
            get_default_filemanager ();
        }

        private void get_default_filemanager () {
            var stdout = "";
            var stderr = "";
            var result = Process.spawn_command_line_sync ("xdg-mime query default inode/directory",
                                    out stdout,
                                    out stderr,
                                    null);
            if(result==false){
                print(stderr + "\n");
                return;
            }
            var filename = stdout;

            var res = Process.spawn_command_line_sync ("cat /usr/share/applications/" + filename,
                                    out stdout,
                                    out stderr,
                                    null);
            if(res==false){
                print(stderr + "\n");
                return;
            }
            var lines = stdout.split("\n");
            var filemanager = "";
            foreach (string line in lines) {
                var split_line = line.split("=");
                if(split_line[0] == "Exec"){
                    filemanager = split_line[1].replace("%U", "");
                    break;
                }
            }
            if(filemanager != ""){
                default_filemanager = filemanager;
            }
        }

        private TerminalBox? get_term_widget (Granite.Widgets.Tab tab) {
            if(Type.from_instance(tab.page).name() == "EasySSHConnection"){
                return null;
            }else{
                return (TerminalBox)tab.page;
            }
            
        }

        private void save_opened_hosts () {
            string[] opened_hosts = {};
            var notebooks = sourcelist.hostmanager.get_notebooks();
            for(int a = 0; a < notebooks.size; a++){
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
                if(count > 0){
                    opened_hosts += location + "," + count.to_string();
                }
                
            }

            settings.hosts = opened_hosts;

        }

        private void restore_hosts(){
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
            if(settings.restore_hosts == true){
                restore_hosts();
            }

        }

        private void save_settings () {
            if(settings.restore_hosts == true){
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
        private void action_new_conn () {
            sourcelist.new_conn();
        }
        private void action_edit_conn () {
            sourcelist.edit_conn();
        }
        private void action_remove_conn () {
            sourcelist.remove_conn();
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
            if(default_filemanager == null){
                return;
            }
            var command = "sftp://" + current_terminal.host.username + "@" + current_terminal.host.host + ":" + current_terminal.host.port;
            Process.spawn_command_line_async (default_filemanager + " " + command);
        }

        const Gtk.ActionEntry[] main_entries = {
            { "Copy", null, N_("Copy"), "<Control><Shift>c", null, action_copy },
            { "Paste", null, N_("Paste"), "<Control><Shift>v", null, action_paste },
            { "Select All", null, N_("Select All"), "<Control><Shift>a", null, action_select_all },
            { "Select All", null, N_("Select All"), "<Control><Shift>a", null, action_select_all },
            { "Show in File Browser", null, N_("Show in File Browser"), "<Control><Shift>e", null, action_open_in_files }
        };
    }

}