classdef Movie < o_ptb.stimuli.visual.TextureBase & o_ptb.internal.ChecksPropertiesSet & o_ptb.stimuli.visual.PostFlipCallback
  % Read a movie file and provide the frames.
  %
  % Please refer to the :doc:`tutorial </tutorial/o_ptb/movies>` for detailed
  % instructions.
  %
  % This class provides all methods of :class:`+o_ptb.+stimuli.+visual.TextureBase`
  % and :class:`+o_ptb.+stimuli.+visual.Base`.
  %
  % Parameters
  % ----------
  %
  % f_name : string
  %   The filename of the movie to load.
  %
  % Attributes
  % ----------
  %
  % duration : float
  %   Duration of the movie in seconds.
  %
  % fps : float
  %   Framrate of the movie.
  %
  % next_flip_time : float
  %   Timestamp of the flip for the currently loaded frame.

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

  properties (SetAccess = protected, GetAccess = public)
    movie_ptr;
    next_frame_time;
  end %protected properties

  properties (SetAccess = protected, GetAccess = public)
    duration;
    fps;
    movie_f_name;
    movie_start_time;
    n_frames;
  end %read only properties

  properties (Dependent)
    next_flip_time;
  end % dependent properties

  properties (Access = protected)
    special_flags = 2 + 16;

    old_texture_id;
  end %properties

  methods
    function obj = Movie(f_name)
      obj@o_ptb.stimuli.visual.TextureBase()
      ptb = o_ptb.PTB.get_instance();

      [obj.movie_ptr, obj.duration, obj.fps, width, height obj.n_frames] = ptb.screen('OpenMovie', f_name, 4, [], obj.special_flags);

      obj.movie_f_name = f_name;

      obj.destination_rect = SetRect(0, 0, width, height);
      obj.center_on_screen();
    end %function


    function start(obj)
      % Start movie playback.

      Screen('PlayMovie', obj.movie_ptr, 1);
      obj.movie_start_time = [];
    end %function


    function stop(obj)
      % Stop movie playback.

      Screen('PlayMovie', obj.movie_ptr, 0, 0, 0);
      Screen('SetMovieTimeIndex', obj.movie_ptr, 0);
    end %function


    function resync(obj)
      % Skip frames of the movie to catch up with current time.

      if ~isempty(obj.movie_start_time)
        Screen('SetMovieTimeIndex', obj.movie_ptr, GetSecs() - obj.movie_start_time);
      end %if
    end %function


    function has_frame = fetch_frame(obj)
      % Fetch the next frame of the movie.
      %
      % Returns
      % -------
      %
      % bool
      %   ``true`` if another frame was available.
      
      ptb = o_ptb.PTB.get_instance();
      old_frame_time = obj.next_frame_time;

      obj.texture_id = [];
      obj.next_frame_time = [];

      [local_texture_id, local_next_frame_time] = ptb.screen('GetMovieImage', obj.movie_ptr);

      if local_texture_id == 0
        error('Could not get a valid movie frame.');
      end %if

      if old_frame_time == local_next_frame_time
        error('Something is wrong with the timecode of the movie. Probably the file is corrupted!');
      end %if

      if local_texture_id > 0
        obj.texture_id = local_texture_id;
        obj.next_frame_time = local_next_frame_time;

        has_frame = true;
      else
        has_frame = false;
      end %if
    end %function


    function after_flip(obj, flip_info)
      if isempty(obj.movie_start_time)
        timestamp = flip_info.VBLTimestamp;
        if timestamp == 0
          timestamp = flip_info.FlipTimestamp;
        end %if

        obj.movie_start_time = timestamp - obj.next_frame_time;
      end %if
    end %function


    function flip_time = get.next_flip_time(obj)
      flip_time = obj.movie_start_time + obj.next_frame_time;
      if isempty(flip_time)
        flip_time = GetSecs();
      end %if
    end %function
  end

  methods (Access = protected)
    function draw_texture(obj, ptb)
      if isempty(obj.texture_id) || obj.texture_id < 1
        error('No valid movie frame fetched. Call fetch_frame first');
      end %if
      %ptb.screen('DrawTexture', obj.texture_id, [], obj.destination_rect);

      draw_texture@o_ptb.stimuli.visual.TextureBase(obj, ptb);

      if ~isempty(obj.old_texture_id)
        Screen('Close', obj.old_texture_id);
      end %if

      obj.old_texture_id = obj.texture_id;
    end %function
  end %methods

end
