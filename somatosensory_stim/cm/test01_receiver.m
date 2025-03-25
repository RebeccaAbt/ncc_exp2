%% clear
clear all global

%% load assemblies
NET.addAssembly('F:\sbg\somatosensory_stim\cm/CM.dll');

%% get stimulator...
stimulator = CorticalMetrics.CM5();
stimulator.Init(true);
stimulator.UseInputTrigger = true;

%% make stimulus...
idx_stim = 1;
while true
  stim_chain = CorticalMetrics.QuadStimulusChain();
  stim = CorticalMetrics.Stimulus(200, 10, 1000);

  stim_chain.CH1.Add(CorticalMetrics.StimulusLink(stim));
  fprintf('Now sending stimulus %d\n', idx_stim);
  stimulator.ChainedVibration(stim_chain);
  fprintf('Done with stim %d\n\n', idx_stim);
  idx_stim = idx_stim + 1;
end %while