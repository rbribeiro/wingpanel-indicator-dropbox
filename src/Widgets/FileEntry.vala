using Gtk;

public class FileEntry : Gtk.ListBoxRow {
    public Gtk.Image icon;
    public string file_path;
    public string file_name;
    public Button share_button;
    public Button bookmark_button;
    public TimeVal modification_time;

    private Grid grid_buttons;

    public FileEntry(string path, string? root_path_ignore, IconSize size){
        var css_provider = new CssProvider();
        css_provider.load_from_resource("io/elementary/wingpanel/dropbox/indicator.css");
        this.get_style_context().add_class("file_entry");
        this.get_style_context().add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        this.get_style_context().add_class (Gtk.STYLE_CLASS_MENUITEM);

        string only_path = "";
        string path_no_root_folder = "";
        Grid grid = new Gtk.Grid();
        grid.orientation = Gtk.Orientation.HORIZONTAL;
        file_path = path;
        try {
            File file =  File.new_for_path (path);
            FileInfo info = file.query_info ("*", 0);

            Icon gicon = info.get_icon();
            icon = new Gtk.Image.from_gicon (gicon, size);
            icon.get_style_context().add_class ("file_icon");
            icon.get_style_context().add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            icon.valign = Align.START;

            modification_time = info.get_modification_time();
            file_name = info.get_display_name ();
            only_path = file_path.split(file_name)[0];

            if(root_path_ignore != null && root_path_ignore != "") {
                path_no_root_folder = only_path.split(root_path_ignore)[1];
            }
            file_path = file.get_path();
        } catch (Error e) {
            print (e.message);
        }

        Grid file_attr_grid = new Gtk.Grid();
        file_attr_grid.orientation = Gtk.Orientation.VERTICAL;
        file_attr_grid.margin_end = 2;

        Label file_name_label = new Gtk.Label(file_name);
        file_name_label.get_style_context().add_class ("file_text");
        file_name_label.get_style_context().add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        file_name_label.halign = Gtk.Align.START;
        file_name_label.single_line_mode = true;
        file_name_label.lines = 0;
        file_name_label.ellipsize = Pango.EllipsizeMode.END;
        file_name_label.max_width_chars = 30;

        Label file_path_label = new Gtk.Label(only_path);
        file_path_label.track_visited_links = false;
        file_path_label.halign = Gtk.Align.START;
        file_path_label.single_line_mode = true;
        file_path_label.use_markup = true;
        file_path_label.lines = 0;
        file_path_label.ellipsize = Pango.EllipsizeMode.START;
        file_path_label.max_width_chars = 30;
        file_path_label.wrap = true;
        file_path_label.get_style_context().add_class ("path_text");
        file_path_label.get_style_context().add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        file_path_label.set_markup ("<a href='file://"+only_path+"'><span underline='none'>."+path_no_root_folder+"</span></a>");

        share_button = new Button.from_icon_name ("emblem-shared", IconSize.SMALL_TOOLBAR);
        share_button.hexpand = false;
        share_button.halign = Align.END;
        share_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        bookmark_button = new Button.from_icon_name ("non-starred", IconSize.SMALL_TOOLBAR);
        bookmark_button.hexpand = false;
        bookmark_button.halign = Align.END;
        bookmark_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        grid_buttons = new Grid ();
        grid_buttons.orientation = Orientation.HORIZONTAL;
        grid_buttons.halign = Align.END;
        grid_buttons.add (bookmark_button);
        grid_buttons.add (share_button);
        grid_buttons.no_show_all = true;

        file_attr_grid.add (file_name_label);
        file_attr_grid.add (file_path_label);

        grid.add(icon);
        grid.add(file_attr_grid);
        grid.add(grid_buttons);
        add (grid);
        grid.show_all();

    }

  public string get_file_path() {
    return file_path;
  }

  public void toggle_share_buttons () {

    if (grid_buttons.visible == true) {
      grid_buttons.no_show_all = true;
      grid_buttons.hide ();
    } else {
      grid_buttons.no_show_all = false;
      this.show_all ();
    }
  }


}
