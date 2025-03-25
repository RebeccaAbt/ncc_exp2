How to get responses
====================

Unifying the way how to get responses from the Datapixx (when present) and the keyboard (when the Datapixx is not present) is a little tricky because the response pad of the Datapixx has 4 buttons with different colors while your keyboard has keys.

To get around this issue, o_ptb does something called "button mapping". This means that you define a response, give it a name and assign a Datapixx button and a keyboard key to it.

This is done during the configuration process:

.. code-block::

   %% get a configuration object
   ptb_cfg = o_ptb.PTB_Config();

   %% configure button mappings
   ptb_cfg.datapixxresponse_config.button_mapping('target') = ptb_cfg.datapixxresponse_config.Green;
   ptb_cfg.keyboardresponse_config.button_mapping('target') = KbName('space');

   ptb_cfg.datapixxresponse_config.button_mapping('other_target') = ptb_cfg.datapixxresponse_config.Red;
   ptb_cfg.keyboardresponse_config.button_mapping('other_target') = KbName('RightShift');

We define two responses here called "target" and "other_target". We the assign keys and buttons to it.

You can assign the same button or key to multiple targets!

You can then use the :meth:`ptb.wait_for_keys <+o_ptb.PTB.wait_for_keys>` function to wait until one or both responses are issued. For example:

.. code-block::

   ptb.wait_for_keys('target', GetSecs+1)

This line waits up to one second for a press of the "target" response. So, if you have a Datapixx, it will wait for the green button to be pressed. If not, it waits for the space key.

The function returns instantly as soon as the response is pressed. It returns a cell of the responses issued during the call. If no response was given, it returns after the timeout and returns an empty cell.

You can also wait for multiple responses at the same time:

.. code-block::

   ptb.wait_for_keys({'target', 'other_target'}, GetSecs+10)

.. include:: ../../links.rst
