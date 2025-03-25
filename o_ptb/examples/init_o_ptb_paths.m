function init_o_ptb_paths(force_o_ptb_path)
% tries to find a configuration file and initializes the paths.
% This function searches for a file called 'o_ptb_paths.mat' at the
% following locations:
%    1. The current folder
%    2. The userpath
%    3. A folder called '.o_ptb' in the home folder
%    4. The home folder
%
% If you want to force a specific o_ptb path, you can do so by supplying
% that path as the argument to this function...

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
  force_o_ptb_path = [];
end %if

cfg_filename = 'o_ptb_paths.mat';
hostname = matlab.lang.makeValidName(char(java.net.InetAddress.getLocalHost().getHostName()));
user_home = char(java.lang.System.getProperty('user.home'));

all_folders = {
  pwd;
  userpath;
  fullfile(user_home, '.o_ptb');
  user_home;
  };

path_info = [];
for idx_folder = 1:length(all_folders)
  cur_folder = all_folders{idx_folder};
  if exist(fullfile(cur_folder, cfg_filename))
    path_info = load(fullfile(cur_folder, cfg_filename));
  end %if
end %for

if isempty(path_info)
  error('No path configuration found at any location. Maybe you first need to generate one?');
end %if

restoredefaultpath
this_pathinfo = path_info.(hostname);

if isempty(force_o_ptb_path)
  addpath(this_pathinfo.o_ptb);
else
  addpath(force_o_ptb_path);
end %if
o_ptb.init_ptb(this_pathinfo.ptb);

end

