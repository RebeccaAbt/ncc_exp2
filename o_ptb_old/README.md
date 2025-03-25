# o_ptb
## What is o_ptb?
o_ptb is a class based library that runs on top of the well-known [Psychophysics Toolbox](http://psychtoolbox.org/). It also uses the [VPixx](http://vpixx.com/) system when connected. The latest version also include support for the LabJack U3 device for triggering.

The library tries to achieve two goals:

1. The same code should run and behave as equally as possible whether the Vpixx system is connected or not. If it is not connected, its capabilities will be emulated using the computer's hardware.
2. Make handling visual and auditory stimuli as well as triggers and responses easier and more coherent.

## Attention!!
If you want to update from a version of o_ptb without Labjack support, please redownload it using the instructions provided below. Otherwise, there will be problems with the submodules!

## How to get started
### Download and install required software
#### git
The process of downloading most software uses git. Download and install your it from [here](https://git-scm.com/).

#### Psychophysics Toolbox
o_ptb runs on top of the well-known Psychophysics Toolbox. You can download and put it anywhere you like on your computer. The best way to do this is by using git:
```
git clone https://github.com/Psychtoolbox-3/Psychtoolbox-3.git
```

You do not need to do any of the initialization that comes with the PsychToolbox. o_ptb takes care of the for you.

#### Python
If you want to use the Labjack as a triggering device, you must have python 3 on your computer. If you use Linux, it is most probably already installed. Windows and Mac users can download it from [here](https://www.python.org/).

#### o_ptb
Now you can use git to download the most recent version of o_ptb.

In order to get a fresh download, do this:

```
git clone https://gitlab.com/thht/o_ptb.git
```

If you want to update your version to the latest one, you must first make sure that you are in the folder where you previously cloned o_ptb in. Then do:

```
git pull
```

### Start using o_ptb in your code

In order to initialize o_ptb and Psychophysics Toolbox, you would use code like this:

```
% reset the matlab path
restoredefaultpath;

% add the path to the top-level folder of o_ptb. please note that we are not adding the +o_ptb folder here!
addpath('/home/th/matlab/o_ptb');

% initialize PTB using the init_ptb function
o_ptb.init_ptb('/home/th/matlab/PTB');
```

## How to go on from here
Please take a look at the [o_ptb documentation](https://o-ptb.readthedocs.io) for all the information you need.
