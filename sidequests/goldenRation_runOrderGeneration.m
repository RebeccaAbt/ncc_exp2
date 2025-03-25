% clear variables
cd 'C:\Users\mrsre\NCC_MRI\NCC_exp2'

outDir = 'C:\Users\mrsre\NCC_MRI\other\behav_data';

load("randomisation_table.mat")

% create some entries for testing
randomisation_table.Subj_ID{1} = 'ajrn';
randomisation_table.Subj_ID{2} = 'ekse';
randomisation_table.Subj_ID{3} = 'btre';


[randomisation_table, params] = getStarted(outDir, randomisation_table);

function [randomisation_table, params] = getStarted(outDir, randomisation_table)

% Input from User:
choice_1 = nextStep();

% Depending on Input ....

% 1) create new Subj

if choice_1 == 1
    subjectID = inputdlg('Subject ID','Experiment'); % get ID

    [new_Sub,~] = subjNr(randomisation_table); % find next new line in table
    randomisation_table.Subj_ID{new_Sub} = subjectID{1}; % write ID in table
    task = randomisation_table.block1(new_Sub); % first task

    params.subjectID=subjectID{1};
    params.fileName=subjectID{1};
    params.blocknr = 1;
    params.task = task;
end

% 2) continue with last subject

if choice_1 == 2 % continue with last subj

    [~,last_Subj] = subjNr(randomisation_table);    % Find last Subj from List
    subjectID = randomisation_table.Subj_ID{last_Subj};    % get Subj ID

    msg = "This is the ID of the last Subject. Is this correct? ";
    opts = ["Yes, continue with next block" "No, correct the Subj ID" "<-- Go back"];
    choice_2 = menu(msg,opts);
    
    if choice_2 == 1
    load(fullfile(outDir, strcat(subjectID, '.mat'))) % load Data from Subj

    blocknr = length(data) + 1; % number of next block
    task = randomisation_table.(strcat('block', num2str(blocknr)))(last_Subj); % task of next block

    params.subjectID = subjectID;
    params.fileName = subjectID;
    params.blocknr = blocknr;
    params.task=task;
   
    end
end

% 3) manually define params

if choice_1 == 3
    subjectID= inputdlg('Subject ID?', 'Experiment');
    blocknr=inputdlg('Blocknumber?', 'Experiment');
    task = inputdlg('auditory=1, somatosensory=2, visual=3'); % 4 blocks each, 8(12) total

    params.subjectID=subjectID{1};
    params.fileName=subjectID{1};
    params.blocknr=str2double(blocknr{1});
    params.task=str2double(task{1});
end

end

%% helper functions

function choice = nextStep()
msg = "What do you want to do?";
opts = ["Create new Subj" "Continue with last Subj" "Choose Subj_ID and block number manually"];
choice = menu(msg,opts);
end


function [newSubj, last_Subj] = subjNr(randomisation_table)

newSubj = 1;

if ~isempty(randomisation_table.Subj_ID{1})
    is_subj = 1;
    newSubj = 0;

    while true % find fist empty line for new Subj
        newSubj = newSubj+1;
        is_subj = ~isempty(randomisation_table.Subj_ID{newSubj});
        if ~is_subj
            last_Subj = newSubj-1;
            break
        end
    end
end
end












