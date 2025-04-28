% clear & init
%
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
% 
% params.subjectID = inputParams.subjectID;
% params.fileName = inputParams.subjectID;
% params.runNr = inputParams.runNr;
% subjectNr = inputParams.subjectNr;

% -------------------------------------------- v Option 2: Manual Input

while true
   
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
    
    if ~params.isTest && ~isempty(randomisation_table.Subj_ID{subjectNr})
        
        msg = "Subject number already exists in the randomisation table. Do you really want to overwrite it?" + newline + newline;
        opts = ["Yes" "No"];
        Subj_menu = menu (msg, opts);
        switch Subj_menu
            case 1
                randomisation_table.Subj_ID{subjectNr} = params.subjectID;
                break
        end
    else
        break
    end
    
end

%%
% thisRun = cell2mat(randomisation_table.Properties.VariableNames(params.runNr+1));

params.taskOrder = randomisation_table.(thisRun){subjectNr};
Priority(1);
% HideCursor;
%%
% --- INITIALIZE 1
[params,ptb] = InitializeExp(params);
HideCursor;

waitingText='Waiting for MRI...';

DrawFormattedText(ptb.win_handle, waitingText, 'center', 'center', params.black, 60);
ptb.flip();

base_level = ptb.trigger_status;

params.base_level1 = base_level;

if ~params.isTest
    ptb.get_trigger(base_level, 7); % Wait for seventh trigger from MRI
end

params.MRIstart = GetSecs;
params.expStart=params.MRIstart;

waitingText='MRI ready';
Screen('TextSize',ptb.win_handle,18);
DrawFormattedText(ptb.win_handle, waitingText, 'center', 'center', params.black, 60);
ptb.flip();
time = struct();

for block = 1 :3
    
    params.blocknr = block + (params.runNr-1)*3;
    params.task = randomisation_table.(thisRun){subjectNr}(block);
    modality = params.modalities{params.task};
    % --- INITIALIZE 2
    [ptb, params, time] = InitializeExp2(ptb, params, time, block); % because we want to make sure the MRI is ready before we continue
    
    for trial=1:params.nTrials
        
        % --- STIMULI
        [FlipStart, params, ptb]=showtrial(params, modality, trial, ptb);
        
        time.ITI(trial)=FlipStart.t1-params.trialStart;
        time.Fixation(trial)=FlipStart.t2-FlipStart.t1;
        time.Stimulus(trial)=FlipStart.t3-FlipStart.t2;
        time.PostStim(trial)=FlipStart.t4-FlipStart.t3;
        
        time.MRI_Trialstart(trial) = params.trialStart-params.MRIstart;
        
        stimuli.intensity(trial)=params.intensity;
        
        % --- RESPONSE
        [params, response, ptb]=getResponse(params, modality, trial, ptb);
        
        responses.val(trial)=response.value;
        
        time.ResponseScreen(trial) = params.trialStart-params.t4;
        time.Response(trial)=params.t5-FlipStart.t4; % response time
        
        time.MRI_Fixation(trial) = params.t1-params.MRIstart;
        time.MRI_Stimulus(trial) = params.t2-params.MRIstart;
        time.MRI_PostStim(trial) = params.t3-params.MRIstart;
        time.MRI_ResponseScreen(trial) = params.t4-params.MRIstart;
        time.MRI_Response(trial) = params.t5-params.MRIstart;
        
        WaitSecs(0.001);
        
    end %for  trials
    
    params.blockEnd = GetSecs;
    
    % --- BLOCK END
    if params.runNr == 1 && block == 1
        [ptb, data, params, time] = stopthatshit(ptb, params, time, block, modality,  stimuli, responses); % no data variable yet for first block
    else
        [ptb, data, params, time] = stopthatshit(ptb, params, time, block, modality,  stimuli, responses, data);
    end
end %for blocks

% --- SAVE
if ~params.isTest
%     if ~exist('base_level', 'var')
%         base_level = NaN;
%     end
%     
    [data, params] = savethatshit(ptb, data, params, time, outDir, randomisation_table);
else
    ShowCursor;
    Priority(0);
    Screen('CloseAll')
end
