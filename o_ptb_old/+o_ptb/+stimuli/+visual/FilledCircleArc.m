classdef FilledCircleArc < o_ptb.stimuli.visual.FilledOvalArc
% Draw a filled circle arc.
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

  methods
    function obj = FilledCircleArc(radius, color, start_angle, total_angle)
      obj@o_ptb.stimuli.visual.FilledOvalArc(2*radius, 2*radius, color, start_angle, total_angle);
    end %function
  end

end
