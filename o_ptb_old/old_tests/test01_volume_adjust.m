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

%% init....
ptb = o_ptb.PTB.get_instance(ptb_cfg);
ptb.setup_audio();

%% get audio....
audio = o_ptb.stimuli.auditory.Sine(440, 1);

%% query all properties....
audio.rms
audio.amplification_factor
audio.absmax
audio.db

%% set all...
audio.rms = 0.5;
audio.rms = [0.3 0.4];
audio.db = -20;
audio.db = [-21 -13];
audio.absmax = 1;
audio.absmax = [0.9 0.99];