classdef EnvVarConfig < handle
  %UNTITLED Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    default;
    env_var;
  end
  
  methods
    function obj = EnvVarConfig(default, env_var)
      %UNTITLED Construct an instance of this class
      %   Detailed explanation goes here
      obj.default = default;
      obj.env_var = env_var;
    end
    
    function result = evaluate(obj)
      result = getenv(obj.env_var);
      if isempty(result)
        result = obj.default;
      elseif strcmpi(result, 'true') || strcmpi(result, 'false')
        result = strcmpi(result, 'true');
      else
        tmp = str2double(result);
        if ~isnan(tmp)
          result = tmp;
        end %if
      end %if
    end
  end
end

