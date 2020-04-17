using Gtk;

public class FileEntryList : Gtk.ListBox {
    
    public string[] file_path_list;
    private IconSize icon_size = IconSize.SMALL_TOOLBAR;
    private string root_path_ignored;
    
    public FileEntryList(string[]? path_list, string? root_path, IconSize? iconsize) {
        icon_size = (iconsize != null) ? iconsize : icon_size;
        root_path_ignored = root_path;
        activate_on_single_click = false;
        row_activated.connect(double_click);
        append_from_list (path_list);
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
      this.foreach(row => {this.remove(row);});
    }
    
    public void append_from_list (string[] path_list) {
      if(path_list != null) {
          foreach (string path in path_list) {
            if(path != "") {
              FileEntry file = new FileEntry(path, root_path_ignored, icon_size);
              file.has_tooltip = true;
              add(file);
            }
          } 
      }
    }
    


}
