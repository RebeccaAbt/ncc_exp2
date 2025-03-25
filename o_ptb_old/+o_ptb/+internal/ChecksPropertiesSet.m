classdef (Abstract) ChecksPropertiesSet < handle
  %CHECKSPROPERTIES Summary of this class goes here
  %   Detailed explanation goes here
  
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
  
  properties (Access = protected)
    dont_check_properties = {};
  end %properties
  
  methods (Access = protected)
    function check_all_properties_set(obj)
      all_set = true;
      
      mclass = metaclass(obj);
      all_properties = mclass.PropertyList;
      
      for prop = all_properties'
        if strcmp(prop.SetAccess, 'public') && isempty(obj.(prop.Name)) && ~ismember(prop.Name, obj.dont_check_properties)
          all_set = false;
        end %if
        
        if ~all_set
          error('Some properties are missing...');
        end %if
      end
    end %function
  end %methods
end

