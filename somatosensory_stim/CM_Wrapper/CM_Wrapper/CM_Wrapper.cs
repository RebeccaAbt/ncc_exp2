using System;
using System.Collections.Generic;
using System.Threading;
using CorticalMetrics;

namespace th_CM
{
    public class CM_Wrapper
    {
        protected EventWaitHandle stim_submitted;
        protected EventWaitHandle inner_thread_done;
        protected EventWaitHandle deinit_done;
        protected CM5 stimulator;

        protected QuadStimulusChain cur_stimchain;
        protected bool should_stop;

        protected static List<CM_Wrapper> all_wrappers = null;

        public static CM_Wrapper[] GetAllStimulators()
        {
            if (all_wrappers == null)
            {
                CM5[] all_cms = CM5.AllStims();
                all_wrappers = new List<CM_Wrapper>(all_cms.Length);

                foreach (var cur_cm in all_cms)
                {
                    all_wrappers.Add(new CM_Wrapper(cur_cm));
                }
            }
            return all_wrappers.ToArray();
        }

        public static String[] GetSerialNumbers()
        {
            var all_serials = new List<String>();
            var already_initialized = all_wrappers != null;
            foreach (var cur_stim in GetAllStimulators())
            {
                all_serials.Add(cur_stim.SerialNumber);
            }

            if (!already_initialized)
            {
                ResetAll();
            }
            
            return all_serials.ToArray();
        }

        public static void ResetAll()
        {
            if (all_wrappers != null)
            {
                foreach (var cur_wrapper in all_wrappers)
                {
                    cur_wrapper?.DeInit();
                }
            }
            all_wrappers?.Clear();
            CM_Wrapper.all_wrappers = null;
        }

        private CM_Wrapper(CM5 stimulator)
        {
            this.stim_submitted = new EventWaitHandle(false, EventResetMode.AutoReset);
            this.inner_thread_done = new EventWaitHandle(false, EventResetMode.AutoReset);
            this.deinit_done = new EventWaitHandle(false, EventResetMode.AutoReset);
            this.should_stop = false;

            this.stimulator = stimulator;
            this.stimulator.Init(true);
            Thread.Sleep(2000);
            this.stimulator.UseInputTrigger = false;
            this.cur_stimchain = null;

            Thread cm_wrapper_thread = new Thread(this.Runner);
            cm_wrapper_thread.Start();
        }

        ~CM_Wrapper()
        {
            if (this.stimulator != null)
            {
                this.stimulator.DeInit();
                this.stimulator = null;
            }
        }

        public bool UseInputTrigger
        {
            get { return this.stimulator.UseInputTrigger; }
            set { this.stimulator.UseInputTrigger = value; }
        }

        public String SerialNumber
        {
            get { return this.stimulator.SerialNumber; }
        }

        public void SubmitStimulus(QuadStimulusChain stim)
        {
            if (this.stimulator == null)
            {
                throw new InvalidOperationException("This stimulator has been deinitialized");
            }

            if (this.cur_stimchain != null)
            {
                this.cur_stimchain = null;
                this.stimulator.StopVibration();
                this.inner_thread_done.WaitOne();
            }

            this.cur_stimchain = stim;
            this.stim_submitted.Set();
        }

        public void Reset()
        {
            if (this.stimulator == null)
            {
                throw new InvalidOperationException("This stimulator has been deinitialized");
            }

            if (this.cur_stimchain != null)
            {
                this.cur_stimchain = null;
                this.stimulator.StopVibration();
                this.inner_thread_done.WaitOne();
            }
        }

        public void DeInit()
        {
            this.should_stop = true;
            this.cur_stimchain = null;
            this.stimulator?.StopVibration();
            this.stim_submitted.Set();
            this.deinit_done.WaitOne();
        }

        protected void Runner()
        {
            while (!this.should_stop)
            {
                this.stim_submitted.WaitOne();
                if (this.cur_stimchain != null && !this.should_stop)
                {
                    stimulator.ChainedVibration(this.cur_stimchain);
                    this.cur_stimchain = null;
                }
                this.inner_thread_done.Set();
            }

            this.stimulator.StopVibration();
            this.stim_submitted.Set();
            this.stimulator.DeInit();
            this.stimulator = null;
            this.deinit_done.Set();
        }
    }
}