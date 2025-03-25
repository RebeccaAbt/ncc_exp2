classdef (Abstract) Base < handle
  % This is the base class for audio subsystems. In order to develop a new
  % subsystem, create a class that inherits from this one and override its
  % methods:
  %
  % Base methods:
  %   init(obj)                        - Initialize the audio subsystem
  %                                      here.
  %   ready = is_ready(obj)            - Returns true if the audio
  %                                      subsystem is properly set up and
  %                                      ready.
  %   prepare(obj, stim, delay)        - This method should retrieve the
  %                                      sound data by calling the
  %                                      get_sound_data function of stim.
  %                                      It is then supposed to upload the
  %                                      sound data to the underlying audio
  %                                      subsystem and make sure that the delay is observed.
  %                                      This method is supposed to do the time consuming work.
  %   schedule(obj)                    - Schedules the previously prepared
  %                                      stimulus. This step might not be
  %                                      necessary for all audio
  %                                      subsystems, but some (like the
  %                                      Datapixx) need it.
  %   reset(obj)                       - Resets the audio schedule.
  %   play(obj)                        - Plays the previously prepared and
  %                                      scheduled stimulus.
  %   n_channels = get_n_channels(obj) - Returns the number of channels of
  %                                      the audio subsystem.
  %   srate = get_sampling_rate(obj)   - Returns the current sampling rate
  %                                      of the audio subsystem.
  %   on_play_on_flip(obj, screen_results) - This method gets called
  %                                          automatically after a flip has
  %                                          been executed. If, like for the
  %                                          Datapixx system, audio stimuli get
  %                                          played automatically in that case,
  %                                          you do not need to override this
  %                                          method. If a command needs to be
  %                                          called to then play the stimulus,
  %                                          do it here.
  
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
    background_object =  [];
  end %properties
  
  properties (GetAccess = public, SetAccess = protected)
    n_channels = 2;
  end %properties
  
  methods (Abstract, Access = public)
    init(obj);
    ready = is_ready(obj);
    schedule(obj);
    play(obj);
    reset(obj);
    start_background(obj);
    prune(obj, seconds);
    
    srate = get_sampling_rate(obj);
  end %methods
  
  methods (Access = public)
    function prepare(obj, stim, delay, mix)
      if ~isa(stim, 'o_ptb.stimuli.auditory.Base')
        error('Only Auditory Stimuli can be scheduled');
      end %if
      
    end %function
    
    function set_audio_background(obj, background_object)
      obj.background_object = background_object;
    end %function
    
    function stop_audio_background(obj)
      obj.background_object = [];
    end %function
    
    function on_play_on_flip(obj, screen_results)
    end %function
    
  end %methods
  
  methods (Access = protected)
    function data = get_background_data(obj, s_rate, n_channels)
      ptb = o_ptb.PTB.get_instance();
      ptb_cfg = ptb.get_config();
      
      data = obj.background_object.get_sound_data(s_rate, n_channels, ptb_cfg.internal_config.background_audio_duration);
    end %function
    
    function rval = has_background_data(obj)
      rval = ~isempty(obj.background_object);
    end %function
  end %methods
  
end

