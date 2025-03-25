function save_path_config( location )
% saves the current o_ptb path config at the given location.
%
% location can be one of the following:
%    'cur_folder'     : save the configuration in the current folder
%    'home_cfg'       : save the configuration in %HOME/.o_ptb/

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

if nargin < 1
  location = 'cur_folder';
end %if

cfg_filename = 'o_ptb_paths.mat';
hostname = matlab.lang.makeValidName(char(java.net.InetAddress.getLocalHost().getHostName()));
user_home = char(java.lang.System.getProperty('user.home'));

if strcmp(location, 'cur_folder')
  f_name = fullfile(pwd, cfg_filename);
elseif strcmp(location, 'home_cfg')
  f_name = fullfile(user_home, '.o_ptb', cfg_filename);
  if ~exist(fullfile(user_home, '.o_ptb'))
    mkdir(fullfile(user_home, '.o_ptb'));
  end %if
else
  error('Please provide a valid value for location.');
end %if

if exist(f_name)
  path_info = load(f_name);
else
  path_info = [];
end %if

this_pathinfo.o_ptb = fileparts(fileparts(which('o_ptb.PTB')));
this_pathinfo.ptb = fileparts(fileparts(fileparts(which('Screen'))));

path_info.(hostname) = this_pathinfo;

save(f_name, '-struct', 'path_info');
end

