from time import time
_tstart_stack = []

def tic():
    _tstart_stack.append(time())

def toc(fmt="Elapsed: %s ms"):
    print(fmt % ((time() - _tstart_stack.pop())*1000))