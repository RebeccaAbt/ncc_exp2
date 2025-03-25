% clear variables
cd 'C:\Users\mrsre\NCC_MRI\NCC_exp2'
outDir = 'C:\Users\mrsre\NCC_MRI\other\behav_data';
load("randomisation_table.mat")

%% add some entries to test script

randomisation_table.Subj_ID{1} = 'ajrn';
randomisation_table.Subj_ID{2} = 'ekse';
randomisation_table.Subj_ID{3} = 'btre';
%%
[randomisation_table, params] = userDialog(outDir, randomisation_table);
%%
msg = "msg" + newline;
for i = 1:length(subjIndices)
    subj = strcat("Nr. ", num2str(subjIndices(i)), ":   ", randomisation_table.Subj_ID{subjIndices(i)}, "     ");
    msg = msg + newline + subj;  % Append each subject's information to the message
end %for
opts = ["OK"];
menu(msg,opts);


