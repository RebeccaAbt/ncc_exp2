classdef Gabor < o_ptb.stimuli.visual.TextureBase & o_ptb.internal.ChecksPropertiesSet
  % Draw a Gabor patch.
  %
  % .. note::
  %   It is mandatory to set the following properties after the class is
  %   instantiated:
  %
  %   - frequency
  %   - sc
  %   - contrast
  %
  % This class provides all methods of :class:`+o_ptb.+stimuli.+visual.TextureBase`
  % and :class:`+o_ptb.+stimuli.+visual.Base`.
  %
  % Parameters
  % ----------
  %
  % width : float
  %   The width of the gabor patch.
  %
  % height : float
  %   The height of the gabor patch.
  %
  % Attributes
  % ----------
  % rotate : float
  %   The rotation of the gabor in degrees. Default = 0.
  %
  % phase : float
  %    The phase of the gabor in degrees. Default = 180.
  %
  % aspectration : float
  %   Leave at 1 (the default) if you want the gabor to be
  %   as wide as it is high.
  %
  % frequency : float
  %   The spatial frequency in cycles per pixel. No default.
  %
  % sc : float
  %   The sigma value of the gauss function. No default.
  %
  % contrast : float
  %   The contrast of the gabor. No default.

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

  properties (Access = protected)
    gabor_rect;
  end %properties

  properties (Access = public, SetObservable = true)
    phase = 180;
    aspectratio = 1;
    frequency;
    sc;
    contrast;
  end

  methods (Access = public)
    function obj = Gabor(width, height)
      obj@o_ptb.stimuli.visual.TextureBase()

      if nargin < 2
        height = width;
      end %if

      [obj.texture_id, obj.gabor_rect] = CreateProceduralGabor(obj.get_ptb.win_handle, width, height);
      obj.destination_rect = CenterRect(Screen('Rect', obj.texture_id), obj.get_ptb.win_rect);
    end %function
  end %methods

  methods (Access = protected)
    function draw_texture(obj, ptb)
      obj.check_all_properties_set();

      ptb.screen('DrawTexture', obj.texture_id, [], obj.destination_rect,...
        obj.rotate, [], [], [], [], kPsychDontDoRotation,...
        [obj.phase, obj.frequency, obj.sc, obj.contrast, obj.aspectratio, 0, 0, 0]);
    end %function
  end %methods

end
