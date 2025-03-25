using System;
using System.Collections.Generic;
using System.Threading;
using CorticalMetrics;
using th_CM;

namespace Test_Wrapper
{
    internal class Program
    {
        public static void Main(string[] args)
        {
            CM_Wrapper[] all_stims = CM_Wrapper.GetAllStimulators();

            Stimulus stim = new Stimulus(200, 10, 1000);
            for (double indent = 0; indent < 100; indent += 10)
            {
                stim.Indent = indent;
                QuadStimulusChain stim_chain = new QuadStimulusChain();
                stim_chain.CH4.Add(new StimulusLink(stim));
                
                Console.WriteLine("Now stimulting with indent: {0}", indent);
                all_stims[0].SubmitStimulus(stim_chain);
                Thread.Sleep(1500);
            }
        }
    }
}