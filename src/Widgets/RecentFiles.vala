using Gtk;

public class RecentFiles : Gtk.Grid {

    private FileEntryList file_list;
    private string[] files_string_list;
    private int time_day = 1;
    private int max_results = 7;
    private int file_list_current_last_index = 0;
    private Button more_results_btn;
    private Button less_results_btn;
    private Label placeholder;
    public string dir_path;

    public RecentFiles (string dest_path, int days) {
        dir_path = dest_path;
        time_day = days;
        orientation = Gtk.Orientation.VERTICAL;
        expand = true;

        string[] recent_files = {""};
        CssProvider css_provider = new CssProvider();
        css_provider.load_from_resource("io/elementary/wingpanel/dropbox/indicator.css");
        
        Label time_stamp = new Gtk.Label("Recent activity");
        time_stamp.use_markup = true;
        time_stamp.set_markup ("<b>Recent activity </b>");
        time_stamp.halign = Gtk.Align.START;
        time_stamp.get_style_context().add_class("h3");
        time_stamp.margin_start = time_stamp.margin_bottom = 10;
        time_stamp.no_show_all = true;

        placeholder = new Label("No activity");
        placeholder.get_style_context().add_class (Granite.STYLE_CLASS_H2_LABEL);
        placeholder.get_style_context().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        placeholder.get_style_context().add_class ("place_holder_large");
        placeholder.get_style_context().add_provider(css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        placeholder.show();
        
        file_list = new FileEntryList(null,dir_path, IconSize.DND, true);
        file_list.halign = Align.FILL;
        file_list.expand = true;
        file_list.set_placeholder (placeholder);
          
        more_results_btn = new Button.with_label ("More results");
        more_results_btn.clicked.connect (show_more_results);
        more_results_btn.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
        more_results_btn.no_show_all = true;
        
        less_results_btn = new Button.with_label("Less results");
        less_results_btn.no_show_all = true;
        less_results_btn.clicked.connect(show_less_results);
        less_results_btn.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
        
        this.add(time_stamp);
        this.add(file_list);
        this.add (more_results_btn);
        this.add (less_results_btn);
        
        get_recent_files.begin(dest_path, days, (obj, res) => {
            try {
                recent_files = get_recent_files.end(res);
                if (recent_files != null && recent_files[0] != "" && recent_files[0] != null) {
                    time_stamp.show_now();
                    populate (recent_files, max_results);
                }
            } catch (ThreadError e) {
                print (e.message);
            }
        });
    }

    private async string[] get_recent_files (string dest_path, int days) throws ThreadError {
      SourceFunc callback = get_recent_files.callback;
      string stdout = "";
      string stderr = "";
      int exit_st = 0;
      string[] files = {""};
      // Excluding hidden files and directories
      string find_cmd = "find "+dest_path+" -not -path '*/\\.*' -type f -ctime -" + days.to_string() +"";

      ThreadFunc<bool> run = () => {
          try {
            Process.spawn_command_line_sync (find_cmd, out stdout, out stderr, out exit_st);
            files = stdout.split("\n");
            // The last element has to be removed since it is null or empty.
            files = files[0:files.length-1];
            files_string_list = files;

          } catch (Error e) {
            print (e.message);
            return false;
          }

          Idle.add((owned)callback);
          return true;
        };

        new Thread<bool>("recent-files-search", run);
        yield;

        return files;
     }

    private void populate (string[] files, int max_results) {

        if (files != null && files[0] != "" && files[0] != null) {
            
            file_list.remove_all();
            file_list.append_from_list (files[0:max_results]);
            
            if(max_results < files.length) {
                file_list_current_last_index = max_results;
                more_results_btn.show_now();
            }

        } 
        
        show_all();
    }

    private void show_more_results() {
        int start = file_list_current_last_index;
        int end = (int)Math.fmin(start+max_results, files_string_list.length);

        print("end: "+end.to_string()+". Total: "+files_string_list.length.to_string());
        if(end == files_string_list.length) {
            less_results_btn.show_now();
            more_results_btn.hide();
        }
        if (start < files_string_list.length) {
            file_list.append_from_list(files_string_list[start:end]);
            file_list_current_last_index = end;
            file_list.show_all();
        }
    }

    private void show_less_results() {
        populate(files_string_list, max_results);
        less_results_btn.hide();
        more_results_btn.show_now();
    }
}
