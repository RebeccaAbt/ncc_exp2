classdef Base < handle & matlab.mixin.Copyable
  % Base class for tactile stimuli.
  %
  % As opposed to all the other base classes, this one can be used directly.
  %
  % For details how to do tactile stimulation, refer to the
  % :doc:`respective tutorial </tutorial/o_ptb/tactile>`.
  %
  % Parameters
  % ----------
  %
  % stimulator : string
  %   Mapped name of the stimulator to use.
  %
  % finger : int
  %   Finger to stimulate.
  %
  % amplitude : int
  %   Amplitude at which to stimulate. Range is 0 to 256.
  %
  % frequency : float
  %   Stimulation frequency.
  %
  % duration : float
  %   Duration of the stimulation in seconds.
  %
  % phase : float, optional
  %   Initial phase of the stimulation oscillation.

  properties (Access = public)
    stimulator;
    finger;
    amplitude;
    frequency;
    duration;
    phase = 0;
  end

  methods (Access = public)
    function obj = Base(stimulator, finger, amplitude, frequency, duration, phase)
      if nargin >= 1
        obj.stimulator = stimulator;
      end %if

      if nargin >= 2
        obj.finger = finger;
      end %if

      if nargin >=3
        obj.amplitude = amplitude;
      end %if

      if nargin >=4
        obj.frequency = frequency;
      end %if

      if nargin >= 5
        obj.duration = duration;
      end %if

      if nargin >= 6
        obj.phase = phase;
      end %if
    end %function
  end %methods

end
