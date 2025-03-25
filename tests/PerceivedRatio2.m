% How mani Stimuli were perceived / not perceived
modalities = {'auditory', 'tactile', 'visual'};

for task = 1:length(modalities)
    
    summary(task).task =   modalities {task};
    
    summary(task).perceived_high = 0;
    summary(task).perceived_catch = 0;
    summary(task).perceived_NT = 0;
    summary(task).not_perceived_NT = 0;
    
    summary(task).stim1 = 0;
    summary(task).stim2 = 0;
    summary(task).stim3 = 0;
    summary(task).stim4 = 0;
    
end


%%
for iblock = 1:length(data)
    task = data(iblock).task;
       
    idx1 = data(iblock).StimuliOrder3 == 1;
    idx2 = data(iblock).StimuliOrder3 == 2;
    idx3 = data(iblock).StimuliOrder3 == 3;
    
    response = 1;
    
    summary(task).perceived_high = summary(task).perceived_high + sum(data(iblock).response(idx2) == response);
    summary(task).perceived_catch =  summary(task).perceived_catch + sum(data(iblock).response(idx3) == response);
    summary(task).perceived_NT = summary(task).perceived_NT + sum(data(iblock).response(idx1) == response);
        
    response = 0;
    
    summary(task).not_perceived_NT =  summary(task).not_perceived_NT + sum(data(iblock).response(idx1) == response);
        
    stim1 = data(iblock).StimuliOrder2 == 1;
    stim2 = data(iblock).StimuliOrder2 == 2;
    stim3 = data(iblock).StimuliOrder2 == 3;
    stim4 = data(iblock).StimuliOrder2 == 4;
    
    NT = data(iblock).StimuliOrder3 == 1;
    
    response = 1;
    
    summary(task).stim1 =  summary(task).stim1 + sum(data(iblock).response(stim1 & NT) == response);
    summary(task).stim2 =  summary(task).stim2 + sum(data(iblock).response(stim2 & NT) == response);
    summary(task).stim3 =  summary(task).stim3 + sum(data(iblock).response(stim3 & NT) == response);
    summary(task).stim4 =  summary(task).stim4 + sum(data(iblock).response(stim4 & NT) == response);
    
end

disp('PILOT 3')
disp('____________________________________________________')

for task = 1:3

disp('--------------------------------------------')

fprintf('Condition: %s\n', modalities{task})

fprintf('\n   perceived high:    %i', summary(task).perceived_high)
fprintf('\n   perceived catch:   %i', summary(task).perceived_catch)
fprintf('\n   perceived NT:      %i',  summary(task).perceived_NT)
fprintf('\n   not perceived NT:  %i\n', summary(task).not_perceived_NT)

fprintf('\n   perceived NT stim 1:      %i', summary(task).stim1)
fprintf('\n   perceived NT stim 2:      %i', summary(task).stim2)
fprintf('\n   perceived NT stim 3:      %i', summary(task).stim3)
fprintf('\n   perceived NT stim 4:      %i\n', summary(task).stim4)

disp('--------------------------------------------')

end