/*
* Copyright (c) 2018 Cassidy James Blaede (https://cassidyjames.com)
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
* Authored by: Cassidy James Blaede <c@ssidyjam.es>
*/

public class MainWindow : Gtk.Window {
    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "com.github.cassidyjames.palette",
            resizable: false,
            title: _("Palette"),
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
        default_theme.add_resource_path ("/com/github/cassidyjames/palette");

        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        var header_context = header.get_style_context ();
        header_context.add_class ("titlebar");
        header_context.add_class ("default-decoration");
        header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var strawberry_button = new ColorButton ("strawberry", _("Strawberry"));
        var orange_button = new ColorButton ("orange", _("Orange"));
        var banana_button = new ColorButton ("banana", _("Banana"));
        var lime_button = new ColorButton ("lime", _("Lime"));
        var blueberry_button = new ColorButton ("blueberry", _("Blueberry"));
        var grape_button = new ColorButton ("grape", _("Grape"));
        var cocoa_button = new ColorButton ("cocoa", _("Cocoa"));
        var silver_button = new ColorButton ("silver", _("Silver"));
        var slate_button = new ColorButton ("slate", _("Slate"));
        var black_button = new ColorButton ("black", _("Black"));

        var main_layout = new Gtk.Grid ();
        main_layout.column_spacing = main_layout.row_spacing = 12;
        main_layout.margin_bottom = main_layout.margin_start = main_layout.margin_end = 12;

        main_layout.attach (strawberry_button, 0, 0, 1, 1);
        main_layout.attach (orange_button,     1, 0, 1, 1);
        main_layout.attach (banana_button,     2, 0, 1, 1);
        main_layout.attach (lime_button,       3, 0, 1, 1);        
        main_layout.attach (blueberry_button,  4, 0, 1, 1);
        main_layout.attach (grape_button,      5, 0, 1, 1);

        main_layout.attach (cocoa_button,  0, 1, 1, 1);
        main_layout.attach (silver_button, 1, 1, 1, 1);
        main_layout.attach (slate_button,  2, 1, 1, 1);
        main_layout.attach (black_button,  3, 1, 1, 1);

        var context = get_style_context ();
        context.add_class ("palette");
        context.add_class ("rounded");
        context.add_class ("flat");

        show_all ();

        set_titlebar (header);
        add (main_layout);
    }
}
