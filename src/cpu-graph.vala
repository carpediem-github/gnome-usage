using Rg;

namespace Usage {

    public class CpuGraph : Rg.Graph {

        static string[] colors = {
          "#73d216",
          "#f57900",
          "#3465a4",
          "#ef2929",
          "#75507b",
          "#ce5c00",
          "#c17d11",
          "#ce5c00",
        };

		private static CpuGraphTable table;

        public CpuGraph (int64 timespan, int64 max_samples)
        {
            if(table == null)
            {
                table = new CpuGraphTable(30000, 60);
                set_table(table);
            }
            else
                set_table(table);

            for(int i = 0; i < get_num_processors(); i++)
            {
                LineRenderer renderer = new LineRenderer();
                renderer.column = i;
                renderer.stroke_color = colors [i % colors.length];
                add_renderer(renderer);
            }
        }
    }
}