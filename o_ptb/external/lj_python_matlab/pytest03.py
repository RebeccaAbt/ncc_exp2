import sys
sys.path.append('python/LabJackPython/src')
sys.path.append('python/th')
import th_py_labjack
import time

lj = th_py_labjack.LabjackTrigger(th_py_labjack.ChannelGroup.EIO, method=th_py_labjack.TriggerMethod.PULSEWIDTH, single_channel=0, num_bits=3)


lj.prepare_trigger(4, 0.3)
lj.prepare_trigger(2)
lj.fire_trigger()

time.sleep(1)
del(lj)
sys.exit(0)