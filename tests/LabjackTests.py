#%%
import u3
import threading
import enum
import collections
import math
import time
import pprint

#%%
device = u3.U3()
pprint.pprint(device.configU3())
#%%

def wait_for_intrigger(device, base_level, n_trigger, chan_nr, chan_type):  # timeout unnecessary!
        #self.triggered = None
        base_level = int(base_level)
        base_level = bool(base_level)

        if chan_type == 'EIO':
            chan_nr = chan_nr + 8

        if chan_type == 'CIO':
            chan_nr = chan_nr + 16

        if n_trigger > 1:
            for i in range(0, n_trigger):
                while True:
                    time.sleep(0.01)
                    if device.getDIState(chan_nr) != base_level:
                        break

                if i == n_trigger-1:
                    return True 

                while True:
                    if device.getDIState(chan_nr) == base_level:
                        break  
        else:
            while True:
                if device.getDIState(chan_nr) != base_level:
                    return True
                

a = wait_for_intrigger(device, 1, 1, 5, 'FIO')

#%%

device.close()