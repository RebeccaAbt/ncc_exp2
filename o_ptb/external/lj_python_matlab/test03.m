%% clear
clear all global
restoredefaultpath

%% get device....
lj = labjack.Labjack(labjack.Labjack.ChannelGroup.FIO, labjack.Labjack.TriggerMethod.PULSEWIDTH, 0, 5);