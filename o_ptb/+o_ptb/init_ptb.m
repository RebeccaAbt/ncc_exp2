function init_ptb(ptb_folder)
% Initialize ``o_ptb``.
%
% Parameters
% ----------
%
% ptb_folder : string, optional
%   Path to the Psychtoolbox folder. If this is not provided, the 
%   environment variable "O_PTB_PTB_FOLDER" will be used if set. Otherwise
%   the current folder and all subfolder will be searched for an installation.

%Copyright (c) 2016-2017, Thomas Hartmann
%
% This file is part of the o_ptb class library, see: https://gitlab.com/thht/o_ptb
%
%    o_ptb is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    o_ptb is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with obob_ownft. If not, see <http://www.gnu.org/licenses/>.
%
%    Please be aware that we can only offer support to people inside the
%    department of psychophysiology of the university of Salzburg and
%    associates.

% look for Psychtoolbox installations in the working folder...

if nargin == 1
  ptb_setup_files = rdir(fullfile(ptb_folder, '**', 'SetupPsychtoolbox.m'));
elseif ~isempty(getenv('O_PTB_PTB_FOLDER'))
  ptb_setup_files = rdir(fullfile(getenv('O_PTB_PTB_FOLDER'), '**', 'SetupPsychtoolbox.m'));
else
  ptb_setup_files = rdir(fullfile('**', 'SetupPsychtoolbox.m'));
end %if

if isempty(ptb_setup_files)
  error('No PTB installation found.');
end %if

if length(ptb_setup_files) > 1
  error('More than one PTB installation found under your current working directory.');
end %if

tmp = fileparts(ptb_setup_files(1).name);
if strcmp(tmp(1), '/') || strcmp(tmp(2:3), ':\') || strcmp(tmp(2:3), ':/')
  ptb_folder = tmp;
else
  ptb_folder = fullfile(cd, tmp);
end %if

addpath(genpath(ptb_folder));

if ispc
  addpath(fullfile(ptb_folder, 'PsychBasic', 'MatlabWindowsFilesR2007a'));
end %if

KbName('UnifyKeyNames');

% add datapixx driver folder

o_ptb_root_folder = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(o_ptb_root_folder, 'datapixx'));
addpath(fullfile(o_ptb_root_folder, 'datapixx/eyetracker'));
addpath(fullfile(o_ptb_root_folder, 'external', 'lj_python_matlab'));
addpath(fullfile(o_ptb_root_folder, 'external', 'vocoder'));

if IsLinux
  hidden_dpx_dir = fullfile(o_ptb_root_folder, '.datapixx');
  
  if exist(hidden_dpx_dir)
    system(sprintf('rm -r %s', hidden_dpx_dir));
  end %if
  
  mkdir(hidden_dpx_dir);
  
  
  which_dp = '';
  
  lib_paths = {'/usr/lib', '/usr/lib64'};
  
  for idx_lp = 1:length(lib_paths)
    cur_lib_path = lib_paths{idx_lp};
    
    [~, rval] = system(sprintf('find %s -name libgsl.so.19', cur_lib_path));
    
    if contains(rval, 'libgsl.so.19')
      which_dp = 'xenial';
    end %if
    
    [~, rval] = system(sprintf('find %s -name libgsl.so.23', cur_lib_path));
    
    if contains(rval, 'libgsl.so.23')
      which_dp = 'bionic';
    end %if
  end %for
  
  if isempty(which_dp)
    warning('Cannot find the GSL library that is supported by the Datapixx mex files. Datapixx might not work and give strange errors.');
    which_dp = 'bionic';
  end %if
  
  [~, has_vpixxserver] = system('pidof vpixxdeviceserver');
  
  if isempty(has_vpixxserver)
    which_dp = sprintf('%s_noserver', which_dp);
  end %if
  
  system(sprintf('ln -s %s %s', fullfile(o_ptb_root_folder, 'datapixx', sprintf('Datapixx_%s.mexa64', which_dp)), fullfile(hidden_dpx_dir, 'Datapixx.mexa64')));
  
  addpath(hidden_dpx_dir);
  
end %if

end
