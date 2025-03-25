%% set paths
clear all global
restoredefaultpath

%dll_path = 'C:\Users\Andi\Desktop\NCC_exp1\somatosensory_stim\CM_Wrapper\CM_Wrapper\bin\Release';
dll_path = 'C:\Users\Andi\Desktop\NCC_exp1\CM\';
wrapper_path = 'C:\Users\Andi\Desktop\NCC_exp1\o_ptb\+o_ptb\+subsystems\+tactile\';

%% init dlls
NET.addAssembly(fullfile(wrapper_path, 'CM_Wrapper.dll'));
NET.addAssembly(fullfile(dll_path, 'CM.dll'));

%% are there stimulators?
th_CM.CM_Wrapper.ResetAll();
tmp_stims = th_CM.CM_Wrapper.GetAllStimulators();