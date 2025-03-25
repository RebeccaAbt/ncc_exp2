classdef Labjack < o_ptb.subsystems.trigger.Base
  % This is the Labjack implementation of the trigger subsystem.
  
  %Copyright (c) 2016-2017, Thomas Hartmann
  %
  % This file is part of the o_ptb class library, see: https://gitlab.com/thht/o_ptb
  %
  %    o_ptb is free software: you can redistribute it and/or modify
  %    it under the terms of the GNU General Public License as published by
  %    the Free Software Foundation, either version 3 of the License, or
  %    (at your option) any later version.
  %
  %    o_ptb is distributed in the hope that it will be useful,
  %    but WITHOUT ANY WARRANTY; without even the implied warranty of
  %    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  %    GNU General Public License for more details.
  %
  %    You should have received a copy of the GNU General Public License
  %    along with obob_ownft. If not, see <http://www.gnu.org/licenses/>.
  %
  %    Please be aware that we can only offer support to people inside the
  %    department of psychophysiology of the university of Salzburg and
  %    associates.
  
  properties (Access = private)
    lj;
  end %private properties
  
  methods (Access = public)
    function obj = Labjack(ptb_config)
      obj@o_ptb.subsystems.trigger.Base(ptb_config);
      
      lj_cfg = ptb_config.labjacktrigger_config;
      
      obj.lj = labjack.Labjack(lj_cfg.channel_group, lj_cfg.method, lj_cfg.single_channel, lj_cfg.num_bits);
    end %function
    
    function delete(obj)
      delete(obj.lj);
    end %function
    
%--------------------------------------------------------------------------
function triggered = wait_for_intrigger(obj, base_level, n_trigger, chan_nr, chan_type)
        if nargin < 2
            base_level = 0;
        end
    
        if nargin < 3
            n_trigger = 1;
        end

        if nargin < 4
            chan_nr = 5;
        end

        if nargin < 5
            chan_type = 'FIO';
        end
       
        triggered = obj.lj.wait_for_intrigger(n_trigger, base_level, chan_nr, chan_type);   
    end %function
%-------------------------------------------------------------------------- 

%--------------------------------------------------------------------------
    function triggered = intrigger_status(obj, chan_nr, chan_type)
        if nargin < 2
            chan_nr = 5;
        end
        
        if nargin < 3
            chan_type = 'FIO';
        end
     
        triggered = obj.lj.intrigger_status(chan_nr, chan_type);   
    end %function
%-------------------------------------------------------------------------- 
   
    function prepare(obj, trigger_value, delay)
      if nargin < 3
        delay = 0;
      end %if
      
      obj.lj.prepare_trigger(int32(trigger_value), delay);
    end %function
    
    function schedule(obj)
    end %function
    
    function reset(obj)
      obj.lj.reset();
    end %function
    
    function fire(obj)
      obj.lj.fire_trigger();
    end %function
    
    function on_fire_on_flip(obj, screen_results)
      obj.fire();
    end %function
    
  end
  
end

