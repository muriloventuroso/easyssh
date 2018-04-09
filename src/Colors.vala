/*
* Copyright (c) 2018 Cassidy James Blaede (https://cassidyjames.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
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

public enum Color {
    STRAWBERRY,
    ORANGE,
    BANANA,
    LIME,
    BLUEBERRY,
    GRAPE,
    COCOA,
    SILVER,
    SLATE,
    BLACK;
    
    public string to_string () {
        switch (this) {
            case STRAWBERRY:
                return _("Strawberry");

            case ORANGE:
                return _("Orange");

            case BANANA:
                return _("Banana");

            case LIME:
                return _("Lime");

            case BLUEBERRY:
                return _("Blueberry");

            case GRAPE:
                return _("Grape");

            case COCOA:
                return _("Cocoa");

            case SILVER:
                return _("Silver");

            case SLATE:
                return _("Slate");

            case BLACK:
                return _("Black");

            default:
                assert_not_reached();
        }
    }
    
    public string style_class () {
        switch (this) {
            case STRAWBERRY:
                return "strawberry";

            case ORANGE:
                return "orange";

            case BANANA:
                return "banana";

            case LIME:
                return "lime";

            case BLUEBERRY:
                return "blueberry";

            case GRAPE:
                return "grape";

            case COCOA:
                return "cocoa";

            case SILVER:
                return "silver";

            case SLATE:
                return "slate";

            case BLACK:
                return "black";

            default:
                assert_not_reached();
        }
    }
}

