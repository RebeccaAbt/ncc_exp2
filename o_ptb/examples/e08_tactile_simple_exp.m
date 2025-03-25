%% clear...
clear all global
close all

%% init o_ptb
init_o_ptb_paths('../');

%% get a configuration object
ptb_cfg = o_ptb.PTB_Config();

%% do the configuration
ptb_cfg.fullscreen = false;
ptb_cfg.window_scale = 0.2;
ptb_cfg.skip_sync_test = true;
ptb_cfg.hide_mouse = false;
ptb_cfg.corticalmetrics_config.cm_dll = fullfile('C:\Users\th\Documents\cm', 'CM.dll');
ptb_cfg.corticalmetrics_config.stimulator_mapping('left') = 'CM6-0034003E5931570620393639';
ptb_cfg.corticalmetrics_config.trigger_mapping('left') = 128;

%% get o_ptb.PTB object
ptb = o_ptb.PTB.get_instance(ptb_cfg);

%% init subsystems...
ptb.setup_trigger;
ptb.setup_tactile;
ptb.setup_screen;

%% make stims....
iti = 0.1;
stim_duration = 0.25;
n_trials = 2000;

fixcross = o_ptb.stimuli.visual.FixationCross;
tactile_stim1 = o_ptb.stimuli.tactile.Base('left', 4, 256, 30, stim_duration/2);
tactile_stim2 = o_ptb.stimuli.tactile.Base('left', 3, 256, 30, stim_duration/2);
tactile_stim3 = o_ptb.stimuli.tactile.Base('left', 2, 256, 30, stim_duration/2);
ready_text = o_ptb.stimuli.visual.Text('Get Ready, please!');

%% ask subject to get ready....
ptb.draw(ready_text);
ptb.flip;

KbWait;
%% stimulate...
ptb.draw(fixcross);
ptb.flip;

timestamp = GetSecs;

for idx_trial = 1:n_trials
  ptb.reset_subsystems();
  ptb.prepare_tactile(tactile_stim1);
  ptb.prepare_tactile(tactile_stim2, stim_duration/3, true);
  ptb.prepare_tactile(tactile_stim3, stim_duration/2, true);
  ptb.schedule_tactile
  ptb.prepare_trigger(7, 0, true);
  ptb.prepare_trigger(61, 0.2, true);
  ptb.schedule_trigger();
  new_timestamp = WaitSecs('UntilTime', timestamp + iti+stim_duration);

  fprintf('Real ITI: %f\n', new_timestamp - timestamp);
  timestamp = new_timestamp;
  ptb.play_without_flip;
  ptb.wait_for_stimulators();
end %for