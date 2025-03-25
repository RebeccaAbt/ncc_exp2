About Classes and Object-Oriented Programming Part 3
====================================================

Welcome to part 3 about classes and objects.

You now know about constructors and access rights.

Let's tackle the last big challenge: Inheritance

Inheritance is a very powerful tool in Object-Oriented Programming. Because it is possible to do very complex things with it, it might seem very complex. I promise to make it as simple as possible.

So, let's start with an example....

What we want to do
------------------

So, we already have a class describing our ``AdvancedHuman``. It has a name and can do two things: 1. say hello and 2. say its name.

However, you might agree that this is a very generic class. There might be special groups of humans who would do things differently. But they would still be humans, of course...

Let's make a pirate
^^^^^^^^^^^^^^^^^^^

For instance, pirates are a special kind of humans, because instead of saying 'Hi', they say 'ARRRRGGGHHH'.

Create a new class in the same package as the ``AdvancedHuman`` called Pirate.m

Here is the minimum code to start:

.. code-block::

   classdef Pirate < example01.AdvancedHuman

     methods
       function obj = Pirate(name)
         obj = obj@example01.AdvancedHuman(name);
       end %function
     end %methods

   end

Ok, let's go through it line by line:


#. ``classdef Pirate < example01.AdvancedHuman``\ : You already know the first part. We define a new class. The second part (\ ``< example01.AdvancedHuman``\ ) means that we do not create a class from scratch but instead we take the ``AdvancedHuman`` class and start from there. This means that our new class already has **all the methods and all the properties** defined in the ``AdvancedHuman`` class!

#. ``function obj = Pirate(name)``\ : We also need a constructor for our new class because we want our constructor to take a parameter.

#. Remember that the constructor initializes all the properties. In our case, we would need to assign the value of the ``name`` parameter to the ``obj.name`` property of the classe. We could just write something like this:

        .. code-block::

            function obj = Pirate(name)
                obj.name = name;
            end %function

    But this has some disadvantages:

   #. We repeat code that is already written. This is very bad in general!
   
   #. Maybe ``AdvancedHuman`` does some more initialization work? We don't know. Or maybe ``AdvancedHuman`` receives an update at some point in the future that requires it to do some extra work in its constructor.

      So, instead of doing the work of the class we inherit from ourselves, we let it do the work.

#. ``obj = obj@example01.AdvancedHuman(name);``\ : This is how you call the constructor of the "superclass". The "superclass" is the class your new class inherits from.

Now we can write something like this:

.. code-block::

   my_pirate = example01.Pirate('Adam');
   my_pirate.say_name();
   my_pirate.hello();
   my_pirate.name

We now have a class called ``Pirate`` that has all the methods and properties of an ``AdvancedHuman`` without repeating the code.

But this is quite boring. We wanted our pirate to do something different than the ordinary ``AdvancedHuman`` when we ask him to say hello. This is how it works:

.. code-block::

   classdef Pirate < example01.AdvancedHuman

     methods
       function obj = Pirate(name)
         obj = obj@example01.AdvancedHuman(name);
       end %function

       function hello(obj)
         disp('AAARRRRGGGHHHH');
       end %function
     end %methods

   end

Now just execute the same code again and see the difference!

You will see that instead of using the ``hello`` method of the ``AdvancedHuman`` class, the ``Pirate`` class now uses the ``hello`` method we defined here.

Why this is useful
------------------

You might ask yourself: "What is the reason for doing all this?". It is quite simple:

We can define one base class (in this case ``AdvancedHuman``\ ) that has all the properties and methods that we need for a specific purpose. We can then create a function like this that works with instances of that class:

.. code-block::

   function group_hello(humans)
   for i = 1:length(humans)
     cur_human = humans{i};
     cur_human.say_name();
     cur_human.hello();
   end %for
   end

You can see that this function does not care, what kind of ``AdvancedHuman`` it gets. It might be a direct instance of ``AdvancedHuman`` or it might be an instance of a class that inherited from ``AdvancedHuman``.

Take a look at this script that calls the ``group_hello`` function:

.. code-block::

   %% clear and restore path...
   clear all global

   restoredefaultpath

   %% add the toolbox to the path...
   addpath('my_toolbox');

   %% get some pirates and humans
   my_pirate = example01.Pirate('Adam');

   my_first_human = example01.AdvancedHuman('Mary');
   my_second_human = example01.AdvancedHuman('Eve');

   %% send them all to the group_hello function
   all_humans = {my_pirate, my_first_human, my_second_human};

   example01.group_hello(all_humans);

This script create one ``Pirate`` and two ``AdvancedHuman``\ s and sends these to the ``group_hello`` function which then executes both methods of each instance provides in the cell-array.

The important concept behind this is that we have created a hierarchical order between the two classes: Every ``Pirate`` is also an ``AdvancedHuman``. So a function can require to be provided with an instance (or instances) of ``AdvancedHuman`` but it would also work with a ``Pirate``.

