using System;
using System.Threading;
using System.Collections.Generic;
using CorticalMetrics;

namespace CMTest01
{
    internal class Program
    {
        public static void Main(string[] args)
        {
            Console.WriteLine("Hello");

            CM5 stimulator = new CM5();
            stimulator.Init(true);
            stimulator.UseInputTrigger = false;

            QuadStimulusChain stim_chain = new QuadStimulusChain();
            Stimulus stim = new Stimulus(200, 10, 1000);

            stim_chain.CH3.Add(new StimulusLink(stim));

            stimulator.ChainedVibration(stim_chain);
            Console.WriteLine("I have submitted the stimulus. It is now waiting for the trigger");
            Console.WriteLine("I am now going to sleep for 1 seconds and then submit another stimulus...");
            Thread.Sleep(1 * 1000);
            stim_chain = new QuadStimulusChain();
            stim = new Stimulus(200, 20, 1000);

            stim_chain.CH2.Add(new StimulusLink(stim));
            stimulator.ChainedVibration(stim_chain);

            Console.WriteLine("I am now going to sleep for 10 seconds to let you examine the result...");
            Thread.Sleep(10 * 1000);
            Console.WriteLine("So, did you feel something?");
            return;
        }
    }
}