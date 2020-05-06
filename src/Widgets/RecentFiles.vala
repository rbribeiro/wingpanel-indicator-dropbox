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
        
        
        file_list = new FileEntryList(null,dir_path, IconSize.DND, false, max_results);
        file_list.halign = Align.FILL;
        file_list.expand = true;
        file_list.placeholder.label = "No Activity";
          
        this.add(file_list);
        file_list.set_loading_state (true);
        
        get_recent_files.begin(dest_path, days, (obj, res) => {
            try {
                recent_files = get_recent_files.end(res);
                file_list.set_loading_state (false);
                
                if (recent_files != null && recent_files[0] != "" && recent_files[0] != null) {
                    file_list.populate (recent_files);
                    file_list.title.label = "Recent Activity";
                    file_list.title.show();
                }
            } catch (ThreadError e) {
                print (e.message);
            }
        });
        
        DirMonitor dir_monitor = new DirMonitor (dest_path, 500);
        dir_monitor.changed.connect ((f) => {
            print ("Refreshing the recent files. File changed:"+f.get_name());
            this.refresh();
        });
        
        dir_monitor.run();
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
            sort_files(files, 0, files.length-1);
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
     
     public void refresh() {
        string[] result = {""};
         get_recent_files.begin(dir_path, time_day, (obj, res) => {
             try {
                 result = get_recent_files.end(res);
                 if (result != null && result[0] != "" && result[0] != null) {
                     file_list.populate (result);
                     file_list.title.label = "Recent Activity";
                     file_list.title.show();
                 }
             } catch (ThreadError e) {
                 print ("Error refreshing: %s", e.message);
             }
         });
     }
     
     private void sort_files (string[] list, int lower_index, int higher_index) {
         int partition_index = 0;
         if(list != null && list.length > 0) {
         
             if (lower_index < higher_index) {
                 partition_index = partition (list, lower_index, higher_index);
                 
                 sort_files (list, lower_index, partition_index-1);
                 sort_files (list, partition_index+1, higher_index);
                 
             }
         }
         
         
     }
     
     private int partition (string[] list, int lower_index, int higher_index ) {
         string pivot = list[higher_index];
         int i = lower_index-1;
         
         for (int j = lower_index; j < higher_index; j++) {
             
             if (compare_modification_date (list[j], pivot)<= 0) {
                 i++;
                 string elementj = list[j];
                 string elementi = list[i];
                 
                 list[j] = elementi;
                 list[i] = elementj;
             }
         }
         
         list[higher_index] = list[i+1];
         list[i+1] = pivot;
         
         return (i+1);
     }
     
     // return -1 if mod_date path1 < mod_date path2
     private int compare_modification_date (string path1, string path2) {
         File file1 = File.new_for_path (path1);
         File file2 = File.new_for_path (path2);
         
         int result = 0;
         
         try {
             FileInfo info1 = file1.query_info ("*", 0);
             FileInfo info2 = file2.query_info ("*", 0);
             
             string t1_iso = info1.get_modification_time().to_iso8601();
             string t2_iso = info2.get_modification_time().to_iso8601();
             
             DateTime d1 = new DateTime.from_iso8601 (t1_iso, null);
             DateTime d2 = new DateTime.from_iso8601 (t2_iso, null);
             
             result = (-1)*d1.compare (d2);
             return result;
             
         } catch (Error e) {
             print (e.message);
             return result;
         }
     }
     
}
