using System;
using System.Collections.Generic;
using System.Threading;
using CorticalMetrics;
using NLog;
using NLog.Targets;
using NLog.Config;

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

        protected static List<CM_Wrapper> all_wrappers;

        private Logger logger;

        public bool is_busy { get; private set; }

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
            var config = new LoggingConfiguration();

            var fileTarget = new FileTarget();
            config.AddTarget("file", fileTarget);

            // Step 3. Set target properties 
            fileTarget.FileName = "C:/Users/thartmann/Documents/temp/file.txt";
            fileTarget.Layout = "${time}: ${message}";

            // Step 4. Define rules

            var rule2 = new LoggingRule("*", LogLevel.Debug, fileTarget);
            config.LoggingRules.Add(rule2);

            // Step 5. Activate the configuration
            LogManager.Configuration = config;

            // Example usage
            this.logger = LogManager.GetLogger("Example");
            
            this.stim_submitted = new EventWaitHandle(false, EventResetMode.AutoReset);
            this.inner_thread_done = new EventWaitHandle(false, EventResetMode.AutoReset);
            this.deinit_done = new EventWaitHandle(false, EventResetMode.AutoReset);
            this.should_stop = false;

            this.stimulator = stimulator;
            this.stimulator.Init(true);
            Thread.Sleep(2000);
            this.stimulator.UseInputTrigger = false;
            this.cur_stimchain = null;
            this.is_busy = false;

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
            Thread.Sleep(200);
        }

        public String test_string()
        {
            send_cm_event("Returning a string");
            logger.Debug("Hello!");
            return "Hello World";
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

        public void wait_for_stimulation()
        {
            if (!this.is_busy)
            {
                return;
            }

            this.inner_thread_done.WaitOne();
        }

        protected void Runner()
        {
            logger.Debug("Starting Runner");
            while (!this.should_stop)
            {
                logger.Debug("Waiting for stimuli\n\n");
                this.stim_submitted.WaitOne();
                if (this.cur_stimchain != null && !this.should_stop)
                {
                    logger.Debug("Now sending stimuli.");
                    this.is_busy = true;
                    stimulator.ChainedVibration(this.cur_stimchain);
                    this.is_busy = false;
                    logger.Debug("Done sending stimuli.");
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

        public event EventHandler CMEvent;

        protected void send_cm_event(String message)
        {
            var handler = this.CMEvent;
            if (handler != null)
            {
                handler(this, new CMEventArgs(message));
            }
        }
    }

    public class CMEventArgs : EventArgs
    {
        public readonly String message;

        public CMEventArgs(String message)
        {
            this.message = message;
        }
    }
}