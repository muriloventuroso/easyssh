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

    public class TerminalWidget : Vte.Terminal {
        enum DropTargets {
            URILIST,
            STRING,
            TEXT
        }

        internal const string DEFAULT_LABEL = _("Terminal");
        private bool init_complete;
        private EasySSH.Settings settings;

        private MainWindow _window;

        public MainWindow window {
            get {
                return _window;
            }

            set {
                this._window = value;
                this.menu = value.ui.get_widget ("ui/AppMenu") as Gtk.Menu;
            }
        }

        private Gtk.Menu menu;
        public Granite.Widgets.Tab tab;
        public string? uri;
        public Host host { get; construct; }
        GLib.Pid child_pid;

        private string _tab_label;
        public string tab_label {
            get {
                return _tab_label;
            }

            set {
                if (value != null) {
                    _tab_label = value;
                    tab.label = tab_label;
                }
            }
        }

        public int default_size;

        const string SEND_PROCESS_FINISHED_BASH = "dbus-send --type=method_call --session --dest=io.elementary.terminal /io/elementary/terminal io.elementary.terminal.ProcessFinished string:$PANTHEON_TERMINAL_ID string:\"$(history 1 | cut -c 8-)\" int32:\$__bp_last_ret_value >/dev/null 2>&1";

        /* Following strings are used to build RegEx for matching URIs */
        const string USERCHARS = "-[:alnum:]";
        const string USERCHARS_CLASS = "[" + USERCHARS + "]";
        const string PASSCHARS_CLASS = "[-[:alnum:]\\Q,?;.:/!%$^*&~\"#'\\E]";
        const string HOSTCHARS_CLASS = "[-[:alnum:]]";
        const string HOST = HOSTCHARS_CLASS + "+(\\." + HOSTCHARS_CLASS + "+)*";
        const string PORT = "(?:\\:[[:digit:]]{1,5})?";
        const string PATHCHARS_CLASS = "[-[:alnum:]\\Q_$.+!*,;:@&=?/~#%\\E]";
        const string PATHTERM_CLASS = "[^\\Q]'.}>) \t\r\n,\"\\E]";
        const string SCHEME = """(?:news:|telnet:|nntp:|file:\/|https?:|ftps?:|sftp:|webcal:
                                 |irc:|sftp:|ldaps?:|nfs:|smb:|rsync:|ssh:|rlogin:|telnet:|git:
                                 |git\+ssh:|bzr:|bzr\+ssh:|svn:|svn\+ssh:|hg:|mailto:|magnet:)""";

        const string USERPASS = USERCHARS_CLASS + "+(?:" + PASSCHARS_CLASS + "+)?";
        const string URLPATH = "(?:(/" + PATHCHARS_CLASS + "+(?:[(]" + PATHCHARS_CLASS + "*[)])*" + PATHCHARS_CLASS + "*)*" + PATHTERM_CLASS + ")?";

        public bool child_has_exited {
            get;
            private set;
        }

        public bool killed {
            get;
            private set;
        }

        public TerminalWidget (MainWindow parent_window, Host host) {
            Object (
                host: host
            );

            init_complete = false;
            window = parent_window;
            child_has_exited = false;
            killed = false;

            /* Connect to necessary signals */
            button_press_event.connect ((event) => {
                if (event.button ==  Gdk.BUTTON_SECONDARY) {
                    uri = get_link (event);

                    if (uri != null) {
                        window.main_actions.get_action ("Copy").set_sensitive (true);
                    }

                    menu.select_first (false);
                    menu.popup (null, null, null, event.button, event.time);

                    return true;
                } else if (event.button == Gdk.BUTTON_MIDDLE) {
                    return window.handle_primary_selection_copy_event ();
                }

                return false;
            });

            button_release_event.connect ((event) => {
                if (event.button == Gdk.BUTTON_PRIMARY) {
                    uri = get_link (event);

                    if (uri != null && ! get_has_selection ()) {
                        try {
                            Gtk.show_uri (null, uri, Gtk.get_current_event_time ());
                        } catch (GLib.Error error) {
                            warning ("Could Not Open link");
                        }
                    }
                }

                return false;
            });

            selection_changed.connect (() => {
                window.main_actions.get_action ("Copy").set_sensitive (get_has_selection ());
            });
        }

        construct {
            settings = EasySSH.Settings.get_default();
            if(settings.terminal_background_color != "") {
                var color = Gdk.RGBA();
                color.parse(settings.terminal_background_color);
                set_color_background(color);
            }
            if(settings.terminal_font != "") {
                set_font(new Pango.FontDescription().from_string(settings.terminal_font));
            }

        }

        public void active_shell() {
            this.spawn_sync(Vte.PtyFlags.DEFAULT, null, {"/bin/sh"},
                                        null, SpawnFlags.SEARCH_PATH, null, out this.child_pid, null);
        }


        public int calculate_width (int column_count) {
            int width = (int) (this.get_char_width ()) * column_count;
            return width;
        }

        public int calculate_height (int row_count) {
            int height = (int) (this.get_char_height ()) * row_count;
            return height;
        }

        private string? get_link (Gdk.Event event) {
            return this.match_check_event (event, null);
        }

        public bool is_init_complete () {
            return init_complete;
        }

        public void set_init_complete () {
            init_complete = true;
        }

    }
}