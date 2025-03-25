classdef Datapixx < o_ptb.subsystems.trigger.Base
  % This is the Datapixx implementation of the trigger subsystem.
  
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
    buffer_address = 0;
    cur_srate = 0;
    
    buffer;
  end
  
  properties (Access = protected, Constant)
    bytes_per_sample = 2;
  end %properties
  
  properties (Access = protected, Dependent)
    is_running
  end %properties
  
  methods (Access = public)
    function obj = Datapixx(ptb_config)
      obj@o_ptb.subsystems.trigger.Base(ptb_config);
      
      obj.cur_srate = ptb_config.datapixxaudio_config.freq;
      
      obj.buffer = [];
      Datapixx('StopDoutSchedule');
      Datapixx('RegWrRd');
      
    end %function
    
    function delete(obj)
      obj.reset();
    end %function
    
    
    function fire(obj)
      Datapixx('RegWrRd');
    end %function
    
    
    function reset(obj)      
      obj.buffer = zeros(size(obj.buffer));
       %if ~isempty(obj.buffer)
         %Datapixx('WriteDoutBuffer', obj.buffer, obj.buffer_address);
         %Datapixx('StopDoutSchedule');
         %Datapixx('RegWr');
       %end %if
      obj.buffer = [];
    end %function
    
    
    function prepare(obj, trigger_value, delay)
      if nargin < 3
        delay = 0;
      end %if
      
%       if obj.is_running
%         error('Cannot prepare trigger while doing output!');
%       end %if
      
      trigger_sequence = [ones(1, floor(obj.trigger_length * obj.cur_srate)) * trigger_value zeros(1, floor(obj.trigger_length * obj.cur_srate))];
      
      onset_sample = round(delay*obj.cur_srate)+1;
      offset_sample = onset_sample + size(trigger_sequence, 2)-1;
      
      if length(obj.buffer) < offset_sample
        obj.buffer(end+1:offset_sample) = zeros(1, offset_sample - length(obj.buffer));
      end %if
      
      obj.buffer(onset_sample:offset_sample) = obj.buffer(onset_sample:offset_sample) + trigger_sequence;
    end %function
    
    
    function schedule(obj)
      Datapixx('WriteDoutBuffer', obj.buffer, obj.buffer_address);
      Datapixx('SetDoutSchedule', 0, obj.cur_srate, length(obj.buffer), obj.buffer_address);
      Datapixx('StartDoutSchedule');
    end %function
  end %methods
  
  methods
    function val = get.is_running(obj)
      status = Datapixx('GetDoutStatus');
      
      val =  status.scheduleRunning;
    end %function
  end %protected methods
end

