classdef Dummy < o_ptb.subsystems.eyetracker.Base
  % Dummy subsystem for eyetrackers
  
  properties (GetAccess = public, SetAccess = protected)
    is_running;
  end %properties
  
  methods (Access = public)
    function obj = Dummy()
      obj.is_running = false;
    end %function
    
    
    function verify_eye_positions(obj)
      ptb = o_ptb.PTB.get_instance();
      
      eyes = o_ptb.stimuli.visual.Image(fullfile(ptb.assets_path, 'images', 'eyes.png'));
      eyes.move(0, -200);
      ptb.draw(eyes);
      
      text = o_ptb.stimuli.visual.Text('Press any button to exit');
      text.move(0, 200);
      
      ptb.draw(text);
      
      ptb.flip();
      
      KbWait;
      
      ptb.flip();
    end %function
    
    
    function calibrate(obj, out_folder)
      ptb = o_ptb.PTB.get_instance();
      
      o_ptb.subsystems.eyetracker.support.do_my_calibration(ptb.win_handle, out_folder, true);
      
    end %function
    
    
    
    function start(obj)
      if obj.is_running
        error('Eyetracker is already running');
      end %if
      
      fprintf('Starting eye tracker...\n');      
      obj.is_running = true;
    end %function
    
    
    
    function stop(obj)
      if ~obj.is_running
        error('Eyetracker is already stopped');
      end %if
      
      fprintf('Stopping eye tracker...\n');
      obj.is_running = false;
    end %function
    
    function data = get_data(obj)
      data = rand(10, 2);
    end %function
    
    function save_data(obj, f_name)
      fprintf('Not saving data because eyetracker in dummy mode.\n');
    end %function
    
    function retval = get_position_on_screen(obj)
      retval = [];
      retval.right.x =0;
      retval.right.y =0;
      retval.left.x =0;
      retval.left.y =0;
    end %function
    
    function reset(obj)
      if obj.is_running
        obj.stop();
      end %if
    end %function
  end % public methods
end

