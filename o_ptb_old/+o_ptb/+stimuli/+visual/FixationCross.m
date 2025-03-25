classdef FixationCross < o_ptb.stimuli.visual.Base
  % Draw a fixation cross.
  %
  % This class provides all methods of :class:`+o_ptb.+stimuli.+visual.Base`.
  %
  % Parameters
  % ----------
  %
  % color : int or array of three ints
  %   The color of the fixation cross.

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

  properties
    pen_width;
    color;
  end %properties

  methods
    function obj = FixationCross(color)
      obj@o_ptb.stimuli.visual.Base();
      ptb = o_ptb.PTB.get_instance;
      size = ptb.get_config.defaults.fixcross_size;
      width_ration = ptb.get_config.defaults.fixcross_width_ratio;
      source_rect = [0 0 size size];
      obj.destination_rect = CenterRect(source_rect, ptb.win_rect);
      obj.pen_width = size * width_ration;

      if nargin < 1
        color = [0 0 0];
      end %if

      obj.color = color;
    end %function

    function on_draw(obj, ptb)
      start_x = obj.destination_rect(1);
      stop_x = obj.destination_rect(3);
      start_y = mean([obj.destination_rect(2) obj.destination_rect(4)]) - obj.pen_width/2;
      stop_y = start_y + obj.pen_width;

      ptb.screen('FillRect',obj.color, [start_x, start_y, stop_x, stop_y]);

      start_x = mean([obj.destination_rect(1) obj.destination_rect(3)]) - obj.pen_width/2;
      stop_x = start_x + obj.pen_width;
      start_y = obj.destination_rect(2);
      stop_y =  obj.destination_rect(4);

      ptb.screen('FillRect',obj.color, [start_x, start_y, stop_x, stop_y]);
    end %function
  end

end
