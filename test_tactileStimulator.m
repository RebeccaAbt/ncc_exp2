% test if stimulator is working (on all fingers) using Labjack config
% --------------------------------------------------------------------
%%
clear all global
close all;
clc
commandwindow
%%
restoredefaultpath
cd 'C:\Users\Andi\Desktop\Rebecca Tinkering'
addpath('C:\Users\Andi\Desktop\NCC_exp2\o_ptb\');
o_ptb.init_ptb('C:\Toolboxes\Psychtoolbox\');
addpath('C:\Users\Andi\Desktop\NCC_exp2\toolbox\');

%%
ptb_cfg = o_ptb.PTB_Config();

ptb_cfg.corticalmetrics_config.cm_dll = fullfile('C:\Users\Andi\Desktop\NCC_exp1\CM\', 'CM.dll');
ptb_cfg.corticalmetrics_config.stimulator_mapping('left') = 'CM6-0034003E5931570620393639'; % Powerbox 1
% ptb_cfg.corticalmetrics_config.stimulator_mapping('left') = 'CM6-0023001A5931570520393639'; % Powerbox 2
ptb_cfg.corticalmetrics_config.trigger_mapping('left') = 2;
ptb_cfg.internal_config.trigger_subsystem = @o_ptb.subsystems.trigger.Labjack;  % force to use Labjack; umgeht manche Probleme, die ab und an random auftauchen
ptb_cfg.internal_config.tactile_subsystem = @o_ptb.subsystems.tactile.CorticalMetricsStimulator; % force to use CorticalMetricsStimulator; 

ptb_cfg.force_real_triggers = true;

ptb_cfg.labjacktrigger_config.method = labjack.Labjack.TriggerMethod.SINGLE;    %  TriggerMethod -->('SINGLE', 0, 'MULTI', 1, 'PULSEWIDTH', 2);
ptb_cfg.labjacktrigger_config.channel_group = labjack.Labjack.ChannelGroup.EIO;  %    ChannelGroup -->('FIO', 0, 'EIO', 1, 'CIO', 2);
ptb_cfg.labjacktrigger_config.single_channel = 1;

%% setup o_ptb

ptb = o_ptb.PTB.get_instance(ptb_cfg);
ptb.setup_trigger;
ptb.setup_tactile;
ptb.wait_for_stimulators();

%% finger 4

fingers = {'little finger'; 'ring finger'; 'middle finger'; 'index finger'};
WaitSecs(10);
for iFinger = 1:4
    WaitSecs(0.5);

stim_object = o_ptb.stimuli.tactile.Base('left', iFinger, 150, 80, 0.5);

fprintf('\n\n----------------------------------------- \n next finger: %s\n-----------------------------------------\n\n',fingers{iFinger}) 
% input('Press ''Enter'' to continue...', 's')
for i=1:1
    ptb.prepare_tactile(stim_object, 0, 0);
    ptb.schedule_tactile();
    ptb.play_without_flip();
ptb.wait_for_stimulators();
    WaitSecs(0.5);

end

end

