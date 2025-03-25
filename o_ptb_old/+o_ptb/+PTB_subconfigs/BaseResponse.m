classdef BaseResponse < o_ptb.base.Config
  % Base class for Response configuration
  %
  % Attributes
  % ----------
  %
  % button_mapping : containers.Map
  %   The button mapping.

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

  properties (Access = public, SetObservable = true)
    button_mapping; % The button mapping.
  end %properties

  methods
    function obj = BaseResponse()
      obj.button_mapping = containers.Map();
    end %function
  end %methods

end
