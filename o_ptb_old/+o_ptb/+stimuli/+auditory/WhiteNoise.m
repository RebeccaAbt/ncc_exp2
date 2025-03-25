classdef WhiteNoise < o_ptb.stimuli.auditory.FromMatrix
  % White Noise stimulus.
  %
  % This class provides all methods of :class:`+o_ptb.+stimuli.+auditory.Base`.
  %
  % Parameters
  % ----------
  %
  % duration : float
  %   Duration in seconds.

  methods
    function obj = WhiteNoise(duration)
      srate = 96000;
      noise_mat = 2.*(rand(round(duration * srate), 1)-0.5);
      obj@o_ptb.stimuli.auditory.FromMatrix(noise_mat', srate);
    end %function
  end

end
