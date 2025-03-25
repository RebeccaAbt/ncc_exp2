%% clear & init

%% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% 
% Extra tactile test in INIT2!!!!!!!!

% init : TL / CM+
%init: au dio
% init: real exp
% Main: get TRigger
% nTrials!
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
cd(mainDir)

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

base_level = ptb.trigger_status
if ~params.isTest
ptb.get_trigger(base_level); % Wait for first trigger from MRI
end

params.MRIstart = GetSecs;
tic
params.expStart=params.MRIstart;

waitingText='MRI ready';
Screen('TextSize',ptb.win_handle,18);
DrawFormattedText(ptb.win_handle, waitingText, 'center', 'center', params.black, 60);
ptb.flip();

for block = 1 :3
    
    params.blocknr = block + (params.runNr-1)*3;
    params.task = randomisation_table.(thisRun){subjectNr}(block);
    modality = params.modalities{params.task};
    % --- INITIALIZE 2
    [params, ptb]=InitializeExp2(ptb, params, block); % because we want to make sure the MRI is ready before we continue
    
    
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
    if params.runNr == 1 && block == 1
        data = stopthatshit(outDir, params, modality, ptb, time, stimuli, responses, block); % no data variable yet for first block
    else
        data = stopthatshit(outDir, params, modality, ptb, time, stimuli, responses, block, data);
    end
    
end %for blocks

% --- SAVE
if ~params.isTest
    [data, params] = savethatshit(ptb, data, params, time, outDir, randomisation_table, base_level);
else
    ShowCursor;
    Priority(0);
    Screen('CloseAll')
end
