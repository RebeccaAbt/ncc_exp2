About Packages
==============

Did you ever think that the Path system of Matlab is not that good? Do you think, it is annoying that you always need to add a prefix (like ``ft_`` or ``obob_``\ ) to your functions because otherwise there might be more than one function sharing the same name which creates chaos?

Packages are here to help you!

What is a "Package"?
--------------------

A Package is a folder that start with a ``+``. Everything coming afterwards is the name of the package. Function you put inside of a folder starting with a ``+`` are part of that package.

Take a look here:


.. image:: /_static/img/t01_package_folders.png
   :alt: folder structure


You see a folder called ``my_toolbox``. This could be a parent folder for a new toolbox you are writing. In order to use your new toolbox, people are supposed to **only** add this parent folder.

Inside, you find two packages: ``first_package`` and ``second_package``. Each of these packages has a function called ``my_fun.m``.

You can see that both functions have the same name. This would not work normally. The trick here is that both functions are in separate packages!

How do I call a function in a package?
--------------------------------------

Packages are available as soon as the *parent folder* of the package is in the Matlab path. So, in our case, we just need to add ``my_toolbox`` to the Matlab path in order to be able to access both packages:

.. code-block::

   restoredefaultpath
   addpath('my_toolbox');

Now we can call our functions like this:

.. code-block::

   first_package.my_fun();
   second_package.my_fun();

So, we write the name of the package first, the put a dot (\ ``.``\ ) and then the name of the function. Easy, isn't it?

More stuff you need to know about packages
------------------------------------------

There is a bit more you need to know how packages work:

Packages can be nested
^^^^^^^^^^^^^^^^^^^^^^

You can have packages that live inside of other packages. Like here:


.. image:: /_static/img/t01_package_folders_with_subpackages.png
   :alt: folder_structure_with_packages


Calling function in sub-packages is quite straight forward:

.. code-block::

   mother.anna.my_fun();
   mother.max.my_fun();

You always need to call functions in packages with all the packages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ok, sounds weird at first. Here is the thing. Even if you call a function that lives in the same package as the function calling it, you need to write all the packages.

For example: In the code, you will find two more function in the ``mother.anna`` package: ``add_numbers`` and ``my_other_fun``. ``my_other_fun`` wants to call ``add_numbers``. 

This would not work:

.. code-block::

   function my_other_fun()
   result = add_numbers(1, 3);

   fprintf('One and three is: %d\n', result);

   end

But this does:

.. code-block::

   function my_other_fun()
   result = mother.anna.add_numbers(1, 3);

   fprintf('One and three is: %d\n', result);

   end

Finally
-------

Play around with the package system. Write your own small toolbox and try to get the grip of it!

