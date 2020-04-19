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
  private string dropbox_folder_path;
  private CssProvider css_provider;
  
  public PopoverWidget () {
    dropbox_folder_path = Dropbox.Services.Service.get_folder_path();
    set_orientation (Gtk.Orientation.VERTICAL);
    width_request = 200;
    expand = true;
    
    css_provider = new CssProvider();
    css_provider.load_from_resource("io/elementary/wingpanel/dropbox/indicator.css");
    
    search_header = new SearchHeader();
    search_header.search_entry.search_changed.connect(on_search_changed);
    search_header.search_entry.grab_focus.connect(on_grab_focus);
    search_header.search_entry.stop_search.connect (on_search_stop);

    search_results = new FileEntryList(null, dropbox_folder_path, IconSize.DND);
    search_results.expand = true;
    search_results.can_focus = true;
    
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
    
    RecentFiles recent_files = new RecentFiles(dropbox_folder_path, 0);
    recent_files.halign = Align.FILL;
    
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
  
  // Performs an async search on the dropbox folder by using the FIND command
   private async string[] search (string path, string text) throws ThreadError {
        SourceFunc callback = search.callback;
        string stdout = "";
        string stderr = "";
        int exit_st = 0;
        string[] result = {""};
        string find_command = "find " + path + " -not -path '*/\\.*' -iname *"+text+"*";

        ThreadFunc<bool> run = () => {
            if(text != "" && text != null) {
              try {
                  GLib.Process.spawn_command_line_sync (find_command, out stdout, out stderr, out exit_st);
                  result = stdout.split("\n");
              } catch (Error e) {
                print (e.message);
                return false;
              }
            }
            Idle.add ((owned)callback);
            return true;
        };
        
        new Thread<bool>("search-thread", run);
        yield;
        
       return result;
   }
   
   private async void on_search_changed () {
        string[] result = {};
        string search_string = search_header.search_entry.text;
        if(search_header.search_entry.text == "") {
          stack.visible_child_name = "home";
        } else {
          if(" " in search_header.search_entry.text) {
            search_string = "'"+search_header.search_entry.text+"'";
          }
          stack.visible_child_name = "search";
        }
        
        try {
            result = yield search(dropbox_folder_path, search_string);
        } catch (ThreadError e) {
            print (e.message);
        }
        
        // Removing old elements
        search_results.remove_all();
        if (result == null || result[0] == null) {
          var l = new Gtk.Label ("Nothing found!");
          l.get_style_context().add_class (Granite.STYLE_CLASS_H2_LABEL);
          l.get_style_context().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
          l.get_style_context().add_class ("place_holder_large");
          l.get_style_context().add_provider(css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
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
   
   private void on_grab_focus () {
       //stack.visible_child_name = "search";
   }
}
