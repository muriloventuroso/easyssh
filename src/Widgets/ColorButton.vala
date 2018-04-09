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

public class ColorButton : Gtk.Button {
    public Color color { get; construct; }
    
    public ColorButton (Color color) {
        Object (
            height_request: 128,
            width_request: 128,
            color: color,
            tooltip_text: color.to_string ()
        );
    }

    construct {
        var color_context = get_style_context ();
        color_context.add_class (color.style_class ());
        color_context.add_class ("circular");

        var color_100 = new Gtk.Label ("%s 100".printf (color.to_string ()));
        color_100.hexpand = true;
        color_100.height_request = 48;
        color_100.get_style_context ().add_class ("%s-100".printf (color.style_class ()));

        var color_300 = new Gtk.Label ("%s 300".printf (color.to_string ()));
        color_300.hexpand = true;
        color_300.height_request = 48;
        color_300.get_style_context ().add_class ("%s-300".printf (color.style_class ()));

        var color_500 = new Gtk.Label ("%s 500".printf (color.to_string ()));
        color_500.hexpand = true;
        color_500.height_request = 48;
        color_500.get_style_context ().add_class ("%s-500".printf (color.style_class ()));

        var color_700 = new Gtk.Label ("%s 700".printf (color.to_string ()));
        color_700.hexpand = true;
        color_700.height_request = 48;
        color_700.get_style_context ().add_class ("%s-700".printf (color.style_class ()));

        var color_900 = new Gtk.Label ("%s 900".printf (color.to_string ()));
        color_900.hexpand = true;
        color_900.height_request = 48;
        color_900.get_style_context ().add_class ("%s-900".printf (color.style_class ()));

        var color_grid = new Gtk.Grid ();
        color_grid.width_request = 200;
        color_grid.attach (color_100, 0, 0, 1, 1);
        color_grid.attach (color_300, 0, 1, 1, 1);
        color_grid.attach (color_500, 0, 2, 1, 1);
        color_grid.attach (color_700, 0, 3, 1, 1);
        color_grid.attach (color_900, 0, 4, 1, 1);

        var color_menu = new Gtk.Popover (this);
        color_menu.add (color_grid);
        color_menu.position = Gtk.PositionType.BOTTOM;

        this.clicked.connect (() => {
            color_menu.popup ();
            color_menu.show_all ();
        });
    }
}
