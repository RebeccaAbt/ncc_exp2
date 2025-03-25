classdef ThresholdHunter < handle
  properties(SetAccess=protected, GetAccess=public)
    psych_functions = {};
    start_values;
    values_range;
    false_alarm_range;
    slopes_range;
    min_trials;
    max_trials;
    use_n_trials_for_stop;
    n_trials;
    guesses;
    responses;
    stimulated_values;
  end
  
  properties(Dependent)
    best_function;
    current_probe_value;
    current_guess;
    std_last_trials;
    stop_std;
    converged;
    stop;
    weighed_ps;
    raw_ps;
  end %dependend properties
  
  methods
    function obj = ThresholdHunter(start_values, values_range, false_alarm_range, slopes_range, min_trials, max_trials, use_n_trials_for_stop)
      if nargin < 5
        min_trials = 12;
      end %if
      
      if nargin < 6
        max_trials = 40;
      end %if
      
      if nargin < 7
        use_n_trials_for_stop = 6;
      end %if
      
      obj.start_values = start_values;
      obj.values_range = values_range;
      obj.false_alarm_range = false_alarm_range;
      obj.slopes_range = slopes_range;
      obj.min_trials = min_trials;
      obj.max_trials = max_trials;
      obj.use_n_trials_for_stop = use_n_trials_for_stop;
      obj.n_trials = 0;
      obj.guesses = [];
      obj.responses = [];
      obj.stimulated_values = [];
      
      for cur_val = obj.values_range(:)'
        for cur_fa = obj.false_alarm_range(:)'
          for cur_slope = obj.slopes_range(:)'
            obj.psych_functions{end+1} = ml_threshold.PsychometricFunction(cur_val, cur_fa, cur_slope);
          end %for
        end %for
      end %for
    end %function
    
    function best_f = get.best_function(obj)
      ps = cellfun(@(x) x.p, obj.psych_functions);
      [~, sortIdx] = sort(ps, 'descend');
      
      f_sorted = obj.psych_functions(sortIdx);
      
      best_f = f_sorted{1};
    end %function
    
    function current_probe_value = get.current_probe_value(obj)
      if (obj.n_trials + 1) <= length(obj.start_values)
        current_probe_value = obj.start_values(obj.n_trials + 1);
      else
        current_probe_value = obj.best_function.sweetpoint_value;
      end %if
    end %function
    
    function current_guess = get.current_guess(obj)
      current_guess = obj.best_function.mean;
    end %function
    
    function std_last_trials = get.std_last_trials(obj)
      if length(obj.guesses) < obj.use_n_trials_for_stop
        std_last_trials = nan;
      else
        std_last_trials = std(obj.guesses(end-obj.use_n_trials_for_stop+1:end));
      end %if
    end %function
    
    function stop_std = get.stop_std(obj)
      stop_std = abs(max(diff(obj.values_range)));
    end %function
    
    function converged = get.converged(obj)
      converged = obj.std_last_trials < obj.stop_std && obj.n_trials > length(obj.start_values);
    end %function
    
    function stop = get.stop(obj)
      stop = (obj.n_trials >= (obj.min_trials + length(obj.start_values)) & obj.converged) | obj.n_trials >= obj.max_trials;
    end %function
    
    function p = get.raw_ps(obj)
      p = cellfun(@(x) x.p, obj.psych_functions);
    end %function
    
    function wp = get.weighed_ps(obj)
      ps = cellfun(@(x) x.p, obj.psych_functions);
      wp = ps ./ sum(ps);
    end %function
    
    function process_response(obj, response, probed_value)
      if nargin < 3
        probed_value = obj.current_probe_value;
      end %if
      obj.n_trials = obj.n_trials + 1;      
      
      cellfun(@(x) x.process_response(response, probed_value), obj.psych_functions);
      
      obj.guesses(end+1) = obj.current_guess;
      obj.responses(end+1) = response;
      obj.stimulated_values(end+1) = probed_value;
    end %function
    
    function str = to_string(obj)
      str = sprintf('ThresholdHunter. Trial %d/%d\nCurrent guess: %d Current std: %d\n', obj.n_trials, obj.max_trials, obj.current_guess, obj.std_last_trials);
    end %for
  end
end

