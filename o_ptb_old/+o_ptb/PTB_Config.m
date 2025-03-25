classdef PTB_Config < o_ptb.base.Config
  % Main configuration class for ``o_ptb``.
  %
  % Some configuration options for subsystems (audio and response) are in
  % subconfigs. Some advanced options can be found in the internal_config
  % field.
  %
  % Attributes
  % ----------
  %
  % fullscreen : bool
  %   Set to true if you want the experiment run in fullscreen
  %   mode. If you set it to false, you also need to specifiy window_size.
  %   Default: ``true``.
  %
  % window_scale : float
  %   The scale of the window when ``fullscreen =
  %   false`` is specified. Default: ``1``.
  %
  % draw_borders_sbg : float
  %   Draws a black border around the screen. Only needed in Salzburg. (Probably)
  %   Default: ``true``.
  %
  % flip_horizontal : bool
  %   Whether to flip the output left/right. Default: ``true``.
  %
  % hide_mouse : bool
  %   Whether to hide the mouse cursor. Default: ``true``.
  %
  % background_color : int or array of int
  %   The background color. Accepts all values accepted by PTB.
  %   Default: :attr:`+o_ptb.+constants.PTB_Colors.grey`.
  %
  % skip_sync_test : bool
  %   Whether to skip PTB's sync test. Default: ``false``.
  %
  % force_datapixx : bool
  %   If set to true, the experiment will stop with an error if no Datapixx
  %   was found. Default: ``false``.
  %
  % disable_datapixx : bool
  %   If set to true, o_ptb will assume that no datapixx system is present.
  %   Default: ``false``.
  %
  % crappy_screen : bool
  %   If set to true, PTB will ignore if it thinks your video setup is super crappy.
  %   Don't use this setting when really running an experiment! Default: ``false``.
  %
  % force_real_triggers : bool
  %   If set to true, the experiment will not run if no hardware based
  %   triggering system has been detected. Default: ``false``.
  %
  % psychportaudio_config : :class:`+o_ptb.+PTB_subconfigs.PsychPortAudio`
  %   Subconfig for the Psychportaudio sound system.
  %
  % datapixxaudio_config : :class:`+o_ptb.+PTB_subconfigs.DatapixxAudio`
  %   Subconfig for the Datapixx sound system.
  %
  % labjacktrigger_config : :class:`+o_ptb.+PTB_subconfigs.LabjackTriggers`
  %   Subconfig for the Labjack trigger system.
  %
  % lsltrigger_config : :class:`+o_ptb.+PTB_subconfigs.LSLTriggers`
  %   Subconfig for triggering with LabStreamingLayer.
  %
  % keyboardresponse_config : :class:`+o_ptb.+PTB_subconfigs.KeyboardResponse`
  %   Subconfig for the Keyboard response system.
  %
  % datapixxresponse_config : :class:`+o_ptb.+PTB_subconfigs.DatapixxResponse`
  %   Subconfig for the Datapixx response system.
  %
  % corticalmetrics_config : :class:`+o_ptb.+PTB_subconfigs.CorticalMetricTactile`
  %   Subconfig for the CorticalMetrics tactile stimulation system.
  %
  % internal_config : :class:`+o_ptb.+PTB_subconfigs.PTBInternal`
  %   Subconfig for advanced options.

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
    fullscreen = true;
    window_scale = 1;
    draw_borders_sbg = true;
    flip_horizontal = false;
    hide_mouse = true;
    background_color = o_ptb.constants.PTB_Colors.grey;
    skip_sync_test = false;
    force_datapixx = false;
    disable_datapixx = false;
    crappy_screen = false;
    force_real_triggers = false;
    psychportaudio_config = o_ptb.PTB_subconfigs.PsychPortAudio;
    keyboardresponse_config = o_ptb.PTB_subconfigs.KeyboardResponse;
    datapixxaudio_config = o_ptb.PTB_subconfigs.DatapixxAudio;
    datapixxresponse_config = o_ptb.PTB_subconfigs.DatapixxResponse;
    datapixxtrackpixx_config = o_ptb.PTB_subconfigs.DatapixxTrackPixx;
    labjacktrigger_config = o_ptb.PTB_subconfigs.LabjackTriggers;
    lsltrigger_config = o_ptb.PTB_subconfigs.LSLTriggers;
    corticalmetrics_config = o_ptb.PTB_subconfigs.CorticalMetricTactile;
    defaults = o_ptb.PTB_subconfigs.Defaults;
    internal_config = o_ptb.PTB_subconfigs.PTBInternal;
  end %public properties

  methods (Access = public)
    function real_experiment_sbg_cdk(obj, do_it)
      % Shortcut for real experiment configuration.
      %
      % Sets all settings to the correct state for a real experiment run.
      % If you have a function that does the configuration for you, some
      % of those are going to be in "debug" mode most of the time. This
      % method sets them all to values needed to get reliable timings etc.
      %
      % Parameters
      % ----------
      %
      % do_it : bool
      %   If set to ``true`` settings are changed.

      if do_it
        obj.fullscreen = true;
        obj.flip_horizontal = true;
        obj.hide_mouse = true;
        obj.skip_sync_test = false;
        obj.force_datapixx = true;
        obj.disable_datapixx = false;
        obj.crappy_screen = false;
      end %if
    end %function

    function is_real = real_experiment_settings(obj)
      % Check whether all settings are in "real experiment" mode.
      %
      % Returns
      % -------
      % bool
      %   ``true`` if all settings are in "real experiment" mode.
      is_real = obj.fullscreen & ...
                obj.flip_horizontal & ...
                obj.hide_mouse & ...
                ~obj.skip_sync_test & ...
                obj.force_datapixx & ...
                ~obj.crappy_screen;

    end %function
  end %methods

  methods (Access = protected)
    function cpObj = copyElement(obj)
      cpObj = copyElement@matlab.mixin.Copyable(obj);
      cpObj.psychportaudio_config = copy(obj.psychportaudio_config);
      cpObj.keyboardresponse_config = copy(obj.keyboardresponse_config);
      cpObj.datapixxaudio_config = copy(obj.datapixxaudio_config);
      cpObj.datapixxresponse_config = copy(obj.datapixxresponse_config);
      cpObj.datapixxtrackpixx_config = copy(obj.datapixxtrackpixx_config);
      cpObj.defaults = copy(obj.defaults);
      cpObj.internal_config = copy(obj.internal_config);
      cpObj.labjacktrigger_config = copy(obj.labjacktrigger_config);
      cpObj.corticalmetrics_config = copy(obj.corticalmetrics_config);
    end %function
  end %methods

end
