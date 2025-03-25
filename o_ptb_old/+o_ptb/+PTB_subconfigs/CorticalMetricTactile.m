classdef CorticalMetricTactile < o_ptb.base.Config
  % Configuration for the CorticalMetrics Tactile Stimulator.
  %
  % See :doc:`/tutorial/o_ptb/tactile` for details how to use it.
  %
  % Attributes
  % ----------
  %
  % cm_dll : string
  %   Full path to the CM.dll.
  %
  % stimulator_mapping : containers.Map
  %   Maps an arbitrary name to the serial number of the stimulator.
  %
  % trigger_mapping : containers.Map
  %   Maps the name give at :attr:`stimulator_mapping` to the trigger port
  %   The device is connected to.

  properties (Access = public, SetObservable = true)
    cm_dll;
    stimulator_mapping = containers.Map();
    trigger_mapping = containers.Map();
  end


end
