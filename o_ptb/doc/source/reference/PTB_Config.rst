PTB_Config
==========

.. automodule:: +o_ptb

:class:`PTB_Config` is the main configuration class for ``o_ptb``.
In your code, you would create an instance of this class like this:

.. code-block::

   ptb_cfg = o_ptb.PTB_Config();

Then you can use ptb_cfg like a structure with the only difference that all the
fields are already in there. If, for instance, you want to run the
experiment in window mode, you need to do:

.. code-block::

   ptb_cfg.fullscreen = false;
   ptb_cfg.window_scale = 0.2;

:class:`PTB_Config` only contains only a small subset of the available options.
The configuration of the subsystems is done via subconfigs.

.. contents::
  :local:

Basic Configuration
-------------------

.. autoclass:: PTB_Config
    :members:

Audio Configuration
-------------------

.. autoclass:: +o_ptb.+PTB_subconfigs.DatapixxAudio
.. autoclass:: +o_ptb.+PTB_subconfigs.PsychPortAudio

Trigger Configuration
---------------------

.. autoclass:: +o_ptb.+PTB_subconfigs.LabjackTriggers
.. autoclass:: +o_ptb.+PTB_subconfigs.LSLTriggers

Response Configuration
----------------------

.. autoclass:: +o_ptb.+PTB_subconfigs.DatapixxResponse
.. autoclass:: +o_ptb.+PTB_subconfigs.KeyboardResponse

Eyetracker Configuration
------------------------

.. autoclass:: +o_ptb.+PTB_subconfigs.DatapixxTrackPixx

Tactile Configuration
---------------------

.. autoclass:: +o_ptb.+PTB_subconfigs.CorticalMetricTactile

Defaults for certain stimuli
----------------------------

.. autoclass:: +o_ptb.+PTB_subconfigs.Defaults

o_ptb Internals
---------------

.. autoclass:: +o_ptb.+PTB_subconfigs.PTBInternal

.. include:: ../links.rst
