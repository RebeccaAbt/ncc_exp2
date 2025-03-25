About "Handle Classes"
======================

All classes used in p_ptb are so-called "handle classes". What does this mean?

When you create an object of a handle class and assign it to a variable like this:

.. code-block::

   my_object = MyHandleClass();

What gets stored in the variable ``my_object`` is **not the object itself** but a "handle" to it. A "handle" is just an address within the computer's memory. So the variable ``my_object`` stores **where the object is**. It **does not store the object itself!**

What are the implications of this? Let's create a simple handle class and put it in the package ``+handle_class_example``\ :

.. code-block::

   classdef MyHandleClass < handle
     properties
       number
     end  
   end

So, we have a simple class with only one property.

Let's create a second class but without the handle:

.. code-block::

   classdef MyNormalClass
     properties
       number
     end  
   end

The only difference between the two is that ``MyHandleClass`` inherits from ``handle`` while ``MyNormalClass`` does not.

If you run this, the output will be as you would expect:

.. code-block::

   >> %% get a normal class
   normal_class1 = handle_class_example.MyNormalClass();
   normal_class1.number = 1;

   %% copy it by assignment
   copy_of_normal_class1 = normal_class1;
   copy_of_normal_class1.number = 100;

   %% see what it is both classes
   normal_class1
   copy_of_normal_class1

   normal_class1 = 

     MyNormalClass with properties:

       number: 1.0000e+000


   copy_of_normal_class1 = 

     MyNormalClass with properties:

       number: 100.0000e+000

If we do the same thing again, but this time use the ``MyHandleClass``\ , this happens:

.. code-block::

   >> %% get a handle class
   handle_class1 = handle_class_example.MyHandleClass();
   handle_class1.number = 1;

   %% copy it by assignment
   copy_of_handle_class1 = handle_class1;
   copy_of_handle_class1.number = 100;

   %% see what it is both classes
   handle_class1
   copy_of_handle_class1

   handle_class1 = 

     MyHandleClass with properties:

       number: 100.0000e+000


   copy_of_handle_class1 = 

     MyHandleClass with properties:

       number: 100.0000e+000

So, whats different here? By assigning a new value to the copy of the object, we also changed what we get when we refer to the original one. This is, as I wrote above, because ``handle_class1`` does not store the object itself but only its handle, i.e. its address in memory. ``copy_of_handle_class1 = handle_class1;`` assigns the address of the object ``handle_class1`` is pointing at to the variable ``copy_of_handle_class1``. As it is the address that is exchanged, both variables point at the **same** object!!

So, how can you do a real copy of a handle class? First, you need to modify the class a little bit:

.. code-block::

   classdef MyHandleClass < handle & matlab.mixin.Copyable
     properties
       number
     end  
   end

And now you can do this:

.. code-block::

   >> %% get a handle class
   handle_class1 = handle_class_example.MyHandleClass();
   handle_class1.number = 1;

   %% copy it by copy
   copy_of_handle_class1 = copy(handle_class1);
   copy_of_handle_class1.number = 100;

   %% see what it is both classes
   handle_class1
   copy_of_handle_class1

   handle_class1 = 

     MyHandleClass with properties:

       number: 1.0000e+000


   copy_of_handle_class1 = 

     MyHandleClass with properties:

       number: 100.0000e+000

So, the bottom line is: Always use the ``copy`` function when you want to really copy a handle class!

**ALL classes of o_ptb are handle classes. ALL classes can be copied**

