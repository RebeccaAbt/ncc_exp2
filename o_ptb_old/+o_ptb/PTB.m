classdef (Sealed) PTB < handle
  % PTB is the main class, controlling the underlying PsychToolbox and
  % devices.
  %
  % Initializing an experiment with this library normally involves the
  % following steps:
  %
  % 1. Issue 'restoredefaultpath' to make sure that you work with a clean path
  % 2. Add the top-level folder of this library to the Matlab path. You do
  %    not need to add all the subfolders!
  % 3. Create an instance of :class:`+o_ptb.PTB_Config` and set all the preferences
  %    you need.
  % 4. Create an instance of this class supplying your :class:`+o_ptb.PTB_Config`
  %    instance
  % 5. Setup the subsystems by calling the appropriate setup methods.
  %
  % IMPORTANT: Per default, your resolution is ALWAYS 1920x1080!!! If your
  % window or screen is smaller, the content gets scaled accordingly.
  %
  % Attributes
  % ----------
  %   win_handle : PTB window handle
  %       The window handle of the PTB window
  %
  %   win_rect : PTB Rect
  %       The window rect (i.e. the position and size) of the PTB window
  %
  %   flip_interval : float
  %       The amount of time between two screen refreshes
  %
  %   width_pixel : int
  %       The width of the PTB window in pixels
  %
  %   height_pixel : int
  %       The height of the PTB window in pixels
  %
  %   using_datapixx_video : bool
  %       True if a Datapixx system was found
  %
  %   base_path : string
  %       The folder of the o_ptb.
  %
  %   assets_path : string
  %       The folder of the o_ptb assets (pictures etc).
  
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
  
  properties (SetAccess = protected, GetAccess = public)
    win_handle; % The window handle of the PTB window
    win_rect; % The window rect (i.e. the position and size) of the PTB window
    flip_interval; % The amount of time between two screen refreshes
    width_pixel; % The width of the PTB window in pixels
    height_pixel; % The height of the PTB window in pixels
    using_datapixx_video; % True if a Datapixx system was found
    triggers_initialized; % True if triggers have been initialized
    
    scale_factor;
  end
  
  properties (Dependent)
    base_path;
    assets_path;
  end %Dependent properties
  
  
  
  properties (Access = protected)
    post_flip_callbacks;
    ptb_config;
  end %properties
  
  
  methods (Static, Access = public)
    function ptb = get_instance(ptb_config)
      % Return an instance of the :class:`PTB <+o_ptb.PTB>` class.
      %
      % If `ptb_config` is supplied, this methods attemps to create a new
      % instance of :class:`+o_ptb.PTB`. If such an instance has already been
      % created, this method is going to fail.
      %
      % If no parameter is supplied, this method returns the currently active
      % :class:`+o_ptb.PTB`. If none has been created earlier, it will fail.
      %
      % Parameters
      % ==========
      % ptb_config : :class:`+o_ptb.PTB_Config`, optional
      %     The configuration. Only supply if you want to create a new instance!
      %
      % Returns
      % =======
      % :class:`+o_ptb.PTB`
      %     The current or new :class:`PTB <+o_ptb.PTB>`.
      
      persistent ptb_instance;
      
      if nargin < 1
        if isempty(ptb_instance) || ~isvalid(ptb_instance)
          error('o_ptb.PTB has not yet been initialized. Please call the get_instance method with an instance of o_ptb.PTB_Config as the first argument');
        end %if
        
        ptb = ptb_instance;
      else
        delete(ptb_instance);
        
        if o_ptb.PTB.is_lab_pc()
          if ~ptb_config.real_experiment_settings()
            fprintf('\n\n\n\nWARNING!!!!!!!!!!\n');
            fprintf('You seem to be running the experiment at the MEG Lab but you are using debug option!\n');
            fprintf('You can go on but all timings will be unreliable!!!!!\n\n');
            fprintf('If you really want to go on, press y now. Otherwise, the experiment will be aborted\n\n');
            
            WaitSecs(0.1);
            [~, key] = KbWait();
            if find(key) ~= KbName('y')
              error('Experiment Aborted');
            end %if
            fprintf('Ok, starting the experiment in DEBUG MODE!\n');
          end %if
        end %if
        
        ptb_instance = o_ptb.PTB(ptb_config);
        ptb = ptb_instance;
      end %if
    end %function
  end %methods
  
  
  methods (Access = public)
    function setup_screen(obj)
      % Set up the screen for the experiment.
      %
      % You need to call this method before doing any drawing on the screen
      % or working with visual stimuli.
      
      fprintf('Setting up screen...\n');
      cfg = obj.ptb_config;
      
      if cfg.fullscreen
        obj.scale_factor = 1;
      else
        obj.scale_factor = cfg.window_scale;
      end %if
      
      if cfg.skip_sync_test
        Screen('Preference', 'SkipSyncTests', 1);
      end %if
      
      PsychImaging('PrepareConfiguration');
      PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
      
      if obj.has_datapixx()
        Datapixx('Open');
        Datapixx('SetVideoPixelSyncLine', 0, 1, 1)
        Datapixx('RegWrRd');
        obj.using_datapixx_video = true;
      else
        obj.using_datapixx_video = false;
      end %if
      
      if cfg.flip_horizontal
        PsychImaging('AddTask', 'AllViews', 'FlipHorizontal');
      end %if
      
      screen_resolution = Screen('Resolution', 0);
      if cfg.fullscreen
        window_resolution = [screen_resolution.width screen_resolution.height];
      else
        window_resolution = cfg.internal_config.final_resolution * cfg.window_scale;
      end %if
      
      if ~all(window_resolution == cfg.internal_config.final_resolution)
        PsychImaging('AddTask', 'General', 'UsePanelFitter', cfg.internal_config.final_resolution, 'Aspect');
      end %if
      
      screen_flags = [];
      if cfg.fullscreen
        rect = [];
        screen_flags = [];
      else
        rect = [0 0 window_resolution];
        if cfg.internal_config.use_decorated_window
          screen_flags = kPsychGUIWindow;
        end %if
      end %if
      
      if cfg.crappy_screen
        Screen('Preference', 'ConserveVRAM', 64);
      end %if
      
      [obj.win_handle, obj.win_rect] = PsychImaging('OpenWindow', cfg.internal_config.screen, cfg.background_color, rect, [], [], [], [], [], screen_flags);
      
      obj.flip_interval = obj.screen('GetFlipInterval');
      
      [obj.width_pixel, obj.height_pixel] = RectSize(obj.win_rect);
      
      obj.play_on_next_flip = false;
      
      obj.screen('BlendFunction', cfg.internal_config.blend_function{:});
      
      if cfg.hide_mouse
        HideCursor();
      end %if
      
      obj.post_flip_callbacks = {};
    end %function
    
    
    function setup_audio(obj)
      % Set up the audio system for the experiment.
      %
      % You need to call this method before working with auditory stimuli.
      
      fprintf('Setting up audio...\n');
      audio_system = obj.ptb_config.internal_config.audio_subsystem;
      
      if audio_system == -1
        if obj.has_datapixx()
          audio_system = @o_ptb.subsystems.audio.Datapixx;
        else
          audio_system = @o_ptb.subsystems.audio.PsychPortAudio;
        end %if
      end %if
      
      if strcmp(func2str(audio_system), 'o_ptb.subsystems.audio.PsychPortAudio')
        obj.audio_subsystem = audio_system(obj.ptb_config.psychportaudio_config);
      elseif strcmp(func2str(audio_system), 'o_ptb.subsystems.audio.Datapixx')
        obj.audio_subsystem = audio_system(obj.ptb_config.datapixxaudio_config);
      end %if
      
      obj.audio_subsystem.init();
    end %function
    
    
    function setup_trigger(obj)
      % Set up the triggering system for the experiment.
      %
      % You need to call this method before working with triggers.
      
      fprintf('Setting up triggers...\n');
      
      obj.triggers_initialized = false;
      
      trigger_system = obj.ptb_config.internal_config.trigger_subsystem;
      
      if ~isa(trigger_system, 'function_handle')
        if obj.has_datapixx()
          trigger_system = @o_ptb.subsystems.trigger.Datapixx;
        elseif labjack.Labjack.has_labjack
          trigger_system = @o_ptb.subsystems.trigger.Labjack;
        else
          if obj.ptb_config.force_real_triggers
            error('No Hardware Trigger System detected.');
          end %if
          trigger_system = @o_ptb.subsystems.trigger.Dummy;
        end %if
      end %if
      
      obj.trigger_subsystem = trigger_system(obj.ptb_config);
      
      obj.triggers_initialized = true;
    end %function
    
    
    function setup_response(obj)
      % Set up the response system for the experiment.
      %
      % You need to call this method before working with responses.
      
      fprintf('Setting up responses...\n');
      
      response_system = obj.ptb_config.internal_config.response_subsystem;
      
      if response_system == -1
        if obj.has_datapixx()
          response_system = @o_ptb.subsystems.response.Datapixx;
        else
          response_system = @o_ptb.subsystems.response.Keyboard;
        end %if
      end %if
      
      obj.response_subsystem = response_system(obj.ptb_config);
    end %function
    
    function setup_tactile(obj)
      % Set up the tactile system for the experiment.
      %
      % You need to call this method before working with tactile stimuli.
      fprintf('Setting up tactile...\n');
      
      if ~obj.triggers_initialized
        error('You must initialze the trigger subsystem before the tactile subsystem.');
      end %if
      tactile_system = obj.ptb_config.internal_config.tactile_subsystem;
      
      if tactile_system == -1
        if o_ptb.subsystems.tactile.CorticalMetricsStimulator.is_present
          tactile_system = @o_ptb.subsystems.tactile.CorticalMetricsStimulator;
        else
          tactile_system = @o_ptb.subsystems.tactile.Dummy;
        end %if
      end %if
      
      obj.tactile_subsystem = tactile_system(obj.ptb_config);
    end %function
    
    
    function setup_eyetracker(obj)
      % Set up the eyetracker system for the experiment.
      %
      % You need to call this method before working with the eyetracker.
      fprintf('Setting up eyetracker...\n');
      
      eyetracker_system = obj.ptb_config.internal_config.eyetracker_subsystem;
      
      if eyetracker_system == -1
        if obj.has_datapixx()
          eyetracker_system = @o_ptb.subsystems.eyetracker.Datapixx;
        else
          eyetracker_system = @o_ptb.subsystems.eyetracker.Dummy;
        end %if
      end %if
      
      obj.eyetracker_subsystem = eyetracker_system();
    end %function
    
    function reset_subsystems(obj)
      % Reset all active subsystems.
      
      if ~isempty(obj.tactile_subsystem)
        obj.tactile_subsystem.reset();
      end %if
      
      if ~isempty(obj.trigger_subsystem)
        obj.trigger_subsystem.reset();
      end %if
      
      if ~isempty(obj.audio_subsystem)
        obj.audio_subsystem.reset();
      end %if
      
      if ~isempty(obj.eyetracker_subsystem)
        obj.eyetracker_subsystem.reset();
      end %if
      
    end %function
    
    
    function draw(obj, stimulus)
      % Draw a visual stimulus.
      %
      % Draw a visual stimulus to the offscreen buffer. It
      % does not appear immediately but at the next screen flip.
      %
      % Parameters
      % ==========
      % stimulus : Instance of subclass of :class:`+o_ptb.+stimuli.+visual.Base`
      %     The stimulus to draw.
      
      if ~isa(stimulus, 'o_ptb.stimuli.visual.Base')
        error('Can only draw VisualStimulus instances');
      end %if
      
      stimulus.on_draw(obj);
      
      if isa(stimulus, 'o_ptb.stimuli.visual.PostFlipCallback')
        if ~any(cellfun(@(x) x == stimulus, obj.post_flip_callbacks))
          obj.post_flip_callbacks{end+1} = stimulus;
        end %if
      end %if
    end %function
    
    
    function prepare_audio(obj, stimulus, delay, hold, mix)
      % Prepare and upload an auditory stimulus.
      %
      % This is the first step of using an auditory stimulus. This method
      % will prepare the audio stimulus and upload it to the audio subsystem.
      % This may take some processing time so it should be done when timing
      % is not crucial. The second step would be to call
      % :meth:`schedule_audio <+o_ptb.PTB.schedule_audio>`.
      %
      % .. note::
      %     If you prepare two stimuli at overlapping time-intervals, the latter
      %     overwrites the earlier one.
      %
      % Parameters
      % ==========
      % stimulus : Instance of subclass of :class:`+o_ptb.+stimuli.+auditory.Base`
      %     The stimulus to prepare.
      % delay : float, optional
      %     The delay in seconds. Default = 0
      % hold : bool, optional
      %     If this is set to true, the previous stimuli will be
      %     retained. If it is set to false, the previous stimuli will be
      %     deleted. This is useful if you want to schedule multiple sounds
      %     with different delays. Please be aware that if sounds overlap,
      %     the new one wins.
      % mix : bool, optional
      %     If this is set to true, a new stimulus overlapping a previously
      %     prepared one will not overwrite the former. Instead, both
      %     streams will be mixed.
      
      if nargin < 3
        delay = 0;
      end %if
      
      if nargin < 4
        hold = false;
      end %if
      
      if nargin < 5
        mix = false;
      end %if
      
      if mix & ~hold
        error('If mix is true, hold must be true as well!');
      end %if
      
      if ~hold
        obj.audio_subsystem.reset();
      end %if
      
      if ~isempty(obj.audio_background_object)
        stimulus = copy(stimulus);
        stimulus.add_background(obj.audio_background_object);
      end %if
      
      obj.audio_subsystem.prepare(stimulus, delay, mix);
    end %function
    
    
    function schedule_audio(obj)
      % Schedule the prepared auditory stimuli.
      %
      % This is the second step of using an auditory stimuli. This method
      % will do the final preparations of the audio subsystem to emit the
      % stimulus. In order to actually fire the stimulus, you need to call
      % either :meth:`play_without_flip <+o_ptb.PTB.play_without_flip>`
      % to stimulate immediately or
      % :meth:`play_on_flip <+o_ptb.PTB.play_on_flip>` to stimulate at the next
      % flip command.
      %
      % .. note::
      %     Calling this method without calling
      %     :meth:`prepare_audio <+o_ptb.PTB.prepare_audio>`
      %     first results in the previously prepared stimulus being played again.
      
      obj.audio_subsystem.schedule();
    end %function
    
    
    function set_audio_background(obj, background_object)
      % Set the audio background.
      %
      % The sound data in background_object will be played continuously. If
      % an auditory stimulus is prepared, it will be added to the
      % background noise.
      %
      % The background should be a signal that does not create distortions
      % when the position of the current audio frame jumps.
      %
      % The background audio will start right away.
      %
      % Parameters
      % ==========
      % background_object : Instance of subclass of :class:`+o_ptb.+stimuli.+auditory.Base`
      %     The sound object to play in the background
      
      if obj.audio_background_running
        error('Cannot set audio background will it is running.');
      end %if
      
      obj.audio_background_object = copy(background_object);
      obj.audio_subsystem.set_audio_background(obj.audio_background_object);
      
      obj.audio_subsystem.start_background();
      obj.audio_background_running = true;
      
    end %function
    
    function prune_audio(obj, seconds)
      % Make sure that the audio stream is at most seconds long.
      %
      % This method works on the audio data that has been prepared but not
      % yet scheduled.
      %
      % Parameters
      % ==========
      % seconds : float
      %     Maximum length of the audio stream.
      
      obj.audio_subsystem.prune(seconds);
    end %function
    
    
    function stop_audio_background(obj)
      % Stop the background audio.
      
      obj.audio_background_object = [];
      obj.audio_subsystem.stop_audio_background();
      obj.audio_background_running = false;
    end %function
    
    function prepare_trigger(obj, value, delay, hold)
      % Prepare to fire a trigger.
      %
      % This is the first step of firing a trigger. This method will upload
      % the trigger value to the trigger subsystem.
      % This may take some processing time so it should be done when timing
      % is not crucial. The second step would be to call
      % :meth:`schedule_trigger <+o_ptb.PTB.schedule_trigger>`
      %
      % Parameters
      % ==========
      %
      % value : int
      %   The trigger value to prepare.
      %
      % delay : float, optional
      %   The delay in seconds.
      %
      % hold : bool, optional
      %   If this is set to true, the previous triggers will be
      %   retained. If it is set to false, the previous triggers will be
      %   deleted. This is useful if you want to schedule multiple triggers
      %   with different delays. Please be aware that if triggers overlap,
      %   the new one wins.
      
      if nargin < 3
        delay = 0;
      end %if
      
      if nargin < 4
        hold = false;
      end %if
      
      if ~hold
        obj.trigger_subsystem.reset();
      end %if
      
      obj.trigger_subsystem.prepare(value, delay);
    end %function
    
    
    function schedule_trigger(obj)
      % Schedule the prepared trigger.
      %
      % This is the second step of firing a trigger. This method
      % will do the final preparations of the trigger subsystem to emit the
      % trigger. In order to actually fire the stimulus, you need to call
      % either :meth:`play_without_flip <+o_ptb.PTB.play_without_flip>`
      % to stimulate immediately or
      % :meth:`play_on_flip <+o_ptb.PTB.play_on_flip>` to stimulate at the next
      % flip command.
      %
      % .. note::
      %     Calling this method without calling
      %     :meth:`prepare_trigger <+o_ptb.PTB.prepare_trigger>`
      %     first results in the previously prepared trigger being fired again.
      
      obj.trigger_subsystem.schedule();
    end %function
    
    
    function prepare_tactile(obj, stim, delay, hold)
      % Prepare a tactile stimulus.
      %
      % This is the first step of doing tactile stimulation. This method
      % prepares the stimulus, uploads it to the stimulator and prepares the
      % triggers. This may take some processing time so it should be done when timing
      % is not crucial. The second step would be to call
      % :meth:`schedule_tactile <+o_ptb.PTB.schedule_tactile>`
      %
      % Parameters
      % ==========
      %
      % stim : :class:`+o_ptb.+stimuli.+tactile.Base`
      %   The stimulus to prepare.
      %
      % delay : float, optional
      %   The delay in seconds.
      %
      % hold : bool, optional
      %   If this is set to true, the previous stimuli will be
      %   retained. If it is set to false, the previous stimuli will be
      %   deleted. This is useful if you want to schedule multiple stimuli
      %   with different delays. Please be aware that if stimuli overlap,
      %   the new one wins.
      
      
      if nargin < 3
        delay = 0;
      end %if
      
      if nargin < 4
        hold = false;
      end %if
      
      if ~hold
        obj.tactile_subsystem.reset();
      end %if
      
      obj.tactile_subsystem.prepare(stim, delay);
    end %function
    
    
    function schedule_tactile(obj)
      % Schedule the prepared tactile stimuli.
      %
      % This is the second step of doing tactile stimulation. This method
      % will do the final preparations of the tactile subsystem to emit the
      % stimuli. In order to actually fire the stimulus, you need to call
      % either :meth:`play_without_flip <+o_ptb.PTB.play_without_flip>`
      % to stimulate immediately or
      % :meth:`play_on_flip <+o_ptb.PTB.play_on_flip>` to stimulate at the next
      % flip command.
      %
      % .. note::
      %     Calling this method without calling
      %     :meth:`prepare_trigger <+o_ptb.PTB.prepare_tactile>`
      %     first results in the previously prepared trigger being fired again.
      
      obj.tactile_subsystem.schedule();
    end %function
    
    function wait_for_stimulators(obj)
      % Wait until the tactile stimulators are ready.
      
      obj.tactile_subsystem.wait_for_stimulators();
    end %function
    
    function [keys_pressed, timestamp] = wait_for_keys(obj, keys, until)
      % Wait for specified keys or buttons to be pressed.
      %
      % This method uses the underlying response subsystem to wait keys or
      % buttons being pressed by the participant. It uses the button
      % mapping specified in :class:`+o_ptb.PTB_Config`
      %
      % Parameters
      % ==========
      %
      % keys : cell array of key_ids
      %   A cell array of key_ids to wait for.
      %
      % until : float, optional
      %   Timeout of the method in PTB seconds.
      %
      % Returns
      % =======
      %
      % keys_pressed : cell array of strings
      %   A cell array of the keys that were pressed. Empty
      %   if no key was pressed.
      %
      % timestamp : cell array of floats
      %   The timestamps of the key presses.
      
      if nargin < 3
        until = [];
      end %if
      
      [keys_pressed, timestamp] = obj.response_subsystem.wait_for_keys(keys, until);
    end %function
    
    
    function start_record_keys(obj)
      % Starts recording button presses.
      %
      % As soon as you call this method, button presses are recorded
      % internally. After calling
      % :meth:`stop_record_keys <+o_ptb.PTB.stop_record_keys>`,
      % you can query what keys
      % (if any) have been pressed in that interval using
      % :meth:`get_recorded_keys <+o_ptb.PTB.get_recorded_keys>`,
      
      obj.response_subsystem.start_record_keys();
    end %function
    
    
    function stop_record_keys(obj)
      % Stops recording button presses.
      %
      % As soon as you call this method, you can query what keys
      % (if any) have been pressed in the interval between the call to
      % :meth:`start_record_keys <+o_ptb.PTB.start_record_keys>`  and this call using
      % :meth:`get_recorded_keys <+o_ptb.PTB.get_recorded_keys>`.
      
      obj.response_subsystem.stop_record_keys();
    end %function
    
    
    function [keys_pressed, timestamp] = get_recorded_keys(obj, keys)
      % Return recorded keys.
      %
      % Return keys pressed between
      % :meth:`start_record_keys <+o_ptb.PTB.start_record_keys>` and
      % :meth:`stop_record_keys <+o_ptb.PTB.stop_record_keys>`
      %
      % Returns
      % =======
      %
      % keys_pressed : cell array of strings
      %   A cell array of the keys that were pressed. Empty
      %   if no key was pressed.
      %
      % timestamp : cell array of floats
      %   The timestamps of the key presses.
      
      [keys_pressed, timestamp] = obj.response_subsystem.get_recorded_keys(keys);
    end %function
    
    
    function play_without_flip(obj)
      % Play scheduled sounds and fire triggers immediately.
      
      if obj.using_datapixx_video & isa(obj.audio_subsystem, 'o_ptb.subsystems.audio.Datapixx')
        Datapixx('RegWr');
      else
        if ~isempty(obj.audio_subsystem)
          obj.audio_subsystem.play();
        end %if
        if ~isempty(obj.trigger_subsystem)
          obj.trigger_subsystem.fire();
        end %if
        
        if ~isempty(obj.tactile_subsystem)
          obj.tactile_subsystem.play();
        end %if
      end %if
    end %function
    
    
    function play_on_flip(obj)
      % Play scheduled sounds and fire triggers at the next flip.
      %
      % Please note that in order for this to work, you need to use the
      % :meth:`flip <+o_ptb.PTB.flip>`  shortcut function
      % provided by this class.
      
      obj.play_on_next_flip = true;
    end %function
    
    
    function screenshot(obj, fname)
      % Takes a screenshot of the current display and save it to a file.
      %
      % Parameters
      % ==========
      %
      % fname : string
      %   The filename to save the screenshot to.
      
      img_array = obj.screen('GetImage');
      imwrite(img_array, fname);
    end %function
    
    
    function eyetracker_verify_eye_positions(obj)
      % Verify the position of the eyes for the eyetracker.
      
      obj.eyetracker_subsystem.verify_eye_positions();
    end %function
    
    
    function eyetracker_calibrate(obj, out_folder)
      % Do eyetracker calibration
      %
      % Parameters
      % ==========
      %
      % out_folder : str
      %   Folder where to store the logs and images of the calibration.
      
      if nargin < 2
        out_folder = [];
      end %if
      
      obj.eyetracker_subsystem.calibrate(out_folder);
      
    end %function
    
    
    function start_eyetracker(obj)
      % Start the eyetracker.
      
      obj.eyetracker_subsystem.start();
    end %function
    
    
    function stop_eyetracker(obj)
      % Stop the eyetracker
      
      obj.eyetracker_subsystem.stop();
    end %function
    
    
    function save_eyetracker_data(obj, f_name)
      % Save the data acquired during an eyetracker measurement run.
      %
      % Parameters
      % ==========
      %
      % fname : str, optional
      %   Filename to save the digital eyetracker data to
      
      obj.eyetracker_subsystem.save_data(f_name);
      
    end %function
    
    function coords = get_eye_positions(obj)
      % Return the current position of the eyes on the screen.
      %
      % Returns
      % =======
      %
      % coords : struct
      %   struct with four fields containing the coordinates:
      
      coords = obj.eyetracker_subsystem.get_position_on_screen();
      
    end %function
    
    
    function [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos] = flip(obj, varargin)
      % Issues a screen flip.
      %
      % This is basically a shortcut to the PTB Screen('Flip', ...)
      % command that also takes sure that stimuli scheduled with
      % :meth:`play_on_flip <+o_ptb.PTB.play_on_flip>` are
      % fired. So, always use this one.
      %
      % Parameters and return values are identical to the Screen('Flip')
      % command with the exception that you must not provide the windowPtr.
      
      if obj.ptb_config.draw_borders_sbg
        obj.draw_border(95);
      end %if
      
      if obj.using_datapixx_video && obj.play_on_next_flip
        sync_pixel = randi(255, 1, 3);
        obj.screen('FillRect', sync_pixel, [0, 0, obj.width_pixel, ceil(1/obj.scale_factor)]);
        Datapixx('RegWrPixelSync', sync_pixel', 65535);
      end %if
      
      [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos] = obj.screen('Flip', varargin{:});
      
      flip_info.VBLTimestamp = VBLTimestamp;
      flip_info.StimulusOnsetTime = StimulusOnsetTime;
      flip_info.FlipTimestamp = FlipTimestamp;
      flip_info.Missed = Missed;
      flip_info.Beampos = Beampos;
      
      for idx_callbacks = 1:length(obj.post_flip_callbacks)
        obj.post_flip_callbacks{idx_callbacks}.after_flip(flip_info);
      end %for
      
      obj.post_flip_callbacks = {};
    end %function
    
    
    function deinit(obj)
      % Uninitializes the system.
      %
      % Closes the window and all connections to the subsystems.
      
      sca;
      obj.win_handle = [];
      obj.win_rect = [];
      obj.flip_interval = [];
      obj.width_pixel = [];
      obj.height_pixel = [];
      obj.audio_subsystem = [];
      obj.trigger_subsystem = [];
      obj.response_subsystem = [];
      obj.eyetracker_subsystem = [];
      obj.tactile_subsystem = [];
      
      if obj.has_datapixx()
        Datapixx('Close');
      end %if
      
      obj.has_datapixx_cached = [];
    end %function
    
    
    function is_ready = is_screen_ready(obj)
      % Query if we have a valid and open window.
      %
      % Returns
      % =======
      %
      % bool
      %   ``true`` if the screen is ready.
      
      try
        obj.screen('GetWindowInfo');
        is_ready = true;
      catch
        is_ready = false;
      end %try
    end %function
    
    
    function [varargout] = screen(obj, command, varargin)
      % Shortcut for the PTB Screen functions.
      %
      % It allows you to call all the PTB Screen function that need a
      % windowPtr as their first parameter. Instead of providing it
      % yourself, it gets inserted automatically. The rest of the
      % parameters and return values is exactly the same.
      
      if isempty(obj.win_handle)
        error('The screen is not initialized. Please call the setup_screen method');
      end %if
      
      varargout = cell(1, obj.screen_cmd_argout_map(command));
      [varargout{:}] = Screen(command, obj.win_handle, varargin{:});
      
      if strcmp(command, 'Flip') && obj.play_on_next_flip
        if ~isempty(obj.audio_subsystem)
          obj.audio_subsystem.on_play_on_flip(varargout);
        end %if
        
        if ~isempty(obj.trigger_subsystem)
          obj.trigger_subsystem.on_fire_on_flip(varargout);
        end %if
        
        if ~isempty(obj.tactile_subsystem)
          obj.tactile_subsystem.on_play_on_flip(varargout);
        end %if
        obj.play_on_next_flip = false;
      end %if
    end %function
    
    function result = has_datapixx(obj)
      if obj.ptb_config.disable_datapixx
        obj.has_datapixx_cached = false;
      end %if
      
      result = obj.has_datapixx_cached;
      
      if isempty(obj.has_datapixx_cached)
        try
          Datapixx('Open');
          if Datapixx('IsReady')
            result = true;
          else
            result = false;
          end %if
        catch
          result = false;
        end %try
        
      end %if
      
      obj.has_datapixx_cached = result;
      
      if ~result && obj.ptb_config.force_datapixx
        error('Datapixx was not found. We would normally continue but you set force_datapixx to true so we stop with an error');
      end %if
    end %function
    
    
    function cfg = get_config(obj)
      cfg = copy(obj.ptb_config);
    end %function
    
    
    function delete(obj)
      obj.deinit();
    end %function
  end %public methods declarations
  
  
  methods
    function p = get.base_path(obj)
      p = fileparts(fileparts(mfilename('fullpath')));
    end %function
    
    
    function p = get.assets_path(obj)
      p = fullfile(obj.base_path, 'assets');
    end %function
  end %getter/setter methods
  
  
  methods (Access = protected)
    function draw_border(obj, thickness)
      obj.screen('FrameRect', o_ptb.constants.PTB_Colors.black, [], thickness);
    end %function
  end %protected methods
  
  
  methods (Access = protected, Static)
    function lab_pc = is_lab_pc()
      envvar = o_ptb.internal.EnvVarConfig(false, 'O_PTB_IS_LAB_PC');
      legacy_lab_pc = strcmp(gethostname(), 'TestPC') || strcmp(gethostname(), 'VPIXX-HP');
      
      lab_pc = envvar.evaluate() || legacy_lab_pc;
    end %function
  end %static protected methods
  
  
  properties (Access = private)
    screen_cmd_argout_map;
    has_datapixx_cached;
    play_on_next_flip = false;
    audio_subsystem;
    trigger_subsystem;
    response_subsystem;
    tactile_subsystem;
    eyetracker_subsystem;
    audio_background_object;
    audio_background_running;
  end %properties
  
  
  methods (Access = private)
    function obj = PTB(ptb_config)
      % Create an instance of the PTB class.
      % You need to supply an instance of <a href="matlab:help
      % o_ptb.PTB_Config">o_ptb.PTB_Config</a> in order to create the
      % instance like this:
      %
      %    ptb_config = o_ptb.PTB_Config();
      %    ptb_config.fullscreen = false;
      %    % add more configuration here...
      %
      %    ptb = o_ptb.PTB(ptb_config);
      
      try
        if isempty(Screen('Screens'))
          error('PTB does not provide any screens.');
        end %if
      catch
        error('PTB was not found in your path. You can use o_ptb.init_ptb to do that for you!');
      end %try
      
      ptb_config = copy(ptb_config);
      
      if ~ptb_config.is_valid()
        error('Please supply a valid PTB_Config instance');
      end %if
      
      obj.ptb_config = ptb_config;
      obj.create_screen_cmd_argout_map;
      obj.triggers_initialized = false;
      obj.using_datapixx_video = false;
      obj.audio_background_object = [];
      obj.audio_background_running = false;
      
    end %function
    
    
    function create_screen_cmd_argout_map(obj)
      obj.screen_cmd_argout_map = containers.Map();
      
      all_cmds = obj.get_all_screen_cmds();
      
      for i = 1:length(all_cmds)
        obj.screen_cmd_argout_map(all_cmds{i}) = obj.get_screen_nargout(all_cmds{i});
      end %for
    end %function
  end %private methods
  
  
  methods (Access = private, Static)
    function nargout = get_screen_nargout( command )
      nargout = 0;
      call = sprintf('Screen(''%s?'')', command);
      raw_text = strsplit(evalc(call), '\n');
      
      for i = 1:length(raw_text)
        if ~isempty(strfind(raw_text{i}, '=')) && ~isempty(strfind(raw_text{i}, command))
          tokenized = strsplit(raw_text{i}, '=');
          token = tokenized{1};
          token(strfind(token, '[')) = [];
          token(strfind(token, ']')) = [];
          nargout = length(strsplit(strtrim(token), {' ', ','}));
          return;
        end %if
      end %for
    end %function
    
    
    function screen_cmds = get_all_screen_cmds()
      screen_cmds = {};
      
      raw_text = strsplit(evalc('Screen'), '\n');
      
      for i = 1:length(raw_text)
        if strfind(raw_text{i}, 'Screen(''')
          tokenized = strsplit(raw_text{i}, '''');
          screen_cmds{end+1} = tokenized{2};
        end %if
      end %for
    end %function
  end % private static methods
end
