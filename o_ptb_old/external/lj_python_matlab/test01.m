%% clear
clear all global
restoredefaultpath

%% append path to labjackpython
append(py.sys.path, 'python/LabJackPython/src');

%% get device...
device = py.u3.U3();
device.configIO(pyargs('EIOAnalog', int32(0), 'FIOAnalog', int32(0)));

%% send test trigger
chan = 8;

device.getFeedback(py.list({py.u3.BitDirWrite(int32(chan), int32(1)), py.u3.BitStateWrite(int32(chan), int32(1)), py.u3.WaitLong(int32(32)), py.u3.BitStateWrite(int32(chan), int32(0))}));