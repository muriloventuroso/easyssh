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
    public class Settings : Granite.Services.Settings {

        public int pos_x { get; set; }
        public int pos_y { get; set; }
        public int window_width { get; set; }
        public int window_height { get; set; }
        public int panel_size { get; set; }
        public bool window_maximized { get; set; }
        public string hosts_folder { get; set; }
        public string terminal_background_color {get; set;}
        public string terminal_font {get; set;}
        public string[] hosts { get; set; }
        public bool restore_hosts { get; set; }

        public static Settings get_default () {
            if (settings == null) {
                settings = new Settings ();
            }
            return settings;
        }

        public Settings() {
            base ("com.github.muriloventuroso.easyssh");
            if (hosts_folder == "") {
                hosts_folder = GLib.Environment.get_user_config_dir() + "/easyssh";
                var file = File.new_for_path(hosts_folder);
                file.make_directory();
            }
        }

    }
}