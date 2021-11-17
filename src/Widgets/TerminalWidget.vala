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
        public bool ssh { get; construct; }
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

        private long remembered_position; /* Only need to remember row at the moment */
        private long remembered_command_start_row = 0; /* Only need to remember row at the moment */
        private long remembered_command_end_row = 0; /* Only need to remember row at the moment */
        public bool last_key_was_return = true;

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

        public TerminalWidget (MainWindow parent_window, Host host, bool ssh) {
            Object (
                host: host,
                ssh: ssh
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
                    menu.popup_at_pointer (event);

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
            if(host.color != "" && host.color != null) {
                var color = Gdk.RGBA();
                color.parse(host.color);
                set_color_background(color);

            } else if (Application.settings.get_string ("terminal-background-color") != "") {
                var color = Gdk.RGBA();
                color.parse(Application.settings.get_string ("terminal-background-color"));
                set_color_background(color);
            }
            if(host.font != "" && host.font != null) {
                set_font(new Pango.FontDescription().from_string(host.font));
            } else if (Application.settings.get_string ("terminal-font") != "") {
                set_font(new Pango.FontDescription().from_string(Application.settings.get_string ("terminal-font")));
            }

        }

        public void active_shell() {
            if(ssh){
                this.spawn_sync(Vte.PtyFlags.DEFAULT, null, {"/bin/sh"},
                                        null, SpawnFlags.SEARCH_PATH, null, out this.child_pid, null);
            }else{
                string dir = GLib.Environment.get_current_dir ();
                var shell = Vte.get_user_shell ();
                Idle.add_full (GLib.Priority.LOW, () => {
                    try {
                        this.spawn_sync (Vte.PtyFlags.DEFAULT, dir, { shell },
                                                null, SpawnFlags.SEARCH_PATH, null, out this.child_pid, null);
                    } catch (Error e) {
                        warning (e.message);
                    }
                    return false;
                });
            }

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

        public void send_cmd (string cmd) {
            #if UBUNTU_BIONIC_PATCHED_VTE
                this.feed_child(cmd, cmd.length);
            #else 
                #if PATCHED_VTE
                    this.feed_child((uint8[]) cmd.to_utf8 ());
                #else
                    this.feed_child(cmd.to_utf8 ());
                #endif
            #endif
        }

        public void remember_position () {
            long col, row;
            get_cursor_position (out col, out row);
            remembered_position = row;
        }

        public void remember_command_start_position () {
            if (!last_key_was_return) {
                return;
            }

            long col, row;
            get_cursor_position (out col, out row);
            remembered_command_start_row = row;
            last_key_was_return = false;
        }

        public void remember_command_end_position () {
            if (last_key_was_return) {
                return;
            }

            long col, row;
            get_cursor_position (out col, out row);
            remembered_command_end_row = row;
            last_key_was_return = true;
        }

        public string get_last_output (bool include_command = true) {
            long output_end_col, output_end_row, start_row;
            get_cursor_position (out output_end_col, out output_end_row);

            var command_lines = remembered_command_end_row - remembered_command_start_row;

            if (!include_command) {
                start_row = remembered_command_end_row + 1;
            } else {
                start_row = remembered_command_start_row;
            }

            if (output_end_row - start_row < (include_command ? command_lines + 1 : 1)) {
                return "";
            }
            /* get text to the beginning of current line (to omit last prompt)
             * Note that using end_row, 0 for the end parameters results in the first
             * character of the prompt being selected for some reason. We assume a nominal
             * maximum line length rather than determine the actual length.  */
            return get_text_range (start_row, 0, output_end_row - 1, 1000, null, null) + "\n";
        }

        public void scroll_to_last_command () {
            long col, row;
            get_cursor_position (out col, out row);
            int delta = (int)(remembered_position - row);
            vadjustment.set_value (vadjustment.get_value () + delta + get_window ().get_height () / get_char_height () - 1);
        }

    }
}