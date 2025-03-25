classdef KeyboardResponse < o_ptb.PTB_subconfigs.BaseResponse
  % Configuration for the Keyboard response system.
  %
  % The only thing to do here is setup the mapping between the response names
  % and the actual keys.
  %
  % If necessary, you can also set the device number of the keyboard you want
  % to use.
  %
  % Suppose, we have two possible reponses ``yes`` and ``no`` that we want
  % to map to the blue and red button of the response box, this is how
  % it is done:
  %
  % .. code-block ::
  %
  %   ptb_config.datapixxresponse_config.button_mapping('yes') = KbName('Right');
  %   ptb_config.datapixxresponse_config.button_mapping('no') = KbName('Left');
  %
  % For further details, please take a look at :doc:`/tutorial/o_ptb/responses`.
  %
  % Attributes
  % ----------
  %
  % device_number : int or []
  %   The device number of the Keyboard. Default: ``[]``.

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
    device_number = [];
  end %properties
end
