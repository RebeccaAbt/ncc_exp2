%% clear...
clear all global
close all
restoredefaultpath;
commandwindow

%% add path
o_ptb.init_ptb('C:\Users\thartmann\Documents\git\Psychtoolbox-3');

%% configure...
ptb_cfg = o_ptb.PTB_Config;
ptb_cfg.fullscreen = false;
ptb_cfg.window_scale = 0.2;
ptb_cfg.skip_sync_test = true;
ptb_cfg.hide_mouse = false;
ptb_cfg.datapixxresponse_config.button_mapping('change_side') = ptb_cfg.datapixxresponse_config.Yellow;
ptb_cfg.keyboardresponse_config.button_mapping('change_side') = KbName('space');

ptb_cfg.datapixxresponse_config.button_mapping('stop') = ptb_cfg.datapixxresponse_config.Red;
ptb_cfg.keyboardresponse_config.button_mapping('stop') = KbName('Return');

ptb_cfg.real_experiment_sbg_cdk(true);

ptb = o_ptb.PTB.get_instance(ptb_cfg);

%% setup subsystems


%% do eye position calibration
ptb.setup_eyetracker();
ptb.setup_response();
ptb.setup_screen();
ptb.eyetracker_verify_eye_positions();
sca

%% do calibration
ptb.setup_eyetracker();
ptb.setup_response();
ptb.setup_screen();
ptb.eyetracker_calibrate()
sca

%% start eyetracker
ptb.setup_eyetracker();
ptb.setup_response();
ptb.setup_screen();
ptb.start_eyetracker();

% show some dots and see whether the coordinates correspond....
shall_stop = false;
target = o_ptb.stimuli.visual.FilledCircle(50, o_ptb.constants.PTB_Colors.white);
eye_marker = o_ptb.stimuli.visual.FilledCircle(30, o_ptb.constants.PTB_Colors.black);

current_move = [-600, 0];

while(~shall_stop)
  target.center_on_screen();
  eye_marker.center_on_screen();
  target.move(current_move(1), current_move(2));
  eye_pos = ptb.get_eye_positions();
  
  eye_marker.move(eye_pos.right.x, eye_pos.right.y);
  
  ptb.draw(target);
  ptb.draw(eye_marker);
  ptb.flip();
  
  resp = ptb.wait_for_keys({'change_side', 'stop'}, GetSecs+0.01);
  %resp = {};
  
  if(any(strcmp(resp, 'stop')))
    shall_stop = true;
  elseif(any(strcmp(resp, 'change_side')))
    current_move(1) = -current_move(1);
  end
  
end %while

% stop eyetracker
ptb.stop_eyetracker();

% save data
%ptb.save_eyetracker_data('snippets/eye_output/dig.mat');

sca
