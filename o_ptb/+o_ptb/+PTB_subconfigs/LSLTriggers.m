classdef LSLTriggers < o_ptb.base.Config
  % Configuration options for LabStreamingLayer based triggering.
  %
  % Please be aware that you need to explicitly request using this system
  % because it is impossible to automatically determine whether it should
  % be used as it is not hardware based.
  %
  % You also need to have a current version of liblsl-Matlab
  % (https://github.com/labstreaminglayer/liblsl-Matlab) that you also need
  % to configure and compile the mex files for your system.
  %
  % Attributes
  % ----------
  %
  % liblsl_matlab_path : string
  %   The full path to liblsl-Matlab.
  %
  % trigger_type : string
  %   Triggers can be sent as strings like ``<MARKER>#code</MARKER>`` or as
  %   32bit integers. If you want strings, set this to ``string``, otherwise
  %   to ``int``. Default: ``string``.
  %
  % stream_id : string
  %   ID of the LSL stream. Default: ``o_ptb_marker_stream``.
  
  %Copyright (c) 2016-2020, Thomas Hartmann
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
  
  
  properties (Access = public, SetObservable = true)
    liblsl_matlab_path = '';
    trigger_type = 'string';
    stream_id = 'o_ptb_marker_stream';
  end %properties
end

