classdef (Abstract) TextureBase < o_ptb.stimuli.visual.Base
  % Base class for all texture based stimuli.
  %
  % Attributes
  % ----------
  %
  %   rotate : float
  %     Rotation of the stimulus in degrees.
  %
  % This class provides all methods of :class:`+o_ptb.+stimuli.+visual.Base`.

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
    texture_id;
    gl_operator;
  end

  properties (Access = public, SetObservable = true)
    rotate = 0;
  end %public properties

  methods (Access = protected)
    function draw_texture(obj, ptb)
      ptb.screen('DrawTexture', obj.texture_id, [], obj.destination_rect, obj.rotate);
    end %function
  end %protected methods

  methods (Access = public)
    function rect = get_rect(obj)
      rect = Screen('Rect', obj.texture_id);
    end %function

    function on_draw(obj, ptb)
      if ~isempty(obj.gl_operator)
        new_texture = Screen('TransformTexture', obj.texture_id, obj.gl_operator);
        Screen('Close', obj.texture_id);
        obj.texture_id = new_texture;
      end %if

      obj.draw_texture(ptb);
    end %function


    function add_gauss_blur(obj, stdev, kernel_size)
      % Add gaussian blur to the stimulus.
      %
      % Blur the image with a guassian kernel.
      %
      % Parameters
      % ----------
      %
      % stdev : float
      %   Standard deviation of the gaussian kernel.
      %
      % kernel_size : int
      %   Size of the kernel.
      
      ptb = o_ptb.PTB.get_instance();

      kernel = fspecial('gaussian',[1 kernel_size], stdev);
      kernel = kernel ./ sum(kernel(:));

      if max(kernel) / kernel(1) < 3
        warning('kernel_size might be too small for this stdev.');
      end %if

      gauss_blur = CreateGLOperator(ptb.win_handle);
      Screen('HookFunction', gauss_blur, 'ImagingMode', mor(kPsychNeed16BPCFloat, Screen('HookFunction', gauss_blur, 'ImagingMode')));
      Add2DSeparableConvolutionToGLOperator(gauss_blur, kernel, kernel', [], [], [], [], 0);

      obj.gl_operator = gauss_blur;
    end %function
  end

end
