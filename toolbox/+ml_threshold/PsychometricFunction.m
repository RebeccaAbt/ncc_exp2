classdef PsychometricFunction < handle
  %PSYCHOMETRICFUNCTION Summary of this class goes here
  %   Detailed explanation goes here
  
  properties(SetAccess=protected, GetAccess=public)
    mean;
    false_alarm;
    slope;
    p;
  end
  
  properties (Dependent)
    sweetpoint;
    sweetpoint_value;
  end %dependent properties
  
  methods
    function obj = PsychometricFunction(mean, false_alarm, slope)
      obj.mean = mean;
      obj.false_alarm = false_alarm;
      obj.slope = slope;
      obj.p = 1;
    end
    
    function val = get_value_from_p(obj, p)
      val = (log((obj.false_alarm - p) ./ (p - 1)) + obj.slope * obj.mean) / obj.slope;
    end %function
    
    function p = get_p_from_value(obj, val)
      p = obj.false_alarm + (1 - obj.false_alarm) * (1 ./ (1 + exp(-1 * obj.slope * (val - obj.mean))));
    end %function
    
    function sweetpoint = get.sweetpoint(obj)
      sweetpoint = (2 * obj.false_alarm + 1 + sqrt(1 + 8 * obj.false_alarm)) / (3 + sqrt(1 + 8 * obj.false_alarm));
    end %function
    
    function sweetpoint_val = get.sweetpoint_value(obj)
      sweetpoint_val = obj.get_value_from_p(obj.sweetpoint);
    end %function
    
    function process_response(obj, response, value)
      x = obj.get_p_from_value(value);
      if ~response
        x = 1 - x;
      end %if
      obj.p = obj.p * x;
    end %function
  end
end

