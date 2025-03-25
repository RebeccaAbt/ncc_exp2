%% clear
clear all global

%% load assemblies
NET.addAssembly('C:\Users\thartmann\Documents\cm/CM.dll');

%% get stimulator...
stimulator = CorticalMetrics.CM5();
stimulator.Init(true);
stimulator.UseInputTrigger = true;

%% make stimulus...
stim_chain = CorticalMetrics.QuadStimulusChain();
stim = CorticalMetrics.Stimulus(200, 10, 1000);

stim_chain.CH1.Add(CorticalMetrics.StimulusLink(stim));

%% send stimulus....
stimulator.ChainedVibration(stim_chain);