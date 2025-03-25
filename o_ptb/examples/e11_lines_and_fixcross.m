%% clear...
clear all global
close all

%% init o_ptb
restoredefaultpath
addpath('../');
o_ptb.init_ptb();

%% get a configuration object
ptb_cfg = o_ptb.PTB_Config();

%% do the configuration
ptb_cfg.fullscreen = false;
ptb_cfg.window_scale = 0.7;
ptb_cfg.skip_sync_test = true;
ptb_cfg.hide_mouse = false;
ptb_cfg.defaults.fixcross_width_ratio = 0.1;

%% init....
ptb = o_ptb.PTB.get_instance(ptb_cfg);
ptb.setup_screen();

%% draw some lines....
line1 = o_ptb.stimuli.visual.Line(-10, 200, [255 0 0], 4);
line1.move(-100, 200);
ptb.draw(line1);
ptb.flip();

%% draw new fixcross
fixcross = o_ptb.stimuli.visual.FixationCross();
ptb.draw(fixcross)
ptb.flip();