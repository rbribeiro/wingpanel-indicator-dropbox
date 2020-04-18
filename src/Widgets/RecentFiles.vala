using Gtk;

public class RecentFiles : Gtk.Grid {
    
    private FileMonitor recent_files_monitor;
    private FileEntryList file_list;
    
    public string dir_path;
    
    public RecentFiles (string path, int days) {
        dir_path = path;
        orientation = Gtk.Orientation.VERTICAL;
        expand = true;
        
        File f = File.new_for_path(path);
        try {
            recent_files_monitor = f.monitor_directory(FileMonitorFlags.NONE, null);
            recent_files_monitor.changed.connect ((src, dest, event) => {
            populate (get_recent_files(path, 3));
            });
        } catch (Error e) {
            print (e.message);
        }
        string[] recent_files = get_recent_files(path, 3);
        populate (recent_files);
    }
    
    private string[] get_recent_files (string path, int days) {
      string[] files = {""};
      // Excluding hidden files and directories
      string find_cmd = "find "+path+" -not -path '*/\\.*' -type f -ctime -" + days.to_string() +"";
      
      try {
        string res, err;
        int ext;
        Process.spawn_command_line_sync (find_cmd, out res, out err, out ext);
        files = res.split("\n");
        return files;
      } catch (Error e) {
        print (e.message);
        return files;
      }
      
    }
    
    private void populate (string[] files) {
        Label time_stamp = new Gtk.Label("Recent activity");
        time_stamp.use_markup = true;
        time_stamp.set_markup ("<b>Recent activity </b>");
        time_stamp.halign = Gtk.Align.START;
        time_stamp.get_style_context().add_class("h3");
        time_stamp.margin_start = time_stamp.margin_bottom = 10;
        
        file_list = new FileEntryList(null,dir_path, IconSize.DND);
        
        if (files != null && files[0] != "" && files[0] != null) {
            this.halign = this.valign = Align.START;
            
            this.foreach (child => {remove (child);});
            
            file_list.append_from_list (files);
            this.add (time_stamp);
            this.add(file_list);
            
        } else {
            this.foreach (child => {remove (child);});
            this.halign = this.valign = Align.CENTER;
            
            Image peaceful_img = new Image.from_icon_name ("face-smile-symbolic", IconSize.DIALOG);
            peaceful_img.pixel_size = 128;
            
            Label peaceful_text = new Label ("");
            peaceful_text.use_markup = true;
            peaceful_text.set_markup ("<b>It has been quite peaceful here!</b>");
            
            Label info = new Label("No activity in the past 7 days.");
            
            this.add (peaceful_img);
            this.add (peaceful_text);
            this.add (info);
        }
    }
    
}
