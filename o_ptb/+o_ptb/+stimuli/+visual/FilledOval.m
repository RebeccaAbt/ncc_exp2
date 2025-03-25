classdef FilledOval < o_ptb.stimuli.visual.Base
% Draw a filled oval.
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

  properties
    color;
  end %properties

  methods
    function obj = FilledOval(width, height, color)
      obj@o_ptb.stimuli.visual.Base();
      ptb = o_ptb.PTB.get_instance;
      source_rect = [0 0 width height];
      obj.destination_rect = CenterRect(source_rect, ptb.win_rect);
      obj.color = color;
    end %function

    function on_draw(obj, ptb)
      ptb.screen('FillOval', obj.color, obj.destination_rect);
    end %function
  end

end
