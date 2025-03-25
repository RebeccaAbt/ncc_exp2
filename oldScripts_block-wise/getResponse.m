function [params, response,ptb]=getResponse(params, trial,ptb)

% --- response

if params.responseorderRandom(trial)==1
    text1 = 'yes';
    text2 = 'no';
else
    text1 = 'no';
    text2 = 'yes';
end

Screen('TextSize', ptb.win_handle, 50);

    blue = [0, 0, 255];
    yellow= [255, 255, 0];
    Screen('DrawDots', ptb.win_handle, [params.x0-300;params.y0-200], 20, blue,[],1);
    Screen('DrawDots', ptb.win_handle, [params.x0+300;params.y0-200], 20, yellow,[],1);


    DrawFormattedText(ptb.win_handle, text1, params.x0-350, params.y0, [0 0 0]);
    DrawFormattedText(ptb.win_handle, text2, params.x0+250, params.y0, [0 0 0]);


% % Draw the circles
% Screen('FillOval', ptb.win_handle, params.blue,   CenterRectOnPointd([0 0 params.r*2 params.r*2], params.blue_x,   params.blue_y));
% Screen('FillOval', ptb.win_handle, params.yellow, CenterRectOnPointd([0 0 params.r*2 params.r*2], params.yellow_x, params.yellow_y));
% 
% % Draw the text
% DrawFormattedText(ptb.win_handle, text1, 'center', 'center', [0 0 0], [], [], [], [], [], [params.blue_x   - params.r, params.y0 - params.r, params.blue_x +   params.r, params.y0 + params.r]);
% DrawFormattedText(ptb.win_handle, text2, 'center', 'center', [0 0 0], [], [], [], [], [], [params.yellow_x - params.r, params.y0 - params.r, params.yellow_x + params.r, params.y0 + params.r]);

Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
ptb.flip();

% --- get response + wait rest of the time

timeout = 3;
response_t1 = GetSecs;  
response.key = ptb.wait_for_keys({'target', 'other_target'}, response_t1 + timeout);
response_t2 = GetSecs - response_t1;  
remainingTime = timeout - response_t2;  
if remainingTime > 0
    WaitSecs(remainingTime);  
end

if ~isempty(response.key)
    if params.responseorderRandom(trial)==1 && strcmp(response.key, 'target')
        response.value=1;
    elseif params.responseorderRandom(trial)==1 && strcmp(response.key, 'other_target')
        response.value=0;
    elseif params.responseorderRandom(trial)==2 && strcmp(response.key, 'target')
        response.value=0;
    elseif params.responseorderRandom(trial)==2 && strcmp(response.key, 'other_target')
        response.value=1;
    end
else
    response.value=NaN;
end

if ~isnan(response.value)
    params.stimuli(params.trialorderRandom2(trial)).thr.process_response(response.value,params.intensity);
else
end

params.trialStart=GetSecs;