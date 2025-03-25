classdef Text < o_ptb.stimuli.visual.Base & o_ptb.internal.ChecksPropertiesSet
  % Draw formatted text.
  %
  % This class provides all methods of :class:`+o_ptb.+stimuli.+visual.Base`.
  %
  % Parameters
  % ----------
  % text : string
  %   The text to display
  %
  % Attributes
  % ----------
  %
  % size : float
  %   The font size of the text. Defaults to 46.
  %
  % style : int
  %   The style of the text. You can use the constants defined
  %   in :class:`+o_ptb.+constants.PTB_TextStyles`.
  %   Defaults to :attr:`+o_ptb.+constants.PTB_TextStyles.Normal`.
  %
  % font : string
  %   The font used for drawing the text. Defaults to Arial.
  %
  % sx : float
  %   The x coordinates of the text. Defaults to the center of
  %   the destination_rect (normally the whole window).
  %
  % sy : float
  %   The y coordinates of the text. Defaults to the center of
  %   the destination_rect (normally the whole window).
  %
  % color : int or array of three ints
  %   The color of the text. You can use the constants defined
  %   in :class:`+o_ptb.+constants.PTB_Colors`
  %   Defaults to :attr:`+o_ptb.+constants.PTB_Colors.black`.
  %
  % wrapat : int
  %   If set, text will automatically be continued on the next
  %   line if one line exceeds that amount of characters.
  %
  % vspacing : int
  %   The spacing between vertical lines. If your lines overlap,
  %   increase this property. Defaults to 1.

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
    size;
    style = o_ptb.constants.PTB_TextStyles.Normal;
    font = 'Arial';
    sx = 'center';
    sy = 'center';
    wrapat;
    color = o_ptb.constants.PTB_Colors.black;
    vspacing;
  end

  properties (GetAccess = public, SetAccess = protected)
    text;
  end %properties

  methods
    function obj = Text(text)
      obj@o_ptb.stimuli.visual.Base()
      obj.text = text;
      obj.destination_rect = obj.get_ptb.win_rect;

      ptb = o_ptb.PTB.get_instance;
      obj.size = ptb.get_config.defaults.text_size;
      obj.wrapat = ptb.get_config.defaults.text_wrapat;
      obj.vspacing = ptb.get_config.defaults.text_vspacing;
      obj.color = ptb.get_config.defaults.text_color;
    end %function

    function on_draw(obj, ptb)
      obj.check_all_properties_set();

      old_size = ptb.screen('TextSize', obj.size);
      old_style = ptb.screen('TextStyle', obj.style);
      old_font = ptb.screen('TextFont', obj.font);

      DrawFormattedText(ptb.win_handle, obj.text, obj.sx, obj.sy, obj.color, obj.wrapat, [], [], obj.vspacing, [], obj.destination_rect);

      ptb.screen('TextSize', old_size);
      ptb.screen('TextStyle', old_style);
      ptb.screen('TextFont', old_font);

    end
  end %methods

end
