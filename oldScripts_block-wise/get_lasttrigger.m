function [endTrigger, recordedTriggers] = get_lasttrigger(ptb)

fprintf(['\n------------------------------------- \n' ...
         '    waiting for last trigger from MRI... \n' ...
            '------------------------------------- \n'])

recordedTriggers = recordtriggers(ptb);

fieldNames = fieldnames(recordedTriggers);
endTrigger = NaN;

for i  = (length(recordedTriggers): -1 : 1)

    if recordedTriggers(i).(fieldNames{2}) == 1
        endTrigger = recordedTriggers(i).(fieldNames{1}) ;
        break
    end
end
end


function recordedTriggers = recordtriggers(ptb)
recordedTriggers = struct('GetSecs', {}, 'Triggered', {});

noTriggers = 50;
timeout = 2;

while true
    currentTime = GetSecs;
    triggered = ptb.trigger_status(5, 'FIO');

    recordedTriggers(end+1) = struct('GetSecs', currentTime, 'Triggered', triggered);

    % --- option 1: append at end of structure; wait until 50 times no trigger received
                  % end after set number of "no Trigger" signals"  
    
%     if length(recordTriggers) > noTriggers && sum([recordTriggers(end-noTriggers:end).Triggered]) == 0 
    
    % --- option 2

    indices = length(recordedTriggers):-1:1; % use reverse indexing
    recentTriggerIndex = find(arrayfun(@(i) ismember(1, recordedTriggers(i).Triggered), indices), 1); % find most recent trigger index
    recentTriggerIndex = length(indices)-recentTriggerIndex+1; % we need the right index, not the inverse one

    % this solution doesn't work in case the MRI is done before the
    % experiment is done )because then "recentTriggerIndex" will always be
    % empty
    if ~isempty(recentTriggerIndex) && recordedTriggers(end).GetSecs - recordedTriggers(recentTriggerIndex).GetSecs > timeout

        fprintf(['\n------------------------------------- \n' ...
            '    Last MRI trigger received! \n' ...
            '------------------------------------- \n'])
        break
    elseif ~sum([recordedTriggers.Triggered]) && recordedTriggers(end).GetSecs - recordedTriggers(1).GetSecs > timeout
        warning('    No Trigger received! Recording ended before!')
        break
    end
    
    
    
    WaitSecs(0.01);
end
end