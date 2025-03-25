function [params, ptb]=InitializeExp(outDir)
% Subject Parameters

% subjectID= inputdlg('Subject ID?', 'Experiment');
% blocknr=inputdlg('Blocknumber?', 'Experiment');
% task = inputdlg('auditory=1, somatosensory=2, visual=3'); % 4 blocks each, 8(12) total
% 
% blocknr = "1";  % only while testing !!
% task = "2";     % only while testing tactile!!
% 
% %--- params
% 
% params.subjectID=subjectID{1};
% params.fileName=strcat(subjectID{1});
% params.blocknr=str2double(blocknr{1});
% params.task=str2double(task{1});

load("randomisation_table.mat")

[randomisation_table, params] = userDialog(outDir, randomisation_table);

params.nBlocks = 18;

% ------------------------------------------------------ v
if strcmpi(params.subjectID(1:4), 'test')  % can create test* files
    % ------------------------------------------------------ ^
    params.nTrials=5; %120
else
    params.nTrials=50; %120
end

nTrials = 50;

params.viewingDistance=1200; %mm
params.physical=[560, 290];  %MEG

%%
ptb_cfg = o_ptb.PTB_Config();

if params.task == 2
    ptb_cfg.corticalmetrics_config.cm_dll = fullfile('C:\Users\Andi\Desktop\NCC_exp1\CM\', 'CM.dll');
    % ptb_cfg.corticalmetrics_config.stimulator_mapping('left') = 'CM6-0034003E5931570620393639'; % Powerbox 1  --> currently in MRI Lab
    ptb_cfg.corticalmetrics_config.stimulator_mapping('left') = 'CM6-0023001A5931570520393639'; % Powerbox 2    --> currently in MEG Lab
    ptb_cfg.corticalmetrics_config.trigger_mapping('left') = 128;
%     ptb_cfg.internal_config.trigger_subsystem = @o_ptb.subsystems.trigger.Labjack;  % force to use Labjack; umgeht manche Probleme, die ab und an random auftauchen
%     ptb_cfg.internal_config.tactile_subsystem = @o_ptb.subsystems.tactile.CorticalMetricsStimulator; % force to use CorticalMetricsStimulator;
%     ptb_cfg.labjacktrigger_config.method = labjack.Labjack.TriggerMethod.SINGLE;    %  TriggerMethod -->('SINGLE', 0, 'MULTI', 1, 'PULSEWIDTH', 2);
%     ptb_cfg.labjacktrigger_config.channel_group = labjack.Labjack.ChannelGroup.EIO;  %    ChannelGroup -->('FIO', 0, 'EIO', 1, 'CIO', 2);
    ptb_cfg.labjacktrigger_config.single_channel = 1;
else
end
ptb_cfg.datapixxresponse_config.button_mapping('target') = ptb_cfg.datapixxresponse_config.Blue;
ptb_cfg.datapixxresponse_config.button_mapping('other_target') = ptb_cfg.datapixxresponse_config.Yellow;

ptb_cfg.keyboardresponse_config.button_mapping('target') = KbName('b'); % blue
ptb_cfg.keyboardresponse_config.button_mapping('other_target') = KbName('z'); % yellow

% --- for testing

% ptb_cfg.fullscreen = false;
% ptb_cfg.window_scale = 0.5;
% ptb_cfg.skip_sync_test = true;
% ptb_cfg.hide_mouse = false;
% 
% ptb_cfg.skip_sync_test = false;
% ptb_cfg.force_real_triggers = true;
% ptb_cfg.draw_borders_sbg = false;

% --- real experiment

% ------------------------------------------------------ v
% ptb_cfg.fullscreen = true;
% ptb_cfg.flip_horizontal = true;
% ptb_cfg.hide_mouse = true;
% ptb_cfg.skip_sync_test = false;
% ptb_cfg.force_datapixx = false;
% ptb_cfg.disable_datapixx = true;

% ------------------------------------------------------ v
% ptb_cfg.real_experiment_sbg_cdk(true); % <- MEG experiment
% ------------------------------------------------------ ^

ptb_cfg.real_labjack_experiment(true) % <- MRI experiment

% --- setup o_ptb

AssertOpenGL;
ptb = o_ptb.PTB.get_instance(ptb_cfg);
ptb.setup_screen;
ptb.setup_trigger;
ptb.setup_response;
if params.task == 1
    ptb.setup_audio;
elseif params.task == 2
    ptb.setup_tactile;
    ptb.wait_for_stimulators()
else
end

% --- params 2

%   PsychImaging('AddTask', 'AllViews', 'FlipHorizontal')
params.x0 = ptb.win_rect(3)/2;
params.y0 = ptb.win_rect(4)/2;

params.white = WhiteIndex(ptb.win_handle);
params.black = BlackIndex(ptb.win_handle);
params.gray = (params.white+params.black)/2;

params.blue = [0, 0, 255];
params.yellow = [255, 255, 0];

params.backgrcolor=params.gray;
params.framesize=100;

x_offset = 300;  % for blue / yellow circle
y_offset = 200;

params.r = 50;
params.blue_x = params.x0 - x_offset;
params.blue_y = params.y0 - y_offset;
params.yellow_x = params.x0 + x_offset;
params.yellow_y = params.y0 - y_offset;

Screen('TextSize',ptb.win_handle,20);
DrawFormattedText(ptb.win_handle, 'Initializing ...', 200, 200, params.black, 60);
Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
ptb.flip();

params.pixelSize=Screen('PixelSize', ptb.win_handle);
params.resolution=[ptb.win_rect(3) ptb.win_rect(4)];
params.degperpix=2*((atan(params.physical./(2*params.viewingDistance))).*(180/pi))./params.resolution;
params.pixperdeg=1./params.degperpix;
params.frame=FrameRate(ptb.win_handle);
params.ifi = Screen('GetFlipInterval', ptb.win_handle);

% --- create stimuli

params.fix_cross = o_ptb.stimuli.visual.FixationCross();

if params.task == 1                                        % auditory stuff
    sound_frequencies=[200, 431, 928, 2000];
    params.max_audio_intensity=-10;
    for i=1:length(sound_frequencies)
        params.stimuli(i).sound = o_ptb.stimuli.auditory.Sine(sound_frequencies(i), 0.05);
        params.stimuli(i).thr = ml_threshold.ThresholdHunter(-70, -40:-0.5:-120, 0, 0.5); % check this!
    end

elseif params.task == 2                                     % tactile stuff
    stimulated_fingers=1:4;
    params.max_tactile_intensity=256;
    for i=1:length(stimulated_fingers)
        params.stimuli(i).tactile = o_ptb.stimuli.tactile.Base('left', stimulated_fingers(i), params.max_tactile_intensity, 30, 0.05);
        params.stimuli(i).thr = ml_threshold.ThresholdHunter(65, 10:0.5:80, 0, 0.5);
    end

elseif params.task == 3                                      % visual stuff
    gabor_orientations=[0, 45, 90, 135];
    params.max_visual_intensity=100;
    for i=1:length(gabor_orientations)
        params.stimuli(i).gabor=o_ptb.stimuli.visual.Gabor(300);
        params.stimuli(i).gabor.frequency = .05;
        params.stimuli(i).gabor.sc = 60;
        params.stimuli(i).gabor.contrast = params.max_visual_intensity;
        params.stimuli(i).gabor.move_to(params.x0-300,params.y0)
        params.stimuli(i).gabor.rotate = gabor_orientations(i);
        params.stimuli(i).thr = ml_threshold.ThresholdHunter(25, 1:0.5:30, 0, 0.5); % check this!
    end
end

% --- timings

params.stimon_duration=50; %10
% params.stimon_duration = 500; % just for testimg stim reliability!!
params.ITI=1000;
params.waitDuration=500; %msecs

params.prestim_jitter = randsample([500:50:1500], params.nTrials, true); % we want 1-2 s pre-stim jitter, but we also have 500ms flipWait time --> 

for iTrial = 1:params.nTrials
    params.poststim_jitter(iTrial) = 2000 - params.prestim_jitter(iTrial); % this is in theory 2500 - prestim_jitter, but we already have 500ms flipWait time
end

params.stimon_frames=params.stimon_duration/(1000/params.frame);
params.ITIframes=params.ITI/(1000/params.frame);
params.waitframes=params.waitDuration/(1000/params.frame);
params.prestim_jitter_frames=params.prestim_jitter/(1000/params.frame);
params.poststim_jitter_frames=params.poststim_jitter/(1000/params.frame);

params.stim_ontime=params.ifi*(params.stimon_frames-0.5);
params.flipITI=params.ifi*(params.ITIframes-0.5);
params.flipWait=params.ifi*(params.waitframes-0.5);
params.flip_prestim_jitter=params.ifi*(params.prestim_jitter_frames-0.5);
params.flip_poststim_jitter=params.ifi*(params.poststim_jitter_frames-0.5);

% --- randomisation

s = RandStream.create('mt19937ar','seed',sum(100*clock));
RandStream.setGlobalStream(s);

params.trialorder1=ones(nTrials,1)*params.task; % task
% params.trialorder2=[ones(24,1)*1;ones(24,1)*2;ones(24,1)*3;ones(24,1)*4;[1 1 1 2 2 2 3 3 3 4 4 4]';[1 1 1 2 2 2 3 3 3 4 4 4]']; % stimuli

params.trialorder2 = [ones(24,1)*1;ones(24,1)*2;ones(24,1)*3;ones(24,1)*4];


% if strcmpi(subjectID{1}(1:4), 'test')
if strcmpi(params.subjectID(1:4), 'test')
    params.trialorder3=[ones(nTrials,1)*2]; % stimuli category
    fprintf("test")
else
    params.trialorder3=[ones(nTrials*0.8,1)*1;ones(nTrials*0.1,1)*2;ones(nTrials*0.1,1)*3]; % stimuli category   (80% near threshold, 10% high, 10% catch)
end
params.responseorder=[ones(nTrials/2,1);ones(nTrials/2,1)*2];

vector=1:length(params.trialorder1);
randomvector=Shuffle(vector);
params.trialorderRandom2=params.trialorder2(randomvector);
params.trialorderRandom3=params.trialorder3(randomvector);
params.responseorderRandom=params.responseorder(randomvector);