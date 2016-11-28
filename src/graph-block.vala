using Gtk;

namespace Usage
{
    public class GraphBlock : Gtk.Grid
    {
        CookieGraph graph;
        GraphBlockRow application_row;
        GraphBlockRow others_row;
        GraphBlockRow available_row;
        Gtk.Label label;
        string block_name;

        class construct
        {
            set_css_name("GraphBlock");
        }

        public GraphBlock(string block_name, string app_name)
        {
            this.expand = true;
            this.block_name = block_name;
            label = new Gtk.Label("<span font_desc=\"11.0\"><b>" + block_name + "</b></span>");
            label.set_use_markup(true);
            this.attach(label, 0, 0, 1, 1);

            graph = new CookieGraph();
            graph.margin = 15;
            graph.height_request = 90;
            graph.width_request = 90;
            this.attach(graph, 0, 1, 1, 1);

            application_row = new GraphBlockRow(app_name, "used");
            others_row = new GraphBlockRow(_("Others"), "others");
            available_row = new GraphBlockRow(_("Available"), "available");

            Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.margin_left = 15;
            box.valign = Align.CENTER;
            box.pack_start(application_row, false, false);
            box.pack_start(others_row , false, false);
            box.pack_start(available_row, false, false);
            this.attach(box, 1, 1, 1, 1);
        }

        public void update(int processor_core, int application_percentages, int other_percentages)
        {
            if(processor_core != -1)
            {
                label.set_text("<span font_desc=\"11.0\"><b>" + block_name + " " + processor_core.to_string() + "</b></span>");
                label.use_markup = true;
            }

            graph.update(application_percentages, other_percentages);
            application_row.update(application_percentages);
            others_row.update(other_percentages-application_percentages);
            available_row.update(100-other_percentages);
        }
    }
}
