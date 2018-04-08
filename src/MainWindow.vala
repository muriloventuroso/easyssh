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

    var strawberry_button = new Gtk.Button ();
    strawberry_button.width_request = strawberry_button.height_request = 128;
    var strawberry_context = strawberry_button.get_style_context ();
    strawberry_context.add_class ("strawberry");
    strawberry_context.add_class ("circular");

    var orange_button = new Gtk.Button ();
    orange_button.width_request = orange_button.height_request = 128;
    var orange_context = orange_button.get_style_context ();
    orange_context.add_class ("orange");
    orange_context.add_class ("circular");

    var banana_button = new Gtk.Button ();
    banana_button.width_request = banana_button.height_request = 128;
    var banana_context = banana_button.get_style_context ();
    banana_context.add_class ("banana");
    banana_context.add_class ("circular");

    var lime_button = new Gtk.Button ();
    lime_button.width_request = lime_button.height_request = 128;
    var lime_context = lime_button.get_style_context ();
    lime_context.add_class ("lime");
    lime_context.add_class ("circular");

    var blueberry_button = new Gtk.Button ();
    blueberry_button.width_request = blueberry_button.height_request = 128;
    var blueberry_context = blueberry_button.get_style_context ();
    blueberry_context.add_class ("blueberry");
    blueberry_context.add_class ("circular");

    var grape_button = new Gtk.Button ();
    grape_button.width_request = grape_button.height_request = 128;
    var grape_context = grape_button.get_style_context ();
    grape_context.add_class ("grape");
    grape_context.add_class ("circular");

    var cocoa_button = new Gtk.Button ();
    cocoa_button.width_request = cocoa_button.height_request = 128;
    var cocoa_context = cocoa_button.get_style_context ();
    cocoa_context.add_class ("cocoa");
    cocoa_context.add_class ("circular");

    var silver_button = new Gtk.Button ();
    silver_button.width_request = silver_button.height_request = 128;
    var silver_context = silver_button.get_style_context ();
    silver_context.add_class ("silver");
    silver_context.add_class ("circular");

    var slate_button = new Gtk.Button ();
    slate_button.width_request = slate_button.height_request = 128;
    var slate_context = slate_button.get_style_context ();
    slate_context.add_class ("slate");
    slate_context.add_class ("circular");

    var black_button = new Gtk.Button ();
    black_button.width_request = black_button.height_request = 128;
    var black_context = black_button.get_style_context ();
    black_context.add_class ("black");
    black_context.add_class ("circular");

    var main_layout = new Gtk.Grid ();
    main_layout.column_spacing = main_layout.row_spacing = 12;
    main_layout.margin_bottom = main_layout.margin_left = main_layout.margin_right = 12;

    main_layout.attach (strawberry_button, 0, 0, 1, 1);
    main_layout.attach (orange_button,     1, 0, 1, 1);
    main_layout.attach (banana_button,     2, 0, 1, 1);

    main_layout.attach (lime_button,      3, 0, 1, 1);    
    main_layout.attach (blueberry_button, 4, 0, 1, 1);
    main_layout.attach (grape_button,     5, 0, 1, 1);

    main_layout.attach (cocoa_button,  0, 1, 1, 1);
    main_layout.attach (silver_button, 1, 1, 1, 1);
    main_layout.attach (slate_button,  2, 1, 1, 1);

    main_layout.attach (black_button, 3, 1, 1, 1);

    var context = get_style_context ();
    context.add_class ("palette");
    context.add_class ("rounded");
    context.add_class ("flat");

    set_titlebar (header);
    add (main_layout);
  }
}
