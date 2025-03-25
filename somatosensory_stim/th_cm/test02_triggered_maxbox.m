%% clear
clear all global
close all

restoredefaultpath;

%% init...
asminfo = NET.addAssembly(fullfile(pwd, 'CM.dll'));
addpath('C:\Users\th\Documents\MATLAB\topdown-ci\external\obob_maxbox');

%% init maxbox...
maxbox.init;

%% start maxbox...
maxbox.startstim([]);

%% init Stimulator....
stimulator = CorticalMetrics.CM5;
stimulator.Init(true);
stimulator.UseInputTrigger = false;

%% make ci stim...
ci_stim = maxbox.basesequences.SimplePulse;
ci_stim.left = true;
ci_stim.amplitudes = 100;
ci_stim.channels = [1];
ci_stim.distance = 10000000;
ci_stim.triggerlength = 5e4;

%% play
ci_stim.play();

%% create a stimulus....
stim_chain = CorticalMetrics.QuadStimulusChain;

stim = CorticalMetrics.Stimulus(500, 10, 1000);
stim_silent = CorticalMetrics.Stimulus(0, 10, 1000);

stim_chain.CH3.Add(CorticalMetrics.StimulusLink(stim));

stim.Phase = 90;
stim.StartTemp = 500;

stim_chain.CH2.Add(CorticalMetrics.StimulusLink(stim_silent));
stim_chain.CH2.Add(CorticalMetrics.StimulusLink(stim));

stimulator.ChainedVibration(stim_chain);