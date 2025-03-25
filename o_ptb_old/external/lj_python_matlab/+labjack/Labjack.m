classdef Labjack < handle
  %LABJACK Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Access=public, Constant)
    ChannelGroup = struct('FIO', 0, 'EIO', 1, 'CIO', 2);
    TriggerMethod = struct('SINGLE', 0, 'MULTI', 1, 'PULSEWIDTH', 2);
  end %properties
  
  properties (Access=protected)
    lj;
  end
  
  methods
    function obj = Labjack(channel_group, method, single_channel, num_bits)
      obj.prepare_python();
      
      if nargin < 2
        method = labjack.Labjack.TriggerMethod.MULTI;    
      end %if
      
      if nargin < 3
        single_channel = py.None;
      end %if
      
      if nargin < 4
        num_bits = py.None;
      end %if
      
      obj.lj = py.th_py_labjack.LabjackTrigger(py.th_py_labjack.ChannelGroup(channel_group), py.th_py_labjack.TriggerMethod(method), int32(single_channel), int32(num_bits));
    end %function
    
    function delete(obj)
      delete(obj.lj);
    end %if
    
    function prepare_trigger(obj, trigger, delay)
      obj.lj.prepare_trigger(int32(trigger), delay);
    end %function
    
    function fire_trigger(obj)
      obj.lj.fire_trigger();
    end %function
    
    function reset(obj)
      obj.lj.reset();
    end %function
  end
  
  methods (Static)
    function rval = has_labjack()
      try
        labjack.Labjack.prepare_python()
        rval = py.th_py_labjack.has_labjack();
      catch
        rval = false;
      end %try
    end %function
  end %static methods
  
  methods (Static, Access=private)
    function prepare_python()
      clear py;
      lj_toolbox_path = fileparts(fileparts(mfilename('fullpath')));
      labjackpython_path = fullfile(lj_toolbox_path, 'python', 'LabJackPython', 'src');
      th_py_python_path = fullfile(lj_toolbox_path, 'python', 'th');
      enum34_python_path = fullfile(lj_toolbox_path, 'python', 'enum34');
      
      append(py.sys.path, labjackpython_path);
      append(py.sys.path, th_py_python_path);
      append(py.sys.path, enum34_python_path);
    end %function
    
  end
end
