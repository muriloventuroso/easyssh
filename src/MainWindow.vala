/*
* Copyright (c) 2018 Cassidy James Blaede (https://cassidyjames.com)
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


        // TODO: Abstract these buttons into a color widget

        var strawberry_button = new Gtk.Button ();
        strawberry_button.width_request = strawberry_button.height_request = 128;
        strawberry_button.tooltip_text = _("Strawberry");
        var strawberry_context = strawberry_button.get_style_context ();
        strawberry_context.add_class ("strawberry");
        strawberry_context.add_class ("circular");
        
        var strawberry_100 = new Gtk.Label ("Strawberry 100");
        strawberry_100.hexpand = true;
        strawberry_100.get_style_context ().add_class ("strawberry-100");
        
        var strawberry_300 = new Gtk.Label ("Strawberry 300");
        strawberry_300.hexpand = true;
        strawberry_300.get_style_context ().add_class ("strawberry-300");
        
        var strawberry_500 = new Gtk.Label ("Strawberry 500");
        strawberry_500.hexpand = true;
        strawberry_500.get_style_context ().add_class ("strawberry-500");
        
        var strawberry_700 = new Gtk.Label ("Strawberry 700");
        strawberry_700.hexpand = true;
        strawberry_700.get_style_context ().add_class ("strawberry-700");
        
        var strawberry_900 = new Gtk.Label ("Strawberry 900");
        strawberry_900.hexpand = true;
        strawberry_900.get_style_context ().add_class ("strawberry-900");
        
        var strawberry_grid = new Gtk.Grid ();
        strawberry_grid.width_request = 200;
        strawberry_grid.attach (strawberry_100, 0, 0, 1, 1);
        strawberry_grid.attach (strawberry_300, 0, 1, 1, 1);
        strawberry_grid.attach (strawberry_500, 0, 2, 1, 1);
        strawberry_grid.attach (strawberry_700, 0, 3, 1, 1);
        strawberry_grid.attach (strawberry_900, 0, 4, 1, 1);

        var strawberry_menu = new Gtk.Popover (strawberry_button);
        strawberry_menu.add (strawberry_grid);
        strawberry_menu.position = Gtk.PositionType.BOTTOM;
        
        strawberry_button.clicked.connect (() => {
            strawberry_menu.popup ();
            strawberry_menu.show_all ();
        });

        var orange_button = new Gtk.Button ();
        orange_button.width_request = orange_button.height_request = 128;
        orange_button.tooltip_text = _("Orange");
        var orange_context = orange_button.get_style_context ();
        orange_context.add_class ("orange");
        orange_context.add_class ("circular");

        var banana_button = new Gtk.Button ();
        banana_button.width_request = banana_button.height_request = 128;
        banana_button.tooltip_text = _("Banana");
        var banana_context = banana_button.get_style_context ();
        banana_context.add_class ("banana");
        banana_context.add_class ("circular");

        var lime_button = new Gtk.Button ();
        lime_button.width_request = lime_button.height_request = 128;
        lime_button.tooltip_text = _("Lime");
        var lime_context = lime_button.get_style_context ();
        lime_context.add_class ("lime");
        lime_context.add_class ("circular");

        var blueberry_button = new Gtk.Button ();
        blueberry_button.width_request = blueberry_button.height_request = 128;
        blueberry_button.tooltip_text = _("Blueberry");
        var blueberry_context = blueberry_button.get_style_context ();
        blueberry_context.add_class ("blueberry");
        blueberry_context.add_class ("circular");

        var grape_button = new Gtk.Button ();
        grape_button.width_request = grape_button.height_request = 128;
        grape_button.tooltip_text = _("Grape");
        var grape_context = grape_button.get_style_context ();
        grape_context.add_class ("grape");
        grape_context.add_class ("circular");

        var cocoa_button = new Gtk.Button ();
        cocoa_button.width_request = cocoa_button.height_request = 128;
        cocoa_button.tooltip_text = _("Cocoa");
        var cocoa_context = cocoa_button.get_style_context ();
        cocoa_context.add_class ("cocoa");
        cocoa_context.add_class ("circular");

        var silver_button = new Gtk.Button ();
        silver_button.width_request = silver_button.height_request = 128;
        silver_button.tooltip_text = _("Silver");
        var silver_context = silver_button.get_style_context ();
        silver_context.add_class ("silver");
        silver_context.add_class ("circular");

        var slate_button = new Gtk.Button ();
        slate_button.width_request = slate_button.height_request = 128;
        slate_button.tooltip_text = _("Slate");
        var slate_context = slate_button.get_style_context ();
        slate_context.add_class ("slate");
        slate_context.add_class ("circular");

        var black_button = new Gtk.Button ();
        black_button.width_request = black_button.height_request = 128;
        black_button.tooltip_text = _("Black");
        var black_context = black_button.get_style_context ();
        black_context.add_class ("black");
        black_context.add_class ("circular");


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
