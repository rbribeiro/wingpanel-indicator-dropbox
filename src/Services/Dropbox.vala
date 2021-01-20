/*
* Copyright (c) 2011-2018 Ivan Vilanculo (https://ivan.vilanculo.me)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not,see <http://www.gnu.org/licenses/>.
*
*/

public class Dropbox.Services.Service {
  public const int DROP_BOX_STATUS_UNKNOWN = -1;
  public const int DROP_BOX_STATUS_STOPPED = 0;
  public const int DROP_BOX_STATUS_SYNCING = 1;
  public const int DROP_BOX_STATUS_UPTODATE = 2;

  public Service () {}

  private string get_pid_file_path () {
    return GLib.Environment.get_home_dir () + "/.dropbox/dropbox.pid";
  }

  private string get_pid () {
    string pid;
    var pid_file = File.new_for_path(get_pid_file_path());
    if (!pid_file.query_exists ()) {
      return "";
    }
    try {
        FileInputStream @is = pid_file.read ();
        DataInputStream dis = new DataInputStream (@is);
        pid = dis.read_line ();
        return pid;
    } catch (Error e) {
      debug("Error " + e.message);
      return "";
    }
  }

  public bool is_dropbox_running () {
    var proc_file = File.new_for_path("/proc/" + get_pid() + "/cmdline");
    return proc_file.query_exists ();
  }


//  Return [FULL_STATUS, STATUS_INDEX]
public async string[] get_status () throws ThreadError {
    SourceFunc callback = get_status.callback;
    string dropbox_stdout = "";
    string dropbox_stderr = "";
    int dropbox_status = 0;
    int status = -1;
    string[] result = {"", ""};
    
    ThreadFunc<bool> run = () => {
        try {
          Process.spawn_command_line_sync ("dropbox status",
            out dropbox_stdout,
            out dropbox_stderr,
            out dropbox_status);
    
          dropbox_stdout = dropbox_stdout.split("\n")[0];
          
          switch (dropbox_stdout) {
            case "Up to date":
              status = DROP_BOX_STATUS_UPTODATE;
              break;
  
           case "Connecting...":
             status = DROP_BOX_STATUS_SYNCING;
             break;
  
           case "Starting...":
             status = DROP_BOX_STATUS_SYNCING;
             break;
  
           case "Checking for changes...":
             status = DROP_BOX_STATUS_SYNCING;
             break;
          }
  
          if (dropbox_stdout.has_prefix ("Syncing")) {
            status = DROP_BOX_STATUS_SYNCING;
          } else if (dropbox_stdout.has_prefix ("Indexing")) {
            status = DROP_BOX_STATUS_SYNCING;
          } else if (dropbox_stdout.has_prefix ("Uploading")) {
            status = DROP_BOX_STATUS_SYNCING;
          } else if (dropbox_stdout.has_prefix ("Downloading")) {
            status = DROP_BOX_STATUS_SYNCING;
          }
          
          result[0] = dropbox_stdout;
          result[1] = status.to_string();

        } catch (Error e) {
            print (e.message);
            result[0] = "Dropbox process not found...";
        }
        
        Idle.add((owned)callback);
        return true;
    };
    
    new Thread<bool>("status-thread", run);
    yield;
    
    return result;
}

   public static string? get_folder_path() {
       string home_dir = GLib.Environment.get_home_dir();
       File info_json = File.new_for_path(home_dir+"/.dropbox/info.json");

       if(info_json.query_exists()) {
           Json.Parser parser = new Json.Parser();
           try {
               parser.load_from_file (home_dir+"/.dropbox/info.json");
               Json.Node info_root_node = parser.get_root();
               Json.Object info_obj = info_root_node.get_object();
               Json.Node info_personal = info_obj.get_member("personal");
               
                string path = info_personal.get_object().get_member("path").get_string();
               
               return path;
               
           } catch (Error e) {
               print ("Error loading info.json: "+e.message);
               return home_dir;
           }
       } else {
           return home_dir;
       }
   }
   
   public static void exec_sync_command (string command) {
       //string dropbox_stdout, dropbox_stderr = "";
       //int dropbox_status = -1;
       try {
            Process.spawn_command_line_async (command);
      
       } catch (Error e) {
           print(e.message);
       }
   }
   
}


