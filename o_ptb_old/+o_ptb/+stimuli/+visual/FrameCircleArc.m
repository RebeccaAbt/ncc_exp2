classdef FrameCircleArc < o_ptb.stimuli.visual.FrameOvalArc
% Draw the outline of a circle arc.
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
% start_angle : float
%   The angle in degrees at which to start drawing.
%
% total_angle : float
%   The angle of the arc in degrees.
%
% pen_size : float, optional
%   The width of the circle outline.

  methods
    function obj = FrameCircleArc(radius, color, start_angle, total_angle, pen_size)

      if nargin < 5
        pen_size = 1;
      end %if

      obj@o_ptb.stimuli.visual.FrameOvalArc(2*radius, 2*radius, color, start_angle, total_angle, pen_size);
    end %function
  end

end
