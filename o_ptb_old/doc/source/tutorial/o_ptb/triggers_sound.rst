Using Triggers and Sound
========================

Triggers and Sound are handled entirely different from how you are used to. The reason for this is that depending on whether you want to use the Datapixx system or not, the commands you normally have to use are completely different. o_ptb changes this by providing a unified interface for you.

In fact, you do not need to worry whether a Datapixx is connected or not. o_ptb tries to find it at the beginning and if it is connected, it will use it. If not, it will automatically fall back to using PsychPortAudio for the sound and just print the triggers in the command window (for now).

This is the strength of abstraction: The user does not need to care whether a Datapixx is connected or not. The code will run in either case. And if you want to support other sound or trigger systems in the future, all you need to do is write a new class doing the low-level work and plug it into o_ptb.

Introduction to how Triggers and Sound works
--------------------------------------------

You might ask yourself, why Triggers and Sounds are both handled in this section. The answer is simple: o_ptb follows the way it is implemented in the Datapixx system. And for the Datapixx system, triggers and sounds are basically the same.

The Datapixx provides a buffer (i.e. some internal memory) to upload your sound data to. After you have done that, you can tell it to start playing that sound either at once or at the next flip. Triggers are basically handled like an additional channel to the sound. So you can also upload your trigger data and "play" it at once or at the next flip.

Initializing
------------

The code to initialize everything is really similar to what you already know:

.. code-block::

   %% clear
   clear all global
   restoredefaultpath

   %% add the path to o_ptb
   addpath('/home/th/git/o_ptb/') % change this to where o_ptb is on your system

   %% initialize the PTB
   o_ptb.init_ptb('/home/th/git_other/Psychtoolbox-3/'); % change this to where PTB is on your system

   %% get a configuration object
   ptb_cfg = o_ptb.PTB_Config();

   %% do the configuration
   ptb_cfg.fullscreen = false;
   ptb_cfg.window_scale = 0.2;
   ptb_cfg.skip_sync_test = true;
   ptb_cfg.hide_mouse = false;

   %% get o_ptb.PTB object
   ptb = o_ptb.PTB.get_instance(ptb_cfg);

   %% init audio and triggers
   ptb.setup_screen;
   ptb.setup_audio;
   ptb.setup_trigger;

You can see that the only real difference is these two lines:

.. code-block::

   ptb.setup_audio;
   ptb.setup_trigger;

Now we have our visual, audio and trigger system ready to use. Please note that it is not necessary to setup the visual system if you only want to present sounds and/or triggers. But we are going to need it later, so I leave it in.

Presenting a wav file
---------------------

In order to send sounds to the audio system, we need to get an object representing that sound. At the moment, o_ptb offers two kinds of audio stimuli: You can get it from a wav file or supply it via a matrix.

Let's keep it simple at first and load the wav file that you find in the folder:

.. code-block::

   my_sound = o_ptb.stimuli.auditory.Wav('da_40.wav');

Now we have the auditory stimulus object. In order to present it, we need to do a three step process:


#. Call :meth:`ptb.prepare_audio <+o_ptb.PTB.prepare_audio>` to tell o_ptb that you want to use it. You can call this function many times if you want to present multiple stimuli in a row.
#. Once you have prepared all you sound stimuli, you need to call :meth:`ptb.schedule_audio <+o_ptb.PTB.schedule_audio>`. This uploads all the sound data to the Datapixx or sound card and prepares everything to play it.
#. Tell o_ptb when to play it. Either use :meth:`ptb.play_on_flip <+o_ptb.PTB.play_on_flip>` to automatically play it the next time you call :meth:`ptb.flip <+o_ptb.PTB.flip>`. Or you can use :meth:`ptb.play_without_flip <+o_ptb.PTB.play_without_flip>` to play it at once.

Here is the code:

