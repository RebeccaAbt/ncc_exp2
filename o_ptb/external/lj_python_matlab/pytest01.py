import sys
sys.path.append('python/LabJackPython/src')
sys.path.append('python/th')
import th_py_labjack
import time

lj = th_py_labjack.LabjackTrigger(th_py_labjack.ChannelGroup.EIO, method=th_py_labjack.TriggerMethod.MULTI, single_channel=0, num_bits=5)
lj._dec2bin(3)
#lj.trigger_duration = 1

for trigger in range(1, 32):
    print('Firing trigger %d' % (trigger,))
    lj.prepare_trigger(trigger)
    lj.fire_trigger()
    lj.fire_trigger()
    time.sleep(1)

print('done')
del(lj)
sys.exit(0)

