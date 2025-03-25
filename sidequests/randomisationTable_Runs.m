clear all

outDir = 'C:\Users\mrsre\NCC_MRI\NCC_exp2\';

%% create permutations

block_orders = perms([1 2 3]); % all permutations how blocks are ordered within 1 run --> 1st order randomisation
run_orders = perms([1 2 3 4 5 6]); % all permutations, in which order the runs can appear

rng(77)

% generate quasi-random sequence
GR = distributeByGoldenRatio(size(run_orders,1));

% run_orders = run_orders(randperm(size(run_orders, 1)), :); % shuffle them

run_orders = run_orders(GR, :); % sort them by Golden Ratio low-distance measure

%% crate table to store block randomisation scheme

columnNames = ['Subj_ID', arrayfun(@(x) sprintf('run%d', x), 1:6, 'UniformOutput', false)]; % empty cell for subj.ID + columns for block1 - block18

emptyRow = [cell(1, 1), num2cell(zeros(1, 6))]; % create empty row...
randomisation_table = cell2table(emptyRow, 'VariableNames', columnNames); %...to start the table
randomisation_table(1,:) = []; % remove empty row

for i = 1:length(run_orders)

    exp_order = block_orders(run_orders(i,:),:); % This is your 3x6 matrix where each row corresponds to a run containing 3 blocks
    exp_order = num2cell(exp_order, 2); % Convert each row into a cell, preserving the 3-element structure per row
    exp_order = reshape(exp_order, 1, []);

    newRow = cell2table([{''}, num2cell(exp_order)], 'VariableNames', columnNames); % make new row with empty subj. ID
    randomisation_table = [randomisation_table; newRow];

end

%% before saving: look if file(s) already exist so we dont overwrite info

outfileName = 'randomisation_table.mat';

cd(outDir)
files = dir('randomisation_table*.mat');

if ~isempty(files)
    fileNr_new = 1;
    fileNumbers = cell2mat(regexp([files.name],'\d*','Match')'); % if there are files with numbers
    outfileName = 'randomisation_table_1.mat';
    if ~isempty(fileNumbers)
        fileNr_old = max(str2num(fileNumbers)); % find highest number in all filenames
        fileNr_new = fileNr_old+1;
        outfileName = strcat('randomisation_table_', num2str(fileNr_new), '.mat');
    end
end

save(outfileName,"randomisation_table")

%%

function outArray = distributeByGoldenRatio(n)
phi = (1 + sqrt(5)) / 2;    % Golden Ratio
GR = mod((1:n) * phi, 1);   % Scale indices by phi and take modulo 1
[~, indices] = sort(GR);    % Sort indices by their scaled modulo results
outArray = indices;  % Return the original indices reordered by this scheme
end




