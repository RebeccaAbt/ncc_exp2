clear all global
close all;
restoredefaultpath
commandwindow

mainDir = 'C:\Users\Andi\Desktop\NCC_exp2\';
% mainDir = 'C:\Users\mrsre\NCC_MRI\NCC_exp2';

outDir  = mainDir;
addpath(mainDir + "\o_ptb\");
addpath(mainDir + "\toolbox\");
addpath(mainDir + "\helpers\");
cd(mainDir)
%%
o_ptb.init_ptb('C:\Toolboxes\Psychtoolbox\');
% o_ptb.init_ptb('C:\Users\mrsre\MATLAB\Psychtoolbox-3-master\Psychtoolbox');

ptb_cfg = o_ptb.PTB_Config();

ptb_cfg.corticalmetrics_config.trigger_mapping('left') = 2;
ptb_cfg.internal_config.trigger_subsystem = @o_ptb.subsystems.trigger.Labjack;  % force to use Labjack; umgeht manche Probleme, die ab und an random auftauchen
ptb_cfg.labjacktrigger_config.method = labjack.Labjack.TriggerMethod.SINGLE;    %  TriggerMethod -->('SINGLE', 0, 'MULTI', 1, 'PULSEWIDTH', 2);
ptb_cfg.labjacktrigger_config.channel_group = labjack.Labjack.ChannelGroup.EIO;  %    ChannelGroup -->('FIO', 0, 'EIO', 1, 'CIO', 2);
ptb_cfg.labjacktrigger_config.single_channel = 1;

ptb = o_ptb.PTB.get_instance(ptb_cfg);
ptb.setup_trigger;

%% Wait for 7th trigger (when base_level = high)

% % 1) praparation for test: simulate high base level --> Wait with lv 0
% % until buitton on Impuls generator is pressed
% base_level = ptb.trigger_status
% ptb.get_trigger(base_level);
% 
% % here is the start of the 1 second long on phase --> simulats start with
% % high voltage base state
% % % 
% base_level = ptb.trigger_status;
% ptb.get_trigger(base_level,7);

%%
% tic
% ptb.get_trigger(6); % = (5, 6, 'FIO') --> ChanNr, n_trigger, ChanType
% toc

%%

base_level = ptb.trigger_status
%%
ptb.get_trigger(base_level);

disp("trigger received")
get_lasttrigger(ptb, base_level)

disp("last trigger received")
%%
a= GetSecs;
while true
    ptb.trigger_status()
    if GetSecs-a >10
        break
    end
end