classdef Defaults < o_ptb.base.Config
  % Configuration of some default values for certain stimuli.
  %
  % Attributes
  % ----------
  %
  % text_size : float
  %   Default text size. Default: ``46``.
  %
  % text_wrapat : int
  %   Number of characters in one line. Default: ``80``.
  %
  % text_vspacing : float
  %   Vertical space between two lines of text. Default: ``1``.
  %
  % text_color : int or array of ints
  %   Text color. Default: :attr:`+o_ptb.+constants.PTB_Colors.black`.
  %
  % fixcross_size : float
  %   Size of the fixation cross in pixels. Default: ``120``.
  %
  % fixcross_width_ratio : float
  %   Ratio between the length of each line of the fixation cross and its width.
  %   Default: ``0.25``.

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

  properties(Access = public, SetObservable = true)
    text_size = 46;
    text_wrapat = 80;
    text_vspacing = 1;
    text_color = o_ptb.constants.PTB_Colors.black;
    fixcross_size = 120;
    fixcross_width_ratio = 0.25;
  end

end
