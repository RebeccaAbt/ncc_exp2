Using the Eyetracker
====================

o_ptb currently supports controlling the TrackPixx eyetracker. For convenient
development, a dummy eyetracker is also provided that simulates calibration
and otherwise just writes messages to the console.

How to initialize and use the eyetracker
----------------------------------------

No extra configuration is required if you want to use the eyetracker. However,
you need to initialize as every other subsystem:

.. code-block::

   ptb.setup_eyetracker();

As at least the eye-position verification and the calibration process need to
use the screen, you also need to call
:meth:`ptb.setup_screen <+o_ptb.PTB.setup_screen>`:

.. code-block::

   ptb.setup_eyetracker();
   ptb.setup_screen();

.. note::

   Please be aware that calibrating the eye tracker only makes sense if the
   screen is set to fullscreen!

The next step is to verify the positions of the eyes in the camera of the
eye tracker. The TrackPixx system also requires you to tell it, where the
left and the right eye is. Just follow the instructions on the screen.

.. code-block::

   ptb.eyetracker_verify_eye_positions();

Next, we need to calibrate the eye tracker:

.. code-block::

   ptb.eyetracker_calibrate()

Data acquisition and forwarding of the eye positions to the MEG is started by:

.. code-block::

   ptb.start_eyetracker();

When the experiment has finished, stop the eyetracker using:

.. code-block::

   ptb.stop_eyetracker();

And save the acquired data:

.. code-block::

   ptb.save_eyetracker_data('eyetracker_data.mat');
