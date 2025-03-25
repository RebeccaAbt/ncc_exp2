classdef CorticalMetricsStimulator < o_ptb.subsystems.tactile.Base
  %CORTICALMETRICS Summary of this class goes here
  %   Detailed explanation goes here
 
  properties (Access=protected)
%   -------------------------------------------
%   properties (Access=public)
%   -------------------------------------------
    init_done = false;
    stimulators;
    stim_chains;
    raw_stimchain;
    
  end %properties
  
  properties (GetAccess = public, SetAccess = protected)
    
  end
  
  properties (Access = protected)
    is_scheduled;
  end %properties
  
  methods (Static)
    function serial_numbers = get_serial_numbers(ptb_config)
      dll_path = fileparts(mfilename('fullpath'));
      NET.addAssembly(fullfile(dll_path, 'CM_Wrapper.dll'));
      NET.addAssembly(ptb_config.corticalmetrics_config.cm_dll);
      
      serial_numbers = cell(th_CM.CM_Wrapper.GetSerialNumbers());
    end %function
    
    function reset_all(ptb_config)
      dll_path = fileparts(mfilename('fullpath'));
      NET.addAssembly(fullfile(dll_path, 'CM_Wrapper.dll'));
      NET.addAssembly(ptb_config.corticalmetrics_config.cm_dll);
      
      th_CM.CM_Wrapper.ResetAll();
    end %function
    
    function rval = is_present()
      rval = false;
      
      if ~ispc
        warning('Cortical Metrics stimulators can only be used on windows systems');
        return;
      end %if
      
      ptb = o_ptb.PTB.get_instance();
      ptb_config = ptb.get_config();
      
      if ~exist(ptb_config.corticalmetrics_config.cm_dll)
        warning('Cortical Metrics stimulator DLL not found');
        return;
      end %if
      
      dll_path = fileparts(mfilename('fullpath'));
      NET.addAssembly(fullfile(dll_path, 'CM_Wrapper.dll'));
      NET.addAssembly(ptb_config.corticalmetrics_config.cm_dll);
      th_CM.CM_Wrapper.ResetAll();
      tmp_stims = th_CM.CM_Wrapper.GetAllStimulators();
      
      if tmp_stims.Length == 0
        warning('No Cortical Metric Stimulators found');
        return;
      end %if
      
      rval = true;
    end %function
  end %static methods
  
  methods (Access = public)
    function obj = CorticalMetricsStimulator(ptb_config)
      obj@o_ptb.subsystems.tactile.Base(ptb_config);
      try
        dll_path = fileparts(mfilename('fullpath'));
        NET.addAssembly(fullfile(dll_path, 'CM_Wrapper.dll'));
        NET.addAssembly(ptb_config.corticalmetrics_config.cm_dll);
        th_CM.CM_Wrapper.ResetAll();
        tmp_stims = th_CM.CM_Wrapper.GetAllStimulators();
        
        if tmp_stims.Length == 0
          error('No Cortical Metric Stimulators found');
        end %if
        
        obj.stimulators = containers.Map('KeyType', 'char', 'ValueType', 'any');
        stim_mapping = ptb_config.corticalmetrics_config.stimulator_mapping;
        stim_mapping_keys = stim_mapping.keys;
        for idx_stim_key = 1:length(stim_mapping_keys)
          cur_key = stim_mapping_keys{idx_stim_key};
          cur_serial = stim_mapping(cur_key);
          
          for idx_raw_stimulator = 0:(tmp_stims.Length - 1)
            cur_stimulator = tmp_stims.Get(idx_raw_stimulator);
            lh = addlistener(cur_stimulator, 'CMEvent', @(o, e) fprintf('%s\n', char(e.message)));
            cur_stimulator.test_string;
            if strcmp(char(cur_stimulator.SerialNumber), cur_serial)
              cur_stimulator.UseInputTrigger = obj.stimulator_uses_triggers(cur_key);
              obj.stimulators(cur_key) = cur_stimulator;
            end %if
          end %for
          if ~obj.stimulators.isKey(cur_key)
            error('Could not find stimulator "%s". Make sure it is connected!', cur_key);
          end %if
        end %for
        
        obj.stim_chains = {};
        obj.setup_raw_stimchain();
      catch this_error
        th_CM.CM_Wrapper.ResetAll();
        rethrow(this_error);
      end %try
    end %function
    
    function delete(obj)
      th_CM.CM_Wrapper.ResetAll();
    end %function
    
    function init(obj)
      fprintf('CorticalMetrics Tactile System Initialized');
      obj.init_done = true;
    end %function
    
    function schedule(obj)
      ptb = o_ptb.PTB.get_instance;
      
      all_keys = obj.stimulators.keys;
      for idx_keys = 1:length(all_keys)
        cur_key = all_keys{idx_keys};
        cur_chain = CorticalMetrics.QuadStimulusChain;
        all_channels = fieldnames(obj.raw_stimchain.(cur_key));
        for idx_chan = 1:length(all_channels)
          cur_chan = all_channels{idx_chan};
          cur_stims = obj.raw_stimchain.(cur_key).(cur_chan);
          
          cur_time = 0;
          all_delays = sort(cell2mat(cur_stims.keys()));
          
          for idx_delay = 1:length(all_delays)
            cur_delay = all_delays(idx_delay);
            if cur_delay < cur_time
              error('Tactile Stimuli are overlapping. This is not supported');
            end %if
            
            if cur_delay > cur_time
              silent_stim = CorticalMetrics.StimulusLink(CorticalMetrics.Stimulus(0, 10, cur_delay - cur_time));
              cur_chain.(cur_chan).Add(silent_stim);
              cur_time = cur_time + silent_stim.Stimulus.Duration;
            end %if
            
            if cur_delay == cur_time
              cur_chain.(cur_chan).Add(cur_stims(cur_delay));
              cur_time = cur_time + cur_stims(cur_delay).Stimulus.Duration;
            end %if
          end %for
          
        end %for
        obj.stim_chains.(cur_key) = cur_chain;
        if obj.stimulator_uses_triggers(cur_key)
          cur_stimulator = obj.stimulators(cur_key);
          cur_stimulator.SubmitStimulus(obj.stim_chains.(cur_key));
          %WaitSecs(0.5);
          cur_stim_trigger = ptb.get_config().corticalmetrics_config.trigger_mapping(cur_key);
          ptb.prepare_trigger(cur_stim_trigger, 0, true);
          %ptb.schedule_trigger();
        end %if
      end %for
      
      if obj.any_stimulator_uses_triggers()
        %obj.send_to_stimulators();
        ptb.schedule_trigger();
      end %if
      
      obj.is_scheduled = true;
    end %function
    
    function prepare(obj, stim, delay)
      if nargin < 3
        delay = 0;
      end %if
      
      obj.raw_stimchain.(stim.stimulator).(sprintf('CH%d', stim.finger))(delay*1e3) = CorticalMetrics.StimulusLink(CorticalMetrics.Stimulus(stim.amplitude, stim.frequency, stim.duration*1e3));
    end %function
    
    function reset(obj)
      if obj.any_device_busy
        error('Cannot reset while at least one stimulator is still busy!');
      end %if
      obj.stim_chains = {};
      obj.setup_raw_stimchain();
      obj.is_scheduled = false;
    end %function
    
    function ready = is_ready(obj)
      ready = obj.init_done;
    end %function
    
    function play(obj)
      if ~obj.any_stimulator_uses_triggers()
        obj.send_to_stimulators();
      end %if
    end %function
    
    function on_play_on_flip(obj, screen_results)
      obj.play();
    end %function
    
    function n_fingers = get_n_fingers(obj)
      n_fingers = 4;
    end %function
    
    function wait_for_stimulators(obj)
      all_keys = obj.stimulators.keys;
      for idx_keys = 1:length(all_keys)
        cur_key = all_keys{idx_keys};
        cur_stimulator = obj.stimulators(cur_key);
        cur_stimulator.wait_for_stimulation();
      end %for
    end %function
  end
  
  methods (Access = protected)
    function setup_raw_stimchain(obj)
      obj.raw_stimchain = {};
      
      all_keys = obj.stimulators.keys;
      for idx_keys = 1:length(all_keys)
        cur_key = all_keys{idx_keys};
        obj.raw_stimchain.(cur_key).CH1 = containers.Map('KeyType', 'int64', 'ValueType', 'any');
        obj.raw_stimchain.(cur_key).CH2 = containers.Map('KeyType', 'int64', 'ValueType', 'any');
        obj.raw_stimchain.(cur_key).CH3 = containers.Map('KeyType', 'int64', 'ValueType', 'any');
        obj.raw_stimchain.(cur_key).CH4 = containers.Map('KeyType', 'int64', 'ValueType', 'any');
      end %for
    end %function
    
    function send_to_stimulators(obj)
      all_keys = obj.stimulators.keys;
      for idx_keys = 1:length(all_keys)
        cur_key = all_keys{idx_keys};
        cur_stimulator = obj.stimulators(cur_key);
        cur_stimulator.SubmitStimulus(obj.stim_chains.(cur_key));
        
        obj.is_scheduled = false;
      end %if
      
      if ~isempty(all_keys)
        WaitSecs(0.1);
      end %if
    end %function
    
    function rval = stimulator_uses_triggers(obj, stimulator_key)
      ptb = o_ptb.PTB.get_instance;
      rval = isKey(ptb.get_config().corticalmetrics_config.trigger_mapping, stimulator_key);
    end %function
    
    function rval = any_stimulator_uses_triggers(obj)
      all_keys = obj.stimulators.keys;
      rval = false;
      for idx_keys = 1:length(all_keys)
        cur_key = all_keys{idx_keys};
        
        rval = rval | obj.stimulator_uses_triggers(cur_key);
      end %for
    end %function
    
    function rval = any_device_busy(obj)
      all_keys = obj.stimulators.keys;
      rval = false;
      for idx_keys = 1:length(all_keys)
        cur_key = all_keys{idx_keys};
        cur_stimulator = obj.stimulators(cur_key);
        
        rval = rval | cur_stimulator.is_busy;
      end %for
    end %function
  end %methods
  
end

