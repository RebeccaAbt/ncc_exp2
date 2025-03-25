%% init
clear all global
close all;
restoredefaultpath
addpath('C:\Users\Andi\Desktop\NCC_exp1\o_ptb\');
o_ptb.init_ptb('C:\Toolboxes\Psychtoolbox\');
addpath('C:\Users\Andi\Desktop\NCC_exp1\toolbox\');

ptb_cfg = o_ptb.PTB_Config();
ptb_cfg.corticalmetrics_config.cm_dll = fullfile('C:\Users\Andi\Desktop\NCC_exp1\CM\', 'CM.dll');
%ptb_cfg.corticalmetrics_config.stimulator_mapping('left') = 'CM6-0023001A5931570520393639';
ptb_cfg.corticalmetrics_config.stimulator_mapping('left') = 'CM6-0034003E5931570620393639';
ptb_cfg.corticalmetrics_config.trigger_mapping('left') = 128;
ptb_cfg.fullscreen = false;
ptb_cfg.window_scale = 0.5;
ptb_cfg.skip_sync_test = true;
ptb_cfg.hide_mouse = false;

ptb_cfg.force_datapixx = true;

%% setup o_ptb
ptb = o_ptb.PTB.get_instance(ptb_cfg);
ptb.setup_trigger;
ptb.setup_response;
ptb.setup_tactile;

%% send tactile
stim_object = o_ptb.stimuli.tactile.Base('left', 2, 255, 90, 1);
ptb.prepare_tactile(stim_object);
ptb.prepare_trigger(1);
ptb.schedule_tactile();
%ptb.schedule_trigger();

ptb.play_without_flip();

%% send a few triggers
for i=1:1
    ptb.prepare_trigger(128);
    ptb.schedule_trigger();
    
    ptb.play_without_flip();
    WaitSecs(0.2);
end %for