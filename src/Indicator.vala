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

public class Dropbox.Indicator : Wingpanel.Indicator {
  private Wingpanel.Widgets.OverlayIcon? indicator_icon = null;
  private Dropbox.Widgets.PopoverWidget? popover_wigdet = null;
  private Dropbox.Services.Service service = null;
  private string dropbox_full_status = "Waiting...";
  private int dropbox_status = -1;

  public Indicator (Wingpanel.IndicatorManager.ServerType server_type) {
    Object (
      code_name: "wingpanel-indicator-dropbox",
      display_name: _("Dropbox"),
      description: _("The dropbox indicator")
    );
  }

  construct {
    visible = true;
    service = new Dropbox.Services.Service ();
    GLib.Timeout.add(2000, update, Priority.DEFAULT_IDLE);

  }

  public override Gtk.Widget get_display_widget () {
    if (indicator_icon == null) {
      indicator_icon = new Wingpanel.Widgets.OverlayIcon ("dropboxstatus-symbolic");
    }
    indicator_icon.button_press_event.connect ((e) => {
      // todo change
      return Gdk.EVENT_PROPAGATE;
    });
    return indicator_icon;
  }

  public override Gtk.Widget? get_widget () {
    // todo implement
    if (popover_wigdet == null) {
      popover_wigdet = new Dropbox.Widgets.PopoverWidget ();
      popover_wigdet.status_indicator.set_text (dropbox_full_status);
      
    }
    return popover_wigdet;
  }

    public override void opened () {}

    public override void closed () {}

    private void set_status (string[] status) {
        string indicator_icon_name = "dropboxstatus-stopped-symbolic";
        string popover_icon_name = "process-stop-symbolic";
        
        if (indicator_icon != null) {
            if(popover_wigdet != null) {
                popover_wigdet.status_indicator.set_text (status[0]);
                popover_icon_name = popover_wigdet.status_indicator.icon_list[int.parse(status[1])+1];
                popover_wigdet.status_indicator.set_icon_from_name(popover_icon_name);
            }
            
        switch (int.parse(status[1])) {
          case Dropbox.Services.Service.DROP_BOX_STATUS_UNKNOWN:
            indicator_icon_name = "dropboxstatus-stopped-symbolic";
            break;

          case Dropbox.Services.Service.DROP_BOX_STATUS_STOPPED:
            indicator_icon_name = "dropboxstatus-stopped-symbolic";
            break;

          case Dropbox.Services.Service.DROP_BOX_STATUS_SYNCING:
            indicator_icon_name = "dropboxstatus-busy-symbolic";
            break;

          case Dropbox.Services.Service.DROP_BOX_STATUS_UPTODATE:
            indicator_icon_name = "dropboxstatus-idle-symbolic";
            break;
        }
        indicator_icon.set_main_icon_name (indicator_icon_name);

        }
    }
    
    public bool update () {
    string[] sts = {"", ""};
  
    service.get_status.begin((obj, res) => {
          try {
                sts = service.get_status.end(res);
                if(dropbox_full_status != sts[0]) {
                    // refreshing the list of recent files
                    if (dropbox_full_status == "Up to date" && popover_wigdet != null) {
                        popover_wigdet.recent_files.refresh();
                    }
                    dropbox_full_status = sts[0];
                    set_status (sts);
                }
                
          } catch (ThreadError e) {
              print(e.message);
          }
      });
  
    return true;
    }
}

/*
 * This method is called once after your plugin has been loaded.
 * Create and return your indicator here if it should be displayed on the current server.
 */
public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    /* A small message for debugging reasons */
    debug ("Activating Sample Indicator");

    /* Check which server has loaded the plugin */
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        /* We want to display our sample indicator only in the "normal" session, not on the login screen, so stop here! */
        return null;
    }

    /* Create the indicator */
    var indicator = new Dropbox.Indicator (server_type);

    /* Return the newly created indicator */
    return indicator;
}
