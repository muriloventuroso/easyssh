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

public class ColorVariant : Gtk.Button {
    public Color color { get; construct; }
    public int variant { get; construct; }
    public Gtk.Popover color_menu { get; construct; }
    
    public ColorVariant (Color color, int variant, Gtk.Popover color_menu) {
        Object (
            color: color,
            color_menu: color_menu,
            height_request: 48,
            hexpand: true,
            tooltip_text: _("Copy %s to clipboard").printf (color.hex ()[variant]),
            variant: variant
        );
    }

    construct {
        get_style_context ().add_class ("%s-%i".printf (
            color.style_class (), 
            variant
        ));

        var variant_label = new Gtk.Label ("%s %i".printf (color.to_string (), variant));
        variant_label.expand = true;
        variant_label.halign = Gtk.Align.START;
        variant_label.valign = Gtk.Align.CENTER;

        var hex_label = new Gtk.Label ((string)color.hex ()[variant]);
        hex_label.expand = true;
        hex_label.halign = Gtk.Align.END;
        hex_label.valign = Gtk.Align.CENTER;
        hex_label.get_style_context ().add_class ("monospace");

        var grid = new Gtk.Grid ();
        grid.attach (variant_label, 0, 0, 1, 1);
        grid.attach (hex_label,     1, 0, 1, 1);

        this.add (grid);

        this.clicked.connect (() => {
            Gtk.Clipboard.get_default (this.get_display ()).set_text (color.hex ()[variant], -1);
            color_menu.hide ();
        });
    }
}

