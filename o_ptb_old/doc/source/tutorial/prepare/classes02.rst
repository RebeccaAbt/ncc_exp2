About Classes and Object-Oriented Programming Part 2
====================================================

Welcome to part 2 about classes and objects.

You have already written your first class. You know what is meant when we talk about an instance of a class. You know how to add properties and methods to a class.

Great, let's go on.

Preparations
------------

We are going to do some changes to the ``Human`` class that we developed during the first part of the Classes-And-OOP tutorial. These changes make it impossible to use the class with the example scripts that we have written so far. So, i would suggest you copy the class and give it a new name. You can call it as you wish, but I will assume that it is called ``AdvancedHuman``.

At the beginning, this class is a mere copy of the ``Human`` class. So it look like this:

.. code-block::

   classdef AdvancedHuman
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

Naming conventions
^^^^^^^^^^^^^^^^^^

Especially in collaborative projects, it is important to agree on some convention on how to name things. In o_ptb as well as in this tutorial, the following convention is used:


#. Variables, Properties, Functions and Methods are always written in lower case. Words are separated by an underscore:

   #. ``function hello(obj)``
   #. ``function say_name(obj)``
   #. ``name = 'Adam';``
   #. ``postal_code = '12345';``

#. Classes are always written with a capital first letter followed by lower case letters. If a class name consists of two or more words, a capital letter marks the beginning of a new word:

   #. ``classedef AdvancedHuman``

Constructors
------------

If we want to create an instance of an ``AdvancedHuman`` and give it the name "Max", it is a two-step process:

.. code-block::

   my_human = examples01.AdvancedHuman();
   my_human.name = 'Max';

But this does not really make sense, does it? It does not make sense, because a human always has a name. So, it would be much better to supply the name when we create the instance.

This is where **Constructors** come in. Every class has a constructor. It is a special method that gets called when you create a new instance of a class.

You might be a bit confused now because you do not see such a method in the code. You are right. Matlab is so nice to just add an empty constructor when we do not provide one.

Adding a constructor is really easy. It is just an extra method like this:

.. code-block::

   function obj = ClassName()

In order to be a valid constructor, a method needs to follow three requirements:


#. It must have the **exact same name** as the class.
#. It **must** return a variable called ``obj`` and nothing else.
#. Contrary to all other methods, it does not take ``obj`` as its first parameter.

So, let's add a simple constructor to our class:

.. code-block::

   classdef AdvancedHuman
     properties
       name
     end

     methods
       function obj = AdvancedHuman()
         disp('Creating a nice Human for you.');
       end %function

       function hello(obj)
         disp('Hi!');
       end %function

       function say_name(obj)
         disp(['My name is ' obj.name '!']);
       end %function
     end

   end

You see that the constructor does not really do something now other than displaying a message. But lets try it:

.. code-block::

   >> my_human = example01.AdvancedHuman();
   Creating a nice Human for you.

Ok, that worked well. Let's implement the functionality I described above: We want the constructor to take the name and automatically put it into the correct property of the instance.

Here is the code:

.. code-block::

   classdef AdvancedHuman
     properties
       name
     end

     methods
       function obj = AdvancedHuman(name)
         fprintf('Creating a nice Human called %s for you.\n', name);
         obj.name = name;
       end %function

       function hello(obj)
         disp('Hi!');
       end %function

       function say_name(obj)
         disp(['My name is ' obj.name '!']);
       end %function
     end

   end

This is what happens now:


#. The constructor now requires a parameter which is called name.
#. It uses the value of that parameter in the next line to display the message.
#. It the assigns the value to the property called ``name`` of the instance, which it can access via the ``obj`` variable.

I deliberately chose to use the same name for the parameter as for the property to demonstrate how both of them are accessed:


#. ``name`` is the parameter of the method.
#. ``obj.name`` is the property called "name" of the current instance.

Now you can do this:

.. code-block::

   my_human = example01.AdvancedHuman('Adam');
   my_human.say_name();

Access rights
-------------

At the moment, we can still do this:

.. code-block::

   my_human = example01.AdvancedHuman('Adam');
   my_human.name = 'Eve';

I don't think this makes much sense because a name is given one time at birth and does not change (yes, there are exceptions to this.).

Luckily, you can set access rights for properties and methods which defines who can call the methods or write/read to the property.

Matlab knows three levels of access rights:


#. Public: The method or property can be accessed from anywhere.
#. Private: The method or property can only be accessed from methods of that specific class.
#. Protected: Like private but access is also allowed from sub-classes (more on that later).

For properties, you can set these rights separately for reading and writing to the property.

So, in our case, our code now looks like this:

.. code-block::

   classdef AdvancedHuman
     properties (SetAccess=private)
       name
     end

     methods
       function obj = AdvancedHuman(name)
         fprintf('Creating a nice Human called %s for you.\n', name);
         obj.name = name;
       end %function

       function hello(obj)
         disp('Hi!');
       end %function

       function say_name(obj)
         disp(['My name is ' obj.name '!']);
       end %function
     end

   end

We have restricted access to the property ``name`` so that it can only be written to from methods of the class. So, assigning a value as in the constructor still works because the constructor is a member of the class.

But this does not work anymore:

.. code-block::

   my_human = example01.AdvancedHuman('Adam');
   my_human.name = 'Eve';
