function [data, params] = savethatshit(ptb, data, params, time, outDir, randomisation_table)

EndTime=GetSecs; % now here! instead of in "stopthatshit" --> so we have the timing of the experiment, not the MRI sequence!

data(params.blocknr).runTime=(EndTime-params.expStart)/60;
data(params.blocknr).runTime_duration = seconds(EndTime-params.expStart); % duration in minutes & seconds
data(params.blocknr).runTime_duration.Format = 'mm:ss.SSS';

time.MRI_blockStart = params.blockStart-params.MRIstart;
time.MRI_blockEnd = EndTime-params.MRIstart;
MRI_EndTime = EndTime-params.MRIstart;


% [MRIstop, recordedTriggers] = get_lasttrigger(ptb);

MRIstop = GetSecs; 
% warning('using dummy value instead of real MRI trigger!!')


MRIduration = MRIstop-params.MRIstart;
MRIduration = seconds(MRIduration);  % Convert seconds to a duration object
MRIduration.Format = 'mm:ss.SSS';
time.MRI_Duration = MRIduration;

ShowCursor;
Priority(0);

[~, neworder] = sort(lower(fieldnames(params)));
params = orderfields(params, neworder);

save(fullfile(outDir,'data', strcat(params.fileName, '.mat')), 'data');
Screen ('Close');
Screen('CloseAll');
if params.runNr == 1
    save(fullfile(outDir,'params\', strcat(params.fileName, '_params.mat')), 'params');
end

if ~params.isTest
save("randomisation_table.mat", "randomisation_table")
end

end