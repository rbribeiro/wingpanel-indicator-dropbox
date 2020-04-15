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
  public StatusIndicator status_indicator;
  public Wingpanel.Widgets.Switch theme_switch;
  
  private SearchHeader search_header;
  private FileEntryList search_results;
  private Stack stack;
  
  public PopoverWidget () {
  
    set_orientation (Gtk.Orientation.VERTICAL);
    width_request = 200;
    expand = true;
    
    var css_provider = new CssProvider();
    css_provider.load_from_resource("io/elementary/wingpanel/dropbox/indicator.css");
    
    search_header = new SearchHeader();
    search_header.search_entry.search_changed.connect(on_search_changed);
    search_header.search_entry.stop_search.connect (on_search_stop);

    search_results = new FileEntryList(null, IconSize.DND);
    search_results.expand = true;
    search_results.can_focus = true;
    
    stack = new Stack();
    stack.expand = true;
    stack.can_focus = true;
    stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
    
    Adjustment hadj = new Adjustment (300, 250, 300, 1, 1, 300);
    Adjustment hadj2 = new Adjustment (300, 250, 300, 1, 1, 300);
    
    Adjustment vadj = new Adjustment (350, 250, 350, 1, 1, 350);
    Adjustment vadj2= new Adjustment (350, 250, 350, 1, 1, 350);
    
    var scrolledWindow = new Gtk.ScrolledWindow(hadj, vadj);
    scrolledWindow.hscrollbar_policy = Gtk.PolicyType.NEVER;
    scrolledWindow.min_content_height = 350;
    
    var scrolledWindowHome = new Gtk.ScrolledWindow(hadj2, vadj2);
    scrolledWindowHome.hscrollbar_policy = Gtk.PolicyType.NEVER;
    //scrolledWindowHome.min_content_height = 300;
    
    RecentFiles recent_files = new RecentFiles();
    scrolledWindowHome.add (recent_files);
    
    stack.add_named(scrolledWindowHome, "home");
    stack.add_named (scrolledWindow, "search");
  
    scrolledWindow.add(search_results);
    
    // The indicator widget at the bottom of the popover
    status_indicator = new StatusIndicator ("process-working-symbolic","...");
    status_indicator.width_request = 300;
    status_indicator.hexpand = true;
    status_indicator.margin = 6;
    
    add(search_header);
    add (new Wingpanel.Widgets.Separator ());
    add (stack);
    add (new Wingpanel.Widgets.Separator ());
    add(status_indicator);
    
  }
  
  // Performs a search on the dropbox folder by using the FIND command
   private string[] search_exec (string path, string text) {
        string out_res, err_msg;
        string[] result = null;
        int exit_st;
        
        if(text != "" && text != null) {
          try {
            string find_command = "find " + path + " -iname *"+text+"*";
              GLib.Process.spawn_command_line_sync (find_command, out out_res, out err_msg, out exit_st);
              result = out_res.split("\n");
          } catch (Error e) {
            print (e.message);
            return result;
          }
        }
        
       return result;
   }
   
   private void on_search_changed () {
        string[] result = {};
        string search_string = search_header.search_entry.text;
        string dropbox_folder = Dropbox.Services.Service.get_folder_path();
        if(search_header.search_entry.text == "") {
          stack.visible_child_name = "home";
        } else {
          if(" " in search_header.search_entry.text) {
            search_string = "'"+search_header.search_entry.text+"'";
          }
          stack.visible_child_name = "search";
        }
        // Removing old elements
        search_results.remove_all();
        result = search_exec(dropbox_folder, search_string);
        
        if (result == null || result[0] == null) {
          var l = new Gtk.Label ("Nothing found!");
          search_results.add (l);
          search_results.get_row_at_index (0).selectable = false;
          search_results.show_all();
        } else {
          search_results.append_from_list (result);
          search_results.show_all();
        }
   }
   
   private void on_search_stop () {
     search_header.search_entry.text = "";
     search_results.remove_all ();
     stack.visible_child_name = "home";
     stack.has_focus = true;
   }
   
}
