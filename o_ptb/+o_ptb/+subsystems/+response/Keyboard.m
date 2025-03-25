classdef Keyboard < o_ptb.subsystems.response.Base
  % This is the Keyboard implementation of the response subsystem.
  
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
  
  properties (GetAccess = public, SetAccess = protected);
    config;
    key_recording_running;
  end
  
  methods (Access = public)
    function obj = Keyboard(ptb_config)
      obj@o_ptb.subsystems.response.Base(ptb_config);
      
      if ~isa(ptb_config.keyboardresponse_config, 'o_ptb.PTB_subconfigs.KeyboardResponse')
        error('No valid configuration found');
      end %if
      
      KbName('UnifyKeyNames');
      KbQueueCreate;
      
      obj.config = ptb_config.keyboardresponse_config;
      key_recording_running = false;
    end %function
    
    
    function [keys_pressed, timestamp] = wait_for_keys(obj, keys, until)
      timestamp = [];
      keys_pressed = {};
      if isempty(until)
        until = Inf;
      end %if
      
      if ~iscell(keys)
        keys = {keys};
      end %if
      
      % first check if the buttons might already be pressed...
      [~, ~, button_states] = KbCheck(obj.config.device_number);
      keys_pressed = obj.check_keys_pressed(keys, button_states);
      
      if ~isempty(keys_pressed)
        return;
      end %if
      
      while isempty(keys_pressed)
        [ts, button_states] = KbWait(obj.config.device_number, 0, until);
        if sum(button_states) == 0
          return;
        end %if
        
        keys_pressed = obj.check_keys_pressed(keys, button_states);
      end %while
      
      if ~isempty(keys_pressed)
        timestamp = ts;
      end %if
    end %function
    
    function start_record_keys(obj)
      if obj.key_recording_running
        error('Key Recording is already running');
      end %if
      KbQueueFlush();
      KbEventFlush();
      KbQueueStart();
      obj.key_recording_running = true;
    end %function
    
    function stop_record_keys(obj)
      if ~obj.key_recording_running
        error('Key Recording not running');
      end %if
      KbQueueStop();
      obj.key_recording_running = false;
    end %function
    
    function [keys_pressed, timestamp] = get_recorded_keys(obj, keys)
      timestamp = [];
      keys_pressed = {};
      
      if ~iscell(keys)
        keys = {keys};
      end %if
      
      while KbEventAvail() > 0
        evt = KbEventGet();
        if evt.Pressed
          button_states = false(1, 255);
          button_states(evt.Keycode) = true;
          tmp_keypressed = obj.check_keys_pressed(keys, button_states);
          if ~isempty(tmp_keypressed)
            timestamp(end+1) = evt.Time;
            keys_pressed{end+1} = tmp_keypressed{1};
          end %if
        end %if        
      end %while
    end %function
  end %methods
  
  methods (Access = protected)
    function keys_pressed = check_keys_pressed(obj, keys, button_states)
      keys_pressed = {};
      
      for i = 1:length(keys)
        if button_states(obj.config.button_mapping(keys{i}))
          keys_pressed{end+1} = keys{i};
        end %if
      end %for
    end %function
  end %methods
  
  methods
    function delete(obj)
      KbQueueRelease;
    end %function
  end %methods
  
end

