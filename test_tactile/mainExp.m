%% clear & init

%% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Init: Labjack + CM config!
% PsychPortaudio!!
% get_trigger !!
% end_trigger !!
%%
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
cd(mainDir+"\test_tactile\")

o_ptb.init_ptb('C:\Toolboxes\Psychtoolbox\');
% o_ptb.init_ptb('C:\Users\mrsre\MATLAB\Psychtoolbox-3-master\Psychtoolbox');
%%

load("randomisation_table.mat")

% -------------------------------------------- v Option 1: Dialog
% [randomisation_table, inputParams] = userDialog(outDir, randomisation_table);

% params.subjectID = inputParams.subjectID;
% params.fileName = inputParams.subjectID;
% params.runNr = inputParams.runNr;
% subjectNr = inputParams.subjectNr;

% -------------------------------------------- v Option 2: Manual Input
subjectID = inputdlg('Subject ID?', 'Experiment');
subjectNr = inputdlg('Subject Number?', 'Experiment');
runNr=inputdlg('Run Number?', 'Experiment');

params.subjectID = subjectID{1};
params.fileName = subjectID{1};
params.runNr = str2double(runNr);

subjectNr = str2double(subjectNr);

if strcmpi(params.subjectID(1:4), 'test')
    params.isTest = true;
else
    params.isTest = false;
end

if ~params.isTest && params.runNr > 1
    load(fullfile(outDir,'data\', strcat(params.fileName, '.mat')))
end

thisRun = cell2mat(randomisation_table.Properties.VariableNames(params.runNr+1));
Priority(1);
% HideCursor;
%%
% --- INITIALIZE 1
[params,ptb] = InitializeExp(outDir, params); 
HideCursor;

waitingText='Waiting for MRI...';
DrawFormattedText(ptb.win_handle, waitingText, 'center', 'center', params.black, 60);
ptb.flip();

% if ~params.isTest
%     ptb.get_trigger(); % Wait for first trigger from MRI
% end

params.MRIstart = GetSecs;
params.expStart=params.MRIstart;

waitingText='MRI ready';
Screen('TextSize',ptb.win_handle,18);
DrawFormattedText(ptb.win_handle, waitingText, 'center', 'center', params.black, 60);
ptb.flip();

trialorder3_original =  params.tactile.trialorderRandom3;
trialorder2_original =  params.tactile.trialorderRandom2;

% last4 = ((params.nTrials-3):params.nTrials);
% 
% int_min =   [10  40  70 100 130 10  40  70 100 130];
% int_max =   [80 110 140 170 200 80 110 140 170 200];


int_min =   [10  40  10  40 10  40   40  70 100 130];
int_max =   [80 110  80 110 80  110 110 140 170 200];
int_start = [65  95  65  95 65  95   95 125 155 185];

freq = [30 30 60 60 120 120 120 120 120];

for iblock = 1 :10
    
%     if iblock == 1 || iblock == 5
%         params.tactile.trialorderRandom3(last4) = 2; % make first stimulations with this frequency high intensity
%         params.tactile.trialorderRandom2(last4) = (1:4); % high intensity stims on all 4 fingers first
%     elseif iblock == 2 || iblock == 6
%         params.tactile.trialorderRandom3 = trialorder3_original;
%         params.tactile.trialorderRandom2 = trialorder2_original;
%     end
    
    stimulated_fingers=1:4;
    params.max_tactile_intensity=256;
    for i=1:length(stimulated_fingers)
        params.stimuli(i).tactile = o_ptb.stimuli.tactile.Base('left', stimulated_fingers(i), params.max_tactile_intensity, freq(iblock), 0.05);
        params.stimuli(i).thr_tactile = ml_threshold.ThresholdHunter(int_start(iblock), int_min(iblock):0.5:int_max(iblock), 0, 0.5);
    end
    
    
    params.blocknr = iblock + (params.runNr-1)*3;
    params.task = 2;
    modality = params.modalities{params.task};
    % --- INITIALIZE 2
    [params, ptb]=InitializeExp2(ptb, params, iblock); % because we want to make sure the MRI is ready before we continue
    
    
    for trial=1:params.nTrials
        
        % --- STIMULI
        [FlipStart, params, ptb]=showtrial(params, modality, trial, ptb);
        
        time.ITI(trial)=FlipStart.t1-params.trialStart;
        time.Fixation(trial)=FlipStart.t2-FlipStart.t1;
        time.Stimulus(trial)=FlipStart.t3-FlipStart.t2;
        time.PostStim(trial)=FlipStart.t4-FlipStart.t3;
        stimuli.intensity(trial)=params.intensity;
        
        % --- RESPONSE
        [params, response, ptb]=getResponse(params, modality, trial, ptb);
        
        time.response(trial)=params.t5-FlipStart.t4;
        responses.val(trial)=response.value;
        
        time.MRI_Trialstart(trial) = params.t1-params.MRIstart;
        time.MRI_Stimulus(trial) = params.t2-params.MRIstart;
        time.MRI_PostStim(trial) = params.t3-params.MRIstart;
        time.MRI_Response(trial) = params.t5-params.MRIstart;
        
        WaitSecs(0.001);
        
    end %for  trials
    
    params.blockEnd = GetSecs;
    
    % --- BLOCK END
    if params.runNr == 1 && iblock == 1
        data = stopthatshit(outDir, params, modality, ptb, time, stimuli, responses, iblock); % no data variable yet for first block
    else
        data = stopthatshit(outDir, params, modality, ptb, time, stimuli, responses, iblock, data);
    end
    
end %for blocks

% --- SAVE
if ~params.isTest
    [data, params] = savethatshit(ptb, data, params, time, outDir, randomisation_table);
else
    ShowCursor;
    Priority(0);
    Screen('CloseAll')
end
