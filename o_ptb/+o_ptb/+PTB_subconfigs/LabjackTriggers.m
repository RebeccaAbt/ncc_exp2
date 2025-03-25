classdef LabjackTriggers < o_ptb.base.Config
  % Configuration for the Labjack Triggering System.
  %
  % Please note that you need a recent version of python_ to use the
  % Labjack!
  %
  % Sensible defaults are provided for all of them, so normally you do not
  % need to change them.
  %
  % Attributes
  % ----------
  %
  % channel_group : :attr:`+labjack.Labjack.ChannelGroup`
  %   The Labjack U3 (the only one supported
  %   right now) has three different channel
  %   groups. The relevant ones for you are:
  %     * :attr:`+labjack.Labjack.ChannelGroup.EIO`: If you have the plug attached.
  %     * :attr:`+labjack.Labjack.ChannelGroup.FIO`: If you use the wires.
  %
  % method : :attr:`+labjack.Labjack.TriggerMethod`
  %   There are three different methods to do the triggering:
  %     * :attr:`+labjack.Labjack.TriggerMethod.MULTI`: Uses
  %       all 8 channels of the chosen channelgroup.
  %       Values are binary coded. This is the normal
  %       mode of operation you should be familar with.
  %     * :attr:`+labjack.Labjack.TriggerMethod.SINGLE`: Uses
  %       only one bit to signal a trigger. Use
  %       the single_channel property to configure
  %       which one you want. Obviously, it is
  %       impossible to signal different values
  %       this way.
  %     * :attr:`+labjack.Labjack.TriggerMethod.PULSEWIDTH`:
  %       Uses "Pulse Width Modulation" to signal
  %       different bit values using only one
  %       channel. This is done by modulating the
  %       time, the trigger line stays up or down.
  %         * 10ms = 1.
  %         * 20ms = 0.
  %       The num_bits property sets the number of
  %       bits that are coded.
  %       Example: num_bits = 5 and you wan to
  %       send the trigger value 5. 5 in binary
  %       representation with 5 bits is: 00101.
  %       This would be coded like this:
  %         1. trigger up for 20ms
  %         2. trigger down for 20ms
  %         3. trigger up for 10ms
  %         4. trigger down for 20ms
  %         5. trigger up for 10ms
  %
  % single_channel : int
  %   The channel to use for single or pulsewidth triggering.
  %
  % num_bits : int
  %   The number of bits to code when using
  %   pulsewidth mode. Must be uneven.

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
    channel_group = labjack.Labjack.ChannelGroup.EIO;
    method = labjack.Labjack.TriggerMethod.MULTI;
    single_channel = 0;
    num_bits = 5;
  end %properties

end
