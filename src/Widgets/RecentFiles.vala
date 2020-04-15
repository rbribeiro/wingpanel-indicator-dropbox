using Gtk;

public class RecentFiles : Gtk.Grid {
    
    public RecentFiles () {
      orientation = Gtk.Orientation.VERTICAL;
      expand = true;
      Label time_stamp = new Gtk.Label("Last 7 days");
      time_stamp.use_markup = true;
      time_stamp.set_markup ("<b>Last 7 days </b>");
      time_stamp.halign = Gtk.Align.START;
      time_stamp.get_style_context().add_class("h3");
      time_stamp.margin_start = time_stamp.margin_bottom = 10;
      
      FileEntryList file_list = new FileEntryList(null, IconSize.DND);
      file_list.hexpand = true;
      
      string[] recent_files = get_recent_files(14);
      
      if (recent_files != null && recent_files[0] != "" && recent_files[0] != null) {
          halign = valign = Align.START;
          
          this.foreach (child => {remove (child);});
          
          file_list.append_from_list (recent_files);
          add (time_stamp);
          add(file_list);
          
      } else {
          this.foreach (child => {remove (child);});
          halign = valign = Align.CENTER;
          
          Image peaceful_img = new Image.from_icon_name ("face-smile-symbolic", IconSize.DIALOG);
          peaceful_img.pixel_size = 128;
          
          Label peaceful_text = new Label ("");
          peaceful_text.use_markup = true;
          peaceful_text.set_markup ("<b>It has been quite peaceful here!</b>");
          
          Label info = new Label("No activity in the past 7 days.");
          
          add (peaceful_img);
          add (peaceful_text);
          add (info);
      }
    }
    
    private string[] get_recent_files (int days) {
      string[] files = {""};
      string dropbox_folder = Dropbox.Services.Service.get_folder_path();
      string find_cmd = "find "+dropbox_folder+" -iname *.* -ctime -" + days.to_string() +"";
      
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
    
}
