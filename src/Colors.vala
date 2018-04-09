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
                assert_not_reached ();
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
                assert_not_reached ();
        }
    }
    
    public Gee.HashMap<int, string> hex () {
        var hex = new Gee.HashMap<int, string> ();

        switch (this) {
            case STRAWBERRY:
                hex.set (100, "#ff8c82");
                hex.set (300, "#ed5353");
                hex.set (500, "#c6262e");
                hex.set (700, "#a10705");
                hex.set (900, "#7a0000");
                break;
            case ORANGE:
                hex.set (100, "#ffc27d");
                hex.set (300, "#ffa154");
                hex.set (500, "#f37329");
                hex.set (700, "#cc3b02");
                hex.set (900, "#a62100");
                break;
            case BANANA:
                hex.set (100, "#fff394");
                hex.set (300, "#ffe16b");
                hex.set (500, "#f9c440");
                hex.set (700, "#d48e15");
                hex.set (900, "#ad5f00");
                break;
            case LIME:
                hex.set (100, "#d1ff82");
                hex.set (300, "#9bdb4d");
                hex.set (500, "#68b723");
                hex.set (700, "#3a9104");
                hex.set (900, "#206b00");
                break;
            case BLUEBERRY:
                hex.set (100, "#8cd5ff");
                hex.set (300, "#64baff");
                hex.set (500, "#3689e6");
                hex.set (700, "#0d52bf");
                hex.set (900, "#002e99");
                break;
            case GRAPE:
                hex.set (100, "#e29ffc");
                hex.set (300, "#ad65d6");
                hex.set (500, "#7a36b1");
                hex.set (700, "#4c158a");
                hex.set (900, "#260063");
                break;
            case COCOA:
                hex.set (100, "#a3907c");
                hex.set (300, "#8a715e");
                hex.set (500, "#715344");
                hex.set (700, "#57392d");
                hex.set (900, "#3d211b");
                break;
            case SILVER:
                hex.set (100, "#fafafa");
                hex.set (300, "#d4d4d4");
                hex.set (500, "#abacae");
                hex.set (700, "#7e8087");
                hex.set (900, "#555761");
                break;
            case SLATE:
                hex.set (100, "#95a3ab");
                hex.set (300, "#667885");
                hex.set (500, "#485a6c");
                hex.set (700, "#273445");
                hex.set (900, "#0e141f");
                break;
            case BLACK:
                hex.set (100, "#666666");
                hex.set (300, "#4d4d4d");
                hex.set (500, "#333333");
                hex.set (700, "#1a1a1a");
                hex.set (900, "#000000");
                break;
            default:
                assert_not_reached ();
        }
        
        return hex;
    }
}

