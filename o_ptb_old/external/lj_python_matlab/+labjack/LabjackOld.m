classdef LabjackOld < handle
  %LABJACK Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Access=protected)
    device;
  end %properties
  
  methods (Access=private)
    function obj = Labjack()
      obj.prepare_python();
      obj.setup_device();
      
    end %function
  end %methods
  
  methods (Static)
    function instance = get_instance()
      persistent local_instance
      
      if isempty(local_instance)
        local_instance = labjack.Labjack();
      end %if
      
      instance = local_instance;
      instance.setup_device();
    end %function
  end %static methods
  
  methods
    
    function delete(obj)
      fprintf('deleting\n');
      close(obj.device);
    end %function
    
    function dev = get_device(obj)
      dev = obj.device;
    end %function
    
    function prepare_trigger(obj, value, channels, duration)
      fio = 0;
      eio = 0;
      cio = 0;
      
      if strcmp(channels, 'FIO')
        fio = value;
      elseif strcmp(channels, 'EIO')
        eio = value;
      elseif strcmp(channels, 'CIO')
        cio = value;
      else
        error('channels must be "EIO", "FIO" or "CIO"');
      end %if
      
      obj.current_trigger = py.list({obj.get_PortStateWrite(fio, eio, cio), obj.get_wait(duration), obj.get_PortStateWrite(0, 0, 0)});
    end %function
    
    function fire_trigger(obj)
      if length(obj.current_trigger) == 0
        error('No Triggers scheduled');
      end %if
      
      obj.device.getFeedback(obj.current_trigger);
      obj.current_trigger = py.list();
    end %function
  end
  
  methods (Access=private)
    function prepare_python(obj)
      clear py;
      lj_toolbox_path = fileparts(fileparts(mfilename('fullpath')));
      python_path = fullfile(lj_toolbox_path, 'LabJackPython', 'src');
      
      append(py.sys.path, python_path);
    end %function
    
    function setup_device(obj)
      if isempty(obj.device) || isa(obj.device.handle, 'py.NoneType')
        obj.device = py.u3.U3();
      end %if
      obj.device.configIO(pyargs('EIOAnalog', int32(0), 'FIOAnalog', int32(0)));
      obj.device.getFeedback(py.u3.PortDirWrite(py.list({int32(255), int32(255), int32(255)})));
      obj.device.getFeedback(obj.get_PortStateWrite(0, 0, 0));
      obj.current_trigger = py.list();
    end %function
    
    function command = get_PortStateWrite(obj, fio, eio, cio)
      command = py.u3.PortStateWrite(py.list({int32(fio), int32(eio), int32(cio)}));
    end %function
    
    function command = get_wait(obj, secs)
      smallest_wait_secs_short = 128e-6;
      smallest_wait_secs_long = 32e-3;
      
      if secs <= 256*smallest_wait_secs_short
        command = py.u3.WaitShort(int32(round(secs/smallest_wait_secs_short)));
      else
        command = py.u3.WaitLong(int32(round(secs/smallest_wait_secs_long)));
      end %if
    end %function
    
  end % private methods;
end

