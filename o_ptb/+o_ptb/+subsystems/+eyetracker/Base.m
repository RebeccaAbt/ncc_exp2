classdef (Abstract) Base < handle
  % This is the base class for all eyetracker subsystems. In order to develop a new
  % subsystem, create a class that inherits from this one and override its
  % methods.
  %
  % Methods
  % =======
  %
  % verify_eye_positions()
  %   Show screen that helps the user position the eyes and adjust the camera.
  %
  % calibrate()
  %   Perform the calibration.
  %
  % get_position_on_screen()
  %   Get current position of the eyes in screen coordinates.
  %
  % start()
  %   Start the eyetracker.
  %
  % stop()
  %   Stop the eyetracker.
  %
  % save_data()
  %   Save eyetracker data to disk
  %
  % get_data()
  %   Return current eyetracker data
  %
  % reset()
  %   Reset the subsystem
  
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
  
  
  methods (Abstract, Access = public)
    verify_eye_positions(obj);
    calibrate(obj, out_folder);
    start(obj);
    stop(obj);
    save_data(obj, f_name);
    get_data(obj);
    reset(obj);
    get_position_on_screen(obj);
  end %abstract methods
  
end

