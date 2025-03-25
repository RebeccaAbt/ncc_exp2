function [params, ptb] = InitializeExp2(ptb, params, block)


    % ListenChar(2);
    Screen('FillRect', ptb.win_handle, params.backgrcolor);
    Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
    Screen('TextSize', ptb.win_handle, 60);
    
    intro = 'The next block will start now!\n\n'; 
  
    intro=strcat(intro, 'Can you feel it ?');

    DrawFormattedText(ptb.win_handle, intro, 'center', 'center', params.black, 60);
    ptb.flip();

    [params.trialStart] = WaitSecs(2); % don't wait for kbPress to control length of experimental block

    params.blockStart=GetSecs;

end