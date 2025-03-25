classdef Wav < o_ptb.stimuli.auditory.Base
  % Audio Stimulus read from a wav file.
  %
  % This class provides all methods of :class:`+o_ptb.+stimuli.+auditory.Base`.
  %
  % Parameters
  % ----------
  %
  % filename : string
  %   The filename of the wav file to load.

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
    filename;
  end

  methods
    function obj = Wav(filename)
      obj@o_ptb.stimuli.auditory.Base();
      info = audioinfo(filename);
      obj.s_rate = info.SampleRate;

      obj.sound_data = audioread(filename);
      obj.filename = filename;

    end %function
  end

end
