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
sine1.db = -30;

noise = o_ptb.stimuli.auditory.WhiteNoise(1);
noise.db = -30;
noise.apply_sin_ramp(10e-3);

%% set angles....
angles = linspace(-pi*0.9, pi*0.9, 20);

%% play sounds....
for cur_angle=angles
    noise.angle = cur_angle;
    disp(cur_angle);
    noise.debug_play_now;
    WaitSecs(noise.duration*1.1);
end %for