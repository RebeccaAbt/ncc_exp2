function [params, ptb] = InitializeExp2(ptb, params, block)


% ListenChar(2);
Screen('FillRect', ptb.win_handle, params.backgrcolor);
Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
Screen('TextSize', ptb.win_handle, 60);

intro = 'The next block will start now!\n\n';

a = ptb.trigger_status % too keep the labjack busy

if params.task==1
    intro=strcat(intro, 'Can you hear it ?');
    
elseif params.task==2
    
%     --------------------------------------------- v  this is to "loosen" elements of the stimulator
%     testtext=strcat('Quick tactile test...');
%     
%     DrawFormattedText(ptb.win_handle, testtext, 'center', 'center', params.black, 60);
%     ptb.flip();
%     
%     for iFinger = 1:4
%         stim_object = o_ptb.stimuli.tactile.Base('left', iFinger, 150, 80, 0.5);
%             ptb.prepare_tactile(stim_object, 0, 0);
%             ptb.schedule_tactile();
%             ptb.play_without_flip();
%             WaitSecs(0.5);
%         
%     end
      % --------------------------------------------- ^   
    intro=strcat(intro, 'Can you feel it ?');
    
    
elseif params.task==3
    intro=strcat(intro, 'Can you see it ?');
end

DrawFormattedText(ptb.win_handle, intro, 'center', 'center', params.black, 60);
ptb.flip();

[params.trialStart] = WaitSecs(5); % don't wait for kbPress to control length of experimental block

params.blockStart=GetSecs;

end