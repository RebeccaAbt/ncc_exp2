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

%% get background noise object....
noise = o_ptb.stimuli.auditory.WhiteNoise(10);
noise.amplify_db(-25);

%% get sound object
sound = o_ptb.stimuli.auditory.Sine(440, 1);
sound.apply_cos_ramp(0.1);
sound.amplify_db(-10);

%% set noise as background noise...
ptb.set_audio_background(noise);

%% play sound....
tic;
ptb.prepare_audio(sound);
%ptb.prepare_audio(sound, 2, true);
ptb.schedule_audio();
toc;

ptb.play_without_flip();

%% stop background...
ptb.stop_audio_background();

%% play sound again....
ptb.prepare_audio(sound);
ptb.schedule_audio();

ptb.play_without_flip();