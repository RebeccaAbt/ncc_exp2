classdef (Abstract) Config < o_ptb.internal.ChecksPropertiesSet & matlab.mixin.Copyable
  %BASE Summary of this class goes here
  %   Detailed explanation goes here
  %Copyright (c) 2016-2017, Thomas Hartmann
  
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
  
  methods (Access = public)
    function obj = Config()
      mclass = metaclass(obj);
      all_properties = mclass.PropertyList;
      
      for prop = all_properties'
        if ~strcmp(prop.SetAccess, 'none')
          obj.(prop.Name) = obj.evaluate_property(obj.(prop.Name));
        end %if
      end %for
    end %function
    
    function valid = is_valid(obj)
      valid = true;
      
      try
        obj.check_all_properties_set();
      catch
        valid = false;
      end %try
    end %function
  end %methods
  
  methods (Access = protected)
    function result = evaluate_property(obj, property)
      if isa(property, 'o_ptb.internal.EnvVarConfig')
        result = property.evaluate();
      elseif isempty(property)
        result = property;
      elseif iscell(property)
        for idx = 1:numel(property)
          property{idx} = obj.evaluate_property(property{idx});
          result = property;
        end %for
      elseif ~isscalar(property) && ismatrix(property)
        for idx = 1:numel(property)
          property(idx) = obj.evaluate_property(property(idx));
          result = property;
        end %for
      else
        result = property;
      end %if
    end %function
  end %methods
  
end

