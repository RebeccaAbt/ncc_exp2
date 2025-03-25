classdef FilledOvalArc < o_ptb.stimuli.visual.Base
% Draw a filled oval arc.
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
  properties
    color;
    start_angle;
    total_angle;
  end %properties

  methods
    function obj = FilledOvalArc(width, height, color, start_angle, total_angle)
      obj@o_ptb.stimuli.visual.Base();
      ptb = o_ptb.PTB.get_instance;
      source_rect = [0 0 width height];
      obj.destination_rect = CenterRect(source_rect, ptb.win_rect);
      obj.color = color;
      obj.start_angle = start_angle;
      obj.total_angle = total_angle;
    end %function

    function on_draw(obj, ptb)
      ptb.screen('FillArc', obj.color, obj.destination_rect, obj.start_angle, obj.total_angle);
    end %function
  end

end
