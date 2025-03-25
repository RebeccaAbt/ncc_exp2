%% clear...
clear all global
close all
restoredefaultpath;

%% add path
addpath('/home/th/git/o_ptb'); % change this to point to o_ptb

o_ptb.init_ptb('/home/th/git_other/Psychtoolbox-3');

%% configure...
ptb_cfg = o_ptb.PTB_Config;
ptb_cfg.force_real_triggers = true;
ptb_cfg.psychportaudio_config.device = 5;
ptb = o_ptb.PTB.get_instance(ptb_cfg);

ptb.setup_trigger;
ptb.setup_audio;

%% send a trigger...
%ptb.prepare_trigger(255);
%ptb.schedule_trigger;

ptb.play_without_flip;

%% send a trigger and a sound...
my_sound = o_ptb.stimuli.auditory.FromMatrix(ones(2, 96000/10).*0.1, 96000);
my_sound = o_ptb.stimuli.auditory.Sine(100, 0.1);

srate = 96000;
duration = 0.1;
freq = 100;
n_samples = duration * srate;
tmp_s_idx = (1:round(n_samples));

s_data = sin(2*pi*tmp_s_idx*(freq/srate));
s_data = s_data .* linspace(1, 0, n_samples);

my_sound = o_ptb.stimuli.auditory.FromMatrix(s_data, 96000);

t = GetSecs;
while true
  ptb.prepare_trigger(255);
  ptb.prepare_audio(my_sound);

  ptb.schedule_audio;
  ptb.schedule_trigger;

  ptb.play_without_flip;
  t = WaitSecs('UntilTime', t+0.25);
end %while