.. code-block::

   %% prepare sound
   ptb.prepare_audio(my_sound);

   %% schedule sound
   ptb.schedule_audio;

   %% play at once
   ptb.play_without_flip;

Presenting with a delay and two sounds in a row
-----------------------------------------------

:meth:`ptb.prepare_audio <+o_ptb.PTB.prepare_audio>` takes two additional parameters. The first is the delay in seconds after which to present the sound. So, if you want the sound to start 500ms after you called :meth:`ptb.play_without_flip <+o_ptb.PTB.play_without_flip>` or after the flip, you do this:

.. code-block::

   ptb.prepare_audio(my_sound, 0.5);
   ptb.schedule_audio;
   ptb.play_without_flip;

The third parameter allows you to prepare a second sound while holding the first. So, if you want to play the sound twice, once without delay and once after 600ms, you do this:

.. code-block::

   ptb.prepare_audio(my_sound);
   ptb.prepare_audio(my_sound, 0.6, true);

   ptb.schedule_audio;
   ptb.play_without_flip;

Create your own sounds
----------------------

If you do not want to load your sounds from a wav file but rather supply the data directly, you can use the :class:`+o_ptb.stimuli.auditory.FromMatrix` stimulus:

.. code-block::

   %% create a sine wave and make a sound object
   s_rate = 44100;
   freq = 440;
   amplitude = 0.1;
   duration = 1;

   sound_data = amplitude * sin(2*pi*(1:(s_rate*duration))/s_rate*freq);

   sin_sound = o_ptb.stimuli.auditory.FromMatrix(sound_data, s_rate);

   %% play it
   ptb.prepare_audio(sin_sound);
   ptb.schedule_audio;
   ptb.play_without_flip;

Adding triggers
---------------

Adding triggers is really easy and very similar to using sounds:

.. code-block::

   ptb.prepare_audio(my_sound);
   ptb.prepare_trigger(1);

   ptb.schedule_audio;
   ptb.schedule_trigger;

   ptb.play_without_flip;

:meth:`ptb.prepare_trigger <+o_ptb.PTB.prepare_trigger>` takes the same arguments as :meth:`ptb.prepare_audio <+o_ptb.PTB.prepare_audio>`. So you can do this:

.. code-block::

   ptb.prepare_audio(my_sound);
   ptb.prepare_trigger(1);

   ptb.prepare_audio(my_sound, 0.5, true);
   ptb.prepare_trigger(2, 0.5, true);

   ptb.schedule_audio;
   ptb.schedule_trigger;

   ptb.play_without_flip;

Playing sound and triggers when a visual stimulus appears
---------------------------------------------------------

Of course, you would like to synchronize the onset of your sounds and triggers to when some visual stimulus appears on the screen. This is done by using :meth:`ptb.play_on_flip <+o_ptb.PTB.play_on_flip>` instead of :meth:`ptb.play_without_flip <+o_ptb.PTB.play_without_flip>`. :meth:`ptb.play_on_flip <+o_ptb.PTB.play_on_flip>` does not do anything until you issue :meth:`ptb.flip <+o_ptb.PTB.flip>`:

.. code-block::

   hello_world = o_ptb.stimuli.visual.Text('Hello World!');
   ptb.draw(hello_world);

   ptb.prepare_audio(my_sound);
   ptb.prepare_trigger(1);

   ptb.prepare_audio(my_sound, 0.5, true);
   ptb.prepare_trigger(2, 0.5, true);

   ptb.schedule_audio;
   ptb.schedule_trigger;

   ptb.play_on_flip;

   ptb.flip(GetSecs + 1);

Things to keep in mind to keep the timing right
-----------------------------------------------

Some of the functions presented here take some time to run while others are very quick. For example, creating a stimulus object can take quite a long time. So it is a good idea to create all your stimulus objects after the initialization and **not** when running your trial.

It is also a good idea to call all the prepare and schedule functions in sections that are not time critical.

.. include:: ../../links.rst
