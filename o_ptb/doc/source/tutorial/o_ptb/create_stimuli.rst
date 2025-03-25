How to create your own stimuli
==============================

Do you have to be able to do this to use o_ptb? **NO!** You can just use normal :func:`Screen` commands for your visual stimuli and use the :class:`+o_ptb.stimuli.auditory.FromMatrix` audio stimulus.

However, the o_ptb base classes for these stimuli come with some advantages. For instance, you can automatically scale and move your visual stimuli. And it is not that hard!

Let's create a rectangle that we can move and scale
---------------------------------------------------

So, we want to create a new class that shows a filled rectangle. It should appear at the center of the screen by default and let us define the initial size and color.

So, create a new class called "Rectangle" by doing a right-click in the "Current Folder" section and choose "New File -> Class".

You will start out with something like this:

.. code-block::

   classdef Rectangle
     %RECTANGLE Summary of this class goes here
     %   Detailed explanation goes here

     properties
     end

     methods
     end

   end

The first thing we will do is to make our class inherit from the base class of all visual stimuli:

.. code-block::

   classdef Rectangle < o_ptb.stimuli.visual.Base
     %RECTANGLE Summary of this class goes here
     %   Detailed explanation goes here

     properties
     end

     methods
     end

   end

Very good. Now your class is officially a visual stimulus! Now we need to teach it, what it needs to do when you want it to draw something. The :class:`+o_ptb.stimuli.visual.Base` class defines a method called ``on_draw(obj, ptb)``. This method gets called whenever o_ptb wants the class to draw something on the screen. So, we need to implement that:

.. code-block::

   classdef Rectangle < o_ptb.stimuli.visual.Base
     %RECTANGLE Summary of this class goes here
     %   Detailed explanation goes here

     properties
     end

     methods
       function on_draw(obj, ptb)
         ptb.screen('FillRect', [0 0 0], CenterRect([0 0 300 300], ptb.win_rect));
       end %function
     end

   end

You can try this out now:

.. code-block::

   my_rect = Rectangle
   ptb.draw(my_rect);
   ptb.flip

And you see that a black rectangle is displayed at the center of the screen.

But we want the class to be more flexible. The next step would be to get the hard coded colors out of the ``on_draw`` methods and use properties instead:

.. code-block::

   classdef Rectangle < o_ptb.stimuli.visual.Base
     %RECTANGLE Summary of this class goes here
     %   Detailed explanation goes here

     properties
       width = 300;
       height = 300;
       color = [0 0 0];
     end %properties

     methods
       function on_draw(obj, ptb)
         ptb.screen('FillRect', obj.color, CenterRect([0 0 obj.width obj.height], ptb.win_rect));
       end %function
     end

   end

This class does the same as the old version. But we defined the width, height and color as properties.

Still, we cannot choose from outside of the class, how big we want the rectangle to be and what color we want. So, we add a constructor method:

.. code-block::

   classdef Rectangle < o_ptb.stimuli.visual.Base
     %RECTANGLE Summary of this class goes here
     %   Detailed explanation goes here

     properties
       width;
       height;
       color;
     end %properties

     methods
       function obj = Rectangle_other(width, height, color)
         obj@o_ptb.stimuli.visual.Base();

         obj.width = width;
         obj.height = height;
         obj.color = color;
       end %function

       function on_draw(obj, ptb)
         ptb.screen('FillRect', obj.color, CenterRect([0 0 obj.width obj.height], ptb.win_rect));
       end %function
     end

   end

You might wonder what the first line in the constructor means? (\ ``obj@o_ptb.stimuli.visual.Base();``\ ). Remember that we inherit from another class. And that class also has a constructor that needs to be called. This line does that for you.

The rest is pretty straight forward. Our constructor takes three arguments and we assign it to the properties of the class.

We can now create and display our rectangle like this:

.. code-block::

   my_rect = Rectangle(200, 200, [0 0 0]);
   ptb.draw(my_rect);
   ptb.flip

Now for the last-but-one step: The :class:`+o_ptb.stimuli.visual.Base` class defines two very handy methods: :meth:`scale <+o_ptb.stimuli.visual.Base.scale>` and :meth:`move <+o_ptb.stimuli.visual.Base.move>`. In order for these to work, we need to make use of the :class:`+o_ptb.stimuli.visual.Base` classe's property called ``destination_rect``. This holds the destination rectangle where our stimulus should appear. The :meth:`scale <+o_ptb.stimuli.visual.Base.scale>` and :meth:`move <+o_ptb.stimuli.visual.Base.move>` method recalculate its coordinates.

Here is how it works now:

.. code-block::

   classdef Rectangle < o_ptb.stimuli.visual.Base
     %RECTANGLE Summary of this class goes here
     %   Detailed explanation goes here

     properties
       width;
       height;
       color;
     end %properties

     methods
       function obj = Rectangle(width, height, color)
         obj@o_ptb.stimuli.visual.Base();

         ptb = o_ptb.PTB.get_instance;

         obj.width = width;
         obj.height = height;
         obj.color = color;
         obj.destination_rect = CenterRect([0 0 obj.width obj.height], ptb.win_rect);
       end %function

       function on_draw(obj, ptb)
         ptb.screen('FillRect', obj.color, obj.destination_rect);
       end %function
     end

   end

Now check this out:

.. code-block::

   my_rect = Rectangle(200, 150, [0 0 0]);

   for i = 1:200
     my_rect.move(1, 1);

     ptb.draw(my_rect);
     ptb.flip();
   end %for

There is only one problem remaining: The three properties can be modified by anyone. This would lead to unexpected behavior, because I would expect that the width of the object changes if I change the width property. The easies solution is to just prohibit these properties to be read and modified from outside the class:

.. code-block::

   classdef Rectangle < o_ptb.stimuli.visual.Base
     %RECTANGLE Summary of this class goes here
     %   Detailed explanation goes here

     properties (Access=protected)
       width;
       height;
       color;
     end %properties

     methods
       function obj = Rectangle(width, height, color)
         obj@o_ptb.stimuli.visual.Base();

         ptb = o_ptb.PTB.get_instance;

         obj.width = width;
         obj.height = height;
         obj.color = color;
         obj.destination_rect = CenterRect([0 0 obj.width obj.height], ptb.win_rect);
       end %function

       function on_draw(obj, ptb)
         ptb.screen('FillRect', obj.color, obj.destination_rect);
       end %function
     end

   end

That's it!

.. include:: ../../links.rst
