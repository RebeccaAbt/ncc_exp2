function [randomisation_table, params] = userDialog(outDir, randomisation_table)
close all

if isempty(randomisation_table.Subj_ID{1}) % if this is the first Subject
    msg = "No subjects in this list." + newline + newline;
    opts = ["Create new Subject" "Manual Input" "Stop"];
    firstSubj_menu = menu (msg, opts);
    switch firstSubj_menu
        case 1 % create new Subj

            while true
                go_back = false;
                subjectID = inputdlg('Subject ID','Experiment'); % get ID
                ID_menu = checkID(subjectID);
                switch ID_menu
                    case 1 % confirm ID

                        randomisation_table.Subj_ID{1} = subjectID{1}; % ID for fist Subj ID in table
                        task = randomisation_table.block1(1); % first task

                        params.subjectID=subjectID{1};
                        params.fileName=subjectID{1};
                        params.blocknr = 1;
                        params.task = task;
                        break

                    case 2  % wrong ID

                    case 3 % back to menu
                        params = [];
                        go_back = true;
                        break
                end %switch ID_menu
            end %while

        case 2 % manual input
                subjectID= inputdlg('Subject ID?', 'Experiment');
                blocknr=inputdlg('Blocknumber?', 'Experiment');
                task = inputdlg('auditory=1, somatosensory=2, visual=3'); % 4 blocks each, 8(12) total

                params.subjectID=subjectID{1};
                params.fileName=subjectID{1};
                params.blocknr=str2double(blocknr{1});
                params.task=str2double(task{1});
                
        case 3 % Stop
    end
else % if not the first subject

    while true
        msg = "What do you want to do?";
        opts = [    "Create new Subject"                        % 1
            "Continue with last Subject"                % 2
            "Manual Input"  % 3
            "Show list of all previous subjects"                     % 4
            "Delete last Subject ID";                   % 5
            "Look for number of existing behav. files. Next sequence based on this number. "]; %6
        menu1 = menu(msg,opts);

        switch menu1

            case 1 % ========================================================== create new Subj

                while true
                    go_back = false;
                    [new_Subj,~] = subjNr(randomisation_table);

                    msg =   "New subject will have the running order nr.   " + newline + newline + new_Subj;
                    opts = ["OK"];
                    menu(msg,opts)

                    subjectID = inputdlg('Subject ID','Experiment'); % get ID
                    ID_menu = checkID(subjectID);

                    switch ID_menu
                        case 1
                            randomisation_table.Subj_ID{new_Subj} = subjectID{1}; % write ID in table
                            task = randomisation_table.block1(new_Subj); % first task

                            params.subjectID=subjectID{1};
                            params.fileName=subjectID{1};
                            params.blocknr = 1;
                            params.task = task;
                            break

                        case 2  % wrong ID

                        case 3 % back to menu
                            params = [];
                            go_back = true;
                            break
                    end %switch ID_menu
                end %while

                if ~go_back
                    break
                end %if

            case 2 % ========================================================== continue with last subj

                go_back = false;
                [~,last_Subj] = subjNr(randomisation_table);    % Find last Subj from List
                subjectID = randomisation_table.Subj_ID{last_Subj};    % get Subj ID

                ID_menu = checkID({subjectID}); % ID correct?

                switch ID_menu
                    case 1 % -------------------------------------------------- ID correct --> Continue

                        load(fullfile(outDir, strcat(subjectID, '.mat'))) % load Data from Subj

                        blocknr = length(data) + 1; % number of next block
                        task = randomisation_table.(strcat('block', num2str(blocknr)))(last_Subj); % task of next block

                        params.subjectID = subjectID;
                        params.fileName = subjectID;
                        params.blocknr = blocknr;
                        params.task=task;

                    case 2 % -------------------------------------------------- ID incorrect --> New Name

                        rename_menu = createConfirmationDialog(); % Sicher, dass neuer Name?

                        switch rename_menu
                            case 1 % yes, new ID
                                while true
                                    go_back = false;
                                    subjectID = inputdlg('Subject ID','Experiment'); % get ID
                                    ID_menu = checkID(subjectID);

                                    switch ID_menu
                                        case 1
                                            [~,last_Subj] = subjNr(randomisation_table); % find next new line in table
                                            randomisation_table.Subj_ID{last_Subj} = subjectID{1}; % write ID in table

                                            load(fullfile(outDir, strcat(subjectID{1}, '.mat'))) % load Data from Subj

                                            blocknr = length(data) + 1; % number of next block
                                            task = randomisation_table.(strcat('block', num2str(blocknr)))(last_Subj); % task of next block

                                            params.subjectID = subjectID;
                                            params.fileName = subjectID;
                                            params.blocknr = blocknr;
                                            params.task=task;
                                            break

                                        case 2  % wrong ID

                                        case 3 % back to menu
                                            params = [];
                                            go_back = true;
                                            break
                                    end %switch
                                end %while

                            case 2 % No
                                go_back = true;
                        end %switch

                    case 3 % -------------------------------------------------- Back
                        params = [];
                        go_back = true;
                end %switch

                if ~go_back
                    break
                end %if

            case 3 % ========================================================== manually define params

                subjectID= inputdlg('Subject ID?', 'Experiment');
                blocknr=inputdlg('Blocknumber?', 'Experiment');
                task = inputdlg('auditory=1, somatosensory=2, visual=3'); % 4 blocks each, 8(12) total

                params.subjectID=subjectID{1};
                params.fileName=subjectID{1};
                params.blocknr=str2double(blocknr{1});
                params.task=str2double(task{1});
                break

            case 4 % ========================================================== show last subject IDs

                [~, last_Subj] = subjNr(randomisation_table);

                msg = "Previous Subjects: " + newline;
                subjIndices = find(~cellfun(@isempty, randomisation_table.Subj_ID));

                for i = 1:length(subjIndices)
                    subj = strcat("Nr. ", num2str(subjIndices(i)), ":   ", randomisation_table.Subj_ID{subjIndices(i)}, "     ");
                    msg = msg + newline + subj;  % Append each subject's information to the message
                end %for

                opts = ["OK"];
                menu(msg,opts);
                go_back = true;

            case 5 % ========================================================== delete last Subject ID

                [~, last_Subj] = subjNr(randomisation_table);
                msg = strcat("Delete subject    --->  ", randomisation_table.Subj_ID{last_Subj}, "     ?");
                opts = ["Yes" "No"];
                delete_menu = menu(msg,opts);
                switch delete_menu
                    case 1
                        randomisation_table.Subj_ID{last_Subj} = '';
                    case 2
                end %switch

            case 6 % ========================================================== check number of existing behav. files

                behavFiles = dir(fullfile(outDir,"*.mat"));
                msg =   "There are  " + num2str(length(behavFiles)) + "  files in the directory" + newline + newline + outDir + newline + newline + ...
                    "Create new subject with running order " + num2str(length(behavFiles)+1) + " ?";
                opts = ["OK", "No"];

                menu2 = menu(msg,opts);
                switch menu2 % create new Subj in line x?
                    case 1 % yes

                        while true
                            go_back = false;
                            subjectID = inputdlg('Subject ID','Experiment'); % get ID
                            ID_menu = checkID(subjectID);

                            switch ID_menu
                                case 1
                                    randomisation_table.Subj_ID{length(behavFiles)+1} = subjectID{1}; % write ID in table
                                    task = randomisation_table.block1(length(behavFiles)+1); % first task

                                    params.subjectID=subjectID{1};
                                    params.fileName=subjectID{1};
                                    params.blocknr = 1;
                                    params.task = task;
                                    break

                                case 2  % wrong ID

                                case 3 % back to menu
                                    params = [];
                                    go_back = true;
                                    break
                            end %switch ID_menu
                        end %while
                    case 2
                        params = [];
                        go_back = true;
                        break
                end %switch menu 2
        end %switch menu 1
        if ~go_back
            break
        end %if
    end %while
