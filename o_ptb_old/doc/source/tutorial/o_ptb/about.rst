About o_ptb
============

So, let's use all your new knowledge about packages and object-oriented programming to understand o_ptb.

What is o_ptb?
---------------

o_ptb is a so-called "class library". A "class library" is nothing else than a toolbox (or function library) that makes use of classes to provide its functionality.

The main purpose of o_ptb is to make using the Psychophysics Toolbox and the Vpixx/Datapixx system easier and more coherent.

Both toolboxes (i.e. Psychtoolbox_ and Datapixx) are very powerful but are very low level. This property makes the hard to use correctly if you do not know exactly how especially the Datapixx system works. And it makes your code look really ugly and not intuitive. In addition, you might have noticed that you would repeat lots of code when you develop your experiment using Psychtoolbox_ and Datapixx. Repeating code, especially low-level code is very undesirable because it makes it easier to do mistakes and it makes it harder to correct them.

o_ptb provides functionality to overcome this by putting a thin layer of abstraction on top of both toolboxes.

What does "abstraction" mean? Glad you asked: Abstraction means that you hide low-level code and provide functions that do common jobs with an easier interface. Take a car for example: If you want to construct or repair a car, you need to know a lot about how it works on the low-level. Like how the engine works, the gears, the brakes etc. Accelerating, for instance, is quite a complex thing to do for a car: It needs to inject just the right amount of fuel, it needs to monitor the ignition and all kind of other stuff. Luckily, if you just want to drive a car, this complexity is hidden from you. You just press down the accelerator and your car goes faster.

The design principles of o_ptb
-------------------------------

When I planned how to develop o_ptb, I used the following principles:


#. Be as intuitive as possible. If a function say "draw", it draws.
#. Allow all Psychtoolbox_ functions that do something visual to still be used.
#. User must not use Datapixx functions directly.
#. Code written by users must run with and without a Datapixx and should behave the same.

.. include:: ../../links.rst
