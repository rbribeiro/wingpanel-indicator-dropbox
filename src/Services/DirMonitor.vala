using Gtk;

public class DirMonitor : GLib.Object {
    
    public int time_interval;
    public string path;
    public signal void changed (FileInfo file_info);
    
    private bool is_working;
    private DateTime last_check_date;
    
    public DirMonitor (string dir_path, int interval) {
        path = dir_path;
        time_interval = interval;
        last_check_date = new DateTime.now_local ();
        is_working = false;
    }
    
    public void run () {
        GLib.Timeout.add (time_interval, timeout_func, Priority.DEFAULT_IDLE);
    }
    
    private bool timeout_func () {
        core.begin ();
        return true;
    }
    
    private async bool core () throws ThreadError {
        // Do not create a new Thread if there is another
        if (is_working == false) {
            is_working = true;
            SourceFunc callback = core.callback;
            
            ThreadFunc<bool> run = () => {
                File dir_root = File.new_for_path (path);
                try {
                    FileInfo info = dir_root.query_info ("*", 0);
                    string iso = info.get_modification_time().to_iso8601();
                    GLib.DateTime file_modification_date = new GLib.DateTime.from_iso8601 (iso, null);
                    
                    // Check if the root dir has changed
                    if (last_check_date.compare (file_modification_date) == -1) {
                        is_working = false;
                        changed (info);
                    } else {
                        compare_modification_date (path, last_check_date);
                        is_working = false;
                    }
                    
                    last_check_date = new DateTime.now_local ();
                    Idle.add ((owned)callback);
                    
                    return true;
                    
                } catch (Error e) {
                    print ("Error getting info: %s",e.message);
                    return false;
                }
    
            };
            
            new Thread<bool>("compare-dir", run);
            yield;
        }
        
        return true;
    }
    
    private void compare_modification_date (string dir_path, GLib.DateTime d) {
        File dir = File.new_for_path (dir_path);
        //
            try {
                FileEnumerator files = dir.enumerate_children("*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
                FileInfo info = files.next_file (null);
                while(info != null) {
                   /* if (info.get_file_type () == FileType.REGULAR) {
                        string iso = info.get_modification_time().to_iso8601();
                        GLib.DateTime file_modification_date = new GLib.DateTime.from_iso8601 (iso, null);
                        
                        if (d.compare(file_modification_date) == -1) {
                            changed (info);
                            break;
                        } else {
                            info = files.next_file (null);
                        }
                        
                    } else */
                    if(info.get_file_type() == FileType.DIRECTORY && !info.get_name().has_prefix(".") ) {
                         string iso = info.get_modification_time().to_iso8601();
                         GLib.DateTime file_modification_date = new GLib.DateTime.from_iso8601 (iso, null);
                         
                         if (d.compare(file_modification_date) == -1) {
                             print ("The dir %s has been modified.", info.get_name());
                             changed (info);
                             break;
                         } else {
                             compare_modification_date(dir_path+"/"+info.get_name(), d);
                             info =files.next_file (null);
                         }
                     } else {
                         info = files.next_file(null);
                     }
                }
            } catch (Error e) {
                print ("Error comparing dates:%s", e.message);
            }
     }
    
}
