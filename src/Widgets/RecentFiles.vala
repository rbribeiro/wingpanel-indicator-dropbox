using Gtk;

public class RecentFiles : Gtk.Grid {

    private FileEntryList file_list;
    private string[] files_string_list;
    private int time_day = 1;
    private int max_results = 7;
    public string dir_path;

    public RecentFiles (string dest_path, int days) {
        dir_path = dest_path;
        time_day = days;
        orientation = Gtk.Orientation.VERTICAL;
        expand = true;

        string[] recent_files = {""};
        
        file_list = new FileEntryList(null,dir_path, IconSize.DND, true, max_results);
        file_list.halign = Align.FILL;
        file_list.expand = true;
        file_list.placeholder.label = "No Activity";
          
        this.add(file_list);
    
        get_recent_files.begin(dest_path, days, (obj, res) => {
            try {
                recent_files = get_recent_files.end(res);
                if (recent_files != null && recent_files[0] != "" && recent_files[0] != null) {
                    file_list.populate (recent_files);
                    file_list.title.label = "Recent Activity";
                    file_list.title.show();
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
            files = (files.length > 0) ? files[0:files.length-1]: files;
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
}
