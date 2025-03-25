classdef FrameOval < o_ptb.stimuli.visual.Base
  % Draw the outline of an oval.
  %
  % This class provides all methods of :class:`+o_ptb.+stimuli.+visual.Base`.
  %
  % Parameters
  % ----------
  %
  % width : float
  %   The width of the oval.
  %
  % height : float
  %   The height of the oval.
  %
  % color : int or array of three ints
  %   The color of the oval.
  %
  % pen_size : float, optional
  %   The width of the ovals outline.

  properties
    color;
    pen_size;
  end %properties

  methods
    function obj = FrameOval(width, height, color, pen_size)
      obj@o_ptb.stimuli.visual.Base();
      ptb = o_ptb.PTB.get_instance;
      source_rect = [0 0 width height];
      obj.destination_rect = CenterRect(source_rect, ptb.win_rect);
      obj.color = color;

      if nargin < 4
        pen_size = 1;
      end %if

      obj.pen_size = pen_size;
    end %function

    function on_draw(obj, ptb)
      ptb.screen('FrameOval', obj.color, obj.destination_rect, obj.pen_size);
    end %function
  end

end
