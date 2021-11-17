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

    public class Application : Gtk.Application {
        public static Settings settings;

        public Application () {
            Object (application_id: "com.github.muriloventuroso.easyssh",
            flags: ApplicationFlags.FLAGS_NONE);
        }

        construct {
            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
            Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
            Intl.textdomain (GETTEXT_PACKAGE);
        }

        static construct {
            settings = new Settings ("com.github.muriloventuroso.easyssh");
            if (settings.get_string ("hosts-folder") == "") {
                string hosts_folder = GLib.Environment.get_user_config_dir() + "/easyssh";
                settings.set_string ("hosts-folder", hosts_folder);

                try {
                    var file = File.new_for_path(hosts_folder);
                    file.make_directory();
                } catch (Error e) {
                    warning (e.message);
                }
            }
        }

        protected override void activate () {
            if (get_windows ().length () > 0) {
                get_windows ().data.present ();
                return;
            }

            var app_window = new MainWindow (this);
            app_window.show_all ();
            app_window.finish_construction();

            var quit_action = new SimpleAction ("quit", null);
            add_action (quit_action);
            set_accels_for_action ("app.quit", {"<Control>q"});
            quit_action.activate.connect (() => {
                if (app_window != null) {
                    app_window.destroy ();
                }
            });

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/muriloventuroso/easyssh/Application.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }

        private static int main (string[] args) {

            var app = new Application ();
            return app.run (args);
        }
    }
}