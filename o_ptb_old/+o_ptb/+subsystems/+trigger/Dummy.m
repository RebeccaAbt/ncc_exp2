classdef Dummy < o_ptb.subsystems.trigger.Base
  % This is the dummy (i.e. text output) implementation of the trigger subsystem.
  
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
  
  properties (GetAccess = public, SetAccess = protected)
    timers;
  end
  
  properties (Access = protected)
    is_scheduled;
  end %properties
  
  methods (Access = public)
    function obj = Dummy(ptb_config)
      obj@o_ptb.subsystems.trigger.Base(ptb_config);
      obj.timers = {};
    end %function
    
    function delete(obj)
      delete([obj.timers{:}]);
    end %function
    
    
    function schedule(obj)
      obj.is_scheduled = true;
    end %function
    
    
    function fire(obj)
      if obj.is_scheduled
        for i = 1:length(obj.timers)
          start(obj.timers{i});
        end %for
        
        obj.is_scheduled = false;
      end %if
    end %function
    
    
    function on_fire_on_flip(obj, screen_results)
      obj.fire();  
    end %function
    
    
    function prepare(obj, trigger_value, delay)
      if nargin < 3
        delay = 0;
      end %if
      
      timer_str = sprintf('Firing trigger %d\n', trigger_value);
      obj.timers{end+1} = timer('TimerFcn', @(~, ~) fprintf(timer_str), 'StartDelay', delay);
    end %function
    
    
    function reset(obj)
      obj.timers = {};
      obj.is_scheduled = false;
    end %function
  end %methods
  
end

