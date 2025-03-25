classdef Sine < o_ptb.stimuli.auditory.Base
  % Sine wave audio stimulus.
  %
  % This class provides all methods of :class:`+o_ptb.+stimuli.+auditory.Base`.
  %
  % Parameters
  % ----------
  %
  % freq : float
  %   Frequency of the sine wave
  %
  % duration : float
  %   Duration in seconds.

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
    function obj = Sine(freq, duration)
      obj.s_rate = 96000;
      n_samples = duration * obj.s_rate;

      tmp_s_idx = (1:round(n_samples));
      obj.sound_data = sin(2*pi*tmp_s_idx*(freq/obj.s_rate))';
    end %function
  end

end
