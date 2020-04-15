using Gtk;

public class StatusIndicator : Gtk.Grid {
    public Label label;
    public Image icon;
    public string[] icon_list = {"process-stop-symbolic", "process-stop-symbolic", "process-working-symbolic", "process-completed-symbolic"};
    
    public StatusIndicator (string? icon_name, string? text) {
       
        orientation = Gtk.Orientation.HORIZONTAL;

        label = new Gtk.Label(text);
        label.single_line_mode = true;
        label.lines = 0;
        label.ellipsize = Pango.EllipsizeMode.END;
        label.use_markup = true;
        label.max_width_chars = 25;
        label.set_valign (Gtk.Align.BASELINE);
        label.wrap = true;

        icon = new Gtk.Image.from_icon_name (icon_name,Gtk.IconSize.SMALL_TOOLBAR);
        icon.margin_end = 6;
        add(icon);
        add(label);
    }
    
    public void set_text (string text) {
      label.label = text;
    }
    
    public void set_icon_from_name (string name ) {
        icon.icon_name = name;
    }
}
