classdef Datapixx < o_ptb.subsystems.eyetracker.Base
  %DATAPIXX Summary of this class goes here
  %   Detailed explanation goes here
  properties (GetAccess = public, SetAccess = protected)
    is_running;
    data;
    buffer_address = 12e6;
  end %properties
  
  methods (Access = public)
    function obj = Datapixx()
      ptb = o_ptb.PTB.get_instance();
      ptb_cfg = ptb.get_config();
      obj.is_running = false;
      obj.data = [];
      
      obj.buffer_address = ptb_cfg.datapixxtrackpixx_config.buffer_address;
    end %function
    
    
    function verify_eye_positions(obj)
      ShowCursor('CrossHair');
      o_ptb.subsystems.eyetracker.support.tpx_verify_eye();
    end %function
    
    
    function calibrate(obj, out_folder)
      ptb = o_ptb.PTB.get_instance();
      ShowCursor('CrossHair');
      o_ptb.subsystems.eyetracker.support.do_my_calibration(ptb.win_handle, out_folder, false);
      
    end %function
    
    
    
    function start(obj)
      ptb = o_ptb.PTB.get_instance();
      ptb_cfg = ptb.get_config();
      if obj.is_running
        error('Eyetracker is already running');
      end %if
      
      fprintf('Starting eye tracker...\n');
      obj.is_running = true;
      
      Datapixx('HideOverlay');
      Datapixx('SetupTPxSchedule', obj.buffer_address);
      Datapixx('StartTPxSchedule');
      Datapixx('EnableTrackpixxAnalogOutput', ptb_cfg.datapixxtrackpixx_config.analogue_eye);
      Datapixx('SetLedIntensity', ptb_cfg.datapixxtrackpixx_config.led_intensity);
      Datapixx('SetLens', ptb_cfg.datapixxtrackpixx_config.lens);
      Datapixx('SetDistance', ptb_cfg.datapixxtrackpixx_config.distance);
      Datapixx('RegWrRd');
      
    end %function
    
    
    
    function stop(obj)
      if ~obj.is_running
        error('Eyetracker is already stopped');
      end %if
      
      fprintf('Stopping eye tracker...\n');
      obj.is_running = false;
      
      Datapixx('RegWrRd');
      status = Datapixx('GetTPxStatus');
      to_read = status.newBufferFrames;
      
      obj.data = Datapixx('ReadTPxData', to_read);
      
      Datapixx('StopTPxSchedule');
      Datapixx('DisableTrackpixxAnalogOutput');
      Datapixx('RegWrRd');
      
    end %function
    
    function retval = get_position_on_screen(obj)
      [xScreenRight, yScreenRight, xScreenLeft, yScreenLeft] = Datapixx('GetEyePosition');
      retval = [];
      retval.right.x = xScreenRight;
      retval.right.y = yScreenRight;
      retval.left.x = xScreenLeft;
      retval.left.y = yScreenLeft;
    end %function
    
    function save_data(obj, f_name)
      if ~isempty(obj.data)
        data = obj.data;
        save(f_name, 'data');
      else
        error('No data acquired');
      end %if
    end %function
    
    function data = get_data(obj)
      Datapixx('RegWrRd');
      status = Datapixx('GetTPxStatus');
      to_read = status.newBufferFrames;
      
      data = Datapixx('ReadTPxData', to_read);
      if isempty(obj.data)
        obj.data = data;
      else
        obj.data = vertcat(obj.data, data);
      end %if
    end %function
    
    function reset(obj)
      if obj.is_running
        obj.stop();
        obj.data = [];
      end %if
    end %function
  end % public methods
end

