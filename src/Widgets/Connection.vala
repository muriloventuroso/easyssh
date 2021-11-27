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
    public class Connection : Gtk.Box {

        public Host host {get; construct;}
        public Granite.Widgets.DynamicNotebook notebook { get; construct; }
        private Gtk.Label title;
        private Gtk.Label description;
        public MainWindow window {get; construct;}
        public SourceListView sourcelist {get; construct;}

        public Connection (Host host, Granite.Widgets.DynamicNotebook notebook, MainWindow window, SourceListView sourcelist) {
            Object (
                orientation: Gtk.Orientation.VERTICAL,
                valign: Gtk.Align.CENTER,
                host: host,
                notebook: notebook,
                window: window,
                sourcelist: sourcelist
            );
        }

        construct {
            title = new Gtk.Label(host.name);
            title.get_style_context ().add_class("h2");
            var text_description = "";
            if(host.ssh_config != "" && Application.settings.get_boolean ("sync-ssh-config")){
                text_description = "ssh " + host.name;
            } else {
                text_description = "ssh " + host.username + "@" + host.host + " -p " + host.port;
            }
            description = new Gtk.Label(text_description);
            description.get_style_context ().add_class("h4");

            pack_start(title, false, false, 0);
            add(description);

            var connect_button = new Gtk.Button.with_label (_("Connect"));
            connect_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            connect_button.clicked.connect (add_tab);
            var edit_button  = new Gtk.Button.with_label (_("Edit"));
            edit_button.clicked.connect (() => {
                window.action_edit_conn (host.name);
            });
            var remove_button = new Gtk.Button.with_label (_("Remove"));
            remove_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            remove_button.clicked.connect (() => {
                window.action_remove_conn (host.name);
            });
            var buttons = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            buttons.layout_style = Gtk.ButtonBoxStyle.CENTER;
            buttons.spacing = 6;
            buttons.margin_top = 6;

            buttons.pack_start(edit_button, false, false, 0);
            buttons.add(remove_button);
            buttons.pack_end(connect_button, false, false, 0);

            add(buttons);
        }

        public void add_tab() {
            var term = new TerminalBox(host, notebook, window, true);
            term.set_can_focus(false);
            var next_tab = notebook.n_tabs;
            var tab = new Granite.Widgets.Tab (host.name + " - " + next_tab.to_string(), null, term);
            notebook.insert_tab (tab, next_tab);
            notebook.remove_tab(notebook.current);
            notebook.current = tab;
            sourcelist.set_badge_item (host.item, notebook);
            destroy();
        }

    }
}