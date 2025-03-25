How to install o_ptb
====================

Requirements
------------

In order to develop and run experiments with o_ptb, you need to have:

#. Matlab_ 2019b or higher
#. The signal processing toolbox of Matlab
#. A current version of the Psychtoolbox_

If you want to use a Labjack device to trigger, you also need a recent version of python_.

Download o_ptb
--------------

The preferred way to download o_ptb is via git_. This enables you to easily update o_ptb to the most current version. You can also download it directly from the `gitlab repository <https://gitlab.com/thht/o_ptb>`_ as a zip file, but this method is not recommended.

Assuming, you have git_ installed on your computer, you can download o_ptb by "cloning" the repository.

Open a terminal and navigate to the folder under which you want to find o_ptb.

Let's suppose, I have a folder called :code:`matlab_toolboxes` where I store all my toolboxes for Matlab_:

.. code-block:: bash

    cd matlab_toolboxes
    git clone https://gitlab.com/thht/o_ptb.git

This should be rather quick to finish. You should now see a new folder called :code:`o_ptb`.

Keep o_ptb up-to-date
---------------------

o_ptb is under constant development. Make sure that you always keep your version updated. In order to do so,
open a terminal, navigate to the folder in which o_ptb lives and issue :code:`pull` command of git_:

.. code-block:: bash

    cd matlab_toolboxes/o_ptb
    git pull

Where to go next
----------------

Now that you have successfully installed o_ptb, you might want to take a look at the :doc:`tutorials <tutorial>`.


.. include:: links.rst
