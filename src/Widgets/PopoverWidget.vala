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

using Gtk;

public class Dropbox.Widgets.PopoverWidget : Gtk.Grid {
  public signal void close_indicator ();
  public StatusIndicator status_indicator;
  public Wingpanel.Widgets.Switch theme_switch;
  public RecentFiles recent_files;
  public ServiceSwitcher service_switch;
  
  private SearchHeader search_header;
  private FileEntryList search_results;
  private Stack stack;
  private string dropbox_folder_path;
  private CssProvider css_provider;
  
  public PopoverWidget () {
    dropbox_folder_path = Dropbox.Services.Service.get_folder_path();
    set_orientation (Gtk.Orientation.VERTICAL);
    expand = true;
    
    css_provider = new CssProvider();
    css_provider.load_from_resource("io/elementary/wingpanel/dropbox/indicator.css");
    
    search_header = new SearchHeader();
    search_header.search_entry.search_changed.connect(on_search_changed);
    search_header.search_entry.stop_search.connect (on_search_stop);
    search_header.search_entry.key_press_event.connect(on_search_entry_key_press);

    search_results = new FileEntryList(null, dropbox_folder_path, IconSize.DND, false, 10);
    search_results.expand = true;
    search_results.can_focus = true;
    search_results.placeholder.label = "No Results!";
    search_results.activated.connect(on_file_activated);
    
    stack = new Stack();
    stack.halign = Align.FILL;
    stack.vexpand = true;
    stack.can_focus = true;
    stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
    
    Adjustment hadj = new Adjustment (300, 250, 300, 1, 1, 300);
    Adjustment hadj2 = new Adjustment (300, 150, 300, 1, 1, 300);
    
    Adjustment vadj2= new Adjustment (300, 150, 300, 0, 0, 300);
    Adjustment vadj= new Adjustment (300, 150, 300, 0, 0, 300);
    
    
    var scrolledWindow = new Gtk.ScrolledWindow(hadj, vadj);
    scrolledWindow.hscrollbar_policy = Gtk.PolicyType.NEVER;
    scrolledWindow.max_content_height = 500;
    scrolledWindow.propagate_natural_height = true;
    
    var scrolledWindowHome = new Gtk.ScrolledWindow(hadj2, vadj2);
    scrolledWindowHome.hscrollbar_policy = Gtk.PolicyType.NEVER;
    scrolledWindowHome.max_content_height = 500;
    scrolledWindowHome.propagate_natural_height = true;
    
    recent_files = new RecentFiles(dropbox_folder_path, 3);
    recent_files.halign = Align.FILL;
    recent_files.file_list.activated.connect(on_file_activated);
    
    scrolledWindowHome.add (recent_files);
    
    stack.add_named(scrolledWindowHome, "home");
    stack.add_named (scrolledWindow, "search");
  
    scrolledWindow.add(search_results);
    
    // The indicator widget at the bottom of the popover
    status_indicator = new StatusIndicator ("process-working-symbolic","...");
    status_indicator.width_request = 300;
    status_indicator.hexpand = true;
    status_indicator.margin = 6;
    
    service_switch = new ServiceSwitcher();
    service_switch.get_style_context().add_provider(css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    service_switch.get_style_context().add_class("container");
    service_switch.switcher.button_release_event.connect( () => {
        bool b = service_switch.switcher.state;
        print(b.to_string());
        if(!b) {
            Dropbox.Services.Service.exec_sync_command("dropbox start");
        } else {
            Dropbox.Services.Service.exec_sync_command("dropbox stop");
            
        };
        
        return false;
    });
    
    add(search_header);
    add (new Wingpanel.Widgets.Separator ());
    add (stack);
    add (new Wingpanel.Widgets.Separator ());
    add (service_switch);
    add (new Wingpanel.Widgets.Separator ());
    add(status_indicator);
    
  }
  
  // Performs an async search on the dropbox folder by using the FIND command
   private async string[] search (string path, string text) throws ThreadError {
        SourceFunc callback = search.callback;
        string stdout = "";
        string stderr = "";
        int exit_st = 0;
        string[] result = {""};
        string find_command = string.join("","find ",path," -not -path '*/\\.*' -iname *",text,"*");
        //string find_command = "find " + path + " -not -path '*/\\.*' -iname *"+text+"*";
        
        // We execute the find command on a new thread so we do not block the GUI.
        ThreadFunc<bool> run = () => {
            if(text != "" && text != null) {
              try {
                  search_header.spin_revealer.set_reveal_child (true);
                
                  GLib.Process.spawn_command_line_sync (find_command, out stdout, out stderr, out exit_st);
                  result = stdout.split("\n");
                  result = (result.length > 0) ? result[0:result.length-1] : result;
                  search_header.spin_revealer.set_reveal_child (false);
                  
              } catch (Error e) {
                print (e.message);
                return false;
              }
            }
            // We add our callback to the idle queue so the processor come back when it is idle
            Idle.add ((owned)callback);
            return true;
        };
        //execute the new thread
        new Thread<bool>("search-thread", run);
        // Free the processor
        yield;
        
       return result;
   }
   
   private async void on_search_changed () {
        string[] result = {};
        string search_string = search_header.search_entry.text;
        if(search_string == "") {
          stack.visible_child_name = "home";
        } else {
          if(" " in search_string) {
            search_string = "'"+search_header.search_entry.text+"'";
          }
          stack.visible_child_name = "search";
        }
        
        search.begin(dropbox_folder_path, search_string, (obj, res) => {
            try {
                result =  search.end(res); 
                print("Result:"+result.length.to_string());
                if(result[0] != "" && result.length > 0) {
                    // Removing old elements
                    search_results.remove_all();
                    search_results.populate (result);
                    search_results.show_all();
                } else {
                    search_results.remove_all();
                }
            } catch (ThreadError e) {
                print (e.message);
            }
        });
        
        
  
   }
   
   private void on_search_stop () {
    if(search_header.search_entry.text.length >0) {
        search_header.search_entry.text = "";
        search_results.remove_all ();
        stack.visible_child_name = "home";
    } else {
        close_indicator();
    }
   }
   
   
   public bool on_search_entry_key_press (Gdk.EventKey event) {
        var key = Gdk.keyval_name (event.keyval).replace ("KP_", "");

        switch (key) {
            case "Down":
                
                if(stack.visible_child_name == "search" && search_results.listbox.get_row_at_index(0) != null) {
                    search_results.listbox.get_row_at_index(0).grab_focus();
                } else if (stack.visible_child_name == "home" && recent_files.file_list.listbox.get_row_at_index(0) != null){
                    recent_files.file_list.listbox.get_row_at_index(0).grab_focus();
                }
                return Gdk.EVENT_STOP;

        }

        return Gdk.EVENT_PROPAGATE;
    }
    
    private void on_file_activated () {
        close_indicator();
    }
   
}

 
