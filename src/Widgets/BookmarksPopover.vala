/*
* Copyright (c) 2019 Murilo Venturoso
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
using Gee;
namespace EasySSH {

    public class BookmarksPopover : Gtk.Popover {

        public MainWindow window { get; construct; }
        private Gtk.ListBox input_bookmarks_list_box;
        private GLib.ListStore bookmark_list;
        private ValidatedEntry name_bookmark;
        private Gtk.Entry command_bookmark;
        private Gtk.Button button_add;

        public BookmarksPopover (MainWindow window) {
            Object (
                hexpand: false,
                vexpand: false,
                halign: Gtk.Align.END,
                margin_start: 20,
                margin_end: 20,
                window: window
            );
        }

        construct {

            height_request = 400;
            width_request = 400;
            var search_entry = new Gtk.SearchEntry ();
            search_entry.margin = 12;
            search_entry.margin_bottom = 6;
            search_entry.placeholder_text = _("Search bookmark");
            search_entry.hexpand = true;

            Gtk.ToolButton new_bookmark = new Gtk.ToolButton (new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR), null);
            new_bookmark.tooltip_text = _("Create a new bookmark");
            new_bookmark.hexpand = false;
            new_bookmark.margin = 6;

            bookmark_list = new GLib.ListStore (typeof (ListStoreItem));

            input_bookmarks_list_box = new Gtk.ListBox ();

            var input_bookmarks_scrolled = new Gtk.ScrolledWindow (null, null);
            input_bookmarks_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
            input_bookmarks_scrolled.expand = true;
            input_bookmarks_scrolled.add (input_bookmarks_list_box);

            var button_run = new Gtk.Button.with_label (_("Run"));
            button_run.sensitive = false;
            button_run.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

            var button_delete = new Gtk.Button.with_label (_("Delete"));
            button_delete.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            button_delete.sensitive = false;

            var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            button_box.halign = Gtk.Align.END;
            button_box.layout_style = Gtk.ButtonBoxStyle.END;
            button_box.margin = 12;
            button_box.spacing = 6;
            button_box.add (button_delete);
            button_box.add (button_run);

            var input_bookmark_grid = new Gtk.Grid ();
            input_bookmark_grid.orientation = Gtk.Orientation.VERTICAL;
            input_bookmark_grid.attach (new_bookmark, 0, 0, 1, 1);
            input_bookmark_grid.attach (search_entry, 1, 0, 1, 1);
            input_bookmark_grid.attach (input_bookmarks_scrolled, 0, 1, 2, 1);
            input_bookmark_grid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 2, 2, 1);
            input_bookmark_grid.attach (button_box, 0, 3, 2, 2);

            button_add = new Gtk.Button.with_label (_("Add Bookmark"));
            button_add.sensitive = false;
            button_add.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

            var button_add_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            button_add_box.halign = Gtk.Align.END;
            button_add_box.layout_style = Gtk.ButtonBoxStyle.END;
            button_add_box.margin = 12;
            button_add_box.spacing = 6;
            button_add_box.add (button_add);

            var back_button = new Gtk.Button.with_label (_("Bookmarks"));
            back_button.halign = Gtk.Align.START;
            back_button.margin = 6;
            back_button.get_style_context ().add_class ("back-button");

            var add_header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            add_header_box.add (back_button);
            add_header_box.set_center_widget (new Gtk.Label (_("Add Bookmark")));

            var add_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
            add_box.margin = 12;
            add_box.vexpand = true;

            name_bookmark = new ValidatedEntry ();
            name_bookmark.hexpand = true;
            name_bookmark.is_valid = check_can_add();
            command_bookmark = new Gtk.Entry ();
            command_bookmark.hexpand = true;
            command_bookmark.set_activates_default(true);

            add_box.pack_start(new Granite.HeaderLabel (_("Name:")), false, false, 0);
            add_box.pack_start(name_bookmark, false, false, 0);
            add_box.pack_start(new Granite.HeaderLabel (_("Command:")), false, false, 0);
            add_box.pack_start(command_bookmark, false, false, 0);

            var add_grid = new Gtk.Grid ();
            add_grid.orientation = Gtk.Orientation.VERTICAL;
            add_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
            add_grid.add (add_header_box);
            add_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            add_grid.add (add_box);
            add_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            add_grid.add (button_add_box);

            var stack = new Gtk.Stack ();
            stack.expand = true;
            stack.margin_top = 3;
            stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
            stack.add (input_bookmark_grid);
            stack.add (add_grid);

            var grid = new Gtk.Grid ();
            grid.column_spacing = 12;
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.add (stack);

            add (grid);
            grid.show_all();

            search_entry.grab_focus ();

            input_bookmarks_list_box.set_filter_func ((list_box_row) => {
                var item = bookmark_list.get_item (list_box_row.get_index ()) as ListStoreItem;
                return search_entry.text.down () in item.name.down ();
            });

            search_entry.search_changed.connect (() => {
                input_bookmarks_list_box.invalidate_filter ();
            });

            new_bookmark.clicked.connect(() => {
                stack.visible_child = add_grid;
            });

            back_button.clicked.connect (() => {
                stack.visible_child = input_bookmark_grid;
            });

            name_bookmark.changed.connect (() => {
                check_can_add();
            });
            command_bookmark.changed.connect (() => {
                check_can_add();
            });
            command_bookmark.activate.connect(() => {
                add_bookmark();
                stack.visible_child = input_bookmark_grid;
            });

            button_add.clicked.connect (() => {
                add_bookmark();
                stack.visible_child = input_bookmark_grid;
            });

            input_bookmarks_list_box.row_activated.connect(() => {
                button_run.sensitive = true;
                button_delete.sensitive = true;

            });
            button_run.clicked.connect(send_command);
            button_delete.clicked.connect(delete_bookmark);

        }

        private bool check_can_add () {
            if(name_bookmark.text == ""){
                button_add.sensitive = false;
                return false;
            }
            if(window.sourcelist.bookmarkmanager.get_bookmark_by_name(name_bookmark.text) != null){
                button_add.sensitive = false;
                name_bookmark.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "process-error-symbolic");
                return false;
            }
            name_bookmark.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "process-completed-symbolic");
            if(command_bookmark.text == ""){
                button_add.sensitive = false;
                return false;
            }
            button_add.sensitive = true;
            return true;
        }

        private void add_bookmark(){
            var name = name_bookmark.text;
            var command = command_bookmark.text;
            var b = new Bookmark();
            b.name = name;
            b.command = command;
            window.sourcelist.add_bookmark(b);
            name_bookmark.text = "";
            command_bookmark.text = "";
            name_bookmark.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, null);
        }


        private void update_list_store (GLib.ListStore store, HashTable<string, string> values) {
            store.remove_all ();

            values.foreach ((key, val) => {
                store.append (new ListStoreItem (key, val));
            });

            store.sort ((a, b) => {
                if (((ListStoreItem)a).name == _("Default")) {
                    return -1;
                }

                if (((ListStoreItem)b).name == _("Default")) {
                    return 1;
                }

                return ((ListStoreItem)a).name.collate (((ListStoreItem)b).name);
            });



        }

        public void send_command(){
            if(window.current_terminal != null){
                var selected_bookmark_row = input_bookmarks_list_box.get_selected_row ();
                var selected_bookmark = bookmark_list.get_item (selected_bookmark_row.get_index ()) as ListStoreItem;
                var bookmark = window.sourcelist.bookmarkmanager.get_bookmark_by_name(selected_bookmark.name);
                if(bookmark != null){
                    window.current_terminal.send_cmd(bookmark.command + "\n");
                    this.popdown ();
                    window.current_terminal.grab_focus();
                }
            }
        }

        public void delete_bookmark(){
            var selected_bookmark_row = input_bookmarks_list_box.get_selected_row ();
            var selected_bookmark = bookmark_list.get_item (selected_bookmark_row.get_index ()) as ListStoreItem;
            window.sourcelist.remove_bookmark(selected_bookmark.name);

        }

        public void load_list_store(ArrayList<Bookmark> bookmarks){
            input_bookmarks_list_box.@foreach ((row) => {
                input_bookmarks_list_box.remove(row);
            });
            var bookmarks_hash = new HashTable<string, string> (str_hash, str_equal);
            for(int i = 0; i < bookmarks.size; i++) {
                bookmarks_hash.set (bookmarks[i].name, bookmarks[i].name);
            }
            update_list_store (bookmark_list, bookmarks_hash);

            for (int i = 0; i < bookmark_list.get_n_items (); i++) {
                var item = bookmark_list.get_item (i) as ListStoreItem;
                var row = new BookmarkRow (item.name);
                row.button_press_event.connect((event) => {
                    if(event.type == Gdk.EventType.@2BUTTON_PRESS){
                        send_command();
                    }
                    return false;
                });
                input_bookmarks_list_box.add (row);


            }
            input_bookmarks_list_box.show_all();
            return;
        }

        private class ListStoreItem : Object {
            public string id;
            public string name;

            public ListStoreItem (string id, string name) {
                this.id = id;
                this.name = name;
            }
        }

        private class BookmarkRow : Gtk.ListBoxRow {
            public BookmarkRow (string name) {
                var label = new Gtk.Label (name);
                label.margin = 6;
                label.margin_end = 12;
                label.margin_start = 12;
                label.xalign = 0;
                Gtk.EventBox box = new Gtk.EventBox ();
                box.add(label);
                add (box);
            }
        }

        private class ValidatedEntry : Gtk.Entry {
            public bool is_valid { get; set; default = false; }
        }
    }
}