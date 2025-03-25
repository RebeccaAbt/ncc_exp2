Getting Started with o_ptb
===========================

Initializing o_ptb
-------------------

The initialization process of o_ptb includes the following steps:


#. Make sure your workspace and your path are clean.
#. Add the top-level folder of o_ptb to your path.
#. Use o_ptb to initialize PTB.
#. Configure o_ptb.
#. Create a :class:`+o_ptb.PTB` object which is the "manager object".
#. Initialize the subsystems (visual, audio, trigger, response) you need.

Make sure your workspace and your path are clean
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It is **really** important to start out with a clean Matlab path and workspace. A lot of problems can happen if you have multiple versions of Psychtoolbox_ in your path, just to give an example. So, I advise you to do this at the beginning of every script:

.. code-block::

   %% clear
   clear all global
   restoredefaultpath

Add the top-level folder of o_ptb to your path
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This should be an easy one for you:

.. code-block::

   %% add the path to o_ptb
   addpath('/home/th/git/o_ptb/') % change this to where o_ptb is on your system

This adds the top-level folder of o_ptb to your path. The only thing that is in there is actually a package called ``o_ptb``\ , which houses all the functions and classes.

Use o_ptb to initialize Psychtoolbox_
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Unfortunately, Psychtoolbox_ does not provide a nice initialization function for its paths like FieldTrip or obob_ownft. Fortunately, o_ptb provides such a function for you:

.. code-block::

   %% initialize the PTB
   o_ptb.init_ptb('/home/th/git_other/Psychtoolbox-3/'); % change this to where PTB is on your system

You see that we are calling the function called :func:`+o_ptb.init_ptb` in the package ``o_ptb``. You can also call that function without any argument in which case it will search your current path and subfolders for Psychtoolbox_. Another possibility is to set :envvar:`O_PTB_PTB_FOLDER` Environment Variable.

Configure o_ptb
^^^^^^^^^^^^^^^^

Next, we need to configure how o_ptb should behave. In order to do that, we need to get a PTB_Config object:

.. code-block::

   ptb_cfg = o_ptb.PTB_Config();

:class:`+o_ptb.PTB_Config` is a class, so this line creates an object of that class. If you just type ``ptb_cfg`` now on the command line, this is, what you will see:

.. code-block::

   >> ptb_cfg

   ptb_cfg =

     PTB_Config with properties:

                    fullscreen: 1
                  window_scale: 1.0000e+000
              draw_borders_sbg: 1
               flip_horizontal: 0
                    hide_mouse: 1
              background_color: 127.0000e+000
                skip_sync_test: 0
                force_datapixx: 0
                 crappy_screen: 0
         psychportaudio_config: [1×1 o_ptb.PTB_subconfigs.PsychPortAudio]
       keyboardresponse_config: [1×1 o_ptb.PTB_subconfigs.KeyboardResponse]
          datapixxaudio_config: [1×1 o_ptb.PTB_subconfigs.DatapixxAudio]
       datapixxresponse_config: [1×1 o_ptb.PTB_subconfigs.DatapixxResponse]
                      defaults: [1×1 o_ptb.PTB_subconfigs.Defaults]
               internal_config: [1×1 o_ptb.PTB_subconfigs.PTBInternal]

You see that ``o_ptb`` has a bunch of properties you can configure: You also see that every property already has a default value. If you want to know what all these properties mean, you can just type:

.. code-block::

   help ptb_cfg

on the command line. And yes, this would be equivalent to typing ``help o_ptb.PTB_Config``.

The ``ptb_cfg`` object is very similar to a *cfg* structure you know from FieldTrip with one important exception: You cannot add new fields/properties.

You can also see that the ``ptb_cfg`` object has some properties that are objects themselves, for example the ``psychportaudio_config`` property. These properties configure the subsystems. You can leave them alone for now. We will look at them later.

For now, we want our system to:


#. Not show the experiment full screen
#. Thus scale the window down to 1/5 of its original size (which is alway 1920*1080).
#. Not complain if it fails a sync test.
#. Not hide the mouse.

To achieve this, we do this:

.. code-block::

   ptb_cfg.fullscreen = false;
   ptb_cfg.window_scale = 0.2;
   ptb_cfg.skip_sync_test = true;
   ptb_cfg.hide_mouse = false;

Create a o_ptb.PTB object which is the "manager object"
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The central "hub" for all things related to o_ptb is an object of the :class:`+o_ptb.PTB` class. It handles the screen, the audio, trigger and response subsystem. Long story short: It does all the dirty work behind the scenes.

:class:`+o_ptb.PTB` is a special class in the sense that there must always be **one and only one** object of it. There can be many variables with different names pointing to it. In order to achieve this, I needed to use a small trick.

In order to get the ``o_ptb.PTB`` object, you need to do this:

.. code-block::

   ptb = o_ptb.PTB.get_instance(ptb_cfg);

You can see that this is quite different from how we normally get an instance (i.e., an object) of a class. Normally you would call it like: ``o_ptb.PTB(ptb_cfg);``. The reason for doing it with the :meth:`+o_ptb.PTB.get_instance` method is that this method takes care of the requirement that there can only be one :class:`+o_ptb.PTB` around.

If you take a look at the :class:`reference for +o_ptb.PTB <+o_ptb.PTB>` you see that your new object provides some specific and handy methods to do all kinds of things you need to do when developing an experiment. It can take care of setting up the screen for you according to the configuration you provided. If it finds a Datapixx, it will use that to improve timing. It can also initialize the audio, trigger and response system for you. If it finds a Datapixx, it will use it. Otherwise, it will use your keyboard for responses, your sound card for audio and (for the moment) just write the trigger values to the command window.

You can also see that it provides you with some properties that are important when you want to draw stuff on the screen. You need the window handle (also called window_pointer in Psychtoolbox_)? Take it from here: :attr:`+o_ptb.PTB.win_handle`. You need to know the height and width of your screen in pixels? It can do that, too!

Initialize the subsystems (visual, audio, trigger, response) you need
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The final step of initialization is to setup the subsystems that you need. At the moment, we only want to draw stuff on the screen, so here we go:

.. code-block::

   ptb.setup_screen;

This step will take some time. You should see a small PTB window pop up at the top-left of your screen.

When the method returns, we should take a look at the properties of ``ptb``\ :

.. code-block::

   >> ptb

   ptb =

     PTB with properties:

                 win_handle: 10.0000e+000
                   win_rect: [0.0000e+000 0.0000e+000 1.9200e+003 1.0800e+003]
              flip_interval: 16.6636e-003
                width_pixel: 1.9200e+003
               height_pixel: 1.0800e+003
       using_datapixx_video: 0
               scale_factor: 200.0000e-003

Do you notice that ``height_pixel`` is 1080 and ``width_pixel`` is 1920? But hey, the window that has just opened is **way** smaller!!

Yes, you are right. This is another neat trick of Psychtoolbox_: It scales down the original fullscreen window to the small window you have just created. This means that when you want to draw something on the window, you do this in the original resolution and PTB handles all the scaling for you:

**ATTENTION**

Only use this feature when you are developing! If you are running your experiment on a computer that has a different resolution (or you want your screen to be at a lower one), you need to tell o_ptb that resolution in the configuration step:

.. code-block::

   ptb_cfg.internal_config.final_resolution = [1024 768];

.. include:: ../../links.rst
