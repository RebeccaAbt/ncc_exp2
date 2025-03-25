classdef PsychPortAudio < o_ptb.base.Config
  % Configuration of the PsychportAudio audio subsystem.
  %
  % The values all have sensible defaults. Normally, you do not need to
  % change something here.
  %
  % Attributes
  % ----------
  %
  % freq : int
  %   The sampling frequency. Default: The highest possible or the value of :envvar:`O_PTB_PSYCHPORTAUDIO_SFREQ`.
  %
  % mode : int
  %   The mode of operations. 1 means only ouput. Default: ``1``.
  %
  % reqlatencyclass : int
  %   How much the system tries to give you low latencies. Just use the default. (``4``).
  %
  % device : int
  %   The device to use. Defaults to the first available one or the value of :envvar:`O_PTB_PSYCHPORTAUDIO_DEVICE`.

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
    device = o_ptb.internal.EnvVarConfig(-1, 'O_PTB_PSYCHPORTAUDIO_DEVICE');
    mode = 1;
    reqlatencyclass = 4;
    freq = o_ptb.internal.EnvVarConfig(-1, 'O_PTB_PSYCHPORTAUDIO_SFREQ');
  end

end
