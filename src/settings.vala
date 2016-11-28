using Gtk;

namespace Usage {

    public class Settings : Object
    {
        public uint graph_timespan { get; set; default = 15000;}
        public uint graph_max_samples { get; set; default = 20; }
        public uint graph_update_interval { get { return 1000; }}
        public uint list_update_interval_UI { get; set; default = 5000; }
        public uint list_update_cookie_graphs_UI { get; set; default = 1000; }
        public uint list_update_interval { get; set; default = 1000; }
        public uint first_update_interval { get; set; default = 500; }
    }
}
