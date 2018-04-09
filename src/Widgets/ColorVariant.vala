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
    
    public ColorVariant (Color color, int variant) {
        Object (
            color: color,
            height_request: 48,
            hexpand: true,
            label: "%s %i %s".printf (
                color.to_string (),
                variant,
                color.hex ()[variant]
            ),
            tooltip_text: _("Copy %s to clipboard").printf (color.hex ()[variant]),
            variant: variant
        );
    }

    construct {
        get_style_context ().add_class ("%s-%i".printf (
            color.style_class (), 
            variant
        ));
        
        this.clicked.connect (() => {
            Gtk.Clipboard.get_default (this.get_display ()).set_text (color.hex ()[100], -1);
        });
    }
}
