function do_my_calibration(windowPtr, save_folder, fakeHW) 
%Datapixx('Uninitialize');
% clear all;
% close all;

if nargin < 2
  save_folder = [];
end %if

if nargin < 3
  fakeHW = false;
end %if
%% Step 1, Initialize TRACKPixx or TRACKPixx Mini
% Which HW tracker will be used to do the calibration. 0 = TPx-Mini, 1 = TPx
isTPX = 1;

% The following variable defines two calibration types for the TRACPixxMini.
%  0. Chin-rest type that uses the VPixx method (13 points). 
%  1. Remote type that uses the device's built-in calibration (16 points).
isBuiltIn = 0;

%Sets to which screen the calibration will be done, if the platform supports
%multi screen.
screenNumber = 0; %3 originally

if ~fakeHW   
    if isTPX
        ptb = o_ptb.PTB.get_instance();
        ptb_cfg = ptb.get_config();
        Datapixx('Open');
        %Datapixx('ShowOverlay');
        Datapixx('RegWrRd');
        Datapixx('SetTPxAwake');
        Datapixx('RegWrRd');
        Datapixx('SetLedIntensity', ptb_cfg.datapixxtrackpixx_config.led_intensity);
        Datapixx('SetLens', ptb_cfg.datapixxtrackpixx_config.lens);
        Datapixx('SetDistance', ptb_cfg.datapixxtrackpixx_config.distance);
        Datapixx('RegWrRd');
        image = Datapixx('GetEyeImage');
        %imwrite(image, 'test.png');
        % ^ If you want to save an image of eyes
        % to measure Iris size
    else           
        image = Datapixx('GetEyeImageTPxMini');
    end
    
end

%% Step 2, open the Window and show the eye for focus
%Screen('Preference', 'SkipSyncTests', 1)
%[windowPtr, windowRect]=PsychImaging('OpenWindow', screenNumber, 0);
KbName('UnifyKeyNames');
if ~fakeHW
    if isTPX
        t = Datapixx('GetTime');
        t2 = Datapixx('GetTime');
    else
        t = GetSecs;
        t2 = GetSecs;
    end
else
    t = GetSecs;
    t2 = GetSecs;
end

