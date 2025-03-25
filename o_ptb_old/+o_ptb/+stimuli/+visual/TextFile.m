classdef TextFile < o_ptb.stimuli.visual.Text
  % Read formatted text from a file and draw it.
  %
  % This class provides all methods of :class:`+o_ptb.+stimuli.+visual.Text`.
  %
  % Parameters
  % ----------
  %
  % f_name : string
  %   The filename to read the text from.


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
    function obj = TextFile(f_name)
      tf_id = fopen(f_name, 'r', 'n', 'UTF-8');
      text = fscanf(tf_id, '%c');
      text = native2unicode(text, 'UTF-8');
      obj@o_ptb.stimuli.visual.Text(double(text));
      fclose(tf_id);
    end %function
  end %methods

end
