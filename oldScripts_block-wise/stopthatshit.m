function data=stopthatshit(outDir, params, ptb, time, EndTime, stimuli, responses)

if params.blocknr==0
    data=[];
    % release pressure
    ShowCursor;
    Priority(0)
    %ListenChar(0);
    Screen ('Close');
    Screen('CloseAll');
    
elseif params.blocknr>0
    
    data(params.blocknr).subID=params.subjectID;
    data(params.blocknr).blockNr=params.blocknr;
    data(params.blocknr).task=params.task;
    
    data(params.blocknr).trials=1:params.nTrials;
    data(params.blocknr).blockTime=(EndTime-params.expStart)/60;
    data(params.blocknr).StimuliOrder1=params.trialorder1(1:params.nTrials);
    data(params.blocknr).StimuliOrder2=params.trialorderRandom2(1:params.nTrials);
    data(params.blocknr).StimuliOrder3=params.trialorderRandom3(1:params.nTrials);
    data(params.blocknr).ResponseOrder=params.responseorderRandom(1:params.nTrials);
    
    data(params.blocknr).time=time;
    data(params.blocknr).response=responses.val;
    data(params.blocknr).stimuli=stimuli.intensity;
    
if params.blocknr==1
    save(fullfile(outDir,'data', strcat(params.fileName, '.mat')), 'data');
    save(fullfile(outDir,'params\', strcat(params.fileName, '_params.mat')),'params');
else
    load(fullfile(outDir,'data\', strcat(params.fileName, '.mat'))); 
end
        
        data(params.blocknr).subID=params.subjectID;
        data(params.blocknr).blockNr=params.blocknr;
        data(params.blocknr).task=params.task;
        
        data(params.blocknr).trials=1:params.nTrials;
        data(params.blocknr).blockTime=(EndTime-params.expStart)/60;
        data(params.blocknr).StimuliOrder1=params.trialorder1(1:params.nTrials);
        data(params.blocknr).StimuliOrder2=params.trialorderRandom2(1:params.nTrials);
        data(params.blocknr).StimuliOrder3=params.trialorderRandom3(1:params.nTrials);
        data(params.blocknr).ResponseOrder=params.responseorderRandom(1:params.nTrials);
        
        data(params.blocknr).time=time;
        data(params.blocknr).response=responses.val;
        data(params.blocknr).stimuli=stimuli.intensity;
        
        save(fullfile(outDir,'data', strcat(params.fileName, '.mat')), 'data');
    end %if
    
    Screen ('Close',ptb.win_handle);
    Screen('CloseAll');
    
end %if

ShowCursor;
Priority(0)

