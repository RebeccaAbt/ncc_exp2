function [ptb, data, params, time] = stopthatshit(ptb, params, time, block, modality,  stimuli, responses, data)

params.blockEnd = GetSecs;

time.blockDuration = params.blockEnd-params.blockStart;

data(params.blocknr).subID=params.subjectID;
data(params.blocknr).blockNr=params.blocknr;
data(params.blocknr).task=params.task;
data(params.blocknr).trials=1:params.nTrials;

data(params.blocknr).StimuliOrder1=params.(modality).trialorder1(1:params.nTrials);
data(params.blocknr).StimuliOrder2=params.(modality).trialorderRandom2(1:params.nTrials);
data(params.blocknr).StimuliOrder3=params.(modality).trialorderRandom3(1:params.nTrials);
data(params.blocknr).ResponseOrder=params.(modality).responseorderRandom(1:params.nTrials);

data(params.blocknr).response=responses.val;
data(params.blocknr).stimuli=stimuli.intensity;

feedback='Thank you! You have finished this block.';
Screen('TextSize',ptb.win_handle,40);
DrawFormattedText(ptb.win_handle, feedback, 'center', 'center', params.black, 60);
Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
OutroStart = Screen('Flip',ptb.win_handle);

time.MRI_Outro = OutroStart-params.MRIstart;
time.Outro = WaitSecs(5)-OutroStart;
waitTime = 20;
if block ~= 3
    
    if ~params.isTest
        
        ptb.draw(params.fix_cross);
        Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
        waitScreeenStart = Screen('Flip',ptb.win_handle);
        time.MRI_WaitScreen = waitScreeenStart-params.MRIstart;
      
        if params.taskOrder(block+1) == 2
            waitTime = 20;
            wait_t1 = GetSecs;
            ptb.setup_tactile;
            ptb.wait_for_stimulators()
            wait_t2 = GetSecs;
            remainingTime = waitTime - (wait_t2 - wait_t1);
            time.WaitScreen = WaitSecs(remainingTime)-waitScreeenStart;
        else
            time.WaitScreen = WaitSecs(waitTime)-waitScreeenStart;
        end
    else
        if ~strcmp(modality, 'tactile') && ~params.isTest
            ptb.setup_tactile;
            ptb.wait_for_stimulators()
        end
    end %if
    
end %if

% order time structure alphabetically
time = orderfields(time);
% save time in data
data(params.blocknr).time=time;

