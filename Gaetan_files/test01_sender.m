%% clear
clear all global

%% clear...
clear all global
close all

%% init th_ptb
restoredefaultpath
addpath('C:\Users\thartmann\git\th_ptb');
th_ptb.init_ptb('C:\Users\thartmann\git\Psychtoolbox-3'); % change this to where PTB is on your system

%% get a configuration object
ptb_cfg = th_ptb.PTB_Config();

%% do the configuration
ptb_cfg.fullscreen = false;
ptb_cfg.window_scale = 0.2;
ptb_cfg.skip_sync_test = true;
ptb_cfg.hide_mouse = false;

%% get th_ptb.PTB object
ptb = th_ptb.PTB.get_instance(ptb_cfg);

%% init response system...
ptb.setup_trigger;

%% send trigger...
while true
  WaitSecs(1);
  ptb.prepare_trigger(1);
  ptb.schedule_trigger;
  ptb.play_without_flip;
end %while