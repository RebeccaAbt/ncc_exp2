classdef (Abstract) Base < handle
  % This is the base class for trigger subsystems. In order to develop a new
  % subsystem, create a class that inherits from this one and override its
  % methods. All initialization is supposed to take place in the
  % constructor.
  %
  % Base methods:
  %   prepare(obj, trigger_value, delay) - This method should do all
  %                                        necessary preparations for
  %                                        subsequent triggering. It should
  %                                        upload the trigger value to the
  %                                        underlying hardware and make
  %                                        sure the delay is observed. This
  %                                        method is supposed to do the time
  %                                        consuming work.
  %   schedule(obj)                      - Schedules the previously prepared
  %                                        trigger. This step might not be
  %                                        necessary for all trigger
  %                                        subsystems, but some (like the
  %                                        Datapixx) need it.
  %   fire(obj)                          - Fires the previously prepared and
  %                                        scheduled trigger.
  %   reset(obj)                         - Resets the trigger schedule.
  %   on_fire_on_flip(obj, screen_results) - This method gets called
  %                                        automatically after a flip has
  %                                        been executed. If, like for the
  %                                        Datapixx system, triggers get
  %                                        played automatically in that case,
  %                                        you do not need to override this
  %                                        method. If a command needs to be
  %                                        called to then fire the trigger,
  %                                        do it here.
  
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
  
  properties (Access = protected)
    trigger_length;
  end %properties
  
  methods
    function obj = Base(ptb_config)
      if ~isa(ptb_config, 'o_ptb.PTB_Config')
        error('Please supply a PTB_Config instance');
      end %if
      
      obj.trigger_length = ptb_config.internal_config.trigger_length;
    end %function
  end %methods
  
  methods (Abstract, Access = public)
    prepare(obj, trigger_value, delay);
    schedule(obj);
    reset(obj);
    
    fire(obj);
  end %methods
  
  methods (Access = public)
    function on_fire_on_flip(obj, screen_results)
    end %function
  end %methods
  
end

