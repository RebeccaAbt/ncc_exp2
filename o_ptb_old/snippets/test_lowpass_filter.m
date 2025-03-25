%% clear...
clear all global
close all
restoredefaultpath;
commandwindow

%% init...
o_ptb.init_ptb('/home/th/git_other/Psychtoolbox-3');

ptb_cfg = o_ptb.PTB_Config;

ptb = o_ptb.PTB.get_instance(ptb_cfg);
ptb.setup_audio();

%% get a sound....
snd = o_ptb.stimuli.auditory.WhiteNoise(1);

%% lowpass filter
snd.filter_lowpass(2000);