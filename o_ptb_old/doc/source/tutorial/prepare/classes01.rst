About Classes and Object-Oriented Programming Part 1
====================================================

So, you made it to the scary topic. But let me assure you: the basic concepts of object-oriented programming are really easy. And you already know most of the really important stuff - You just have not realized it yet.

The main problem of understanding object-oriented programming is that it is so extremely powerful that you can do very very complex stuff with it. And for developers, this super complex stuff is so awesome that they will talk about that.

We don't do this here. We will keep it very very simple.

Let's create our first class
----------------------------

First, create a new folder that will contain the packages, classes, functions etc. of this tutorial.

Navigate into the folder you just created and create another folder for the "toolbox" you are about to write. For this tutorial, I will assume that this new folder is called ``tut_toolbox``.

So, after you have created the folder for your new toolbox, create a new package folder called ``+example01``.

If you do a right-click on the ``+example01`` folder  and then select *New File*\ , it offers to create a class for you. If you do this and call your new class ``Human.m``\ , it will create this for you:

.. code-block:: matlab

    classdef Human
     %HUMAN Summary of this class goes here
     %   Detailed explanation goes here

     properties
     end

     methods
     end

   end

So, what do we have here:


#. The first line basically says: "I want a class that is called *Human*\ ".

   #. As a convention, all classes begin with a capital letter, while all function names start with a lower case letter!

#. We have an ``end`` statement at the end. You already know this from your functions and ``for`` loops. Everything between the ``classdef`` and the last ``end`` statement belongs to the description of the class.
#. Within the ``classdef`` description, we have empty blocks for something called ``properties`` and something else called ``methods``.

Congratulations, you have just created your first class. Yes, it does not do anything at the moment, but we will change that soon.

Adding methods
--------------

Up to now, our class does not do anything. But you have noticed the ``methods`` block in the file that Matlab created for you. This is, where the class's methods go.

**Methods are functions of a class**

So, lets add a simple method to the class:

.. code-block::

    classdef Human
     properties
     end

     methods
       function hello(obj)
         disp('Hi!');
       end %function
     end

   end

If you compare it to the code we started with, you see that we added a normal Matlab function definition inside the ``methods`` block. You can also see that the function takes one argument called ``obj``. Just ignore this for the moment and just treat the function as if it had no argument at all.

So, it should be obvious for you what this function should do. So let's try that:

.. code-block::

   %% clear and restore path...
   clear all global

   restoredefaultpath

   %% add the toolbox to the path...
   addpath('tut_toolbox');

   %% call the class function...
   example01.Human.hello();

If we do this, Matlab is going to complain:

.. code-block::

   The class example01.Human has no Constant property or Static method named 'hello'.

About Classes and Instances
---------------------------

So, why did we get an error message? In order to understand this, you need to know the difference between *classes* and *instances*\ :

What is a Class?
^^^^^^^^^^^^^^^^

The easiest way to imagine what a class is, is to imagine it as a plan or template.

Let's say, we want to build a car. In this case, the *class* would be the plans and all instructions on **how to build a car**. It is **not** the actual car itself.

But just as you can use the plans and instructions to build a concrete car (or two, three, thousands), we can use a *class* to create a concrete *instance* (or two, three, thousands).

What is an Instance?
^^^^^^^^^^^^^^^^^^^^

An *instance* is the concrete object built by using the definitions and descriptions in a *class*. In our car analogy, it would be the actual car.

If you think about it, this distinction is really important. The actual car can do stuff like accelerated, brake, steer to the left or right. The plan of the car cannot do that, but it describes how this is done.

This is the reason why we got this error in the last section. We basically asked the plan to do something. But the plan cannot do something. It just knows how to do it. We need to build an actual object (or instance) with the help of that plan. The resulting thing (instance, car, whatever) can then do the stuff that is defined in the plan.

How to get an instance
^^^^^^^^^^^^^^^^^^^^^^

Here is how you get an instance of a class:

.. code-block::

   my_first_human = example01.Human();

You see, its really easy: You just write down the name of the class, including all the packages, of course, and the put brackets and assign the result to a variable. Now ``my_first_human`` points to an instance of ``Human``.

Now, we can call the *methods* of the instance like this:

.. code-block::

   my_first_human.hello()

So, if you want to call a method of an instance, you first type the name of the instance (\ **not** the class!), the a dot (\ ``.``\ ) and then the name of the method. Easy, right?

About properties
----------------

Up to now, our new class can do stuff (it can say "hi"). But it would also be good if we could also attach some data to an instance of a class. This is what properties are for.

**Properties are variables of a class**

Or, if you would like to compare it to the structures that you know from FieldTrip:

**Properties are the fields of a class**

So, let's add a property to our class:

.. code-block::

   classdef Human
     properties
       name
     end

     methods
       function hello(obj)
         disp('Hi!');
       end %function
     end

   end

Now, create an instance of this class:

.. code-block::

   my_first_human = example01.Human();

and look what is inside:

.. code-block::

   >> my_first_human

   my_first_human =

     Human with properties:

       name: []

Matlab tells us that our ``Human`` now has a property called ``name``. We can use it now as we would use fields of structures:

.. code-block::

   my_first_human.name = 'Adam';
   my_first_human.name

Properties are specific to instances, not classes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It is really important to understand this. You can create as many instances of a class as you like. But assigning a property of calling a method only affects the instance and not the class!

Here is an example:

.. code-block::

   my_first_human = example01.Human();
   my_first_human.name = 'Adam';

   my_second_human = example01.Human();
   my_second_human.name = 'Eve';

   my_first_human
   my_second_human

You see that both variables point to an instance of the class ``Human``\ , so they look alike. But their data is different.

Let's do something with the property
------------------------------------

One of the incredibly nice and powerful things about Object-Oriented Programming is the fact that the methods of a class can operate on its properties.

For example: Our ``Human`` class now has a property called ``name``. Let's use it to write a function that prints out the name:

.. code-block::

   classdef Human
     properties
       name
     end

     methods
       function hello(obj)
         disp('Hi!');
       end %function

       function say_name(obj)
         disp(['My name is ' obj.name '!']);
       end %function
     end

   end

You see, we created another function called ``say_name``. The function does only one thing:

.. code-block::

   disp(['My name is ' obj.name '!']);

Do you remember that I told you to forget about the ``obj`` parameter earlier? Now we use it.

A method of a class can have any number of parameters. **But** the first parameter always receives the current instance of the class. By convention, this first parameter is always called ``obj``. The method can then use this parameter to access the instance's properties and call its functions. Just like we do here to access the **instance's** ``name`` property.

Try it out:

.. code-block::

   my_first_human.say_name();
   my_second_human.say_name();
