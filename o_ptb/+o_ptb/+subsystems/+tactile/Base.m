classdef (Abstract) Base < handle
  %BASE Summary of this class goes here
  %   Detailed explanation goes here
  
  methods (Abstract, Access = public)
    init(obj);
    ready = is_ready(obj);
    schedule(obj);
    play(obj);
    reset(obj);
    
    n_fingers = get_n_fingers(obj);
  end %methods
  
  methods (Access = public)
    function obj = Base(ptb_config)
      if ~isa(ptb_config, 'o_ptb.PTB_Config')
        error('Please supply a PTB_Config instance');
      end %if
    end %function
      
    function prepare(obj, stim, delay)
      if ~isa(stim, 'o_ptb.stimuli.tactile.Base')
        error('Only Tactile Stimuli can be scheduled');
      end %if
    end %function
    
    function on_play_on_flip(obj, screen_results)
    end %function
    
    function wait_for_stimulators(obj)
    end %function
  end %methods
  
  methods (Access = public, Static)
    function rval = is_present()
      rval = true;
    end %function
  end %methods
  
end

