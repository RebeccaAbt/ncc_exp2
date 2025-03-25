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

ptb.setup_audio;

%% create sounds...
sound_a = o_ptb.stimuli.auditory.Sine(440, 1);
sound_a.db = -20;
tmp_sound_b = o_ptb.stimuli.auditory.Sine(550, 2);
tmp_sound_b.db = -20;
x = tmp_sound_b.get_sound_data(44100, 2);
sound_b = o_ptb.stimuli.auditory.FromMatrix(x', 44100);

%% add sounds...
new_sound = sound_a + sound_b;

x = new_sound.get_sound_data(96000, 2);
plot(x(:, 1));