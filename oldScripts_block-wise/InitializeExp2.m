function [params, ptb] = InitializeExp2(ptb, params)
    Screen('BlendFunction', ptb.win_handle, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    KbName('UnifyKeyNames');
    HideCursor;
    
    Priority(1);
    % ListenChar(2);
    Screen('FillRect', ptb.win_handle, params.backgrcolor);
    Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
    
    
    % ------------------------------------------------------ v
    intro = 'The next block will start now!\n\n'; 
  
    if params.task==1
        intro=strcat(intro, 'Can you hear it ?');
    elseif params.task==2
        intro=strcat(intro, 'Can you feel it ?');
    elseif params.task==3
        intro=strcat(intro, 'Can you see it ?');
    end
    % ------------------------------------------------------ ^

    DrawFormattedText(ptb.win_handle, intro, 'center', 'center', params.black, 60);
    ptb.flip();

    % ------------------------------------------------------ ~
    % KbWait; [params.trialStart]=KbReleaseWait;
    % ------------------------------------------------------ ~
    % [params.trialStart]=WaitSecs(21);
    % WaitSecs(2)
    % ------------------------------------------------------ v
    [params.trialStart] = WaitSecs(5); % don't wait for kbPress to control length of experimental block
    % ------------------------------------------------------ ^
    params.expStart=GetSecs;

end