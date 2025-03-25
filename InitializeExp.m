function [params, ptb]=InitializeExp(params)

params.nBlocks = 18;

if params.isTest
    params.nTrials=6;
else
    params.nTrials=48;
end

nTrials = 48;

params.viewingDistance=1200; %mm
params.physical=[560, 290];  %MEG

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

% --- for testing

ptb_cfg.fullscreen = false;
ptb_cfg.window_scale = 0.5;
% ptb_cfg.skip_sync_test = true;
% ptb_cfg.hide_mouse = true;

% --- real experiment

% ptb_cfg.real_experiment_sbg_cdk(true); % <- MEG experiment

ptb_cfg.real_labjack_experiment(true) % <- MRI experiment

% --- setup o_ptb

AssertOpenGL;

ptb = o_ptb.PTB.get_instance(ptb_cfg);
ptb.setup_screen;
ptb.setup_trigger;
ptb.setup_response;

if params.taskOrder(1) == 2 || params.isTest % initialize tactile here, if tactile is first block or if we do a test run. Else, the tactile System is initalized later because it won't work otherwise
    ptb.setup_tactile;
    ptb.wait_for_stimulators()
end

ptb.setup_audio;

% --- params 2

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

% different order of blue/yellow buttons than in MEG study
params.r = 50;
params.blue_x = params.x0 + x_offset;
params.blue_y = params.y0 - y_offset;
params.yellow_x = params.x0 - x_offset;
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

% auditory stuff
sound_frequencies=[200, 431, 928, 2000];
params.max_audio_intensity=-35;
for i=1:length(sound_frequencies)
    params.stimuli(i).sound = o_ptb.stimuli.auditory.Sine(sound_frequencies(i), 0.05);
    params.stimuli(i).thr_auditory = ml_threshold.ThresholdHunter(-70, -40:-0.5:-120, 0, 0.5); % check this!
end

% Wee need this block in the MRI because for some reason, the first souns is not played. We play one sound here, so the first sound during the actual run will be audible
this_sound = params.stimuli(1).sound;
this_sound.db = -100;
ptb.prepare_audio(this_sound);
ptb.schedule_audio;
ptb.play_without_flip

% tactile stuff
stimulated_fingers=1:4;
params.max_tactile_intensity=256;
for i=1:length(stimulated_fingers)
    params.stimuli(i).tactile = o_ptb.stimuli.tactile.Base('left', stimulated_fingers(i), params.max_tactile_intensity, 30, 0.05);
    params.stimuli(i).thr_tactile = ml_threshold.ThresholdHunter(65, 10:0.5:80, 0, 0.5);
end

% visual stuff
gabor_orientations=[0, 45, 90, 135];
params.max_visual_intensity=100;
for i=1:length(gabor_orientations)
    params.stimuli(i).gabor=o_ptb.stimuli.visual.Gabor(300);
    params.stimuli(i).gabor.frequency = .05;
    params.stimuli(i).gabor.sc = 60;
    params.stimuli(i).gabor.contrast = params.max_visual_intensity;
    params.stimuli(i).gabor.move_to(params.x0-300,params.y0)
    params.stimuli(i).gabor.rotate = gabor_orientations(i);
    params.stimuli(i).thr_visual = ml_threshold.ThresholdHunter(25, 1:0.5:30, 0, 0.5); % check this!
end

% --- general timings

params.stimon_duration=50; %10
params.ITI=1000;
params.waitDuration=500; %msecs
params.shortWait = 5000;
params.longWait = 25000;

% --- timings all conditions

modalities = {'auditory', 'tactile', 'visual'};
params.modalities = {'auditory', 'tactile', 'visual'};
totalDurations = {'stimon_duration', 'ITI', 'waitDuration', 'shortWait', 'longWait'};
DurationFrames = {'stimon_frames', 'ITIframes', 'waitframes', 'shortWait_frames', 'longWait_frames' };
DurationFlips = {'stim_ontime', 'flipITI', 'flipWait', 'shortWait_frames', 'longWait_flips'};

for i = 1:length(totalDurations)
    params.(DurationFrames{i}) = params.(totalDurations{i})/(1000/params.frame);
    params.(DurationFlips{i}) = params.ifi*(params.(DurationFrames{i})-0.5);
end

for iBlock = 1:length(modalities)
    modality = modalities{iBlock};
    
    s = RandStream.create('mt19937ar','seed',iBlock + sum(100*clock));
    RandStream.setGlobalStream(s);
    
    params.(modality) = struct();
    
    params.(modality).prestim_jitter = randsample(500:50:1500, params.nTrials, true);
    params.(modality).poststim_jitter = 2000 - params.(modality).prestim_jitter;
    
    params.(modality).prestim_jitter_frames = params.(modality).prestim_jitter/(1000/params.frame);
    params.(modality).poststim_jitter_frames = params.(modality).poststim_jitter/(1000/params.frame);
    
    params.(modality).flip_prestim_jitter=params.ifi*(params.(modality).prestim_jitter_frames-0.5);
    params.(modality).flip_poststim_jitter=params.ifi*(params.(modality).poststim_jitter_frames-0.5);
    
    % Setup trial orders
    task = iBlock; % Assuming task ID corresponds to modality index
    params.(modality).trialorder1 = ones(params.nTrials, 1) * task;
    
    params.(modality).trialorder2 = repmat([1; 2; 3; 4], 12, 1); % Repeat each stimulus 10 times
    
    if params.isTest
        params.(modality).trialorder3 = ones(params.nTrials, 1) * 2; % All trials same category
    else
        params.(modality).trialorder3 = [ones(40, 1); 2*ones(4, 1); 3*ones(4, 1)]; % 80%, 10%, 10%
    end
    
    params.(modality).responseorder = [ones((params.nTrials/2), 1); 2*ones((params.nTrials/2), 1)];
    
    vector = 1:length(params.(modality).trialorder1);
    randomVector = Shuffle(vector);
    params.(modality).trialorderRandom2 = params.(modality).trialorder2(randomVector);
    params.(modality).trialorderRandom3 = params.(modality).trialorder3(randomVector);
    params.(modality).responseorderRandom = params.(modality).responseorder(randomVector);
    
    Screen('BlendFunction', ptb.win_handle, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    KbName('UnifyKeyNames');
    
    %     Priority(1);
end