Screen('TextSize', windowPtr, 24);
i = 0;
calib_type = 0;
while (1)
    if ((t2 - t) > 1/60) % Just refresh at 60Hz.
        if ~fakeHW
            if isTPX
                Datapixx('RegWrRd');
                image = Datapixx('GetEyeImage');
            else
                image = Datapixx('GetEyeImageTPxMini');
            end

            textureIndex=Screen('MakeTexture', windowPtr, image');
            Screen('DrawTexture', windowPtr, textureIndex);
        end

%         DrawFormattedText(windowPtr, 'Press Enter when ready to calibrate (M for manual). Escape to exit.', 'center', 700, 255);
          DrawFormattedText(windowPtr, 'Press Enter and thereafter Escape to start calibration.', 'center', 700, 255);
        Screen('Flip', windowPtr);
        t = t2;
        if ~fakeHW
            Screen('Close',textureIndex);
        end
    else
        if ~fakeHW
            if isTPX
                Datapixx('RegWrRd');
                t2 = Datapixx('GetTime');
            else
                t2 = GetSecs;
            end
        else
            t2  = GetSecs;
        end
    end
    
    % Keypress goes to next step of demo
    [pressed dum keycode] = KbCheck;
    if pressed
        if keycode(KbName('escape'))  
            return;
        else
            if keycode(KbName('M'))
                calib_type = 1;
            end
            break;
        end
    end
end
WaitSecs(2)

%% Step 3, Calibrations and calibrations results.

if ~isTPX && isBuiltIn
    [xy, nmb_pts] = Datapixx('InitializeCalibration');
    xy(2,:) = 1080 - xy(2,:);
else
    % !!!! rectangle disposition !!!!!
    %
    %       x           x           x
    %
    %             x           x     
    %
    %       x           x           x
    %
    %             x           x      
    %
    %       x           x           x
    %
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    cx = 1920/2; % Point center in x
    cy = 1080/2; % Point center in y
    dx = 600; % How big of a range to cover in X
    dy = 350; % How big of a range to cover in Y

    xy = [  cx cy;...
            cx cy+dy;...
            cx+dx cy;...
            cx cy-dy;...
            cx-dx cy;...
            cx+dx cy+dy;...
            cx-dx cy+dy;...
            cx+dx cy-dy;...
            cx-dx cy-dy;...
            cx+dx/2 cy+dy/2;...
            cx-dx/2 cy+dy/2;...
            cx-dx/2 cy-dy/2;...
            cx+dx/2 cy-dy/2;];

    % !!!! shifted disposition 11x11 row column !!!!!!!!!!!
    %
    %       | x |   |   |   |   |   |   |   |   |   | x |
    %       |   |   |   |   | x |   |   |   |   |   |   |
    %       |   |   |   |   |   |   |   | x |   |   |   |
    %       |   |   | x |   |   |   |   |   |   |   |   |
    %       |   |   |   |   |   |   |   |   |   | x |   |
    %       |   |   |   |   |   | x |   |   |   |   |   |
    %       |   | x |   |   |   |   |   |   |   |   |   |
    %       |   |   |   |   |   |   |   |   | x |   |   |
    %       |   |   |   | x |   |   |   |   |   |   |   |
    %       |   |   |   |   |   |   | x |   |   |   |   |
    %       | x |   |   |   |   |   |   |   |   |   | x |
    %
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    % xy = [];
    % sc_width = 1920;
    % sc_height = 1080;
    % cal_ratio = 0.6;
    % caldiv_idx = [5 5;...
    %               0 0;...
    %               10 0;...
    %               10 10;...
    %               0 10;...
    %               1 6;...
    %               2 3;...
    %               3 8;...
    %               4 1;...
    %               6 9;...
    %               7 2;...
    %               8 7;...
    %               9 4]
    % for i = 1:13
    %     xy(i,1) = calPt(sc_width, cal_ratio, caldiv_idx(i,1));
    %     xy(i,2) = calPt(sc_height, cal_ratio, caldiv_idx(i,2));
    % end
    convertedxy = Datapixx('ConvertCoordSysToCartesian', xy)
    convertedxy = convertedxy'
    xy = xy';
    %xy(1, :) = xy(1) - (xy(1, :) - xy(1));
    xy(2, :) = xy(2) - (xy(2, :) - xy(2));
    nmb_pts = size(xy);
    nmb_pts = nmb_pts(2);
end

i = 0;
Screen('BlendFunction', windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); 
recording = 0;
start_time = 0;
t = 0;
showing_dot = 0;
Sx = 0;
Sy = 0;
HideCursor();
raw_vector = zeros(13,4);
finish_calibration = 0;
t2 = t;
calibrationResult = 0


while (1)
    
    if ((t2 - t) > 2) % points presented every 2 sec
        if isTPX || ~isBuiltIn
            Sx = convertedxy(1,mod(i,nmb_pts)+1); 
            Sy = convertedxy(2,mod(i,nmb_pts)+1);
        end
        Screen('DrawDots', windowPtr, [xy(:,mod(i,nmb_pts)+1) xy(:,mod(i,nmb_pts)+1)], [35;20]', [255 255 255; 200 0 0]', [], 1);
        Screen('Flip', windowPtr);
        showing_dot = 1;
        t = t2;
    else
        if ~fakeHW
            if isTPX
                Datapixx('RegWrRd');
                t2 = Datapixx('GetTime');
            else
                t2 = GetSecs;
            end
        else
            t2 = GetSecs; 
        end
    end
    
    if(showing_dot && (t2 - t) > 0.9)
        Screen('DrawDots', windowPtr, [xy(:,mod(i,nmb_pts)+1) xy(:,mod(i,nmb_pts)+1)], [15;5]', [255 255 255; 200 0 0]', [], 1);
        Screen('Flip', windowPtr);
    elseif(showing_dot && (t2 - t) > 0.8)
        Screen('DrawDots', windowPtr, [xy(:,mod(i,nmb_pts)+1) xy(:,mod(i,nmb_pts)+1)], [17;6]', [255 255 255; 0 0 0]', [], 1);
        Screen('Flip', windowPtr);
    elseif(showing_dot && (t2 - t) > 0.7)
        Screen('DrawDots', windowPtr, [xy(:,mod(i,nmb_pts)+1) xy(:,mod(i,nmb_pts)+1)], [20;8]', [255 255 255; 200 0 0]', [], 1);
        Screen('Flip', windowPtr);
    elseif(showing_dot && (t2 - t) > 0.6)
        Screen('DrawDots', windowPtr, [xy(:,mod(i,nmb_pts)+1) xy(:,mod(i,nmb_pts)+1)], [22;10]', [255 255 255; 0 0 0]', [], 1);
        Screen('Flip', windowPtr);
    elseif(showing_dot && (t2 - t) > 0.5)
        Screen('DrawDots', windowPtr, [xy(:,mod(i,nmb_pts)+1) xy(:,mod(i,nmb_pts)+1)], [25;12]', [255 255 255; 200 0 0]', [], 1);
        Screen('Flip', windowPtr);
    elseif(showing_dot && (t2 - t) > 0.4)
        Screen('DrawDots', windowPtr, [xy(:,mod(i,nmb_pts)+1) xy(:,mod(i,nmb_pts)+1)], [27;14]', [255 255 255; 0 0 0]', [], 1);
        Screen('Flip', windowPtr);
    elseif(showing_dot && (t2 - t) > 0.3)
        Screen('DrawDots', windowPtr, [xy(:,mod(i,nmb_pts)+1) xy(:,mod(i,nmb_pts)+1)], [30;16]', [255 255 255; 200 0 0]', [], 1);
        Screen('Flip', windowPtr);
    elseif(showing_dot && (t2 - t) > 0.2)
        Screen('DrawDots', windowPtr, [xy(:,mod(i,nmb_pts)+1) xy(:,mod(i,nmb_pts)+1)], [31;17]', [255 255 255; 0 0 0]', [], 1);
        Screen('Flip', windowPtr);
    elseif(showing_dot && (t2 - t) > 0.1)
        Screen('DrawDots', windowPtr, [xy(:,mod(i,nmb_pts)+1) xy(:,mod(i,nmb_pts)+1)], [33;18]', [255 255 255; 200 0 0]', [], 1);
        Screen('Flip', windowPtr);
    end

    
    
    if (showing_dot && (t2 - t) > 0.95)% make sure the point has been presented for 0.75 sec
        % Get some samples!
        fprintf('\nGetting samples for screen potision (%d,%d)\n', Sx, Sy);
        
        if (calib_type == 1) % If in manual mode wait for a keypress
            KbWait;
        end
        i = i + 1; % Next point
        fprintf('\ni: %d\n', i);
        if ~fakeHW
            if isTPX || ~isBuiltIn
                % Send the screen coordinates and acquire data from TPx.
                [xRawRight, yRawRight, xRawLeft, yRawLeft] = Datapixx('GetEyeDuringCalibrationRaw', Sx, Sy); % Raw Values from TPx to verify
                raw_vector(i,:) = [xRawRight yRawRight xRawLeft yRawLeft]
            else
                fprintf('\nperform TPX calibration\n');
                Datapixx('ClearError');
                Datapixx('CalibrateTarget', i-1);
                fprintf('\nperform TPX calibration on %d, error: %d\n', (i-1), Datapixx('GetError'));
            end
        else
            raw_vector(i,:) = [Sx Sy Sx Sy] % Raw Values from fakeHW to verify
        end 
        showing_dot = 0;
    end
    
    if (i == nmb_pts) %% We showed all the points, now we evaluate.
       % Plot the results of the calibrations...
       WaitSecs(2);
       
%        if isTPX || ~isBuiltIn
%            figure('Name','raw_data_right');
%            H = scatter(raw_vector(:,1), raw_vector(:,2));
%            grid on;
%            grid minor;
%            saveas(H, 'raw_data_right.fig', 'fig')
% 
%            figure('Name','raw_data_left');
%            H = scatter(raw_vector(:,3), raw_vector(:,4));
%            grid on;
%            grid minor;
%            saveas(H, 'raw_data_left.fig', 'fig')
%        end
       
       while (1)
           % remap data to proper range
           if ~fakeHW
            if isTPX || ~isBuiltIn
                Datapixx('FinishCalibration');
            else
                calibrationResult = Datapixx('FinalizeCalibration');
                fprintf('calibration result: %d\n', calibrationResult);
            end
           end 
           ShowCursor();
           
           if isTPX || ~isBuiltIn
               raw_vector_sc(:,1) = (raw_vector(:,1)-min(raw_vector(:,1)))/(max(raw_vector(:,1))-min(raw_vector(:,1)))*(1800-120)+120;
               raw_vector_sc(:,2) = (raw_vector(:,2)-min(raw_vector(:,2)))/(max(raw_vector(:,2))-min(raw_vector(:,2)))*(1000-80)+80;
               raw_vector_sc(:,3) = (raw_vector(:,3)-min(raw_vector(:,3)))/(max(raw_vector(:,3))-min(raw_vector(:,3)))*(1800-120)+120;
               raw_vector_sc(:,4) = (raw_vector(:,4)-min(raw_vector(:,4)))/(max(raw_vector(:,4))-min(raw_vector(:,4)))*(1000-80)+80;
               DrawFormattedText(windowPtr, '\n Calibration results 1 of 3. \n Showing raw data results. If one dot seems off, calibration might be bad.\n Press any key to continue. Y to acccept, N to restart.', 'center', 100, 255);
           else
               if calibrationResult > 0
                DrawFormattedText(windowPtr, '\n Calibration pass.\n Press any key to continue. Y to acccept, N to restart.', 'center', 100, 255);
               else
                DrawFormattedText(windowPtr, '\n Calibration fail.\n Press any key to continue. Y to acccept, N to restart.', 'center', 100, 255);
               end
                   
           end
           
           if ~fakeHW
               if isTPX || ~isBuiltIn
                   % data
                    Screen('DrawDots', windowPtr, [raw_vector_sc(:,1)'; raw_vector_sc(:,2)'], [10]', [255 0 0]', [], 1);
                    Screen('DrawDots', windowPtr, [raw_vector_sc(:,3)'; raw_vector_sc(:,4)'], [10]', [0 0 255]', [], 1);
               end
           else
               % fake
               Screen('DrawDots', windowPtr, [raw_vector_sc(:,1)'; raw_vector_sc(:,2)'], [10]', [255 0 255]', [], 1);
           end
           
           Screen('Flip', windowPtr);
           
           if isTPX || ~isBuiltIn
               % To save pictures
               imageArray = Screen('GetImage', windowPtr);
               if ~isempty(save_folder)
                imwrite(imageArray, fullfile(save_folder, 'ScaledRawData.jpg'));
               end %if
           end
           
           WaitSecs(1);
           % For debug           
           [secs, keyCode, deltaSecs] = KbWait;
           if keyCode(KbName('Y')) % good calib
                finish_calibration = 1;
                break;
           elseif keyCode(KbName('N')) % bad calib
                % not working.
                t = 0;
                showing_dot = 0;
                Sx = 0;
                Sy = 0;
                HideCursor();
                i = 0; 
                raw_vector = zeros(13,4);
                finish_calibration = 0;
                t2 = t;
                break;
           end 
            
            if isTPX || ~isBuiltIn
                % First we need to acquire the coefficients of the calibration.
                coeff_x = zeros(1,9);
                coeff_y = zeros(1,9);
                coeff_x_L = zeros(1,9);
                coeff_y_L = zeros(1,9);
                if ~fakeHW
                    calibrations_coeff = Datapixx('GetCalibrationCoeff')
                    coeff_x = calibrations_coeff(1:9);
                    coeff_y = calibrations_coeff(10:18);
                    coeff_x_L = calibrations_coeff(19:27);
                    coeff_y_L = calibrations_coeff(28:36);
                else
                    coeff_x(2) = 1;
                    coeff_x_L(2) = 1;
                    coeff_y(3) = 1;
                    coeff_y_L(3) = 1;
                end
                % Now we want to evaluate raw_vector's values using the polynomials.
                % Lets use a function for that. Or 2 for X and Y. Will need to seperate in 
                % groups of 9 terms. 

                [x_eval_cartesian,y_eval_cartesian] = o_ptb.subsystems.eyetracker.support.evaluate_bestpoly(raw_vector(:,1)', raw_vector(:,2)', coeff_x, coeff_y)
                [x_eval_L_cartesian,y_eval_L_cartesian] = o_ptb.subsystems.eyetracker.support.evaluate_bestpoly(raw_vector(:,3)', raw_vector(:,4)', coeff_x_L, coeff_y_L) 
                right_eye_eval = [x_eval_cartesian' y_eval_cartesian']
                left_eye_eval = [x_eval_L_cartesian' y_eval_L_cartesian']
                xy_eval = Datapixx('ConvertCoordSysToCustom', right_eye_eval)
                xy_eval_L = Datapixx('ConvertCoordSysToCustom', left_eye_eval)
                x_eval = xy_eval(:,1)'
                y_eval = xy_eval(:,2)'
                x_eval_L = xy_eval_L(:,1)'
                y_eval_L = xy_eval_L(:,2)'


                % Now we have evaluations of "raw_vectors". 

                p_p = [9 4; 4 8; 9 5; 4 1; 8 3; 5 1; 1 3; 5 7; 1 2; 3 6; 7 2; 2 6];
                n_points = 10;
                x_interpol_raw = zeros(12, n_points); % we have 12 segments, we create 10 points each for now
                y_interpol_raw = zeros(12, n_points); % we have 12 segments, we create 10 points each for now
                x_interpol_raw_L = zeros(12, n_points); % we have 12 segments, we create 10 points each for now
                y_interpol_raw_L = zeros(12, n_points); % we have 12 segments, we create 10 points each for now
                x_interpol = zeros(12, n_points); % we have 12 segments, we create 10 points each for now
                y_interpol = zeros(12, n_points); % we have 12 segments, we create 10 points each for now
                x_interpol_L = zeros(12, n_points); % we have 12 segments, we create 10 points each for now
                y_interpol_L = zeros(12, n_points); % we have 12 segments, we create 10 points each for now
                x_interpol_cartesian = zeros(12, n_points); % we have 12 segments, we create 10 points each for now
                y_interpol_cartesian = zeros(12, n_points); % we have 12 segments, we create 10 points each for now
                x_interpol_L_cartesian = zeros(12, n_points); % we have 12 segments, we create 10 points each for now
                y_interpol_L_cartesian = zeros(12, n_points); % we have 12 segments, we create 10 points each for now
                right_eye_interpol = zeros(n_points,2,12); % we have 12 segments, we create 10 points each for now
                left_eye_interpol = zeros(n_points,2,12); % we have 12 segments, we create 10 points each for now
                xy_interpol = zeros(n_points,2,12); % we have 12 segments, we create 10 points each for now
                xy_interpol_L = zeros(n_points,2,12); % we have 12 segments, we create 10 points each for now
                for i = 1:12
                    x_interpol_raw(i,:) = linspace(raw_vector(p_p(i,1),1),raw_vector(p_p(i,2),1), n_points);
                    y_interpol_raw(i,:) = linspace(raw_vector(p_p(i,1),2),raw_vector(p_p(i,2),2), n_points);
                    x_interpol_raw_L(i,:) = linspace(raw_vector(p_p(i,1),3),raw_vector(p_p(i,2),3), n_points);
                    y_interpol_raw_L(i,:) = linspace(raw_vector(p_p(i,1),4),raw_vector(p_p(i,2),4), n_points);
                end

                % Ok all interpolated data created in raw coordinates. Need to evaluate in
                % polynomial.

                for i = 1:12
                    [x_interpol_cartesian(i,:),y_interpol_cartesian(i,:)] = o_ptb.subsystems.eyetracker.support.evaluate_bestpoly(x_interpol_raw(i,:)', y_interpol_raw(i,:)', coeff_x, coeff_y);
                    [x_interpol_L_cartesian(i,:),y_interpol_L_cartesian(i,:)] = o_ptb.subsystems.eyetracker.support.evaluate_bestpoly(x_interpol_raw_L(i,:)', y_interpol_raw_L(i,:)', coeff_x_L, coeff_y_L);
                    right_eye_interpol(:,:,i) = [x_interpol_cartesian(i,:)' y_interpol_cartesian(i,:)'];
                    left_eye_interpol(:,:,i) = [x_interpol_L_cartesian(i,:)' y_interpol_L_cartesian(i,:)'];
                    xy_interpol(:,:,i) = Datapixx('ConvertCoordSysToCustom', right_eye_interpol(:,:,i));
                    xy_interpol_L(:,:,i) = Datapixx('ConvertCoordSysToCustom', left_eye_interpol(:,:,i));
                    x_interpol(i,:) = xy_interpol(:,1,i);
                    y_interpol(i,:) = xy_interpol(:,2,i);
                    x_interpol_L(i,:) = xy_interpol_L(:,1,i);
                    y_interpol_L(i,:) = xy_interpol_L(:,2,i);               
                end

                % Fill proper display vector from my 12x10 matrix (make 2x120)
                interpolated_dots = zeros(2,n_points*12);
                interpolated_dots_L = zeros(2,n_points*12);
                for i=1:12
                    interpolated_dots(1,(i-1)*n_points+1:(i-1)*n_points+n_points) = x_interpol(i,:);
                    interpolated_dots(2,(i-1)*n_points+1:(i-1)*n_points+n_points) = y_interpol(i,:);
                    interpolated_dots_L(1,(i-1)*n_points+1:(i-1)*n_points+n_points) = x_interpol_L(i,:);
                    interpolated_dots_L(2,(i-1)*n_points+1:(i-1)*n_points+n_points) = y_interpol_L(i,:);
                end
                DrawFormattedText(windowPtr, '\n Calibration results 2 of 3. \n Showing calibration dots and screen from polynomial for right eye. \n If the dots are off or the lines are not well connected, calibration for this eye might be off. \n Press any key to continue. Y to acccept, N to restart.', 'center', 100, 255);
                Screen('DrawDots', windowPtr, [xy(1,:)' xy(2,:)']', [30]', [255 255 255]', [], 1);
                Screen('DrawDots', windowPtr, [x_eval' y_eval']', [20]', [255 0 255]', [], 1);
                Screen('DrawDots', windowPtr, interpolated_dots, [8]', [255 0 0]', [], 1);
                Screen('Flip', windowPtr);
                WaitSecs(1);
                imageArray = Screen('GetImage', windowPtr);
                if ~isempty(save_folder)
                  imwrite(imageArray, fullfile(save_folder, 'PolyResponse_R.jpg'))% For debug
                end %if
                [secs, keyCode, deltaSecs] = KbWait;
                if keyCode(KbName('Y'))
                    finish_calibration = 1;
                    break;
                elseif keyCode(KbName('N'))
                    % not working.
                    t = 0;
                    showing_dot = 0;
                    Sx = 0;
                    Sy = 0;
                    HideCursor();
                    i = 0; 
                    raw_vector = zeros(13,4);
                    finish_calibration = 0;
                    t2 = t;
                    break;
                end 

                DrawFormattedText(windowPtr, '\n Calibration results 3 of 3. \n Showing calibration dots and screen from polynomial for left eye. \n If the dots are off or the lines are not well connected, calibration for this eye might be off. \n Press any key to continue. Y to acccept, N to restart.', 'center', 100, 255);
                Screen('DrawDots', windowPtr, [xy(1,:)' xy(2,:)']', [30]', [255 255 255]', [], 1);
                Screen('DrawDots', windowPtr, [x_eval_L' y_eval_L']', [20]', [0 255 255]', [], 1);
                Screen('DrawDots', windowPtr, interpolated_dots_L, [8]', [0 0 255]', [], 1);
                Screen('Flip', windowPtr);
                WaitSecs(2);
                imageArray = Screen('GetImage', windowPtr);
                if ~isempty(save_folder)
                  imwrite(imageArray, fullfile(save_folder, 'PolyResponse_L.jpg'))% For debug
                end %if
               [secs, keyCode, deltaSecs] = KbWait;
               if keyCode(KbName('Y'))
                    finish_calibration = 1;
                    break;
               elseif keyCode(KbName('N'))
                    % not working.
                    t = 0;
                    showing_dot = 0;
                    Sx = 0;
                    Sy = 0;
                    HideCursor();
                    i = 0; 
                    raw_vector = zeros(13,4);
                    finish_calibration = 0;
                    t2 = t;
                    break;
               else
                    Datapixx('Uninitialize');                    
               end
            else
                break;
            end
       end
    end
            
        
        

    % Keypress goes to next step of demo
    [pressed dum keycode] = KbCheck;
    if pressed
        if keycode(KbName('escape'))
            return;
            break;
        end
    end
    
    if (finish_calibration == 1)
        DrawFormattedText(windowPtr, 'Calculating Calibration results', 'center', 700, 255); 
        if ~fakeHW
            if isTPX || ~isBuiltIn
                Datapixx('FinishCalibration');
            end
        end 
        Screen('Flip', windowPtr);
        break;
    end 
end
%%
