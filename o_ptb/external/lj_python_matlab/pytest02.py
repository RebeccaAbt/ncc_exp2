import sys
sys.path.append('python/LabJackPython/src')
sys.path.append('python/th')
import th_py_labjack
import time
from th_py_labjack.tictoc import tic
tic()

lj = th_py_labjack.LabjackTrigger(th_py_labjack.ChannelGroup.EIO, method=th_py_labjack.TriggerMethod.MULTI, single_channel=0, num_bits=3)

#lj.trigger_duration = 0.2

while True:
    lj.prepare_trigger(255)
    lj.fire_trigger()
    time.sleep(0.2)

time.sleep(6)

print('done')
del(lj)
sys.exit(0)

