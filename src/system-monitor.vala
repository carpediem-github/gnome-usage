using Posix;

namespace Usage
{
    [Compact]
    public class Process
    {
        internal pid_t pid;
        internal string cmdline;
        internal double cpu_load;
        internal double x_cpu_load;
        internal uint64 cpu_last_used;
        internal uint64 x_cpu_last_used;
        internal uint last_processor;
        internal double mem_usage;

        internal bool alive;
    }

    public class SystemMonitor
    {
        public double cpu_load { get; private set; }
        public double[] x_cpu_load { get; private set; }
        public double mem_usage { get; private set; }
        public double swap_usage { get; private set; }

        uint64 cpu_last_used = 0;
        uint64 cpu_last_total = 0;

        uint64[] x_cpu_last_used;
        uint64[] x_cpu_last_total;

        bool change_timeout = false;

        HashTable<pid_t?, Process> process_table;

		private int process_mode = GTop.KERN_PROC_UID;

		public enum ProcessMode
        {
		    ALL,
  			USER,
  			EXCLUDE_IDLE
		}

		public void set_process_mode(ProcessMode mode)
        {
		    switch(mode)
  			{
        		case ProcessMode.ALL:
					process_mode = GTop.KERN_PROC_ALL;
					break;
				case ProcessMode.USER:
					process_mode = GTop.KERN_PROC_UID;
					break;
				case ProcessMode.EXCLUDE_IDLE:
					process_mode = GTop.EXCLUDE_IDLE;
					break;
			  }
		}

		private string get_full_process_cmd (string cmd, string[] args)
        {
            var secure_arguments = new string[2];

            for(int i = 0; i < 2; i++)
            {
                if(args[i] != null)
                {
                    secure_arguments[i] = args[i];
                    for (int j = 0; j < args[i].length; j++)
                    {
                        if(args[i][j] == ' ')
                            secure_arguments[i] = args[i].substring(0, j);
                    }
                }
                else
                    secure_arguments[i] = "";
            }

            for (int i = 0; i < secure_arguments.length; i++)
            {
                var name = Path.get_basename(secure_arguments[i]);

                if (name.has_prefix(cmd))
                {
                    for (int j = 0; j < name.length; j++)
                    {
                        if(name[j] == ' ')
                            name = name.substring(0, j);
                    }

                    return name;
                }
            }

            return cmd;
        }

		public bool update_data()
        {
		    /* CPU */
            GTop.Cpu cpu_data;
            GTop.get_cpu (out cpu_data);
            var used = cpu_data.user + cpu_data.nice + cpu_data.sys;
            cpu_load = (((double) (used - cpu_last_used)) / (cpu_data.total - cpu_last_total)) * 100;

            var x_cpu_used = new uint64[get_num_processors()];
            for (int i = 0; i < x_cpu_load.length; i++)
            {
                x_cpu_used[i] = cpu_data.xcpu_user[i] + cpu_data.xcpu_nice[i] + cpu_data.xcpu_sys[i];
                x_cpu_load[i] = (((double) (x_cpu_used[i] - x_cpu_last_used[i])) / (cpu_data.xcpu_total[i] - x_cpu_last_total[i])) * 100;
            }

            /* Memory */
            GTop.Mem mem;
            GTop.get_mem (out mem);
            mem_usage = (((double) (mem.used - mem.buffer - mem.cached)) / mem.total) * 100;

            /* Swap */
            GTop.Swap swap;
            GTop.get_swap (out swap);
            swap_usage = (double) swap.used / swap.total;

            foreach (unowned Process process in process_table.get_values())
            	process.alive = false;

            var uid = Posix.getuid();
            GTop.Proclist proclist;
            var pids = GTop.get_proclist (out proclist, process_mode, uid);

            for(int i = 0; i < proclist.number; i++)
            {
                GTop.ProcState proc_state;
                GTop.ProcTime proc_time;
                GTop.ProcArgs proc_args;
                GTop.get_proc_state (out proc_state, pids[i]);
                GTop.get_proc_time (out proc_time, pids[i]);
                var arguments = GTop.get_proc_argv (out proc_args, pids[i]);

                if (!(pids[i] in process_table))
                {
                    var process = new Process();
                    process.pid = pids[i];
                    process.alive = true;
                    process.cmdline = get_full_process_cmd ((string) proc_state.cmd, arguments);
                    process.last_processor = proc_state.last_processor;
                    process.cpu_load = 0;
                    process.x_cpu_load = 0;
                    process.cpu_last_used = proc_time.rtime;
                    process.x_cpu_last_used = (proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]);
                    process.mem_usage = 0;
                    process_table.insert (pids[i], (owned) process);
                }
                else
                {
                    unowned Process process = process_table[pids[i]];
                    process.last_processor = proc_state.last_processor;
                    process.cpu_load = (((double) (proc_time.rtime - process.cpu_last_used)) / (cpu_data.total - cpu_last_total)) * 100 * get_num_processors(); //TODO After fix bug bellow remove: * get_num_processors()
                    process.x_cpu_load = (((double) ((proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]) - process.x_cpu_last_used)) / (cpu_data.xcpu_total[process.last_processor] - x_cpu_last_total[process.last_processor])) * 100;
                    //FIX ME: It is always 0, libGTop bug propably
                    //GLib.stdout.printf("X_cpu: " + process.last_processor.to_string() + " " + (proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]).to_string() + "\n");
                    process.alive = true;
                    process.cpu_last_used = proc_time.rtime;
                    process.x_cpu_last_used = (proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]);

                    GTop.ProcMem proc_mem;
                    GTop.get_proc_mem (out proc_mem, process.pid);
                    process.mem_usage = ((double) (proc_mem.resident - proc_mem.share) / mem.total) * 100;
                }
            }

            foreach(unowned Process process in process_table.get_values())
            {
                if (process.alive == false)
                    process_table.remove (process.pid);
            }

            cpu_last_used = used;
            cpu_last_total = cpu_data.total;

            x_cpu_last_used = x_cpu_used;
            x_cpu_last_total = cpu_data.xcpu_total;

            if(change_timeout)
            {
                change_timeout = false;
                Timeout.add((GLib.Application.get_default() as Application).settings.list_update_interval, update_data);
                return false;
            }

            return true;
        }

        public List<unowned Process> get_processes()
        {
            return process_table.get_values();
        }

        public unowned Process get_data_for_pid(pid_t pid)
        {
            return process_table.get(pid);
        }

        public SystemMonitor()
        {
            GTop.init();

            x_cpu_load = new double[get_num_processors()];
            x_cpu_last_used = new uint64[get_num_processors()];
            x_cpu_last_total = new uint64[get_num_processors()];
            process_table = new HashTable<pid_t?, Process>(int_hash, int_equal);

            var settings = (GLib.Application.get_default() as Application).settings;

            settings.notify.connect(() => {
                change_timeout = true;
            });

            Timeout.add(settings.list_update_interval, update_data);
            update_data();
            Timeout.add(settings.first_update_interval, () => //First load
            {
                update_data();
                return false;
            });
        }
    }
}
