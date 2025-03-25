function [data, params] = savethatshit(ptb, data, params, time, outDir, randomisation_table)



EndTime=GetSecs; % now here! instead of in "stopthatshit" --> so we have the timing of the experiment, not the MRI sequence!

data(params.blocknr).runTime=(EndTime-params.expStart)/60;
data(params.blocknr).runTime_duration = seconds(EndTime-params.expStart); % duration in minutes & seconds
data(params.blocknr).runTime_duration.Format = 'mm:ss.SSS';

time.MRI_blockStart = params.blockStart-params.MRIstart;
time.MRI_blockEnd = EndTime-params.MRIstart;
MRI_EndTime = EndTime-params.MRIstart;

base_level2 = ptb.trigger_status;
tic;
if ~params.isTest
    [MRIstop, recordedTriggers, out_message] = get_lasttrigger(ptb, params.base_level1);
    MRIstop2 = GetSecs;
else
    MRIstop = GetSecs;
    warning('using dummy value instead of real MRI trigger!!')
end
WaitTime = toc;

% ------------- v for testing without trigger
% MRIstop = GetSecs;
% warning('using dummy value instead of real MRI trigger!!')
% ------------- ^

MRIduration = MRIstop-params.MRIstart;
MRIduration = seconds(MRIduration);  % Convert seconds to a duration object
MRIduration.Format = 'mm:ss.SSS';
time.MRI_Duration = MRIduration;

MRIduration2 = MRIstop2-params.MRIstart; 
MRIduration2 = seconds(MRIduration2);  % Convert seconds to a duration object
MRIduration2.Format = 'mm:ss.SSS';

ShowCursor;
Priority(0);

save(fullfile(outDir,'data', strcat(params.fileName, '.mat')), 'data');
Screen ('Close');
Screen('CloseAll');

logs = [];
logs.recordedTriggers = recordedTriggers;
logs.out_message = out_message;
logs.base_level1 = params.base_level1;
logs.base_level2 = base_level2;
logs.WaitTime = WaitTime;
logs.MRIduration = MRIduration;
logs.MRIduration2 = MRIduration2;
% sort params alphabetically

[~, neworder] = sort(lower(fieldnames(params)));
params = orderfields(params, neworder);

if params.runNr == 1
    save(fullfile(outDir,'params\', strcat(params.fileName, '_params.mat')), 'params');
    save(fullfile(outDir,'logs\', strcat(params.fileName, '_run2_logs.mat')), 'logs');
end

if ~params.isTest
    save("randomisation_table.mat", "randomisation_table")
end

end