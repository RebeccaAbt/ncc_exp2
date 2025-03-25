function [ptb, params, time] = InitializeExp2(ptb, params, time, block)

% ListenChar(2);
Screen('FillRect', ptb.win_handle, params.backgrcolor);
Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
Screen('TextSize', ptb.win_handle, 60);

intro = 'The next block will start now!\n\n';

if params.task==1
    intro=strcat(intro, 'Can you hear it ?');
    
elseif params.task==2 
    intro=strcat(intro, 'Can you feel it ?');

elseif params.task==3
    intro=strcat(intro, 'Can you see it ?');
end

DrawFormattedText(ptb.win_handle, intro, 'center', 'center', params.black, 60);
IntroStart = ptb.flip();

time.MRI_Intro = IntroStart-params.MRIstart;

[params.trialStart] = WaitSecs(5);

params.blockStart = params.trialStart;

time.Intro = params.blockStart-IntroStart;


end