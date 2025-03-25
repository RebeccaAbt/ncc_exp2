function TPxCalibrationTesting(isTPX,isBuiltIn,screenNumber)
% TPxCalibrationTesting()
%
% This demo calibrates the current session for the TRACKPixx(TPx) or
% TRACKPixx /mini (TPx/m) trackers and displays the calibration results.
% Once the calibration is finished, a gaze follower is started
% to determine the results and the TPx remains calibrated as long as you do not call
% Datapixx('ClearCalibration').  For the TPx/m, a "remote" calibration will
% remain active as long as the TPx/m is not disconnected.  The "Chinrest"
% calibration will persist in Matlab as long as you do not call "clear all;
% close all;"
%
% The Demo Steps are as follows:
% 1- Initialize the USB I/O Hub.
% 2- Initialize the tracker.
% 3- Display the eye picture for camera disposition and focusing (in the case
%    of a TPx).
% 4- Display the calibration targets one after the other, gather eye data,
%    finalize the calibration and display the calibration results.
% 5- Launch the Gaze following demo to verify that the calibration worked correctly.
%
% Once this demo is completed, if you call the data recording schedule, the eye
% data will be calibrated.
%
%  The isTPX parameter defines which HW tracker will be used to perform the
%  calibration. 0 = TPx/m, 1 = TPx
%
%  The isBuiltIn parameter defines two calibration types for the TRACPixx/mini.
%     0. Chinrest type that uses the VPixx method (13 points).
%     1. Remote type that uses TPx/m built-in calibration (16 points).
%
%  The screenNumber parameter selects the screen the calibration will use, in the case where
%  the platform supports multiple screens.



%IMPORTANT NOTICES:
% - In the current demo file, mandatory steps and important
%   information are indicated by a '%-->' comment.
% - Sections exclusive to TRACKPixx3 (TPx) will be surrounded by dashes '-'
% - Sections exclusive to TRACKPixx /mini (TPX/m) will be surrounded by '+'
% - Sections exclusive to chinrest calibration will be surrounded by '='
% - Sections exclusive to remote calibration will be surrounded by '*'
% - Sections concerning the USB I/O Hub will be surrounded by '~'





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 1, Initialize USB I/O Hub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~ USB I/O Hub ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The USB I/O Hub is a powered HS USB Hub containing an event acquisition unit.
% It provides power to the TPx/m and records events from a
% RESPONSEPixx. Two interfaces are accessible to the user:
% 1-HID game controller usable through HEBI joystick library
% 2-Serial port

% The enableUSBIOHub parameter determines if the USB I/O Hub should be included in the demo.
% Set to 1 to enable usage of the USB I/O Hub. If enabled, you must set the joystick id and
% Comm-port number.
enableUSBIOHub = 0;

if enableUSBIOHub == 1
    % Adjust the communication port as detected by the OS
    serPort = 'COM4';
    
    % Adjust the id to correspond to the gamepad assigned by the OS. If only 1
    % gamepad is connected, the id = 1.
    id = 1;
    
    %Define the serial port to use for the USB I/O Hub
    s = serial(serPort, 'StopBits', 1, 'TimeOut', 1, 'Terminator', 'CR')
    
    %Open a stream to the serial port
    fopen(s);
    
    %Get a joystick session
    joy = HebiJoystick(id);
    
    %Read current joystick state
    [axes, buttons0, povs] = read(joy);
    buttonNames = {'Blue', 'Yellow', 'White', 'Green', 'Red'};
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 2, Initialize TRACKPixx or TRACKPixx Mini
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This section prepares the hardware by opening sessions and
%setting parameter values.

% The fakeHW parameter is used to simulate hardware if none is avaialable. It will use
% the mouse position instead of tracker data.  Set the value to 1 to simulate the hardware.
fakeHW = 0;
fprintf('begin\n')
if ~fakeHW
    if isTPX
        %----------------------------- TPx ------------------------------------
        %-->    %It is mandatory to call 'Open' prior to using any VPixx device
        Datapixx('Open');
        
        %'ShowOverlay' will activate the console tracker window to display the camera
        %image and pupil center tracking position.  The window will
        %appear at the top left corner of the monitor connected to the out2
        %display port of the DATAPixx3.
        Datapixx('HideOverlay');
        
        %'ClearCalibration' will permanently destroy the current calibration.
        %-->    %It is mandatory to clear the previous calibration before starting a
        %new one.
        Datapixx('ClearCalibration');
        
        %-->    %PpSizeCalClear disable pupil size calibration.  it is mandatory to
        %clear pupil size calibration before to start a new one.
        Datapixx('PpSizeCalClear');
        
        %-->    %'RegWrRd' will apply previous Datapixx calls that were not applied
        %yet.  Do not forget to call this whenever you must apply a
        %setting or send a command to hardware.
        Datapixx('RegWrRd');
        
        %Thiw will awaken the TPx and turn on the illuminator.
        %-->	%It is mandatory to awaken the TPx before using it.
        Datapixx('SetTPxAwake');
        Datapixx('RegWrRd');
        
        %Sets the infrared LED array intensity, which must be an
        %integer value between 0 and 8.  At 0, the illuminator is off while
        %at 8 the illuminator is at maximum intensity.
        %The absolute value of the luminous intensity depends on the present hardware.
        %Skipping this command means the previous value will be used.  If the value
        %was never set, the default value will be used.
        %The default value is 8 (maximum intensity)
        %-->    %Using too much or not enough light will prevent good tracking results.
        %Experimenting with different intensity values and evaluating tracking quality
        %is the best way to optimize this parameter.
        Datapixx('SetLedIntensity', 8);
        
        %Iris size in pixel. Recommended values for a typical setup are:
        % - 70 pixels for 25 mm lens at about 50 - 60 cm
        % - 140 pixels for 50 mm lens at about 60 cm
        % - 150 pixels for typical MRI setup.
        %-->    %Having a significant mismatch in iris size will prevent good
        %tracking. If using a non typical setup, it is recommended to
        %adapt iris size by either calculating or measuring it.
        Datapixx('SetExpectedIrisSizeInPixels', 140)
        
        Datapixx('RegWrRd');
        %'GetEyeImage' returns the image coming from the TPx.
        image = Datapixx('GetEyeImage');
        %----------------------------------------------------------------------
    else
        %++++++++++++++++++++++++++++ TPx/m +++++++++++++++++++++++++++++++++++
        %Ensure that the TPx/m has no open session before using it.
        fprintf('MiniPath\n')
        Datapixx('Uninitialize');
        fprintf('Uninit Done\n')
        %'Initialize' opens a TPx/m session and determines the
        %filter mode and screen margin to use for calibration.  We
        %recommend using filter mode 0 (no filtering).
        %-->    %It is mandatory to call 'Initialize' before using the
        %TPx/m.
        Datapixx('Initialize', 0);
        fprintf('init Done\n')
        %'GetEyeImageTPxMini' returns the image coming from the TPx/m
        image = Datapixx('GetEyeImageTPxMini');
        fprintf('geteyeimage Done\n')
        %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    end
    
    
end
fprintf('Done init')
image = zeros(512*2,1280,1);
image(1:512,:,1) = linspace(30,200,512)'*ones(1,1280);
image = image';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 3, open the Window and display the eye for focus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This section uses Psychtoolbox to control the video display. It displays the camera
%image from the tracker, allowing the operator to make adjustments before launching
%the calibration process.

%This section is not mandatory to complete a calibration, but good
%adjustment of the camera is necessary for the calibration to be successful.

