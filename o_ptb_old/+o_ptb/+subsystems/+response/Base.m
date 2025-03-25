classdef (Abstract) Base < handle
  % This is the base class of the reponse subsystem. In order to create a
  % new subsystem, create a class that inherits from this one and override its
  % methods. All initialization is supposed to take place in the
  % constructor.
  %
  % Base methods:
  %   keys_pressed = wait_for_keys(obj, keys, until) - Waits until PTB time
  %                                                    until whether one of
  %                                                    the keys was
  %                                                    pressed.
  
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
  
  methods
    function obj = Base(ptb_config)
      if ~isa(ptb_config, 'o_ptb.PTB_Config')
        error('Please supply a PTB_Config instance');
      end %if
    end %function
  end %methods
  
  methods (Abstract, Access = public)
    [keys_pressed, timestamp] = wait_for_keys(obj, keys, until);
    start_record_keys(obj);
    stop_record_keys(obj);
    
    [keys_pressed, timestamp] = get_recorded_keys(obj, keys);
  end %methods
  
  methods (Access = public)
    recalibrate_timing(obj);
  end %methods
  
end

