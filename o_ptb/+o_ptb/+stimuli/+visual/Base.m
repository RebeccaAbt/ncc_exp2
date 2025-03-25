classdef (Abstract) Base < handle & matlab.mixin.Copyable
  % This is the base class for all visual stimuli.
  %
  % This means that:
  %
  % #. All visual stimulus classes provide all the parameters and methods
  %    of this base class. Please refer to :doc:`/tutorial/o_ptb/drawing`
  %    for details.
  % #. In order to create your own visual stimulus class, you need to inherite
  %    from this base class. Please refer to :doc:`/tutorial/o_ptb/create_stimuli`
  %    for details.
  %
  % Attributes
  % ----------
  %   height : float
  %     The height of the stimulus in pixels
  %
  %   width : float
  %     The width of the stimulus in pixels

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

  properties (Access = public)
    destination_rect;
  end %properties

  properties (Dependent)
    height;
    width;
  end %properties

  methods
    function obj = Base()
      ptb = o_ptb.PTB.get_instance;
      obj.destination_rect = ptb.win_rect;
    end %function

    function scale(obj, scalex, scaley)
      % Scale the stimulus.
      %
      % Scale the stimulus by the ratios provided via the parameters.
      %
      % Parameters
      % ----------
      % scalex : float
      %   Ratio to scale the stimulus horizontally.
      %
      % scaley : float, optional
      %   Ration to scale the stimulus vertically. If ommitted, scalex is used.

      if nargin < 3
        scaley = scalex;
      end %if

      old_rect = obj.destination_rect;

      obj.destination_rect = ScaleRect(obj.destination_rect, scalex, scaley);

      xfactor = mean(old_rect([1 3])) - mean(obj.destination_rect([1 3]));
      yfactor = mean(old_rect([2 4])) - mean(obj.destination_rect([2 4]));

      obj.destination_rect = OffsetRect(obj.destination_rect, xfactor, yfactor);
    end %function


    function move(obj, movex, movey)
      % Move the stimulus.
      %
      % Move the stimulus by the amount of pixels.
      %
      % Parameters
      % ----------
      % movex : float
      %   Amount of pixels to move horizontally.
      %
      % movey : float
      %   Amount of pixels to move vertically.

      obj.destination_rect = OffsetRect(obj.destination_rect, movex, movey);
    end %function
    
    
    function move_to(obj, x, y)
      % Move stimulus to x and y coordinates.
      %
      % Parameters
      % ----------
      % x : float
      %   The x coordinate of the destination.
      %
      % y : float
      %   The y coordinate of the destination.
      
      obj.destination_rect = CenterRectOnPoint(obj.destination_rect, x, y);
    end %function


    function center_on_screen(obj)
      % Center the stimulus on the screen.

      ptb = o_ptb.PTB.get_instance;
      obj.destination_rect = CenterRect(obj.destination_rect, ptb.win_rect);
    end %function

    function h = get.height(obj)
      h = obj.destination_rect(4) - obj.destination_rect(2);
    end %function

    function w = get.width(obj)
      w = obj.destination_rect(3) - obj.destination_rect(1);
    end %function
  end %methods

  methods (Access = protected)
    function ptb = get_ptb(obj)
      ptb = o_ptb.PTB.get_instance();

      if ~ptb.is_screen_ready()
        error('Please initialize your screen first.');
      end %if
    end %function
  end %methods

  methods (Abstract)
    on_draw(obj, ptb);
  end %methods

end
