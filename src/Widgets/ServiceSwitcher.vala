public class ServiceSwitcher : Gtk.Grid {
    public Gtk.Switch switcher;
    
    public ServiceSwitcher() {
        orientation = Gtk.Orientation.HORIZONTAL;
        expand = true;
        
        var column_grid = new Gtk.Grid();
        var label = new Gtk.Label("Dropbox Service");
        label.margin_end = 150;
        
        switcher = new Gtk.Switch();
        
        column_grid.add(label);
        column_grid.add(switcher);
        
        add(column_grid);
    }
    
    public void state_set (bool state) {
       // switcher.active state;
        switcher.state = state;
    }
}