%Search limits
%The search limits feature is also available at this step. Right-clicking
%on the right eye and left-clicking on the left eye allows you to
%set two square areas in the image which establish where the algorithm will
%look to detect the eyes. This will prevent incorrect detection due to
%glasses or other problematic elements proper to each subject.
%This feature is only avaialble for the TPx.

%A mouse right-click defines right eye search limits.
%A mouse left-click defines left eye search limits.
%A mouse middle-click or clicking on the 'C' key on the keyboard will clear search limits.
%The blue square indicates the left eye search area and the red square
%indicates the right eye search area.
%If no search areas are specified, the algorithm will search the
%entire image. Note that this is OPTIONAL.

%VPIxx API usage is minimal in this section.

% To proceed to the next step, press any key. The Escape key allows you to exit.
% Clicking on 'M' triggers a manual calibration (key press between fixations).


%Screen('Preference', 'SkipSyncTests', 1)
KbName('UnifyKeyNames');

%Open a window on screen specified by 'screenNumber'
[windowPtr, windowRect]=PsychImaging('OpenWindow', screenNumber, 0);

%cam_rect defines the position and rectangular dimension of the camera
%image texture. It specifies the upper left and lower right corners.
if isTPX
    cam_rect = [windowRect(3)/2-1280/2 0 windowRect(3)/2+1280/2 1024];
    % For TPxMini
else
    cam_rect = [windowRect(3)/2-1280/2 0 windowRect(3)/2+1280/2 1024/2];
end

background = 0;
targetLuminosity = 120;
dotLuminosity = 120;



%left_rec and right_rec represent the position and rectangular dimensions of
%the search limits for each eye.
left_rec = [0 0 0 0];
right_rec = [0 0 0 0];
%The left_rec_pixel_coordinates and right_rec_pixel_coordinates hold the
%position and rectangular dimensions of the search limits for each eye
%converted from screen position to camera image position.
left_rec_pixel_coordinates = [0 0 0 0];
right_rec_pixel_coordinates = [0 0 0 0];
%region_width specifies half the size (in pixels) of the sides of the
%search areas.
region_width = 100;
%left_limits_activated and right_limits_activated indicate if a limit was
%defined for each eye.
left_limits_activated = 0;
right_limits_activated = 0;


if ~fakeHW && isTPX
    %---------------------------- TPx -------------------------------------
    %'GetTime' returns the timer value of the DATAPixx3 (TPx only).
    t = Datapixx('GetTime');
    t2 = Datapixx('GetTime');
    %----------------------------------------------------------------------
else
    %GetSecs returns the time (in seconds) with high precision(fake or TPx/m).
    t = GetSecs;
    t2 = GetSecs;
end

Screen('TextSize', windowPtr, 24);

%calib_type holds the state of the calibration flow you wish to use.
% 0. Automatic: targets will automatically skip after a pre-determined time.
% 1. Manual: the operator must hit a key to skip to the next target during
%            calibration.
calib_type = 0;

