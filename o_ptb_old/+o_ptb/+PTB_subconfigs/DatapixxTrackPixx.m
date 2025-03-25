classdef DatapixxTrackPixx < o_ptb.base.Config
  % Configuration for the Datapixx Eyetracker System
  %
  % The values all have sensible defaults. Normally, you do not need to
  % change something here.
  %
  % Attributes
  % ----------
  %
  % lens : int
  %   The lens type. Default: ``1``. Possible values are:
  %
  %   - 0: 25mm
  %   - 1: 50mm
  %   - 2: 75mm
  %   
  % distance : int
  %   Distance between the eye and the eyetrackerin cm. Default: ``82``
  %
  % analogue_eye : int
  %   Which eye to use for analogue output. Default: ``0``. Possible values
  %   are:
  %
  %   - 0: left
  %   - 1: right
  %
  % led_intensity : int
  %   Intensity of the infrared LED lights. Must be between 0-8. High
  %   values work well for bright eyes while low values seem to work better
  %   for dark eyes. Default: ``8``
  

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

  properties (Access = public, SetObservable = true)
    lens = 1;
    distance = 82;
    analogue_eye = 0;
    led_intensity = 8;
  end

end