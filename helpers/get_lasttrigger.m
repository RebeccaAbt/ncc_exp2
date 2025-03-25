function [endTrigger, recordedTriggers, out_message] = get_lasttrigger(ptb, base_level)

if nargin < 2
    base_level = 0;
end

fprintf(['\n------------------------------------- \n' ...
    '    waiting for last trigger from MRI... \n' ...
    '------------------------------------- \n'])

[recordedTriggers, out_message] = recordtriggers(ptb, base_level);

triggerTimes = struct('time', {}, 'triggered', {});

recentValue = recordedTriggers(1).triggered; % determine, whether first value is 0 or 1
startTime = recordedTriggers(1).GetSecs;

triggerTimes(end+1) = struct('time', startTime, 'triggered', recentValue);

for i = 1:length(recordedTriggers)  % go through all trigger values
    if recordedTriggers(i).triggered ~= recentValue % find time points, where new value (0 or 1) starts
        recentValue = recordedTriggers(i).triggered;
        startTime = recordedTriggers(i).GetSecs;
        triggerTimes(end+1) = struct('time', startTime, 'triggered', recentValue);
    end
end


if length([triggerTimes.triggered]) >1
    endTrigger = triggerTimes(end-1).time; % last trigger = when last "1" section began (= beginning of last trigger)
else
    endTrigger = 0; % if no trigger was received, because MRI ended before...
end

end


function [recordedTriggers, out_message] = recordtriggers(ptb, base_level)
recordedTriggers = struct('GetSecs', {}, 'triggered', {});

trigger_level = ~base_level;

noTriggers = 50;
timeout = 3;

while true
    currentTime = GetSecs;
    triggered = ptb.trigger_status(5, 'FIO');
    
    recordedTriggers(end+1) = struct('GetSecs', currentTime, 'triggered', triggered);
    
    % --- option 1: append at end of structure; wait until 50 times no trigger received
    % end after set number of "no Trigger" signals"
    
    %     if length(recordTriggers) > noTriggers && sum([recordTriggers(end-noTriggers:end).Triggered]) == 0
    
    % --- option 2: wait
    
    recentTriggerIndex = find([recordedTriggers.triggered] == trigger_level, 1, 'last');
    
    recentBaseIndex = find([recordedTriggers.triggered] == base_level, 1, 'last');
    
    
    if ~isempty(recentTriggerIndex) && recordedTriggers(end).GetSecs - recordedTriggers(recentTriggerIndex).GetSecs > timeout
        
        out_message = 'Last MRI trigger received!';
        fprintf('\n------------------------------------- \n    %s \n------------------------------------- \n', out_message);
        break
        
    elseif ~isempty(recentBaseIndex) && recordedTriggers(end).GetSecs - recordedTriggers(recentBaseIndex).GetSecs > timeout
        
        out_message = 'Last MRI trigger received differently than expected\n';
        fprintf('\n------------------------------------- \n    %s \n------------------------------------- \n', out_message);
        break
        
    elseif ~sum([recordedTriggers.triggered] == trigger_level) && recordedTriggers(end).GetSecs - recordedTriggers(1).GetSecs > timeout
        out_message = 'No Trigger received! Recording ended before!'; 
        warning('    No Trigger received! Recording ended before!')
        break
    end
end
end