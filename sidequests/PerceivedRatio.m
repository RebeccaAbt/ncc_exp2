% How mani Stimuli were perceived / not perceived
modalities = {'auditory', 'tactile', 'visual'};
% for
% summary.(modalities{i}).perceived_high = 0;
% summary.(modalities{i}).perceived_catch = 0;
% summary.(modalities{i}).perceived_NT = 0;
% summary.(modalities{i}).not_perceived_NT = 0;

%%

for iblock = 2%:3

disp('--------------------------------------------')

fprintf('Condition: %s\n', modalities{data(iblock).task})

idx1 = data(iblock).StimuliOrder3 == 1;
idx2 = data(iblock).StimuliOrder3 == 2;
idx3 = data(iblock).StimuliOrder3 == 3;

response = 1;

fprintf('\n   perceived high:    %i', sum(data(iblock).response(idx2) == response))
fprintf('\n   perceived catch:   %i', sum(data(iblock).response(idx3) == response))
fprintf('\n   perceived NT:      %i', sum(data(iblock).response(idx1) == response))

response = 0;

fprintf('\n   not perceived NT:  %i\n', sum(data(iblock).response(idx1) == response))

stim1_a = data(iblock).StimuliOrder2 == 1;
stim2_a = data(iblock).StimuliOrder2 == 2;
stim3_a = data(iblock).StimuliOrder2 == 3;
stim4_a = data(iblock).StimuliOrder2 == 4;

NT = data(iblock).StimuliOrder3 == 1;

response = 1;
fprintf('\n   perceived NT stim 1:      %i', sum(data(iblock).response(stim1_a & NT) == response))
fprintf('\n   perceived NT stim 2:      %i', sum(data(iblock).response(stim2_a & NT) == response))
fprintf('\n   perceived NT stim 3:      %i', sum(data(iblock).response(stim3_a & NT) == response))
fprintf('\n   perceived NT stim 4:      %i\n', sum(data(iblock).response(stim4_a & NT) == response))


disp('--------------------------------------------')


end

