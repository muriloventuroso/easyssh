/*
* Copyright (c) 2018 Cassidy James Blaede (https://cassidyjames.com)
*
* Authored by: Cassidy James Blaede <c@ssidyjam.es>
*/

public class MainWindow : Gtk.Window {
  public MainWindow (Gtk.Application application) {
    Object (
      application: application,
      border_width: 0,
      height_request: 480,
      icon_name: "com.github.cassidyjames.palette",
      resizable: false,
      title: _("Palette"),
      width_request: 640,
      window_position: Gtk.WindowPosition.CENTER
    );
  }

  construct {
    weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
    default_theme.add_resource_path ("/com/github/cassidyjames/palette");

    var header = new Gtk.HeaderBar ();
    header.show_close_button = true;

    var hello = new Gtk.Label ("Hello");

    var main_layout = new Gtk.Grid ();
    main_layout.column_spacing = 6;
    main_layout.row_spacing = 6;
    main_layout.attach (hello, 0, 0, 1, 1);

    get_style_context ().add_class ("palette");
    get_style_context ().add_class ("rounded");
    set_titlebar (header);
    add (main_layout);
  }
}
