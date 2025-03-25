%% clear...
clear all global
close all

%% init o_ptb
restoredefaultpath
addpath('../');
o_ptb.init_ptb();

%% get a configuration object
ptb_cfg = o_ptb.PTB_Config();

%% init....
ptb = o_ptb.PTB.get_instance(ptb_cfg);
ptb.setup_audio();

%% get audio objects
sine1 = o_ptb.stimuli.auditory.Sine(440, 1);
sine2 = o_ptb.stimuli.auditory.Sine(550, 1);

sine1.db = -30;
sine2.db = -30;

%% play with overwrite
ptb.prepare_audio(sine1);
ptb.prepare_audio(sine2, 0.3, true, false);

ptb.schedule_audio();
ptb.play_without_flip();

%% play together
ptb.prepare_audio(sine1);
ptb.prepare_audio(sine2, 0.3, true, true);

ptb.schedule_audio();
ptb.play_without_flip();

%% play together and prune
ptb.prepare_audio(sine1);
ptb.prepare_audio(sine2, 0.3, true, true);

ptb.prune_audio(1);

ptb.schedule_audio();
ptb.play_without_flip();