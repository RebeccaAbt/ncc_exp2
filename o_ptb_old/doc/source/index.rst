.. o_ptb documentation master file, created by
   sphinx-quickstart on Tue Jul 23 11:49:57 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to o_ptb's documentation!
=================================

Introduction
------------

o_ptb is a class based library that runs on top of the well-known Psychtoolbox_. It also uses the VPixx_ system when connected. The latest version also include support for the LabJack U3 device for triggering.

The library tries to achieve two goals:

1. The same code should run and behave as equally as possible whether the Vpixx system is connected or not. If it is not connected, its capabilities will be emulated using the computer's hardware.
2. Make handling visual and auditory stimuli as well as triggers and responses easier and more coherent.

How to cite the o_ptb
---------------------

If you have used the o_ptb, you would do us and the authors of the Psychtoolbox_ a great favor if you cited the following articles:

For the o_ptb please cite:

* `Hartmann, T & Weisz, N. (2020). An Introduction to the Objective Psychophysics Toolbox (o_ptb), PsyArXiv <https://doi.org/10.31234/osf.io/g4nbx>`_

For the Psychtoolbox_ please refer their website: `<http://psychtoolbox.org/credits>`_. Currently, they list the following articles they would like you to cite:

* `Brainard, D. H. (1997) The Psychophysics Toolbox, Spatial Vision 10:433-436 <http://color.psych.upenn.edu/brainard/papers/Psychtoolbox.pdf>`_
* `Pelli, D. G. (1997) The VideoToolbox software for visual psychophysics: Transforming numbers into movies, Spatial Vision 10:437-442 <http://www.psych.nyu.edu/pelli/pubs/pelli1997videotoolbox.pdf>`_
* `Kleiner M, Brainard D, Pelli D, 2007 What’s new in Psychtoolbox-3?, Perception 36 ECVP Abstract Supplement <http://www.perceptionweb.com/abstract.cgi?id=v070821>`_

.. toctree::
   :maxdepth: 2
   :caption: Contents

   install
   tutorial
   reference


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

.. include:: links.rst
