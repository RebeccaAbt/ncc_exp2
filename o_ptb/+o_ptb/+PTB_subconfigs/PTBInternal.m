classdef PTBInternal < o_ptb.base.Config
  % PTBInternal provides some advanced configuration options.
  %
  % Sensible defaults are provided for all of them, so normally you do not
  % need to change them.

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
    screen = 0;
    trigger_length = 0.01;
    blend_function = {'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'};
    audio_subsystem = -1;
    trigger_subsystem = -1;
    response_subsystem = -1;
    tactile_subsystem = -1;
    eyetracker_subsystem = -1;
    final_resolution = [1920 1080];
    use_decorated_window = o_ptb.internal.EnvVarConfig(false, 'O_PTB_USE_DECORATED_WINDOW');
    background_audio_duration = 1 * 60;
  end %properties

end
