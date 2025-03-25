Showing Movies
==============

A movie is basically a set of images that need to be displayed at very specific
and regular intervals. In ``o_ptb``, a movie is nothing else than a
:mod:`+o_ptb.stimuli.visual` stimulus with some extra convenient methods.

.. note::
  If you want to display a silent movie simply as a distraction to the
  participants (i.e., in a passive listening task), it is much easier to
  just play the movie with VLC or any other movie player while the auditory
  part of the experiment is running.

.. note::
  ``o_ptb`` only supports playing the video part of the movies. You cannot
  use the audio streams at the moment.

Loading the movie
-----------------

In order to prepare the movie, instantiate an object of
:class:`+o_ptb.+stimuli.+visual.Movie`, providing the filename of the movie:

.. code-block::

   my_movie = o_ptb.stimuli.visual.Movie('movie.avi');

Displaying the movie
--------------------

We can now start the movie internally:

.. code-block::

  my_movie.start();

Now the movie is ready to be displayed. We now need to these three things in a
loop:

#. Request a new frame of the movie and check whether one is available.
#. If it is available, use ``ptb.draw`` to draw in on the screen.
#. Flip at the correct time.

The first task is achieved by the method
:meth:`+o_ptb.+stimuli.+visual.Movie.fetch_frame`. If another frame of the movie
is available, it loads it and returns ``true``. If no more frames are available,
it returns ``false``. This means, we can use it in a neat ``while`` loop.

The second task is achieved by just calling ``ptb.draw`` on the
:class:`Movie <+o_ptb.+stimuli.+visual.Movie>` object we created.

The third task is achieved by calling ``ptb.flip`` using the time
provided by :attr:`+o_ptb.+stimuli.+visual.Movie.next_flip_time`.

In your code, it is going to look like this:

.. code-block::

  while my_movie.fetch_frame()
    ptb.draw(my_movie);

    ptb.flip(my_movie.next_flip_time);
  end %while

If you want to know more
------------------------

If you want to know more and/or do more advanced things with movies,
please refer to the respective section of the
:class:`reference <+o_ptb.+stimuli.+visual.Movie>`.

Keep in mind, that a :class:`Movie <+o_ptb.+stimuli.+visual.Movie>` inherits
from both :class:`+o_ptb.+stimuli.+visual.TextureBase` and
:class:`+o_ptb.+stimuli.+visual.Base`. So you can move it, scale it, add
a gaussian blur and so on and so forth....
