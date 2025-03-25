%% create permutations

bock_orders = perms([1 2 3]); % all permutations how blocks are ordered within 1 run --> 1st order randomisation
run_orders = perms([1 2 3 4 5 6]); % all permutations, in which order the runs can appear
run_orders = run_orders(randperm(size(run_orders, 1)), :); % shuffle them

%% crate table to store block randomisation scheme

columnNames = ['Subj_ID', arrayfun(@(x) sprintf('block%d', x), 1:18, 'UniformOutput', false)]; % empty cell for subj.ID + columns for block1 - block18

emptyRow = [cell(1, 1), num2cell(zeros(1, 18))];
randomisation_table = cell2table(emptyRow, 'VariableNames', columnNames);
newRow = cell2table([{''}, num2cell(exp_order)], 'VariableNames', columnNames);

randomisation_table = [randomisation_table; newRow];
randomisation_table(1,:) = []; % remove empty row


for i = 1:length(run_orders)

    exp_order = bock_orders(run_orders(i,:),:);
    exp_order = reshape(exp_order.',1,[]);

    newRow = cell2table([{''}, num2cell(exp_order)], 'VariableNames', columnNames); % make new row with empty subj. ID
    randomisation_table = [randomisation_table; newRow];

end

%%

cd 'C:\Users\mrsre\NCC_MRI\NCC_exp2'

%%

fileName = 'randomisation_table.mat';

files = dir('randomisation_table*.mat');
if ~isempty(files)
    numbers = regexp({files.name}, 'randomisation_table(\d*)\.mat', 'tokens');
    existingNumbers = cellfun(@(x) str2double(x{1}), [numbers{:}], 'UniformOutput', true);

    % If no numbers are found (just 'file.mat' exists), start numbering from 1
    if all(isnan(existingNumbers))
        maxNumber = 0;
    else
        maxNumber = max(existingNumbers(~isnan(existingNumbers))); % Get the highest number
    end

    % Generate the new filename with the next higher number
    newNumber = maxNumber + 1;
    fileName = sprintf('randomisation_table%d.mat', newNumber);
end

% Display the new or unchanged filename
disp(['Filename to be used: ', fileName]);

%%

files = dir('randomisation_table*.mat');
if ~isempty(files)
fileNr = max(str2num(cell2mat(regexp([a.name],'\d*','Match')')))

while isMatch


end



end

%%
cd 'C:\Users\mrsre\NCC_MRI\NCC_exp2\CM'
a = dir('*.m')
c = max(str2num(cell2mat(regexp([a.name],'\d*','Match')'))) % find highest number in all filenames