end %if (first sbject)
end %function

%% Functions

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

function choice = checkID(subjectID)
msg = "This is the subject ID:" + newline + newline + subjectID{1} + newline + newline + "Is that correct?";
opts = ["Yes, continue with next block" "No, correct the Subj ID" "<-- Go back to menu"];
choice = menu(msg,opts);
end

function yesCallback(dialog)
assignin('base', 'choice', 1); % Assigns choice to 1 in the base workspace
delete(dialog); % Close dialog
end

function noCallback(dialog)
assignin('base', 'choice', 2); % Assigns choice to 2 in the base workspace
delete(dialog); % Close dialog
end


function choice = createConfirmationDialog()
% Create the dialog window
d = dialog('Position', [300, 300, 500, 400], 'Name', 'Confirmation Required');

% Message setup
msg = {'Do you really want to continue?', '', ...
    'Corrects previously saved Subject ID!', '', ...
    '!!! This can lead to problems with loading previous data file of subject', '', ...
    'Make sure to also rename the datafile if you choose this option !!!', '', ...
    'Do you still want to continue?'};
posY = 350;
for i = 1:length(msg)
    uicontrol('Parent', d, ...
        'Style', 'text', ...
        'Position', [20 posY 460 20], ...
        'String', msg{i}, ...
        'HorizontalAlignment', 'left', ...
        'FontName', 'Arial', ...
        'FontSize', 10);
    posY = posY - 30;
end

% Add Yes and No buttons with callbacks
uicontrol('Parent', d, 'Position', [100 30 100 30], 'String', 'Yes', ...
    'Callback', @(src, event) closeDialog(d, 1));
uicontrol('Parent', d, 'Position', [300 30 100 30], 'String', 'No', ...
    'Callback', @(src, event) closeDialog(d, 2));

% Wait for user to respond before exiting
uiwait(d);

% Check what was selected based on the app data stored
choice = guidata(d);
delete(d);  % Ensure the dialog is closed and cleaned up
end

function closeDialog(dialog, choice)
% Store choice in the dialog's application data
guidata(dialog, choice);
uiresume(dialog);  % Resume UI operation, allows uiwait to terminate
end







