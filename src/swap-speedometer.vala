/* swap-speedometer.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Felipe Borges <felipeborges@gnome.org>
 */

using Gtk;

namespace Usage
{
    [GtkTemplate (ui = "/org/gnome/Usage/ui/swap-speedometer.ui")]
    public class SwapSpeedometer : Gtk.Bin
    {
        [GtkChild]
        private Usage.Speedometer speedometer;

        [GtkChild]
        private Gtk.Label label;

        [GtkChild]
        private Gtk.Label swap_used;

        [GtkChild]
        private Gtk.Label swap_available;

        private double swap_usage { get; set; }

        construct {
            var monitor = SystemMonitor.get_default();
            Timeout.add_seconds(1, () => {
                var percentage = (((double) monitor.swap_usage / monitor.swap_total) * 100);

                this.speedometer.percentage = (int)percentage;
                label.label = "%d".printf((int)percentage) + "%";

                var available = (monitor.swap_total - monitor.swap_usage);

                swap_used.label = Utils.format_size_values(monitor.swap_usage);
                swap_available.label = Utils.format_size_values(available);

                return true;
            });

            this.show_all();
        }
    }
}