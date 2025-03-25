%% clear...
clear all global
close all

%% init o_ptb
restoredefaultpath
addpath('C:\Users\Andi\Desktop\NCC_exp1\o_ptb\');
o_ptb.init_ptb('C:\Toolboxes\Psychtoolbox\');
addpath('C:\Users\Andi\Desktop\NCC_exp1\toolbox\');

%% get a configuration object
ptb_cfg = o_ptb.PTB_Config();

%% do the configuration
ptb_cfg.fullscreen = false;
ptb_cfg.window_scale = 0.2;
ptb_cfg.skip_sync_test = true;
ptb_cfg.hide_mouse = false;
ptb_cfg.corticalmetrics_config.cm_dll = fullfile('C:\Users\Andi\Desktop\NCC_exp1\CM\', 'CM.dll');
ptb_cfg.corticalmetrics_config.stimulator_mapping('left') = 'CM6-0034003E5931570620393639';
ptb_cfg.corticalmetrics_config.trigger_mapping('left') = 1;

%% get o_ptb.PTB object
ptb = o_ptb.PTB.get_instance(ptb_cfg);

%% init response system...
ptb.setup_trigger;
ptb.setup_tactile;

%% setup stimulation
all_stims = {o_ptb.stimuli.tactile.Base('left', 4, 256, 10, 1), ...
  o_ptb.stimuli.tactile.Base('left', 3, 256, 20, 1), ...
  o_ptb.stimuli.tactile.Base('left', 2, 256, 30, 1), ...
  o_ptb.stimuli.tactile.Base('left', 1, 256, 40, 1)};

%% send out stim
n_trials = 60*10;

for idx_trial = 1 %:n_trials
  WaitSecs(5);
  for idx_stim = 1:length(all_stims)
    cur_stim = all_stims{idx_stim};
    ptb.prepare_tactile(cur_stim, idx_stim - 1, idx_stim ~= 1);
  end %for

  ptb.schedule_tactile;
  ptb.play_without_flip();
  
end %for


%ptb.flip();