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

        // TODO: Abstract color labels to their own widget

        var color_100 = new Gtk.Button.with_label ("%s 100 %s".printf (
            color.to_string (), 
            color.hex ()[100]
        ));
        color_100.hexpand = true;
        color_100.height_request = 48;
        color_100.get_style_context ().add_class ("%s-100".printf (color.style_class ()));
        color_100.tooltip_text = _("Copy %s to clipboard").printf (color.hex ()[100]);
        color_100.clicked.connect (() => {
            Gtk.Clipboard.get_default (this.get_display ()).set_text (color.hex ()[100], -1);
        });

        var color_300 = new Gtk.Button.with_label ("%s 300 %s".printf (
            color.to_string (), 
            color.hex ()[300]
        ));
        color_300.hexpand = true;
        color_300.height_request = 48;
        color_300.get_style_context ().add_class ("%s-300".printf (color.style_class ()));
        color_300.tooltip_text = _("Copy %s to clipboard").printf (color.hex ()[300]);
        color_300.clicked.connect (() => {
            Gtk.Clipboard.get_default (this.get_display ()).set_text (color.hex ()[300], -1);
        });

        var color_500 = new Gtk.Button.with_label ("%s 500 %s".printf (
            color.to_string (), 
            color.hex ()[500]
        ));
        color_500.hexpand = true;
        color_500.height_request = 48;
        color_500.get_style_context ().add_class ("%s-500".printf (color.style_class ()));
        color_500.tooltip_text = _("Copy %s to clipboard").printf (color.hex ()[500]);
        color_500.clicked.connect (() => {
            Gtk.Clipboard.get_default (this.get_display ()).set_text (color.hex ()[500], -1);
        });

        var color_700 = new Gtk.Button.with_label ("%s 700 %s".printf (
            color.to_string (), 
            color.hex ()[700]
        ));
        color_700.hexpand = true;
        color_700.height_request = 48;
        color_700.get_style_context ().add_class ("%s-700".printf (color.style_class ()));
        color_700.tooltip_text = _("Copy %s to clipboard").printf (color.hex ()[700]);
        color_700.clicked.connect (() => {
            Gtk.Clipboard.get_default (this.get_display ()).set_text (color.hex ()[700], -1);
        });

        var color_900 = new Gtk.Button.with_label ("%s 900 %s".printf (
            color.to_string (), 
            color.hex ()[900]
        ));
        color_900.hexpand = true;
        color_900.height_request = 48;
        color_900.get_style_context ().add_class ("%s-900".printf (color.style_class ()));
        color_900.tooltip_text = _("Copy %s to clipboard").printf (color.hex ()[900]);
        color_900.clicked.connect (() => {
            Gtk.Clipboard.get_default (this.get_display ()).set_text (color.hex ()[900], -1);
        });

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
