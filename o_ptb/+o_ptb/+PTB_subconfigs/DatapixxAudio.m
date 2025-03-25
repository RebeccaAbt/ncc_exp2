classdef DatapixxAudio < o_ptb.base.Config
  % Configuration for the Datapixx audio subsystem.
  %
  % The values all have sensible defaults. Normally, you do not need to
  % change something here.
  %
  % Attributes
  % ----------
  %
  % freq : float
  %   The sampling frequency. Default: ``96000``.
  %
  % volume : float or array of floats
  %   The volume of the sounds. If it is only one number, the
  %   volume is set for both the participant's headphones and
  %   the outside loudspeakers. If it is a vector with two
  %   elements, the first indicates the volume at the
  %   participants while the second indicates the volume at the
  %   loudspeakers at the stimulation computer. Default: ``0.5``.
  %
  % buffer_address : int
  %   The memory address of the audio buffer within the Datapixx.
  %   If you do not know, what this means, do not touch it!
  %   Default: 90e6

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

  properties (Access = public, SetObservable = true)
    freq = 96000;
    volume = 0.5;
    buffer_address = 230400000;
  end

end