while (1)
    %wait for a duration of 1/60 second.
    if ((t2 - t) > 1/60) % Just refresh at 60 Hz.
        if ~fakeHW
            if isTPX
                %---------------------- TPx -------------------------------
                %Get a new image from the camera (TPx)
                Datapixx('RegWrRd');
                image = Datapixx('GetEyeImage');
                %----------------------------------------------------------
            else
                %++++++++++++++++++++++ TPx/m +++++++++++++++++++++++++++++
                %Get a new image from the camera (TPx/m)
                image = Datapixx('GetEyeImageTPxMini');
                %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            end
        end
        %Create a texture from the camera image and draw it.
        textureIndex=Screen('MakeTexture', windowPtr, image');
        Screen('DrawTexture', windowPtr, textureIndex, [], cam_rect);
        
        if isTPX || fakeHW
            %-------------------------- TPx -----------------------------------
            if left_limits_activated
                %If the left search area is defined, draw it as a blue square.
                Screen('FrameRect', windowPtr, [0 0 255], left_rec);
            end
            if right_limits_activated
                %If the right search area is defined, draw it as a red square.
                Screen('FrameRect', windowPtr, [255 0 0], right_rec);
            end
            %Display different instructions depending on the current status of
            %the search limits
            if left_limits_activated
                if right_limits_activated
%                     instructions if both search limits are defined
                    text_to_draw = ['Instructions:\n\n 1- Focus the eyes.'...
                        '\n\n 2- Press Escape when ready to calibrate '...
                        '(M for manual).'];
                
                else
                    %instructions if left search limits are defined
                    text_to_draw = ['Instructions:\n\n 1- Focus the eyes.'...
                        '\n\n 2- Right click on the right eye. C or '...
                        'middle mouse to clear. Escape to exit.'];
                end
            else
                %instructions if no search limits are defined yet
                text_to_draw = ['Left click on the left eye. C or middle mouse to'...
                    'clear. Escape to exit.'];
            end
            %------------------------------------------------------------------
        else
            %++++++++++++++++++++++++++ TPx/m +++++++++++++++++++++++++++++++++
            %operator instructions for the TPx/m
            text_to_draw = [' Press Enter when ready to calibrate '...
                '(M for manual). Escape to exit'];
            
            %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            Screen('CloseAll')
            Datapixx('Uninitialize');
            Datapixx('Close');
            return;
        end
        %Draw instructions
        DrawFormattedText(windowPtr, strcat('',text_to_draw), 'center', 700, 255);
        %Update and refresh display
        Screen('Flip', windowPtr);
        %Start a new 1/60 second count
        t = t2;
        Screen('Close',textureIndex);
    else
        %update timer (TPx)
        if ~fakeHW && isTPX
            Datapixx('RegWrRd');
            t2 = Datapixx('GetTime');
        else
            %update timer (fake or TPx/m)
            t2  = GetSecs;
        end
    end
    
    % Keypress goes to next step of the demo
    [pressed, ~, keycode] = KbCheck;
    if pressed
        %if 'Escape' was pressed, quit
        if keycode(KbName('escape'))
            Screen('CloseAll')
            Datapixx('Uninitialize');
            Datapixx('Close');
            return;
        else
            %if 'M' was pressed, activate the manual calibration type and continue
            if keycode(KbName('M'))
                calib_type = 1;
            end
            %if 'C' was pressed, clear search limits and continue
            if keycode(KbName('C'))
                right_rec = [0 0 0 0];
                left_rec = [0 0 0 0];
                left_limits_activated = 0;
                right_limits_activated = 0;
                if isTPX
                    Datapixx('ClearSearchLimits');
                    Datapixx('RegWrRd');
                end
                continue;
            end
            if keycode(KbName('b'))
                background = 0;
                Screen('FillRect', windowPtr, [background background background]');
                targetLuminosity =  120;
                dotLuminosity = 120;
                continue;
            end
            if keycode(KbName('g'))
                background = 70;
                Screen('FillRect', windowPtr, [background background background]');
                targetLuminosity =  100;
                dotLuminosity = 60;
                continue;
            end
            if keycode(KbName('w'))
                background = 255;
                Screen('FillRect', windowPtr, [background background background]');
                targetLuminosity =  255;
                dotLuminosity = 200;
                continue;
            end
            break;
        end
    end
    if isTPX || fakeHW
        %---------------------------- TPx -------------------------------------
        %Read mouse input
        [X, Y, buttons] = GetMouse(windowPtr);
        %If a left-click is detected
        if buttons(1)
            % Verify that the click was inside the Camera image
            if (X > cam_rect(1) + region_width) && (X < cam_rect(3) - region_width)
                if (Y > cam_rect(2) + region_width) && (Y < cam_rect(4)/2 - region_width)
                    %Define the left eye search area.
                    left_rec = [X-region_width Y-region_width X+region_width Y+region_width];
                    % Convert to fit the camera image from [0 1920] to [0 1280]
                    left_rec_pixel_coordinates = [left_rec(1)-cam_rect(1) left_rec(2) left_rec(3)-cam_rect(1) left_rec(4)];
                    %Enable left eye search limits
                    left_limits_activated = 1;
                    if ~fakeHW
                        %'SetSearchLimits' applies the search limits in the
                        %algorithm that analyzes the eye images.
                        Datapixx('SetSearchLimits', left_rec_pixel_coordinates, right_rec_pixel_coordinates);
                        Datapixx('RegWrRd');
                    end
                end
            end
        end
        %if a middle mouse button click is detected
        if buttons(2)
            %clear search limits
            right_rec = [0 0 0 0];
            left_rec = [0 0 0 0];
            left_limits_activated = 0;
            right_limits_activated = 0;
            if ~fakeHW
                %'ClearSearchLimits' disables search limits in the algorithm
                Datapixx('ClearSearchLimits');
                Datapixx('RegWrRd');
            end
        end
        %If a right-click is detected
        if buttons(3)
            % Verify that the click was inside the Camera image
            if (X > cam_rect(1) + region_width) && (X < cam_rect(3) - region_width)
                if (Y > cam_rect(2) + region_width) && (Y < cam_rect(4)/2 - region_width)
                    %Define and enable the right eye search limits.
                    right_rec = [X-region_width Y-region_width X+region_width Y+region_width];
                    right_rec_pixel_coordinates = [right_rec(1)-cam_rect(1) right_rec(2) right_rec(3)-cam_rect(1) right_rec(4)];
                    right_limits_activated = 1;
                    if ~fakeHW
                        %Apply search limits in the algorithm
                        Datapixx('SetSearchLimits', left_rec_pixel_coordinates, right_rec_pixel_coordinates);
                        Datapixx('RegWrRd');
                    end
                end
            end
        end
        %----------------------------------------------------------------------
    end
    
    
end
if isTPX
    
    %'HideOverlay' will deactivate the console tracker window displaying the camera
    %image and pupil center tracking position. The window will be hidden.
    Datapixx('HideOverlay');
    Datapixx('RegWrRd');
end
Screen('CloseAll')
Datapixx('Uninitialize');
Datapixx('Close');
WaitSecs(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 4, Calibrations and calibration results.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This step uses PsychToolbox to display targets on screen and gathers
%raw eye data in order to calibrate the tracker. It then calculates and
%displays the results of the evaluation. It also saves those results
%for further analysis.

%Two types of calibrations are available:
% 1 - Remote (TPx/m only)
% 2 - Chinrest

%************************** TPx/m remote **********************************
%Remote calibration uses 16 predetermined points of calibration. The
%points are determined automatically by the algorithm and are returned by
%the 'InitializeCalibration' function which initializes a remote calibration.
%The points are distributed as a rectangular matrix of 4x4 elements (4 rows
%and 4 columns). It is possible to influence the coverage of the screen
%by specifying a margin when initializing the TPx/m at step 1 (refer to the
%'Initialize' command for more details). A remote calibration is less
%precise than a chinrest calibration but allows for some head movement
%without negatively affecting tracking.
%**************************************************************************

%=========================== Chinrest =====================================
%Chinrest calibration uses 13 points of calibration specified by the
%experiment. The disposition and dispersion of the points will determine
%the coverage of the screen. WARNING: The disposition of the targets will
%influence the quality of the calibration. Certain dispositions will prevent a successful
%calibration. We recommend the disposition presented below which has proven
%to provide good calibration results.  Chinrest calibrations provide
%very good precision and reliability. However the subject's head must be stabilized
%by a chinrest or else the slight head movement can produce a tracking error.
%With a chinrest calibration, the relationship between raw eye
%data and screen gaze position is determined by 4 different polynomials
%representing each axis of each eye. The same calibration process will be
%performed for each independant axis and eye giving four indenpendant
%calibration processes and results: right eye x axis, right eye y axis,
%left eye x axis and left eye y axis.
%==========================================================================

%Coordinate system:
%Psychtoolbox uses a coordinate system having an origin at the top left
%corner of the screen.  We propose functions to convert back and forth
%between custom coordinate systems and the cartesian coordinate system (origin at center of the screen).

% 1 - 'ConvertCoordSysToCartesian'
% 2 - 'ConvertCoordSysToCustom'

%Both functions take an array of coordinates, the offset of the origin to
%the center and the scaling for both x and y coordinates as inputs and then return
%the converted array of coordinates. Using default offset and scaling will
%convert back and forth to the PsychToolbox coordinate system.

%It is NOT MANDATORY to convert between coordinate systems. However, you
%must pay particular attention to different systems if switching between applications
%or toolboxes using different coordinates systems.

%xy is the calibration point array. It contains all the points that should
%be calibrated as part of the present calibration.

%eyeToVerify indicates if an eye should be ignored during calibration and
%prevents retrying to capture data for that specific eye if data was
%evaluated as invalid.
% 0 - ignore both eyes
% 1 - ignore left eye (on screen)
% 2 - ignore right eye (on screen)
% 3 - consider both eyes
eyeToVerify = 3;

%if remote calibration is used
if ~isTPX && isBuiltIn
    %********************** TPx/m remote **********************************
    %'initializeCalibration' creates a new calibration, initializes it and
    %returns the target positions and the number of points.
    [xy, nmb_pts] = Datapixx('InitializeCalibration');
    %Convert to the Psychtoolbox coordinate system
    xy(2,:) = 1080 - xy(2,:);
    %**********************************************************************
    %otherwise we use a chinrest calibration
else
    %====================== Chinrest ======================================
    
    %Specify the targets to calibrate using the Psychtoolbox coordinate system
    
    % !!!!!!!! rectangle disposition !!!!!!!!
    %                                       |
    %       x           x           x       |
    %                                       |
    %             x           x             |
    %                                       |
    %       x           x           x       |
    %                                       |
    %             x           x             |
    %                                       |
    %       x           x           x       |
    %                                       |
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
    
    %Convert to cartesian coordinate system
    xyCartesian = Datapixx('ConvertCoordSysToCartesian', xy);
    %Transpose array for manipulation simplification
    xyCartesian = xyCartesian';
    xy = xy';
    nmb_pts = size(xy);
    nmb_pts = nmb_pts(2);
    %======================================================================
end

%Set alpha-blending mode to optimize anti-aliasing (refer to Help for more information)
Screen('BlendFunction', windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%prevent potential distraction by hiding mouse pointer
HideCursor();

%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%                       CALIBRATION STATE MACHINE
%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

%This state machine will :
% 1 - Display a target -> enter state showing_dot
% 2 - Shrink the target, swap colour and refresh every 0.07 seconds (make
%     the target dynamic for better subject attention)
% 3 - When 0.95 seconds has elapsed since target display, stop updating the
%     target and save the eye information from the tracker
% 4 - Repeat the first 3 steps for all calibration points
%     (13 for chinrest, 16 for remote)
% 5 - Finalize the calibration (see more details in the corresponding section)
% 6 - Exit if accepted, try again if rejected


%i is the calibration point index that indicates what calibration point to
%display and calibrate.
i = 0;

%t, t2 and t3 are time markers to determine how much time has elapsed since a
%specific event.  They are used to control the display and the amount of time a
%target is displayed before it is calibrated
% t is actual time
% t2 is the time at which point a target is displayed
% t3 is the time of the last target display update (targets are dynamic)
t = 0;
t2 = t;
t3 = t;


%showing_dot is a state entered when a new target is displayed up until the eye
%data for this target is gathered
showing_dot = 0;
%finish_calibration is the state
finish_calibration = 0;

%Sx and Sy are the coordinates of the target to calibrate in the coordinate
%system selected for this calibration
Sx = 0;
Sy = 0;

%raw_vector contains the raw eye information from the tracker. The first
%dimension represents each of the 13 calibration points. The second
%dimension represents each eye and axis.
% 1 - right eye horzontal axis (x)
% 2 - right eye vertical axis (y)
% 3 - left eye horizontal axis (x)
% 4 - left eye vertical axis (y)
raw_vector = zeros(13,4);

%calibrationResult indicates the success or failure of the remote calibration.
calibrationResult = 0;

%The following variables are used to make the target dynamic in order to acquire and maintain
%subject attention.

%big_circle is the size of the target outer circle
big_circle = 60;
%small_circle is the size of the target inner circle
small_circle = 26;
%red RGB colour value of the target inner circle
circle_colour = 230;
if ~fakeHW && isTPX
    TPxPpSizeCal(windowPtr, 0);
    Screen('FillRect', windowPtr, [background background background]');
    Datapixx('RegWrRd');
    t4 = Datapixx('GetTime');
end

%loop until break or return;
while (1)
    %Ensure that at least 2 seconds have elapsed since the previous target display
    if ((t - t2) > 1.2)
        if isTPX || ~isBuiltIn
            %====================== Chinrest ==============================
            %Screen position to calibrate in cartesian coordinates
            Sx = xyCartesian(1,mod(i,nmb_pts)+1);
            Sy = xyCartesian(2,mod(i,nmb_pts)+1);
            %==============================================================
        else
            %********************** TPx/m remote **************************
            %Screen position to calibrate in PsychToolbox coordinates
            Sx = xy(1,mod(i,nmb_pts)+1);
            Sy = xy(2,mod(i,nmb_pts)+1);
            %**************************************************************
        end
        %Show new target specified by index i in xy
        %-->    %To have a valid calibration, it is necessary to ensure that the
        %subject is looking at the correct spot when getting the eye
        %information for that target, or else the gaze calibration will be
        %corrupted and invalid. Note that the system does not oblige you to
        %dispplay the target on screen, but not displaying the target will render the calibration almost impossible.
        %Any kind of stimulis could be used as long as its coordinates correspond
        %to the coordinates of the 'GetEyeDuringCalibrationRaw' in an orthongonal two
        %dimentional coordinate system for that target.
        Screen('DrawDots', windowPtr, [xy(:,mod(i,nmb_pts)+1) xy(:,mod(i,nmb_pts)+1)], [60;26]', [255 255 255; circle_colour 0 0]', [], 1);
        Screen('DrawLine', windowPtr, [0,190,0], xy(1,mod(i,nmb_pts)+1) + 8, xy(2,mod(i,nmb_pts)+1), xy(1,mod(i,nmb_pts)+1) - 8, xy(2,mod(i,nmb_pts)+1),2);
        Screen('DrawLine', windowPtr, [0,190,0], xy(1,mod(i,nmb_pts)+1), xy(2,mod(i,nmb_pts)+1) + 8, xy(1,mod(i,nmb_pts)+1), xy(2,mod(i,nmb_pts)+1) - 8,2);
        Screen('Flip', windowPtr);
        %Enter state showing_dot
        showing_dot = 1;
        %reset new target timer
        t2 = t;
    else %time has not elapsed yet
        %update timer
        if ~fakeHW && isTPX
            Datapixx('RegWrRd');
            t = Datapixx('GetTime');
        else
            t = GetSecs;
        end
    end
    %update the target dynamically every 0.07 seconds in showing_dot state
    if (showing_dot && t - t3 >= 0.05)
        %shrink target
        big_circle = big_circle - 3;
        small_circle = small_circle - 1;
        %change target colour
        if (mod(big_circle,2))
            circle_colour = 230;
        else
            circle_colour = 0;
        end
        %update target
        Screen('DrawDots', windowPtr, [xy(:,mod(i,nmb_pts)+1) xy(:,mod(i,nmb_pts)+1)], [big_circle;small_circle]', [255 255 255; circle_colour 0 0]', [], 1);
        Screen('DrawLine', windowPtr, [0,190,0], xy(1,mod(i,nmb_pts)+1) + small_circle/2, xy(2,mod(i,nmb_pts)+1), xy(1,mod(i,nmb_pts)+1) - small_circle/2, xy(2,mod(i,nmb_pts)+1),2);
        Screen('DrawLine', windowPtr, [0,190,0], xy(1,mod(i,nmb_pts)+1), xy(2,mod(i,nmb_pts)+1) + small_circle/2, xy(1,mod(i,nmb_pts)+1), xy(2,mod(i,nmb_pts)+1) - small_circle/2,2);
        Screen('Flip', windowPtr);
        %reset target update timer
        t3 = t;
    end
    
    %calibrate target if it has been displayed for at least .75 seconds and
    % we are currently in the showing_dot state
    if (showing_dot && (t - t2) > 0.85)
        % Get some samples!
        Screen('DrawDots', windowPtr, [xy(:,mod(i,nmb_pts)+1) xy(:,mod(i,nmb_pts)+1)], [14;9]', [255 255 255; 230 0 0]', [], 1);
        Screen('DrawLine', windowPtr, [0,190,0], xy(1,mod(i,nmb_pts)+1) + small_circle/2, xy(2,mod(i,nmb_pts)+1), xy(1,mod(i,nmb_pts)+1) - small_circle/2, xy(2,mod(i,nmb_pts)+1),1);
        Screen('DrawLine', windowPtr, [0,190,0], xy(1,mod(i,nmb_pts)+1), xy(2,mod(i,nmb_pts)+1) + small_circle/2, xy(1,mod(i,nmb_pts)+1), xy(2,mod(i,nmb_pts)+1) - small_circle/2,1);
        Screen('Flip', windowPtr);
        
        % If in manual mode, wait for a keypress
        if (calib_type == 1)
            KbWait;
        end
        %update target index
        i = i + 1;
        if ~fakeHW
            if isTPX || ~isBuiltIn
                %====================== Chinrest ==========================
                %GetEyeDuringCalibrationRaw acquires eye data from tracker.
                %It also saves that data in memory and is used (once all
                %targets are run) to calculate the formula used to convert
                %raw eye data to calibrate screen position.
                %-->           %It is mandatory to call this function to gather eye
                %information for all targets included in the calibration
                [xRawRight, yRawRight, xRawLeft, yRawLeft] = Datapixx('GetEyeDuringCalibrationRaw', Sx, Sy, eyeToVerify);
                raw_vector(i,:) = [xRawRight yRawRight xRawLeft yRawLeft];
                %==========================================================
            else
                %********************** TPx/m remote **********************
                fprintf('\nperform TPX calibration\n');
                Datapixx('ClearError');
                %'CalibrateTarget' aquires eye data from tracker in the
                %context of a remote calibration.  This data is used by the
                %calibration algorithm to calibrate gaze position.
                Datapixx('CalibrateTarget', i-1);
                fprintf('\nperform TPX calibration on %d, error: %d\n', (i-1), Datapixx('GetError'));
                %**********************************************************
            end
        else
            raw_vector(i,:) = [Sx Sy Sx Sy];
        end
        %Exit showing_dot state and reset target size and colour to prepare
        %for the next calibration point.
        showing_dot = 0;
        big_circle = 60;
        small_circle = 26;
        circle_colour = 200;
    end
    %When all targets in the xy target array have been calibrated
    if (i == nmb_pts)
        WaitSecs(2);
        if isTPX || ~isBuiltIn
            %======================== Chinrest ============================
            %Plot the results of the calibrations.  This can be used as
            %part of the calibration evaluation. It displays the raw data
            %distribution gathered during the previous phase. It quickly
            %indicates if one or more points are invalid.
            %             figure('Name','raw_data_right');
            %             H = scatter(raw_vector(:,1), raw_vector(:,2));
            %             grid on;
            %             grid minor;
            %             %Save the figure for later reference
            %             saveas(H, 'raw_data_right.fig', 'fig')
            %
            %             figure('Name','raw_data_left');
            %             H = scatter(raw_vector(:,3), raw_vector(:,4));
            %             grid on;
            %             grid minor;
            %             saveas(H, 'raw_data_left.fig', 'fig')
            %==============================================================
        end
        
        %========================== Chinrest ==============================
        %'FinishCalibration' uses the data captured in the preceeding steps and
        %runs a mathematical process to determine the formula that
        %will convert raw eye data to a calibrated gaze position on screen.
        %-->    %It is MANDATORY to call FinishCalibration in order to calibrate
        %the tracker for a chinrest calibration
        %==================================================================
        
        %************************** TPx/m remote **************************
        %'FinalizeCalibration' uses the data captured in preceeding steps
        %to determine the relationship between camera data and the subject's gaze position.
        %It is MANDATORY to call FinalizeCalibration in order to calibrate
        %the tracker for a remote calibration.
        %******************************************************************
        if ~fakeHW
            if isTPX || ~isBuiltIn
                Datapixx('FinishCalibration');
                if isTPX
                    Datapixx('RegWrRd');
                    Datapixx('GetTime') - t4
                end
            else
                calibrationResult = Datapixx('FinalizeCalibration');
                fprintf('calibration result: %d\n', calibrationResult);
            end
        end
        % As the calibration is completed, no more distraction can interfere
        % with calibraiton results.  Also, the mouse cursor can be used to
        % evaluate calibration quality.
        ShowCursor();
        
        %This section presents results from the data gathering and
        %interpolation between calibration points to evaluate the calibration.
        %This section is NOT MANDATORY and serves only as calibration
        %result presentation.
        if isTPX || ~isBuiltIn
            %scale raw data down to screen proportion for
            %display purposes
            raw_vector_sc(:,1) = (raw_vector(:,1)-min(raw_vector(:,1)))/(max(raw_vector(:,1))-min(raw_vector(:,1)))*(1800-120)+120;
            raw_vector_sc(:,2) = (raw_vector(:,2)-min(raw_vector(:,2)))/(max(raw_vector(:,2))-min(raw_vector(:,2)))*(1000-80)+80;
            raw_vector_sc(:,3) = (raw_vector(:,3)-min(raw_vector(:,3)))/(max(raw_vector(:,3))-min(raw_vector(:,3)))*(1800-120)+120;
            raw_vector_sc(:,4) = (raw_vector(:,4)-min(raw_vector(:,4)))/(max(raw_vector(:,4))-min(raw_vector(:,4)))*(1000-80)+80;
            
            %coeff_x, coeff_y, coeff_x_L and coeff_y_L hold the
            %coefficients of the polynomials determined by the calibration
            %to correlate raw eye data to screen gaze position.
            coeff_x = zeros(1,9);
            coeff_y = zeros(1,9);
            coeff_x_L = zeros(1,9);
            coeff_y_L = zeros(1,9);
            if ~fakeHW
                %'GetCalibrationCoeff' returns an array of coefficients
                %calculated by the calibration process. Positions
                % - 1 to 9 are the coefficients for the right eye x axis.
                % - 10 to 18 are the coefficients for the right eye y axis.
                % - 19 to 27 are the coefficients for the left eye x axis.
                % - 28 to 36 are the coefficients for the left eye y axis.
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
            %evaluate_bestpoly applies raw eye positions to the polynomial
            %and returns calibrated gaze position on screen.
            %Evaluate all the calibration points
            [x_eval_cartesian,y_eval_cartesian] = evaluate_bestpoly(raw_vector(:,1)', raw_vector(:,2)', coeff_x, coeff_y);
            [x_eval_L_cartesian,y_eval_L_cartesian] = evaluate_bestpoly(raw_vector(:,3)', raw_vector(:,4)', coeff_x_L, coeff_y_L);
            right_eye_eval = [x_eval_cartesian' y_eval_cartesian'];
            left_eye_eval = [x_eval_L_cartesian' y_eval_L_cartesian'];
            %convert back to PsychToolbox coordinate system for display
            xy_eval = Datapixx('ConvertCoordSysToCustom', right_eye_eval);
            xy_eval_L = Datapixx('ConvertCoordSysToCustom', left_eye_eval);
            %transpose for easier manipulation
            x_eval = xy_eval(:,1)';
            y_eval = xy_eval(:,2)';
            x_eval_L = xy_eval_L(:,1)';
            y_eval_L = xy_eval_L(:,2)';
            
            %p_p is the segment list between the calibration points
            p_p = [9 4; 4 8; 9 5; 4 1; 8 3; 5 1; 1 3; 5 7; 1 2; 3 6; 7 2; 2 6];
            
            %n_points represent the number of points to interpolate between
            %two calibration points.
            n_points = 10;
            
            %*_interpol_raw* variables contain raw interpolation points
            %between two calibration points.
            %*_interpol* variables hold the corresponding calibrated data
            %*_interpol_cartesian holds the coordinate system converted data
            %*_eye_interpol holds the raw data interpolation points in x
            %and y. Data organisation for convertion
            %xy_interpol* holds the calibrated and converted interpolation
            %data
            % We have 12 segments and create 10 points each (for now)
            x_interpol_raw = zeros(12, n_points);
            y_interpol_raw = zeros(12, n_points);
            x_interpol_raw_L = zeros(12, n_points);
            y_interpol_raw_L = zeros(12, n_points);
            x_interpol = zeros(12, n_points);
            y_interpol = zeros(12, n_points);
            x_interpol_L = zeros(12, n_points);
            y_interpol_L = zeros(12, n_points);
            x_interpol_cartesian = zeros(12, n_points);
            y_interpol_cartesian = zeros(12, n_points);
            x_interpol_L_cartesian = zeros(12, n_points);
            y_interpol_L_cartesian = zeros(12, n_points);
            right_eye_interpol = zeros(n_points,2,12);
            left_eye_interpol = zeros(n_points,2,12);
            xy_interpol = zeros(n_points,2,12);
            xy_interpol_L = zeros(n_points,2,12);
            
            %Interpolate raw data between calibration points
            for i = 1:12
                x_interpol_raw(i,:) = linspace(raw_vector(p_p(i,1),1),raw_vector(p_p(i,2),1), n_points);
                y_interpol_raw(i,:) = linspace(raw_vector(p_p(i,1),2),raw_vector(p_p(i,2),2), n_points);
                x_interpol_raw_L(i,:) = linspace(raw_vector(p_p(i,1),3),raw_vector(p_p(i,2),3), n_points);
                y_interpol_raw_L(i,:) = linspace(raw_vector(p_p(i,1),4),raw_vector(p_p(i,2),4), n_points);
            end
            
            %Apply calibration to the interpolated raw data and convert to the
            %PsychToolbox coordinate system
            for i = 1:12
                [x_interpol_cartesian(i,:),y_interpol_cartesian(i,:)] = evaluate_bestpoly(x_interpol_raw(i,:)', y_interpol_raw(i,:)', coeff_x, coeff_y);
                [x_interpol_L_cartesian(i,:),y_interpol_L_cartesian(i,:)] = evaluate_bestpoly(x_interpol_raw_L(i,:)', y_interpol_raw_L(i,:)', coeff_x_L, coeff_y_L);
                right_eye_interpol(:,:,i) = [x_interpol_cartesian(i,:)' y_interpol_cartesian(i,:)'];
                left_eye_interpol(:,:,i) = [x_interpol_L_cartesian(i,:)' y_interpol_L_cartesian(i,:)'];
                xy_interpol(:,:,i) = Datapixx('ConvertCoordSysToCustom', right_eye_interpol(:,:,i));
                xy_interpol_L(:,:,i) = Datapixx('ConvertCoordSysToCustom', left_eye_interpol(:,:,i));
                x_interpol(i,:) = xy_interpol(:,1,i);
                y_interpol(i,:) = xy_interpol(:,2,i);
                x_interpol_L(i,:) = xy_interpol_L(:,1,i);
                y_interpol_L(i,:) = xy_interpol_L(:,2,i);
            end
            
            % Fill the proper display vector from the 12x10 matrix (make it 2x120)
            interpolated_dots = zeros(2,n_points*12);
            interpolated_dots_L = zeros(2,n_points*12);
            for i=1:12
                interpolated_dots(1,(i-1)*n_points+1:(i-1)*n_points+n_points) = x_interpol(i,:);
                interpolated_dots(2,(i-1)*n_points+1:(i-1)*n_points+n_points) = y_interpol(i,:);
                interpolated_dots_L(1,(i-1)*n_points+1:(i-1)*n_points+n_points) = x_interpol_L(i,:);
                interpolated_dots_L(2,(i-1)*n_points+1:(i-1)*n_points+n_points) = y_interpol_L(i,:);
            end
        end
        %file_recorded indicates if the displayed results were saved
        %to file to prevent from being required to save them every time they are displayed.
        file_recorded = 0;
        
        %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        %                       DISPLAY RESULT LOOP
        %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        %This loop cycles through results to display and show them on screen.
        %The first time a result is displayed, it is saved to file.
        %Click 'Y' to get out of the result display loop and accept the calibration.
        %Click 'N' to get out of the result display loop and reject the calibration.
        %Any other key will cycle through the result pages.
        while (1)
            %first result page to display: scaled raw data
            if isTPX || ~isBuiltIn
                DrawFormattedText(windowPtr, '\n Calibration results 1 of 4. \n Showing raw data results. If one dot seems off, calibration might be bad.\n Press any key to continue. Y to acccept, N to restart.', 'center', 100, 255);
            else
                if calibrationResult > 0
                    DrawFormattedText(windowPtr, '\n Calibration pass.\n Press any key to acccept, N to restart.', 'center', 100, 255);
                else
                    DrawFormattedText(windowPtr, '\n Calibration fail.\n Press any key to acccept, N to restart.', 'center', 100, 255);
                end
            end
            
            if ~fakeHW
                if isTPX || ~isBuiltIn
                    %Show raw data scaled to screen proportion
                    Screen('DrawDots', windowPtr, [raw_vector_sc(:,1)'; raw_vector_sc(:,2)'], [10]', [255 0 0]', [], 1);
                    Screen('DrawDots', windowPtr, [raw_vector_sc(:,3)'; raw_vector_sc(:,4)'], [10]', [0 0 255]', [], 1);
                end
            else
                % fake
                Screen('DrawDots', windowPtr, [raw_vector_sc(:,1)'; raw_vector_sc(:,2)'], [10]', [255 0 255]', [], 1);
            end
            
            Screen('Flip', windowPtr);
            WaitSecs(0.3);
            if ((isTPX || ~isBuiltIn) && ~file_recorded)
                %save screen to file for further reference
                imageArray = Screen('GetImage', windowPtr);
                imwrite(imageArray, 'ScaledRawData.jpg');
            end
            
            %wait for any keyboard entry before proceeding to the next result page
            [secs, keyCode, deltaSecs] = KbWait;
            %Click 'Y' to ignore other results and immediately accept the calibration
            if (keyCode(KbName('Y')) || (~isTPX && isBuiltIn)) % good calib
                finish_calibration = 1;
                break;
                %Click 'N' to reject the calibration and srart back from the beginning
            elseif keyCode(KbName('N')) % bad calib
                % Reset variables and states.
                t = 0;
                t2 = t;
                t3 = t;
                showing_dot = 0;
                Sx = 0;
                Sy = 0;
                i = 0;
                raw_vector = zeros(13,4);
                finish_calibration = 0;
                break;
                %Click any other key to proceed to the next results page.
            end
            
            %2nd result page to display: right eye interpolation
            DrawFormattedText(windowPtr, '\n Calibration results 2 of 4. \n Showing calibration dots and screen from polynomial for right eye. \n If the dots are off or the lines are not well connected, calibration for this eye might be off. \n Press any key to continue. Y to acccept, N to restart.', 'center', 100, 255);
            Screen('DrawDots', windowPtr, [xy(1,:)' xy(2,:)']', [30]', [255 255 255]', [], 1);
            Screen('DrawDots', windowPtr, [x_eval' y_eval']', [20]', [255 0 255]', [], 1);
            Screen('DrawDots', windowPtr, interpolated_dots, [8]', [255 0 0]', [], 1);
            Screen('Flip', windowPtr);
            WaitSecs(0.3);
            if(~file_recorded)
                imageArray = Screen('GetImage', windowPtr);
                imwrite(imageArray, 'PolyResponse_R.jpg')
            end
            [secs, keyCode, deltaSecs] = KbWait;
            if keyCode(KbName('Y'))
                finish_calibration = 1;
                break;
            elseif keyCode(KbName('N'))
                % not working.
                t = 0;
                t2 = 0;
                t3 = 0;
                showing_dot = 0;
                Sx = 0;
                Sy = 0;
                i = 0;
                raw_vector = zeros(13,4);
                finish_calibration = 0;
                break;
            end
            
            %3rd result page to display; Left eye interpolation
            DrawFormattedText(windowPtr, '\n Calibration results 3 of 4. \n Showing calibration dots and screen from polynomial for left eye. \n If the dots are off or the lines are not well connected, calibration for this eye might be off. \n Press any key to continue. Y to acccept, N to restart.', 'center', 100, 255);
            Screen('DrawDots', windowPtr, [xy(1,:)' xy(2,:)']', [30]', [255 255 255]', [], 1);
            Screen('DrawDots', windowPtr, [x_eval_L' y_eval_L']', [20]', [0 255 255]', [], 1);
            Screen('DrawDots', windowPtr, interpolated_dots_L, [8]', [0 0 255]', [], 1);
            Screen('Flip', windowPtr);
            WaitSecs(0.3);
            if(~file_recorded)
                imageArray = Screen('GetImage', windowPtr);
                imwrite(imageArray, 'PolyResponse_L.jpg')
            end
            [secs, keyCode, deltaSecs] = KbWait;
            if keyCode(KbName('Y'))
                finish_calibration = 1;
                break;
            elseif keyCode(KbName('N'))
                t = 0;
                t2 = 0;
                t3 = 0;
                showing_dot = 0;
                Sx = 0;
                Sy = 0;
                i = 0;
                raw_vector = zeros(13,4);
                finish_calibration = 0;
                break;
            end
            
            DrawFormattedText(windowPtr, '\n Calibration results 4 of 4. \n Showing calibration dots and screen from polynomial for both eyes. \n The error is indicated in the corresponding color. \n Press any key to continue. Y to acccept, N to restart.', 'center', 100, 255);
            Screen('DrawDots', windowPtr, [xy(1,:)' xy(2,:)']', [30]', [255 255 255]', [], 1);
            Screen('DrawDots', windowPtr, [x_eval_L' y_eval_L']', [20]', [0 255 255]', [], 1);
            Screen('DrawDots', windowPtr, [x_eval' y_eval']', [20]', [255 0 255]', [], 1);
            
            %Calculate the error between calibration points and the corresponding gaze position
            %mean_err_r and mean_err_l hold the error at the 13 points of the
            %calibration to calculate the error average
            mean_err_r = zeros(1,size(xy,2));
            mean_err_l = zeros(1,size(xy,2));
            for i = 1:size(xy,2)
                err_r = sqrt((xy(1,i) - x_eval(i))^2 + (xy(2,i) - y_eval(i))^2);
                mean_err_r(i) = err_r;
                err_l = sqrt((xy(1,i) - x_eval_L(i))^2 + (xy(2,i) - y_eval_L(i))^2);
                mean_err_l(i) = err_l;
                Screen('DrawText', windowPtr, sprintf('%.1f', err_r), xy(1,i) + 15, xy(2,i) + 20, [255 0 255]);
                Screen('DrawText', windowPtr, sprintf('%.1f', err_l), xy(1,i) + 15, xy(2,i) - 20, [0 255 255]);
            end
            Screen('DrawText', windowPtr, sprintf('Right eye mean error = %.2f', mean(mean_err_r)), 800, 1000, [255 0 255]);
            Screen('DrawText', windowPtr, sprintf('Left eye mean error  = %.2f', mean(mean_err_l)), 800, 1040, [0 255 255]);
            Screen('Flip', windowPtr);
            WaitSecs(0.3);
            if(~file_recorded)
                imageArray = Screen('GetImage', windowPtr);
                imwrite(imageArray, 'Cal_points_error.jpg')
                file_recorded = 1;
            end
            
            [secs, keyCode, deltaSecs] = KbWait;
            if keyCode(KbName('Y'))
                finish_calibration = 1;
                break;
            elseif keyCode(KbName('N'))
                t = 0;
                t2 = 0;
                t3 = 0;
                showing_dot = 0;
                Sx = 0;
                Sy = 0;
                i = 0;
                raw_vector = zeros(13,4);
                finish_calibration = 0;
                break;
            end
            
        end
    end
    
    % check if 'escape' was pressed to quit
    [pressed, ~, keycode] = KbCheck;
    if pressed
        if keycode(KbName('escape'))
            Datapixx('Uninitialize');
            Screen('CloseAll')
            
            if isTPX || ~isBuiltIn
                Datapixx('Close');
            end
            return;
        end
    end
    
    %If in the finish calibration state, exit the calibration loop
    if (finish_calibration == 1)
        %Run a validation on the recent calibration
        %Display the target and record data in order to compare
        %expected gaze position to actual gaze postion
        cal_status = TPxValidateCalibration(xy, isTPX, windowPtr, 0);
        if cal_status
            break;
        end
        finish_calibration = 0;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 5 -- Gaze follower. A small demo that verifies the calibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This section applies calibration to the eye data collected by the camera and
%displays it live on screen. This allows for the validation that a calibration is
%satisfactory and to evaluate the precision level of this calibration. It can
%also be used to compare results of different calibrations.
%This section is NOT MANDATORY.
%There are some available hidden features:
%Press
% - 'F' to activate averaging on the gaze position, which will smooth the results
% - 'D' to deactivate the averaging
% - 'H' to hide the circles indicating the gaze position
% - 'U' to unhide or show the circles indicating gaze position
% - left mouse button to save the current gaze position to file along with
%   its distance to the mouse pointer (labeled as error) and, in a differnt
%   file, the corresponding raw data. It also displays the error on screen
% - right mouse button to display the current coordinates of the mouse
%   pointer
% - middle mouse button to clear the current error displayed on screen
% - 'Escape' to exit

%fileID will contain the gaze position and its distance to the mouse
%pointer when clicking mouse button 1
fileID = fopen('error_measure.csv', 'a');

%fileID2 will contain the raw eye data corresponding to the gaze position saved
%in fileID
fileID2 = fopen('raw_compare.csv', 'a');

fprintf(fileID, 'timetag,mouse X,mouse Y,right eye x,right eye y,left eye x,left eye y,error rigth x,error right y,error left x,error left y,pp left,pp right\n');

%visible holds the status of the gaze position indicator.
% - 0 : gaze position indicator is hidden
% - 1 : gaze position indicator is displayed
visible = 1;

%mfilter holds the status of the averaging of the gaze position.
% - 0 : gaze position is not averaged
% - 1 : gaze position is averaged
mfilter = 0;

%xAvgRight, yAvgRight, xAvgLeft and yAvgLeft contain the 10 last gaze
%positions read from the camera in order to apply an averaging to the
%outcoming result
xAvgRight = [];
yAvgRight = [];
xAvgLeft = [];
yAvgLeft = [];

%xErrRight, yErrRight, xErrLeft and yErrLeft hold the 20 last error values
%measured between the gaze position and the mouse pointer. The Error is
%measured only when mouse button 1 is clicked.
xErrRight = [];
yErrRight = [];
xErrLeft = [];
yErrLeft = [];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~ USB I/O Hub ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if enableUSBIOHub == 1
    ranNum = randi([1, 5])
    time1 = 0
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%                           GAZE FOLLOWER LOOP
%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%Display subject gaze position on screen
% 1. Draw text and calibration points as white circles
% 2. Get gaze position
% 3. Convert it to the PsychToolbox coordinate system
% 4. Apply averaging if activated
% 5. Draw gaze position as circles if activated
% 6. Check for mouse and keyboard input
% 7. Change state and take action accordingly
%    a) Update state averaging (keyboard 'F' / 'D')
%    b) Update state visible (keyboard 'H' / 'U')
%    c) Display mouse pointer coordinates (right mouse button click)
%    d) Display error between mouse pointer and gaze position and save it
%       to a file (left mouse button click)
%    e) clear the error array (middle mouse button click)
%    f) exit (keyboard 'Escape')
% 8. Apply drawing and display it on screen

while (1)
    %Draw current instructions
    DrawFormattedText(windowPtr, 'Following your gaze now!', 'center', 700, dotLuminosity);
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~ USB I/O Hub ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if enableUSBIOHub == 1
        DrawFormattedText(windowPtr, sprintf('Press %s Button', buttonNames{ranNum}), 'center', 200, 255);
        DrawFormattedText(windowPtr,  sprintf('Pressed Time: %s', time1), 'center', 400, 255);
    end
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %Draw calibration points as white circles
    Screen('DrawDots', windowPtr, [xy(1,:)' xy(2,:)']', [20]', [dotLuminosity dotLuminosity dotLuminosity]', [], 1);
    if ~fakeHW
        %~~~~~~~~~~~~~~~~~~~~ USB I/O Hub ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        if enableUSBIOHub == 1
            [axes, buttons, povs] = read(joy);
            buttonChange = xor(buttons, buttons0);
            if any(buttonChange) > 0
                if buttons(find(buttonChange==1)) == 1
                    if ranNum == find(buttonChange==1)
                        ranNum = randi([1, 5]);
                        fprintf(s,'GetEventTime')
                        time1 = fscanf(s);
                    end
                end
            end
        end
        %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        if isTPX
            Datapixx('RegWrRd');
        end
        %Get gaze position
        [xScreenRightCartesian yScreenRightCartesian xScreenLeftCartesian yScreenLeftCartesian xRawRight yRawRight xRawLeft yRawLeft] = Datapixx('GetEyePosition', isBuiltIn);
        if isTPX
            [ppLeftMajor ppLeftMinor ppRightMajor ppRightMinor] = Datapixx('GetPupilSize');
            
            timetag = Datapixx('GetTime');
        else
            timetag = GetSecs;
            datarray = Datapixx('ReadTPxMiniData');
            ppLeftMajor = datarray(4);
            ppRightMajor = datarray(8);
        end
        
        %Convert gaze position to PsychToolbox coordinate system
        rightEyeCartesian = [xScreenRightCartesian yScreenRightCartesian];
        leftEyeCartesian = [xScreenLeftCartesian yScreenLeftCartesian];
        rightEyeTopLeft = Datapixx('ConvertCoordSysToCustom', rightEyeCartesian);
        leftEyeTopLeft = Datapixx('ConvertCoordSysToCustom', leftEyeCartesian);
        xScreenRight = rightEyeTopLeft(1);
        yScreenRight = rightEyeTopLeft(2);
        xScreenLeft = leftEyeTopLeft(1);
        yScreenLeft = leftEyeTopLeft(2);
        %Accumulate data for averaging (10)
        if (size(xAvgRight,1) < 10)
            xAvgRight = [xScreenRight;xAvgRight];
            yAvgRight = [yScreenRight;yAvgRight];
            xAvgLeft = [xScreenLeft;xAvgLeft];
            yAvgLeft = [yScreenLeft;yAvgLeft];
        else
            xAvgRight = circshift(xAvgRight,1);
            xAvgRight(1) = xScreenRight;
            yAvgRight = circshift(yAvgRight,1);
            yAvgRight(1) = yScreenRight;
            xAvgLeft = circshift(xAvgLeft,1);
            xAvgLeft(1) = xScreenLeft;
            yAvgLeft = circshift(yAvgLeft,1);
            yAvgLeft(1) = yScreenLeft;
        end
    else
        [X,Y] = GetMouse();
    end
    
    
    
    if ~fakeHW
        %Draw gaze position if activated
        if visible
            %Draw averaged data if averaging activated
            if mfilter
                Screen('DrawDots', windowPtr, [mean(xAvgRight); mean(yAvgRight)], [15]', [targetLuminosity 0 0]', [], 1);
                Screen('DrawDots', windowPtr, [mean(xAvgLeft); mean(yAvgLeft)], [15]', [0 0 targetLuminosity]', [], 1);
                %Otherwise draw (non-averaged) data
            else
                Screen('DrawDots', windowPtr, [xScreenRight; yScreenRight], [15]', [targetLuminosity 0 0]', [], 1);
                Screen('DrawDots', windowPtr, [xScreenLeft; yScreenLeft], [15]', [0 0 targetLuminosity]', [], 1);
            end
        end
    else
        Screen('DrawDots', windowPtr, [X; Y], [15]', [targetLuminosity 0 targetLuminosity]', [], 1);
        
    end
    
    %Check mouse action
    [X, Y, buttons] = GetMouse(windowPtr);
    %left click detected
    if buttons(1)
        %clear the error array if a reset was detected (middle mouse button)
        if reset_error
            xErrRight = [];
            yErrRight = [];
            xErrLeft = [];
            yErrLeft = [];
            reset_error = 0;
        end
        %save mouse position, gaze position and the error between both to file
        fprintf(fileID, '%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n',...
            timetag, X, Y, xScreenRight, yScreenRight, xScreenLeft, ...
            yScreenLeft, (X - xScreenRight), (Y - yScreenRight),...
            (X - xScreenLeft), (Y - yScreenLeft), ppLeftMajor, ppRightMajor);
        %save corresponding raw eye data to another file
        fprintf(fileID2, '%f,%f,%f,%f,%f,%f,\n', X, Y, xRawRight, yRawRight, xRawLeft, yRawLeft);
        %keep the 20 last measured errors for averaging
        if (size(xErrRight,1) < 20)
            xErrRight = [X - xScreenRight;xErrRight];
            yErrRight = [Y - yScreenRight;yErrRight];
            xErrLeft = [X - xScreenLeft;xErrLeft];
            yErrLeft = [Y - yScreenLeft;yErrLeft];
        else
            xErrRight = circshift(xErrRight,1);
            xErrRight(1) = X - xScreenRight;
            yErrRight = circshift(yErrRight,1);
            yErrRight(1) = Y - yScreenRight;
            xErrLeft = circshift(xErrLeft,1);
            xErrLeft(1) = X - xScreenLeft;
            yErrLeft = circshift(yErrLeft,1);
            yErrLeft(1) = Y - yScreenLeft;
        end
        %draw the mean of the last 20 errors
        Screen('TextSize', windowPtr, 16);
        Screen('Preference', 'TextAlphaBlending', 1);
        Screen('TextBackgroundColor', windowPtr, [250 248 200]);
        %         DrawFormattedText(windowPtr, sprintf('    %f  |  %f\n    %f  |  %f', mean(xErrRight),mean(yErrRight),mean(xErrLeft),mean(yErrLeft)), 'right', [], 10);
        Screen('Preference', 'TextAlphaBlending', 0);
    elseif buttons(3)
        Screen('TextSize', windowPtr, 16);
        Screen('Preference', 'TextAlphaBlending', 1);
        Screen('DrawText', windowPtr, sprintf('    %d  |  %d', X,Y), X, Y, 10, [250 248 200]);
        Screen('Preference', 'TextAlphaBlending', 0);
    else
        reset_error = 1;
    end
    
    %draw last 10 errors
    Screen('TextSize', windowPtr, 14);
    Screen('Preference', 'TextAlphaBlending', 1);
    Screen('TextBackgroundColor', windowPtr, [250 248 200]);
    %     if (size(xErrRight,1) > 10)
    %         newX = 10;
    %         newY = 920;
    %         for i=1:10
    %             [newX,newY] = DrawFormattedText(windowPtr, sprintf('  %7.2f  |  %7.2f  |  %7.2f  |  %7.2f\n', xErrRight(i), yErrRight(i), xErrLeft(i), yErrLeft(i)), newX, newY, 5);
    %         end
    %     end
    Screen('TextBackgroundColor', windowPtr, [0 0 0 0]);
    Screen('Preference', 'TextAlphaBlending', 0);
    Screen('TextSize', windowPtr, 24);
    
    %Apply drawing on screen
    Screen('Flip', windowPtr);
    
    %Check keyboard event
    [pressed dum keycode] = KbCheck;
    if pressed
        %'Escape' -> exit
        if keycode(KbName('escape'))
            Datapixx('Uninitialize');
            Screen('CloseAll');
            Datapixx('Close');
            break;
        end
        %'h' -> deactivate or hide gaze position display
        if keycode(KbName('h'))
            visible = 0;
        end
        %'u' -> activate or unhide gaze position display
        if keycode(KbName('u'))
            visible = 1;
        end
        %'f' -> activate averaging
        if keycode(KbName('f'))
            mfilter = 1;
        end
        %'d' -> deactivate averaging
        if keycode(KbName('d'))
            mfilter = 0;
        end
        if keycode(KbName('b'))
            Screen('FillRect', windowPtr, [0 0 0]');
            targetLuminosity =  120;
            dotLuminosity = 120;
        end
        if keycode(KbName('g'))
            Screen('FillRect', windowPtr, [70 70 70]');
            targetLuminosity =  100;
            dotLuminosity = 60;
        end
        if keycode(KbName('w'))
            Screen('FillRect', windowPtr, [255 255 255]');
            targetLuminosity = 255;
            dotLuminosity = 215;
        end
    end
end

%'Uninitialize'closes TPx/m session.  it does nothing if the hardware is a TPx.
Datapixx('Uninitialize')

%~~~~~~~~~~~~~~~~~~~~~~~~~~~ USB I/O Hub ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if enableUSBIOHub == 1
    fprintf(s,'SetLedAllOff')
    fclose(s);
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

fclose(fileID);
fclose(fileID2);

end