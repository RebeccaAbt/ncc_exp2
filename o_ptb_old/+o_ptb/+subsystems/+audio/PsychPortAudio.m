classdef PsychPortAudio < o_ptb.subsystems.audio.Base
  % This is the PsychPortAudio implementation of the audio subsystem.
  
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
    pa_handle;
    s_rate;
    
    buffer;
  end
  
  properties (Access = protected)
    is_scheduled;
  end %properties
  
  methods
    function obj = PsychPortAudio(config)
      if ~isa(config, 'o_ptb.PTB_subconfigs.PsychPortAudio')
        error('Wrong configuration supplied to the constructor');
      end %if
      
      if ~config.is_valid
        error('Please supply a valid configuration');
      end %if
      
      obj.config = config;
      
      obj.is_scheduled = false;
    end %function
    
    
    function delete(obj)
      PsychPortAudio('Close');
    end %function
    
    
    function init(obj)
      device = obj.config.device;
      freq = obj.config.freq;
      
      if device == -1
        device = [];
      end %if
      
      if freq == -1
        freq = [];
      end %if
      
      obj.buffer = [];
      
      InitializePsychSound;
      obj.pa_handle = PsychPortAudio('Open', device, obj.config.mode, obj.config.reqlatencyclass,...
        freq, obj.n_channels);
      
      tmp = PsychPortAudio('GetStatus', obj.pa_handle);
      obj.s_rate = tmp.SampleRate;
    end %function
    
    
    function ready = is_ready(obj)
      try
        PsychPortAudio('GetStatus', obj.pa_handle);
        ready = true;
      catch
        ready = false;
      end %try
    end %function
    
    
    function on_play_on_flip(obj, screen_results)
      obj.play();
    end %function
    
    
    function play(obj)
      if obj.is_scheduled
        PsychPortAudio('Start', obj.pa_handle, [], [], 1);
        obj.is_scheduled = false;
      end %if
    end %function
    
    
    function prepare(obj, stim, delay, mix)
      prepare@o_ptb.subsystems.audio.Base(obj, stim);
      
      if nargin < 3
        delay = 0;
      end %if
      
      sound_data = stim.get_sound_data(obj.s_rate, obj.n_channels)';
      
      onset_sample = round(delay*obj.s_rate + 1);
      offset_sample = onset_sample + size(sound_data, 2)-1;
      
      if mix
        obj.buffer(:, end+1:offset_sample) = zeros(2, offset_sample - size(obj.buffer, 2));
      else
        obj.buffer(:, onset_sample:offset_sample) = zeros(2, (offset_sample - onset_sample) + 1); 
      end %if
      
      obj.buffer(:, onset_sample:offset_sample) = obj.buffer(:, onset_sample:offset_sample) + sound_data;
    end %function
    
        
    function schedule(obj)
      if isempty(obj.background_object)
        PsychPortAudio('FillBuffer', obj.pa_handle, obj.buffer, 0, 0);
      else
        PsychPortAudio('RefillBuffer', obj.pa_handle, 0, obj.buffer, 0);
      end %if
      obj.is_scheduled = true;
    end %function
    
    
    function start_background(obj)
      PsychPortAudio('FillBuffer', obj.pa_handle, obj.get_background_data(obj.s_rate, obj.n_channels)');
      PsychPortAudio('Start', obj.pa_handle, [], [], 1);
    end %function
    
    function stop_audio_background(obj)
      stop_audio_background@o_ptb.subsystems.audio.Base(obj);
      PsychPortAudio('Stop', obj.pa_handle, [], [], 1);
    end %function
    
    function prune(obj, seconds)
      if size(obj.buffer, 2) > seconds*obj.s_rate
        obj.buffer(:, (seconds*obj.s_rate)+1:end) = [];
      end %if
    end %function
       
    
    function reset(obj)
      obj.buffer = [];
    end %function
    
    
    function srate = get_sampling_rate(obj)
      srate = obj.s_rate;
    end %function
    
  end %methods
  
end

