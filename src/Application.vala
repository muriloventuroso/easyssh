/*
* Copyright (c) 2018 Cassidy James Blaede (https://cassidyjames.com)
*
* Authored by: Cassidy James Blaede <c@ssidyjam.es>
*/

public class Palette : Gtk.Application {
  public Palette () {
    Object (application_id: "com.github.cassidyjames.lyra",
    flags: ApplicationFlags.FLAGS_NONE);
  }


  protected override void activate () {
    var app_window = new MainWindow (this);
    app_window.show_all ();

    var quit_action = new SimpleAction ("quit", null);

    add_action (quit_action);
    add_accelerator ("Escape", "app.quit", null);

    var provider = new Gtk.CssProvider ();
    provider.load_from_resource ("/com/github/cassidyjames/palette/Application.css");
    Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

    quit_action.activate.connect (() => {
      if (app_window != null) {
        app_window.destroy ();
      }
    });
  }


  private static int main (string[] args) {
    Gtk.init (ref args);

    var app = new Palette ();
    return app.run (args);
  }
}
