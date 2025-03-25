%% clear
clear all global
restoredefaultpath

%% get device
x = labjack.Labjack.get_instance;

%% fire...
x.prepare_trigger(255, 'EIO', 20e-3);
x.fire_trigger