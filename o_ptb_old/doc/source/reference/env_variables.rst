Environment Variables
=====================

Certain aspects of the ``o_ptb`` can be preconfigured by setting so-called environment
variables. On Windows, you can set these in the System Settings. On Mac and Linux you
do this in the bashrc or zshrc file.

General Configuration
---------------------

.. envvar:: O_PTB_PTB_FOLDER

  The location of the Psychtoolbox_.

.. envvar:: O_PTB_USE_DECORATED_WINDOW

  Use decorated windows for the PTB screen when not run in fullscreen mode.

.. envvar:: O_PTB_IS_LAB_PC

  You should set this variable to ``true`` on a Stimulation PC in a lab. This will
  lead so a warning if an experiment is run in debug mode.

Sound Configuration
-------------------

.. envvar:: O_PTB_PSYCHPORTAUDIO_DEVICE

  The PortAudio device number to use.

.. envvar:: O_PTB_PSYCHPORTAUDIO_SFREQ

  The sampling frequency of the device when using PortAudio.


.. include:: ../links.rst
