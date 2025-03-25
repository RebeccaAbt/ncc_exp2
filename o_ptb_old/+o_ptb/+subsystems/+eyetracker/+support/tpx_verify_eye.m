function tpx_verify_eye()

ptb = o_ptb.PTB.get_instance();
ptb_cfg = ptb.get_config();

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
Datapixx('SetLedIntensity', ptb_cfg.datapixxtrackpixx_config.led_intensity);

%Iris size in pixel. Recommended values for a typical setup are:
% - 70 pixels for 25 mm lens at about 50 - 60 cm
% - 140 pixels for 50 mm lens at about 60 cm
% - 150 pixels for typical MRI setup.
%-->    %Having a significant mismatch in iris size will prevent good
%tracking. If using a non typical setup, it is recommended to
%adapt iris size by either calculating or measuring it.
Datapixx('SetLens', ptb_cfg.datapixxtrackpixx_config.lens);
Datapixx('SetDistance', ptb_cfg.datapixxtrackpixx_config.distance);

Datapixx('RegWrRd');
%'GetEyeImage' returns the image coming from the TPx.
image = Datapixx('GetEyeImage');
%----------------------------------------------------------------------

image = zeros(512*2,1280,1);
image(1:512,:,1) = linspace(30,200,512)'*ones(1,1280);
image = image';

%Open a window on screen specified by 'screenNumber'
ptb = o_ptb.PTB.get_instance();
windowPtr = ptb.win_handle;
windowRect = ptb.win_rect;


cam_rect = [windowRect(3)/2-1280/2 0 windowRect(3)/2+1280/2 1024];

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


%---------------------------- TPx -------------------------------------
%'GetTime' returns the timer value of the DATAPixx3 (TPx only).
t = Datapixx('GetTime');
t2 = Datapixx('GetTime');
%----------------------------------------------------------------------

Screen('TextSize', windowPtr, 24);

%calib_type holds the state of the calibration flow you wish to use.
% 0. Automatic: targets will automatically skip after a pre-determined time.
% 1. Manual: the operator must hit a key to skip to the next target during
%            calibration.
calib_type = 0;

while (1)
  %wait for a duration of 1/60 second.
  if ((t2 - t) > 1/60) % Just refresh at 60 Hz.
    %---------------------- TPx -------------------------------
    %Get a new image from the camera (TPx)
    Datapixx('RegWrRd');
    image = Datapixx('GetEyeImage');
    
    %Create a texture from the camera image and draw it.
    textureIndex=Screen('MakeTexture', windowPtr, image');
    Screen('DrawTexture', windowPtr, textureIndex, [], cam_rect);
    
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
        %instructions if both search limits are defined
%         text_to_draw = ['Instructions:\n\n 1- Focus the eyes.'...
%           '\n\n 2- Press Enter when ready to calibrate '...
%           '(M for manual). Escape to exit'];
        text_to_draw = ['Press Escape to exit!'];
      else
        %instructions if left search limits are defined
%         text_to_draw = ['Instructions:\n\n 1- Focus the eyes.'...
%           '\n\n 2- Right click on the right eye. C or '...
%           'middle mouse to clear. Escape to exit.'];
        text_to_draw = ['Right click via right mouse button on the right eye.'];
      end
    else
      %instructions if no search limits are defined yet
%       text_to_draw = ['Instructions:\n\n 1- Focus the eyes.\n\n'...
%         '2- Left click on the left eye. C or middle mouse to'...
%         'clear. Escape to exit.'];
      text_to_draw = ['Left click via left mouse button on the left eye.'];
    end
    %------------------------------------------------------------------
    %Draw instructions
    DrawFormattedText(windowPtr, strcat('',text_to_draw), 'center', 700, 255);
    %Update and refresh display
    Screen('Flip', windowPtr);
    %Start a new 1/60 second count
    t = t2;
    Screen('Close',textureIndex);
  else
    Datapixx('RegWrRd');
    t2 = Datapixx('GetTime');
  end
  
  % Keypress goes to next step of the demo
  [pressed, ~, keycode] = KbCheck;
  if pressed
    %if 'Escape' was pressed, quit
    if keycode(KbName('escape'))
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
    end
  end
  
  %---------------------------- TPx -------------------------------------
  %Read mouse input
  [X, Y, buttons] = GetMouse(windowPtr);
  [X, Y] = RemapMouse(ptb.win_handle, 'AllViews', X, Y);
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
        %'SetSearchLimits' applies the search limits in the
        %algorithm that analyzes the eye images.
        Datapixx('SetSearchLimits', left_rec_pixel_coordinates, right_rec_pixel_coordinates);
        Datapixx('RegWrRd');
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
    %'ClearSearchLimits' disables search limits in the algorithm
    Datapixx('ClearSearchLimits');
    Datapixx('RegWrRd');
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
        %Apply search limits in the algorithm
        Datapixx('SetSearchLimits', left_rec_pixel_coordinates, right_rec_pixel_coordinates);
        Datapixx('RegWrRd');
      end
    end
  end
  %----------------------------------------------------------------------
  
  
end

%'HideOverlay' will deactivate the console tracker window displaying the camera
%image and pupil center tracking position. The window will be hidden.
Datapixx('HideOverlay');
Datapixx('RegWrRd');
