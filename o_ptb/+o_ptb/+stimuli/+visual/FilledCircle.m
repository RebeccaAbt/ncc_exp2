classdef FilledCircle < o_ptb.stimuli.visual.FilledOval
% Draw a filled circle.
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

  methods
    function obj = FilledCircle(radius, color)
      obj@o_ptb.stimuli.visual.FilledOval(2*radius, 2*radius, color);
    end %function
  end

end
