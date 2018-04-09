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

        var color_grid = new Gtk.Grid ();

        var color_menu = new Gtk.Popover (this);
        color_menu.add (color_grid);
        color_menu.position = Gtk.PositionType.BOTTOM;

        var color_100 = new ColorVariant (color, 100, color_menu);
        var color_300 = new ColorVariant (color, 300, color_menu);
        var color_500 = new ColorVariant (color, 500, color_menu);
        var color_700 = new ColorVariant (color, 700, color_menu);
        var color_900 = new ColorVariant (color, 900, color_menu);

        color_grid.width_request = 200;
        color_grid.attach (color_100, 0, 0, 1, 1);
        color_grid.attach (color_300, 0, 1, 1, 1);
        color_grid.attach (color_500, 0, 2, 1, 1);
        color_grid.attach (color_700, 0, 3, 1, 1);
        color_grid.attach (color_900, 0, 4, 1, 1);

        this.clicked.connect (() => {
            color_menu.popup ();
            color_menu.show_all ();
        });
    }
}
