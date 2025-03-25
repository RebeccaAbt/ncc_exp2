classdef Image < o_ptb.stimuli.visual.TextureBase & o_ptb.internal.ChecksPropertiesSet
  % Draw an image read from a file.
  %
  % This class provides all methods of :class:`+o_ptb.+stimuli.+visual.TextureBase`
  % and :class:`+o_ptb.+stimuli.+visual.Base`.
  %
  % Parameters
  % ----------
  %
  % image : string
  %   The filename of the image.

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
  methods
    function obj=Image(image)
      obj@o_ptb.stimuli.visual.TextureBase()
      ptb = o_ptb.PTB.get_instance;
      [imdata, ~, transparency] = imread(image);
      if ~isempty(transparency)
        imdata(:, :, end+1) = transparency;
      end %if

      obj.texture_id = ptb.screen('MakeTexture', imdata);
      obj.destination_rect = CenterRect(obj.get_rect, ptb.win_rect);
    end %function
  end

end
