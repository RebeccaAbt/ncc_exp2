classdef FrameCircle < o_ptb.stimuli.visual.FrameOval
  % Draw the outline of a circle.
  %
  % This class provides all methods of :class:`+o_ptb.+stimuli.+visual.Base`.
  %
  % Parameters
  % ----------
  %
  % radius : float
  %   The radius of the circle.
  %
  % color : int or array of three ints
  %   The color of the circle.
  %
  % pen_size : float, optional
  %   The width of the circle outline.

  methods
    function obj = FrameCircle(radius, color, pen_size)

      if nargin < 3
        pen_size = 1;
      end %if

      obj@o_ptb.stimuli.visual.FrameOval(2*radius, 2*radius, color, pen_size);
    end %function
  end

end
