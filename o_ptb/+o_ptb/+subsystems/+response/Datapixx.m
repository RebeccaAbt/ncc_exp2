classdef Datapixx < o_ptb.subsystems.response.Base
  % This is the Datapixx implementation of the response subsystem.
  
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
    logged_responses;
  end
  
  methods (Access = public)
    function obj = Datapixx(ptb_config)
      obj@o_ptb.subsystems.response.Base(ptb_config);
      
      if ~isa(ptb_config.datapixxresponse_config, 'o_ptb.PTB_subconfigs.DatapixxResponse')
        error('No valid configuration found');
      end %if
      
      Datapixx('Open');
      ResponsePixx('Close');
      ResponsePixx('Open');
      PsychDataPixx('Open');
      
      obj.config = ptb_config.datapixxresponse_config;
      obj.key_recording_running = false;
      obj.logged_responses = [];
    end %function
    
    
    function [keys_pressed, timestamp] = wait_for_keys(obj, keys, until)
      keys_pressed = {};
      timestamp = [];
      
      if ~iscell(keys)
        keys = {keys};
      end %if
      
      % first check if the buttons might already be pressed...
      button_states = ResponsePixx('GetButtons');
      keys_pressed = obj.check_keys_pressed(keys, button_states);
      
      if ~isempty(keys_pressed)
        ResponsePixx('StopNow');
        return;
      end %if
      
      while isempty(keys_pressed)
        ResponsePixx('StartNow', true);
        if isempty(until)
          time_to_go = Inf;
        else
          time_to_go = until - GetSecs();
        end %if
        
        if time_to_go <= 0
          time_to_go = 0.001;
        end %if
        
        [button_states, transition_time] = ResponsePixx('GetLoggedResponses', 1, true, time_to_go);
        if isempty(button_states)
          ResponsePixx('StopNow');
          return;
        end %if
        
        keys_pressed = obj.check_keys_pressed(keys, button_states);
        ResponsePixx('StopNow');
      end %while
      
      if ~isempty(keys_pressed)
        timestamp = PsychDataPixx('FastBoxsecsToGetsecs', transition_time);
      end %if
      
    end %function
    
    function recalibrate_timing(obj)
      PsychDataPixx('GetPreciseTime');
    end %function
    
    function start_record_keys(obj)
      if obj.key_recording_running
        error('Key Recording is already running');
      end %if
      obj.logged_responses = [];
      ResponsePixx('StartNow', true);
      
      obj.key_recording_running = true;
    end %function
    
    function stop_record_keys(obj)
      if ~obj.key_recording_running
        error('Key Recording not running');
      end %if
      [obj.logged_responses.states, obj.logged_responses.ts] = ResponsePixx('GetLoggedResponses');
      ResponsePixx('StopNow');
      obj.key_recording_running = false;
    end %function
    
    function [keys_pressed, timestamp] = get_recorded_keys(obj, keys)
      keys_pressed = {};
      timestamp = [];
      
      if ~iscell(keys)
        keys = {keys};
      end %if
      
      if isempty(obj.logged_responses.ts)
        return;
      end %if
      
      ptb_timestamps = PsychDataPixx('FastBoxsecsToGetsecs', obj.logged_responses.ts);
      tmp_states = [ones(1, 5); obj.logged_responses.states];
      onsets = diff(tmp_states);
      
      for idx_key_event = 1:size(obj.logged_responses.states, 1)
        cur_event = onsets(idx_key_event, :);
        cur_keys = find(cur_event == -1);
        
        for i = 1:length(keys)
          if any(cur_keys == obj.config.button_mapping(keys{i}))
            keys_pressed{end+1} = keys{i};
            timestamp(end+1) = ptb_timestamps(idx_key_event);
          end %if
        end %for
        
      end %for
    end %function
  end %methods
  
  methods (Access = protected)
    function keys_pressed = check_keys_pressed(obj, keys, button_states)
      keys_pressed = {};
      
      for i = 1:length(keys)
        if button_states(obj.config.button_mapping(keys{i})) == 0
          keys_pressed{end+1} = keys{i};
        end %if
      end %for
    end %function
  end %methods
  
end

