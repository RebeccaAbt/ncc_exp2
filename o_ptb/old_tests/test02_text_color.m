%% clear....
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
ptb.setup_screen();

%% display some text....
text = o_ptb.stimuli.visual.Text('Hello World');
ptb.draw(text);
ptb.flip();