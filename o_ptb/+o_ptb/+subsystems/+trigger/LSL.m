classdef LSL < o_ptb.subsystems.trigger.Base
  % This is the Labjack implementation of the trigger subsystem.
  
  %Copyright (c) 2016-2020, Thomas Hartmann
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
    lib;
    trigger_list = {};
    lsl_stream_info;
    lsl_outlet;
    lsl_stream_type;
    ptb_lsl_time_offset;
  end %private properties
  
  methods (Access = public)
    function obj = LSL(ptb_config)
      obj@o_ptb.subsystems.trigger.Base(ptb_config);
      
      lsl_cfg = ptb_config.lsltrigger_config;
      addpath(lsl_cfg.liblsl_matlab_path);
      addpath(fullfile(lsl_cfg.liblsl_matlab_path, 'bin'));
      
      obj.lib = lsl_loadlib();
      
      if strcmp(lsl_cfg.trigger_type, 'string')
        obj.lsl_stream_type = 'cf_string';
      elseif strcmp(lsl_cfg.trigger_type, 'int')
        obj.lsl_stream_type = 'cf_int32';
      else
        error('trigger type must be either "string" or "int"')
      end %if
      
      
      obj.lsl_stream_info = lsl_streaminfo(obj.lib, 'o_ptb_marker_stream', 'Markers', 1, 0, obj.lsl_stream_type, lsl_cfg.stream_id);
      obj.lsl_outlet = lsl_outlet(obj.lsl_stream_info);
      
      offsets = [];
      n_samples = 100;
      w_div = 100;
      
      for s = 1:n_samples
        offsets(end+1) = GetSecs() - lsl_local_clock(obj.lib);
        WaitSecs(rand() / w_div);
      end %for
      
      obj.ptb_lsl_time_offset = mean(offsets);   
      
    end %function
    
    function delete(obj)
      obj.lsl_outlet.delete();
      obj.lsl_stream_info.delete();
    end %
    
    function prepare(obj, trigger_value, delay)
      if nargin < 3
        delay = 0;
      end %if
      
      trigger = {};
      trigger.value = trigger_value;
      trigger.delay = delay;
      
      obj.trigger_list{end+1} = trigger;
    end %function
    
    function schedule(obj)
    end %function
    
    function reset(obj)
      obj.trigger_list = {};
    end %function
    
    function fire(obj)
      obj.do_fire(GetSecs());
    end %function
    
    function on_fire_on_flip(obj, screen_results)
      obj.do_fire(screen_results{1});
    end %function
    
  end
  
  methods (Access = protected)
    function do_fire(obj, now)
      for idx_trigger = 1:length(obj.trigger_list)
        cur_trigger = obj.trigger_list{idx_trigger};
        if strcmp(obj.lsl_stream_type, 'cf_string')
          t_value = {sprintf('<MARKER>%d</MARKER>', cur_trigger.value)};
        else
          t_value = cur_trigger.value;
        end %if
        
        obj.lsl_outlet.push_sample(t_value, obj.ptb_time_to_lsl_time(now + cur_trigger.delay));
        
      end %for
    end %function
    
    
    function lsl_time = ptb_time_to_lsl_time(obj, time)
      lsl_time = time - obj.ptb_lsl_time_offset;
    end %function
  end %protected methods
  
end

