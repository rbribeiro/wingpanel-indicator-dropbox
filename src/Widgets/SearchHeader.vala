using Gtk;
public class SearchHeader : Gtk.Grid {
    
    public SearchEntry search_entry;
    public Button open_folder_button;
    public Button open_dropbox_website_button;
    
    public SearchHeader() {
           var css_provider = new CssProvider();
           css_provider.load_from_resource("io/elementary/wingpanel/dropbox/indicator.css");
           
           search_entry = new SearchEntry();
           search_entry.hexpand = true;
           search_entry.margin_start = 10;
           search_entry.margin_top = 10;
           search_entry.margin_bottom = 10;
           search_entry.placeholder_text = "Search on Dropbox";
           
           open_folder_button = new Button.from_icon_name ("folder");
           open_folder_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
           open_folder_button.margin_end = 4;
           open_folder_button.clicked.connect (open_dropbox_folder);
           
           open_dropbox_website_button = new Button.from_icon_name ("web-browser");
           open_dropbox_website_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
           open_dropbox_website_button.margin_start = 2;
           open_dropbox_website_button.clicked.connect (open_dropbox_website);

           orientation = Gtk.Orientation.HORIZONTAL;
           hexpand = true;
           add (search_entry);
           add (open_dropbox_website_button);
           add (open_folder_button);
    }
    
   private void open_dropbox_folder () {
      string dropbox_folder = Dropbox.Services.Service.get_folder_path();
      try {
        AppInfo.launch_default_for_uri("file://"+dropbox_folder, null);
      } catch (Error e) {
        print (e.message);
      }
   }
   
   private void open_dropbox_website () {
     string url = "https://www.dropbox.com/h";
     try {
       AppInfo.launch_default_for_uri(url, null);
     } catch (Error e) {
       print (e.message);
     }
   }
}
