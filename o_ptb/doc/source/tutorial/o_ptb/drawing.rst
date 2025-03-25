How to draw stuff on the screen
===============================

So, you have mastered the initialization and configuration of o_ptb. Now it's time to draw things on the screen.

Drawing using native Screen commands
------------------------------------

As I have stated before, you can use all the Psychtoolbox_ commands to draw stuff on the screen. The :func:`Screen` function needs the window_handle which you can get from the :class:`+o_ptb.PTB` instance:

.. code-block::

   Screen('FillRect', ptb.win_handle, [0 0 0], [200 200 300 300]);

The next thing you want to do to see you rectangle on the screen is a :code:`Screen('Flip')`.

**Screen('Flip') is the only command you MUST NOT USE!**

In order to get all the timing and added functionality right, you must do:

.. code-block::

   ptb.flip();

:meth:`ptb.flip() <+o_ptb.PTB.flip>` takes the same arguments as the ``Screen('Flip')`` function and also returns the same values.

So, if we want our rectangle to appear on the screen after one second and save the timestamp in a variable, we would need to do this:

.. code-block::

   Screen('FillRect', ptb.win_handle, [0 0 0], [200 200 300 300]);
   timestamp = ptb.flip(GetSecs()+1);

Using the o_ptb convenience function for ``Screen``
--------------------------------------------------------

o_ptb provides a convenience function for you so you do not have to always provide the window handle:

.. code-block::

   ptb.screen('FillRect', o_ptb.constants.PTB_Colors.white, [300 300 400 400]);
   timestamp = ptb.flip(GetSecs()+1);

You can use **all** drawing related ``Screen`` functions like this. The parameters are the same, except for the omission of the window_handle parameter. The return values are identical as well.

Drawing a o_ptb provided stimulus
----------------------------------

As another convenience, o_ptb also provides certain often-used visual stimuli that you can draw on the screen. These are provided as classes.

You can find the stimuli in the package :mod:`+o_ptb.stimuli.visual`. The easiest one is the fixation cross:

.. code-block::

   fix_cross = o_ptb.stimuli.visual.FixationCross();
   ptb.draw(fix_cross);
   ptb.flip();

So, you create an object of the stimulus class you want to draw. You call :meth:`ptb.draw <+o_ptb.PTB.draw>` to draw it and the you flip it.

Please note that you only need to create the stimulus object once. It can be used as often as you like!

Here is how you draw text:

.. code-block::

   hello_world = o_ptb.stimuli.visual.Text('Hello World!');
   ptb.draw(hello_world);
   ptb.flip();

The ``hello_world`` is an object that has some interesting properties:

.. code-block::

   >> hello_world

   hello_world =

     Text with properties:

                   size: 46.0000e+000
                  style: 0.0000e+000
                   font: 'Arial'
                     sx: 'center'
                     sy: 'center'
                 wrapat: 80.0000e+000
                  color: 0.0000e+000
               vspacing: 1.0000e+000
                   text: 'Hello World!'
       destination_rect: [0.0000e+000 0.0000e+000 1.9200e+003 1.0800e+003]

You can change those properties if you like. Let's say, you want to increase the size of the font:

.. code-block::

   hello_world.size = 90;
   ptb.draw(hello_world);
   ptb.flip();

There are many more stimuli provided by o_ptb:

.. code-block::

   gabor = o_ptb.stimuli.visual.Gabor(400);
   gabor.frequency = .01;
   gabor.sc = 60;
   gabor.contrast = 120;

   ptb.draw(gabor);
   ptb.flip();

You can also draw an image from an image file:

.. code-block::

   smiley = o_ptb.stimuli.visual.Image('smiley.png');

   ptb.draw(smiley);
   ptb.flip();

Ok, that one is a little big. So let's scale it:

.. code-block::

   smiley.scale(0.5);

   ptb.draw(smiley);
   ptb.flip();

We can also move the image:

.. code-block::

   smiley.move(150, 200);

   ptb.draw(smiley);
   ptb.flip();

.. include:: ../../links.rst
