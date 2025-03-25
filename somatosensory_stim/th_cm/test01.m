%% clear
clear all global
close all

%% init...
asminfo = NET.addAssembly(fullfile(pwd, 'CM_Wrapper.dll'));
asminfo = NET.addAssembly(fullfile(pwd, 'CM.dll'));

%% init Stimulator....
stimulator = th_CM.CM_Wrapper(false);

%% create a stimulus....
stim_chain = CorticalMetrics.QuadStimulusChain;

stim = CorticalMetrics.Stimulus(500, 10, 1000);
stim_silent = CorticalMetrics.Stimulus(0, 10, 1000);

stim_chain.CH3.Add(CorticalMetrics.StimulusLink(stim));

stim.Phase = 90;
stim.StartTemp = 500;

stim_chain.CH2.Add(CorticalMetrics.StimulusLink(stim_silent));
stim_chain.CH2.Add(CorticalMetrics.StimulusLink(stim));

stimulator.SubmitStimulus(stim_chain);