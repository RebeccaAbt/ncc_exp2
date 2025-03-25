
function conditions = MRconditionTimings(data)
%{

---------------------------------------------
!!!! change condition to 1 for NT trials !!!
---------------------------------------------
This function saves the timepoints of the MRI run for each condition in the
regarding structure field. These time points will be used in the first
level analysis of the MRI data

%}

chunk1 = {'aud', 'tac', 'vis'};
chunk2 = {'_miss', '_hit'};
stims = 1:4;
stim_duration = 0.05;

conditions = [];

% create fieldnames for all conditions
for i = 1:length(chunk1)
    for j = 1:length(chunk2)
        for stims = 1:4

            fieldName = [chunk1{i} num2str(stims) chunk2{j}];
            conditions.(fieldName) = [];

        end
    end
end

for iblock = 1:length(data)
    for iTrial = 1:6

        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! change to 1!!

        isNT = data(iblock).StimuliOrder3(i)==2;    % NT/high/catch

        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        if isNT
            varPart_a = chunk1{data(iblock).StimuliOrder1(iTrial)};   % aud/vis/tac
            varPart_b = num2str(data(iblock).StimuliOrder2(iTrial));    % stim 1/2/3/4

            response = data(iblock).response(iTrial);

            if ~isnan(response) %
                varPart_c = chunk2{response+1};
                fieldName = [varPart_a varPart_b varPart_c];
                conditions.(fieldName) = [conditions.(fieldName); data(iblock).time.MRI_Stimulus(iTrial)  stim_duration];
            end %if
        end %if
    end %for
end %for