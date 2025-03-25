clear all
mainDir = 'C:\Users\Andi\Desktop\NCC_exp2\';
% mainDir = 'C:\Users\mrsre\NCC_MRI\NCC_exp2';

dataDir = (mainDir + "\data\");
outDir  = (mainDir + "\log\");

cd(dataDir)

load('newLog.mat')

%%
varNames = {'onset', 'duration', 'event', 'trial', 'block', 'modality', 'condition', 'stimulus', 'intensity', 'response'};

eventTypes = ["ITI", "Fixation", "Stimulus", "PostStim", "ResponseScreen", "Response"];
onsets = {'MRI_Trialstart', 'MRI_Fixation', 'MRI_Stimulus', 'MRI_PostStim', 'MRI_ResponseScreen', 'MRI_Response'};
durations = {'ITI', 'Fixation', 'Stimulus', 'PostStim', 'ResponseScreen', 'Response'};

myTable = cell2table(cell(0, length(varNames)), 'VariableNames', varNames);

%%
for iBlock = 1:3
    time = data(iBlock).time;
    
    event = "Intro";
    onset = time.MRI_Intro;
    duration = time.Intro;
    trial = 0;
    block = iBlock;
    modality = data(iBlock).task;
    condition = 0;
    stimulus = 0;
    intensity = NaN;
    response = NaN;
    
    newRow = table(onset, duration, event, trial, block, modality, condition, stimulus, intensity, response, 'VariableNames', varNames);
    myTable = [myTable;newRow];
    
    for iTrial = 1:length(data(iBlock).trials)
        
        for iParams = 1:length(eventTypes)
            
            event       = eventTypes(iParams);
            onset       = time.(onsets{iParams})(iTrial);
            duration    = time.(durations{iParams})(iTrial);
            trial       = iTrial;
            block       = iBlock;
            modality    = data(iBlock).task;
            condition   = data(iBlock).StimuliOrder3(iTrial);
            stimulus 	= data(iBlock).StimuliOrder2(iTrial);
            intensity   = NaN;
            response = NaN;
            
            switch iParams
                
                case 3 % Stimulus
                    intensity   = data(iBlock).stimuli(iTrial);
                case 6
                    response = data(iBlock).response(iTrial);
                    if isnan(response)
                        duration = response; % set duration to NaN to indicate that there was no reaction / reaction time
                    end
            end
            
            newRow = table(onset, duration, event, trial, block, modality, condition, stimulus, intensity, response, 'VariableNames', varNames);
            myTable = [myTable;newRow];
            
        end
    end
    
    event = "Outro";
    onset = time.MRI_Outro;
    duration = time.Outro;
    trial = 0;
    block = iBlock;
    modality = 0;
    condition = 0;
    stimulus = 0;
    intensity = NaN;
    response = NaN;
    
    newRow = table(onset, duration, event, trial, block, modality, condition, stimulus, intensity, response, 'VariableNames', varNames);
    myTable = [myTable;newRow];
    
    if iBlock ~=3
        
        event = "WaitScreen";
        onset = time.MRI_WaitScreen;
        duration = time.WaitScreen;
        trial = 0;
        block = 0;
        modality = 0;
        condition = 0;
        stimulus = 0;
        intensity = NaN;
        response = NaN;
        
        newRow = table(onset, duration, event, trial, block, modality, condition, stimulus, intensity, response, 'VariableNames', varNames);
        myTable = [myTable;newRow];
    end
    
end

disp(myTable)

%%

cd(outDir)

writetable(myTable, 'test.tsv', 'FileType', 'text', 'delimiter', '\t')



