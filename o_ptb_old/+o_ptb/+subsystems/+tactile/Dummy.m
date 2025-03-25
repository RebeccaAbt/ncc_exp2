classdef Dummy < o_ptb.subsystems.tactile.Base
  %DUMMY Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Access=protected)
    init_done = false;
  end %properties
  
  properties (GetAccess = public, SetAccess = protected)
    timers;
  end
  
  properties (Access = protected)
    is_scheduled;
  end %properties
  
  methods (Access = public)
    function obj = Dummy(ptb_config)
      obj@o_ptb.subsystems.tactile.Base(ptb_config);
      obj.timers = {};
    end %function
    
    function init(obj)
      fprintf('Dummy Tactile System Initialized');
      obj.init_done = true;
    end %function
    
    function schedule(obj)
      obj.is_scheduled = true;
    end %function
    
    function prepare(obj, stim, delay)
      if nargin < 3
        delay = 0;
      end %if
      
      timer_str = sprintf('Stimulating %s finger %d at amp %d with freq: %d and phase %d for %fs\n', stim.stimulator, stim.finger, stim.amplitude, stim.frequency, stim.phase, stim.duration);
      obj.timers{end+1} = timer('TimerFcn', @(~, ~) fprintf(timer_str), 'StartDelay', delay);
    end %function
    
    function reset(obj)
      obj.timers = {};
      obj.is_scheduled = false;
    end %function
    
    function ready = is_ready(obj)
      ready = obj.init_done;
    end %function
    
    function play(obj)
      if obj.is_scheduled
        for i = 1:length(obj.timers)
          start(obj.timers{i});
        end %for
        
        obj.is_scheduled = false;
      end %if
    end %function
    
    function on_play_on_flip(obj, screen_results)
      obj.play();  
    end %function
    
    function n_fingers = get_n_fingers(obj)
      n_fingers = 4;
    end %function
  end
  
end

