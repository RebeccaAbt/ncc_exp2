classdef Line < o_ptb.stimuli.visual.Base
% Draw a line.
%
% The line is initially centered on the screen. Use the :meth:`move` method
% to move it to the desired location.
%
% This class provides all methods of :class:`+o_ptb.+stimuli.+visual.Base`.
%
% Parameters
% ----------
%
% height : float
%   The distance from the bottom to the top of the line.
%
% width : float
%   The distance from left to right of the line.
%
% color : int or array of three ints
%   The color of the circle.
%
% pen_size : float
%   The width of the circle outline.

  properties
    color;
    pen_width;
  end

  methods
    function obj = Line(height, width, color, pen_width)
      obj@o_ptb.stimuli.visual.Base();
      ptb = o_ptb.PTB.get_instance;
      source_rect = [0 0 width height];
      obj.destination_rect = CenterRect(source_rect, ptb.win_rect);
      obj.color = color;
      obj.pen_width = pen_width;
    end

    function on_draw(obj, ptb)
      start_x = obj.destination_rect(1);
      start_y = obj.destination_rect(2);
      stop_x = obj.destination_rect(3);
      stop_y = obj.destination_rect(4);

      ptb.screen('DrawLine', obj.color, start_x, start_y, stop_x, stop_y, obj.pen_width);
    end %function
  end
end
