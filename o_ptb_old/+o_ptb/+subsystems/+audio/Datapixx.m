classdef Datapixx < o_ptb.subsystems.audio.Base
  % This is the Datapixx implementation of the audio subsystem.
  
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
    config;
    s_rate;
    buffer_address = 90e6;
    
    buffer;
  end
  
  properties (Access = protected, Dependent)
    lrmode;
  end %properties
  
  methods
    function obj = Datapixx(config)
      if ~isa(config, 'o_ptb.PTB_subconfigs.DatapixxAudio')
        error('Wrong configuration supplied to the constructor');
      end %if
      
      if ~config.is_valid
        error('Please supply a valid configuration');
      end %if
      
      obj.config = config;
    end %function
    
    function delete(obj)
      obj.reset();
    end %function
    
    
    function init(obj)
      PsychDataPixx('Open');
      Datapixx('InitAudio');
      
      Datapixx('StopAudioSchedule');
      Datapixx('SetAudioVolume', obj.config.volume);
      Datapixx('RegWrRd');
      
      obj.s_rate = obj.config.freq;
      
      obj.buffer = [];
      obj.reset();
    end %function
    
    
    function ready = is_ready(obj)
      try
        Datapixx('GetAudioStatus');
        ready = true;
      catch
        ready = false;
      end %try
    end %function
    
    
    function play(obj)
      Datapixx('RegWrRd');
    end %function
    
    
    function prepare(obj, stim, delay, mix)
      prepare@o_ptb.subsystems.audio.Base(obj, stim);
      
      if nargin < 3
        delay = 0;
      end %if
      
      sound_data = stim.get_sound_data(obj.s_rate, obj.n_channels)';
      
      onset_sample = round(delay*obj.s_rate + 1);
      offset_sample = round(onset_sample + size(sound_data, 2)-1);
      
      if mix
        obj.buffer(:, end+1:offset_sample) = zeros(2, offset_sample - size(obj.buffer, 2));
      else
        obj.buffer(:, onset_sample:offset_sample) = zeros(2, (offset_sample - onset_sample) + 1);
      end %if
      
      if obj.has_background_data
        background_data = obj.get_background_data();
        first_sample = size(obj.buffer, 2) + 1;
        last_sample = offset_sample - 1;
        
        obj.buffer(:, first_sample:last_sample) = obj.buffer(:, first_sample:last_sample) + background_data(:, first_sample:last_sample);
      end %if
      
      obj.buffer(:, onset_sample:offset_sample) = obj.buffer(:, onset_sample:offset_sample) + sound_data;
      
      
    end %function
    
    
    function schedule(obj)
      if obj.has_background_data
        background_data = obj.get_background_data();
        last_sample = size(background_data, 2);
      else
        last_sample = size(obj.buffer, 2);
      end %if
      
      Datapixx('WriteAudioBuffer', obj.buffer, obj.buffer_address);
      Datapixx('SetAudioSchedule', 0, obj.s_rate, last_sample, obj.lrmode, obj.buffer_address);
      Datapixx('StartAudioSchedule');
    end %function
    
    
    function reset(obj)
      if obj.has_background_data() & ~isempty(obj.buffer)
        background_data = obj.get_background_data();
        buffer_size = size(obj.buffer);
        obj.buffer = background_data(1:buffer_size(1), 1:buffer_size(2));
      else
        obj.buffer = zeros(size(obj.buffer));
      end %if
      if ~isempty(obj.buffer)
        Datapixx('WriteAudioBuffer', obj.buffer, obj.buffer_address);
      end %if
      
      obj.buffer = [];
    end %function
    
    function prune(obj, seconds)
      if size(obj.buffer, 2) > seconds*obj.s_rate
        obj.buffer(:, (seconds*obj.s_rate)+1:end) = [];
      end %if
    end %function
    
    
    function srate = get_sampling_rate(obj)
      srate = obj.s_rate;
    end %function
    
    function start_background(obj)
      background_data = obj.get_background_data();
      Datapixx('WriteAudioBuffer', background_data, obj.buffer_address);
      Datapixx('SetAudioSchedule', 0, obj.s_rate, size(background_data, 2), obj.lrmode, obj.buffer_address);
      Datapixx('StartAudioSchedule');
      Datapixx('RegWrRd');
    end %function
    
    function stop_audio_background(obj)
      stop_audio_background@o_ptb.subsystems.audio.Base(obj);
      Datapixx('StopAudioSchedule');
      Datapixx('RegWrRd');
    end %function
    
    function lr = get.lrmode(obj)
      lr = 3;
    end %function
  end %methods
  
  methods (Access = protected)
    function data = get_background_data(obj)
      data = get_background_data@o_ptb.subsystems.audio.Base(obj, obj.s_rate, obj.n_channels)';
    end %function
  end %methods
  
end

