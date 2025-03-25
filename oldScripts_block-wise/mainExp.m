    %% clear
clear all global
close all;
restoredefaultpath
commandwindow

cd('C:\Users\Andi\Desktop\NCC_exp2\')
addpath('C:\Users\Andi\Desktop\NCC_exp2\o_ptb\');
o_ptb.init_ptb('C:\Toolboxes\Psychtoolbox\');
addpath('C:\Users\Andi\Desktop\NCC_exp2\toolbox\');
outDir = 'C:\Users\Andi\Desktop\Rebecca Tinkering\test data\';


% cd('C:\Rebecca\Uni\NCC_MRI\NCC_exp2')
% addpath('C:\Rebecca\Uni\NCC_MRI\NCC_exp2\o_ptb\');
% o_ptb.init_ptb('C:\Users\mrsre\MATLAB\Psychtoolbox-3-master\Psychtoolbox');
% addpath('C:\Rebecca\Uni\NCC_MRI\NCC_exp1\toolbox\');
% outDir = 'C:\Rebecca\Uni\NCC_MRI\Rebecca Tinkering\test data\';


disp('For the first block sujectID should be "test"')

[params,ptb] = InitializeExp(outDir); % only part 1 now, because we want to everythin to be prepared before we start the MRI


sca


waitingText='Waiting for MRI...';
Screen('TextSize',ptb.win_handle,18);
DrawFormattedText(ptb.win_handle, waitingText, 'center', 'center', params.black, 60);
ptb.flip();

fprintf('\n\nnow we wait for the trigger...\n\n')

ptb.get_trigger(5)
MRIstart = GetSecs;

waitingText='MRI ready';
Screen('TextSize',ptb.win_handle,18);
DrawFormattedText(ptb.win_handle, waitingText, 'center', 'center', params.black, 60);
ptb.flip();

[params, ptb]=InitializeExp2(ptb, params); % because we want to make sure the MRI is ready before we continue

for trial=1:params.nTrials
    
    % STIMULI
    [FlipStart, params, trial, ptb]=showtrial(params, trial, ptb);
    time.ITI(trial)=FlipStart.t1-params.trialStart;    
    time.Fixation(trial)=FlipStart.t2-FlipStart.t1;    
    time.Stimulus(trial)=FlipStart.t3-FlipStart.t2;
    time.PostStim(trial)=FlipStart.t4-FlipStart.t3;
    stimuli.intensity(trial)=params.intensity;
    
    % RESPONSE
    [params, response, ptb]=getResponse(params, trial, ptb);

    time.MRItrials(trial) = params.trialStart-MRIstart; 
    time.MRIstim(trial) = params.t2-MRIstart; 
    time.response(trial)=params.trialStart-FlipStart.t4;
    responses.val(trial)=response.value;

    WaitSecs(0.001);
    
end

feedback='Thank you! You have finished this block.';
Screen('TextSize',ptb.win_handle,18);
DrawFormattedText(ptb.win_handle, feedback, 'center', 'center', params.black, 60);
Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);

Screen('Flip',ptb.win_handle);

EndTime=GetSecs; % now here! instead of in "stopthatshit" --> so we have the timing of the experiment, not the MRI sequence!
[MRIend, recordedTriggers] = get_lasttrigger(ptb);
time.MRI(1, 1:2) = [MRIstart, MRIend];

WaitSecs(1);

data = stopthatshit(outDir, params, ptb, time, EndTime, stimuli, responses); % now save it

