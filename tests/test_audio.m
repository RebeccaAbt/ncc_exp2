% clear all global
% close all;
restoredefaultpath
commandwindow


mainDir = 'C:\Users\Andi\Desktop\NCC_exp2\';
% mainDir = 'C:\Users\mrsre\NCC_MRI\NCC_exp2';

outDir  = mainDir;
addpath(mainDir + "\o_ptb\");
addpath(mainDir + "\toolbox\");
addpath(mainDir + "\helpers\");
cd(mainDir)

o_ptb.init_ptb('C:\Toolboxes\Psychtoolbox\');
% o_ptb.init_ptb('C:\Users\mrsre\MATLAB\Psychtoolbo
%%
ptb_cfg = o_ptb.PTB_Config();

ptb_cfg.corticalmetrics_config.cm_dll = fullfile('C:\Users\Andi\Desktop\NCC_exp1\CM\', 'CM.dll');
ptb_cfg.corticalmetrics_config.stimulator_mapping('left') = 'CM6-0034003E5931570620393639'; % Powerbox 1  --> currently in MRI Lab
% ptb_cfg.corticalmetrics_config.stimulator_mapping('left') = 'CM6-0023001A5931570520393639'; % Powerbox 2    --> currently in MEG Lab
ptb_cfg.corticalmetrics_config.trigger_mapping('left') = 2;
ptb_cfg.internal_config.trigger_subsystem = @o_ptb.subsystems.trigger.Labjack;  % force to use Labjack; umgeht manche Probleme, die ab und an random auftauchen
ptb_cfg.internal_config.tactile_subsystem = @o_ptb.subsystems.tactile.CorticalMetricsStimulator; % force to use CorticalMetricsStimulator;
ptb_cfg.labjacktrigger_config.method = labjack.Labjack.TriggerMethod.SINGLE;    %  TriggerMethod -->('SINGLE', 0, 'MULTI', 1, 'PULSEWIDTH', 2);
ptb_cfg.labjacktrigger_config.channel_group = labjack.Labjack.ChannelGroup.EIO;  %    ChannelGroup -->('FIO', 0, 'EIO', 1, 'CIO', 2);
ptb_cfg.labjacktrigger_config.single_channel = 1;

ptb_cfg.datapixxresponse_config.button_mapping('target') = ptb_cfg.datapixxresponse_config.Blue;
ptb_cfg.datapixxresponse_config.button_mapping('other_target') = ptb_cfg.datapixxresponse_config.Yellow;

ptb_cfg.keyboardresponse_config.button_mapping('target') = KbName('b'); % blue
ptb_cfg.keyboardresponse_config.button_mapping('other_target') = KbName('z'); % yellow
ptb_cfg.psychportaudio_config.reqlatencyclass = 3;
ptb_cfg.psychportaudio_config.device = 11;
%%

% ptb.setup_audio;

this_sound = params.stimuli(4).sound;
this_sound.db = -10;
ptb.prepare_audio(this_sound);
ptb.schedule_audio;
ptb.play_without_flip