using Gtk;

public class RecentFiles : Gtk.Grid {
    
    private FileMonitor recent_files_monitor;
    private FileEntryList file_list;
    private int time_day = 1;
    
    public string dir_path;
    
    public RecentFiles (string dest_path, int days) {
        dir_path = dest_path;
        time_day = days;
        orientation = Gtk.Orientation.VERTICAL;
        hexpand = true;
        
        File f = File.new_for_path(dest_path);
        try {
            recent_files_monitor = f.monitor_directory(FileMonitorFlags.NONE, null);
            recent_files_monitor.changed.connect (on_dropbox_folder_change);
        } catch (Error e) {
            print (e.message);
        }
        string[] recent_files = {""};
        
        get_recent_files.begin(dest_path, days, (obj, res) => {
            try {
                recent_files = get_recent_files.end(res);
                populate (recent_files);
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
    
    private void populate (string[] files) {
        CssProvider css_provider = new CssProvider();
        css_provider.load_from_resource("io/elementary/wingpanel/dropbox/indicator.css");


        Label time_stamp = new Gtk.Label("Recent activity");
        time_stamp.use_markup = true;
        time_stamp.set_markup ("<b>Recent activity </b>");
        time_stamp.halign = Gtk.Align.START;
        time_stamp.get_style_context().add_class("h3");
        time_stamp.margin_start = time_stamp.margin_bottom = 10;
        
        file_list = new FileEntryList(null,dir_path, IconSize.DND);
        file_list.halign = Align.FILL;
        file_list.expand = true;
        
        if (files != null && files[0] != "" && files[0] != null) {
            this.halign = this.valign = Align.FILL;
            
            this.foreach (child => {remove (child);});
            
            file_list.append_from_list (files);
            this.add (time_stamp);
            this.add(file_list);
            
        } else {
            this.foreach (child => {remove (child);});
            this.halign = this.valign = Align.CENTER;
            
            //Image peaceful_img = new Image.from_icon_name ("face-smile-symbolic", IconSize.DIALOG);
            //peaceful_img.pixel_size = 128;
            
            Label info = new Label("No activity");
            info.get_style_context().add_class (Granite.STYLE_CLASS_H2_LABEL);
            info.get_style_context().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
            info.get_style_context().add_class ("place_holder_large");
            info.get_style_context().add_provider(css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            
            this.add (info);
        }
        
        show_all();
    }
    
    private async void on_dropbox_folder_change (FileMonitor fmonitor, File src, File? dest, FileMonitorEvent event) {
            string[] files = {""};
            try {
                files = yield get_recent_files(this.dir_path, this.time_day);
                print (event.to_string()+"\n");
                populate (files);
            } catch (ThreadError e) {
                print (e.message);
            }
    }
    
}
