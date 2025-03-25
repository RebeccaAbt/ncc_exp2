How to do Tactile Stimulation
=============================

The ``o_ptb`` supports tactile stimulation using corticalmetrics_ devices. The
general pattern is very similar to sending triggers and sounds.

.. note::

   In order to use the corticalmetrics_ devices, you need to obtain the
   ``CM.dll``. You should have received it from corticalmetrics_.

   If you work at Salzburg, you can also ask Thomas.

In order to use the device(s), you need to:

#. Connect it to the stimulation PC via USB.
#. Connect the trigger in BNC port to one of the Trigger channels of your
   acquisition setup.

Our experience tells us that the device is very accurate at starting the
stimulation when it receives a trigger. So we exploit this property by
having ``o_ptb`` send a trigger when you want to start the tactile stimulation.
The trigger gets recorded by the EEG/MEG and the device starts stimulating at
the same time.

So, we need to tell ``o_ptb`` three things:

#. Where is the ``CM.dll``. (See above)
#. What is the Serial Number of the stimulator we want to use. (This enables
   us to use more than one).
#. What trigger port is the stimulator connected to.

In order to facilitate handling multiple devices, we give it a name, too.
('left') in this example.

We do this during the configuration process:

.. code-block::

  ptb_cfg = o_ptb.PTB_Config();

  ptb_cfg.corticalmetrics_config.cm_dll = fullfile('C:\Users\exp\Documents\cm', 'CM.dll');
  ptb_cfg.corticalmetrics_config.stimulator_mapping('left') = 'CM6-XXXXXXXXXXXXXXXXXXXXXXXXX';
  ptb_cfg.corticalmetrics_config.trigger_mapping('left') = 128;

We need to initialize the respective subsystems. **The trigger subsystem must be
initialized first!**

.. code-block::

  ptb.setup_trigger;
  ptb.setup_tactile;

Now we can get tactile stimulation objects using
:class:`+o_ptb.+stimuli.+tactile.Base`

As you can see in the reference documentation, the class takes up to 6 parameters,
of which only the last is optional. We need to specify:

#. What stimulator to use.
#. What finger to stimulate.
#. At what amplitude to stimulate.
#. At what frequency to stimulate.
#. For how long.

Optionally, we can also set the phase of the stimulation oscillation.

So, to get a tactile stimulation object, stimulating the fourth finger at
full intensity and 30Hz for 1 second, this is what we need to do:

.. code-block::

  tactile_stim = o_ptb.stimuli.tactile.Base('left', 4, 256, 30, 1);

And then it is just the usual pattern of `prepare` and `schedule`:

.. code-block::

  ptb.prepare_tactile(tactile_stim);
  ptb.schedule_tactile();

  ptb.play_without_flip();

.. include:: /links.rst
