function data=stopthatshit(outDir, params, modality, ptb, time, stimuli, responses, block, data)

params.blockEnd = GetSecs;

time.blockDuration = params.blockEnd-params.blockStart;
time.MRI_blockStart = params.blockStart-params.MRIstart;

data(params.blocknr).subID=params.subjectID;
data(params.blocknr).blockNr=params.blocknr;
data(params.blocknr).task=params.task;
data(params.blocknr).trials=1:params.nTrials;

data(params.blocknr).StimuliOrder1=params.(modality).trialorder1(1:params.nTrials);
data(params.blocknr).StimuliOrder2=params.(modality).trialorderRandom2(1:params.nTrials);
data(params.blocknr).StimuliOrder3=params.(modality).trialorderRandom3(1:params.nTrials);
data(params.blocknr).ResponseOrder=params.(modality).responseorderRandom(1:params.nTrials);

data(params.blocknr).time=time;
data(params.blocknr).response=responses.val;
data(params.blocknr).stimuli=stimuli.intensity;

feedback='Thank you! You have finished this block.';
Screen('TextSize',ptb.win_handle,40);
DrawFormattedText(ptb.win_handle, feedback, 'center', 'center', params.black, 60);
Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
Screen('Flip',ptb.win_handle)


WaitSecs(2)

if block ~= 10
    
    if ~params.isTest
        
       ptb.draw(params.fix_cross);
        Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
        Screen('Flip',ptb.win_handle)
        WaitSecs(1)
           
    end %if
    
end %if

