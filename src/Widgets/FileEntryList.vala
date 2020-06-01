using Gtk;

public class FileEntryList : Gtk.Grid {
    
    public string[] files_string_list;
    private IconSize icon_size = IconSize.SMALL_TOOLBAR;
    private string root_path_ignored;
    private int max_results = 7;
    private int file_list_current_last_index = 0;
    private Button more_results_btn;
    private Button less_results_btn;
    private Spinner spinner;
    
    public Label placeholder;
    public Label title;
    public bool is_loading = false;
    
    public ListBox listbox;
    
    public FileEntryList(string[]? path_list, string? root_path, IconSize? iconsize, bool? sorted, int max_results_p) {
        CssProvider css_provider = new CssProvider();
        css_provider.load_from_resource("io/elementary/wingpanel/dropbox/indicator.css");
        
        files_string_list = path_list;
        max_results = max_results_p;
        
        spinner = new Spinner();
        spinner.active = true;
        
        listbox = new ListBox();
        listbox.activate_on_single_click = false;
        listbox.row_activated.connect(double_click);
        listbox.hexpand = true;
        
        if (sorted) {
        listbox.set_sort_func(sort_func);
        }
        
        icon_size = (iconsize != null) ? iconsize : icon_size;
        root_path_ignored = root_path;
        
        more_results_btn = new Button.with_label ("More results");
        more_results_btn.clicked.connect (show_more_results);
        more_results_btn.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
        more_results_btn.get_style_context().add_class("h4");
        more_results_btn.no_show_all = true;
        
        less_results_btn = new Button.with_label("Less results");
        less_results_btn.no_show_all = true;
        less_results_btn.clicked.connect(show_less_results);
        less_results_btn.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
        less_results_btn.get_style_context().add_class("h4");

        title = new Gtk.Label("");
        title.halign = Gtk.Align.START;
        title.get_style_context().add_class("h3");
        title.margin_start = title.margin_bottom = 10;
        title.no_show_all = true;
        
        placeholder = new Label("Placeholder..");
        placeholder.get_style_context().add_class (Granite.STYLE_CLASS_H2_LABEL);
        placeholder.get_style_context().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        placeholder.get_style_context().add_class ("place_holder_large");
        placeholder.get_style_context().add_provider(css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        placeholder.show();
        listbox.set_placeholder (placeholder);
        
        orientation = Gtk.Orientation.VERTICAL;
        this.add(title);
        this.add(listbox);
        this.add(less_results_btn);
        this.add(more_results_btn);
        this.populate (path_list);
        
    }
    
    private void double_click (ListBoxRow row) {
      if(row is FileEntry) {
        FileEntry file = (FileEntry)row;
        try {
          AppInfo.launch_default_for_uri ("file://"+file.file_path, null);
        } catch (Error e) {
          print (e.message);
        }
      }
    }
    
    public void remove_all() {
      listbox.foreach(row => {row.destroy();});
      more_results_btn.hide();
      less_results_btn.hide();
    }
    
    public void populate (string[] list) {
        files_string_list = list;
        remove_all();
        if(files_string_list != null && files_string_list.length > 0) {
            string[] new_list = (max_results < files_string_list.length) ? files_string_list[0:max_results] : files_string_list;
            append_from_list(new_list);
            if(max_results < files_string_list.length) {
                file_list_current_last_index = max_results;
                more_results_btn.show_now();
                more_results_btn.label =  "More results (" + max_results.to_string() + "/"+files_string_list.length.to_string()+")";
            }
        }
    }
    
    public void append_from_list (string[] path_list) {
      if(path_list != null && path_list.length > 0) {
          foreach (string file_path in path_list) {
            if(file_path != "") {
              FileEntry file = new FileEntry(file_path, root_path_ignored, icon_size);
              file.has_tooltip = true;
              listbox.add(file);
            }
          }
          
          if(max_results < path_list.length) {
              file_list_current_last_index = max_results;
              less_results_btn.show_now();
              more_results_btn.show_now();
          }
         listbox.show_all();
      }
    }
    
    private int sort_func (ListBoxRow row1, ListBoxRow row2) {
        int result = 0;
        if((row1 is FileEntry) && (row2 is FileEntry)) {
        
            var file1 = (FileEntry)row1;
            var file2 = (FileEntry)row2;
            
            DateTime d1 = new DateTime.from_iso8601 (file1.modification_time.to_iso8601(), null);
            DateTime d2 = new DateTime.from_iso8601 (file2.modification_time.to_iso8601(), null);
            result = (-1)*d1.compare(d2);
            
        }
        
        return result;
    } 
    
     private void show_more_results() {
         int start = file_list_current_last_index;
         int end = (int)Math.fmin(start+max_results, files_string_list.length);

         if(end == files_string_list.length) {
             less_results_btn.show_now();
             more_results_btn.hide();
         }
         if (start < files_string_list.length) {
             append_from_list(files_string_list[start:end]);
             file_list_current_last_index = end;
             less_results_btn.show_now();
             more_results_btn.label = "More results ("+end.to_string()+"/"+files_string_list.length.to_string()+")";
             listbox.show_all();
         }
     }

     private void show_less_results() {
        populate(files_string_list);
        less_results_btn.hide();
     }
     
     public void set_loading_state (bool state) {
        is_loading = state;
         if (state) {
            Gtk.Label loading_label = new Gtk.Label ("Loading recent files...");
           // loading_label.halign = Gtk.Align.CENTER;
            
            Gtk.Grid loading_placeholder = new Gtk.Grid();
            loading_placeholder.orientation = Gtk.Orientation.VERTICAL;
            loading_placeholder.halign = Gtk.Align.CENTER;
            loading_placeholder.hexpand = true;
            
            loading_placeholder.add (spinner);
            loading_placeholder.add (loading_label);
            spinner.active = true;

            loading_placeholder.show_all ();
            listbox.set_placeholder (loading_placeholder);
         } else {
            spinner.active = false;
             listbox.set_placeholder (placeholder);
         }
     }

}
