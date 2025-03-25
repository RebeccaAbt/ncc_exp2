%% clear...
clear all global
close all
restoredefaultpath;

%% add path
addpath('/home/th/git/o_ptb'); % change this to point to o_ptb

o_ptb.init_ptb('/home/th/git_other/Psychtoolbox-3/');

%% configure...
ptb_cfg = o_ptb.PTB_Config;
ptb_cfg.labjacktrigger_config.method = labjack.Labjack.TriggerMethod.PULSEWIDTH;
ptb_cfg.labjacktrigger_config.channel_group = labjack.Labjack.ChannelGroup.FIO;
ptb_cfg.labjacktrigger_config.num_bits = 3;
ptb = o_ptb.PTB.get_instance(ptb_cfg);

ptb.setup_trigger;

%% schedule and submit trigger

ptb.prepare_trigger(2, 0.3);
ptb.prepare_trigger(3, 0, true);
ptb.prepare_trigger(6, 0.15, true);


ptb.schedule_trigger;
ptb.play_without_flip;