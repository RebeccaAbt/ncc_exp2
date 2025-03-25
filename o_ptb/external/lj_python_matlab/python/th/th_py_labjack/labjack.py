import u3
import threading
import enum
import collections
import math
import time


from LabJackPython import LabJackException, NullHandleException


class ChannelGroup(enum.Enum):
    FIO = 0
    EIO = 1
    CIO = 2

class TriggerMethod(enum.Enum):
    SINGLE = 0
    MULTI = 1
    PULSEWIDTH = 2

class Command(list):
    def __init__(self, *args, **kwargs):
        self._lj = kwargs.pop('lj')
        self.onset = 0

        super(Command, self).__init__(*args, **kwargs)

    @property
    def duration(self):
        this_duration = 0

        for cmd in self:
            if isinstance(cmd, u3.WaitShort):
                this_duration += cmd.time * self._lj._smallest_wait_secs_short
            elif isinstance(cmd, u3.WaitLong):
                this_duration += cmd.time * self._lj._smallest_wait_secs_long

        return this_duration

class LabjackThread(threading.Thread):  # neue Klasse: LabJackThread; basiert auf class threading.Thread
    def __init__(self):
        super(LabjackThread, self).__init__()
        self._command_event = threading.Event()
        self._command_lock = threading.Lock()
        self._device = u3.U3()
        self._device.configIO(EIOAnalog=0, FIOAnalog=0)    # change to 1 to define analog input
        self._device.getFeedback(u3.PortDirWrite([255, 255, 255]))
        self._device.getFeedback(u3.PortStateWrite([0, 0, 0]))   

        self._current_command = None
        self._should_exit = False
        self.dev_config = self._device.configU3()

    def __del__(self):
        self.stop()

    def _send_command(self, cmd):
        try:
            self._device.getFeedback(cmd)
        except LabJackException as e:
            if e.errorString != "Got a zero length packet.":
                raise e
    
    def run(self):
        while not self._should_exit:
            if self._command_event.wait():
                timers = list()
                if self._current_command:
                    for cmd in self._current_command:
                        timers.append(
                            threading.Timer(cmd.onset,
                                            self._send_command,
                                            args=[cmd])
                        )

                    for timer in timers:
                        timer.start()

                self._command_event.clear()
                self._current_command = None


        self._device.close()

    def send_feedback_command(self, cmd): # das ruft matlab direkt auf, weil ich das sofort will
        self._current_command = cmd
        self._command_event.set()

    def stop(self):
        self._should_exit = True
        self._command_event.set()


class Labjack(object):
    def __init__(self):

        self._lj_thread = LabjackThread()
        self._lj_thread.start()
        self._smallest_wait_secs_short = 0
        self._smallest_wait_secs_long = 0

        hw_version = self._lj_thread.dev_config['HardwareVersion']

        if hw_version == '1.20':
            self._smallest_wait_secs_short = 128e-6
            self._smallest_wait_secs_long = 32768e-6
        elif hw_version == '1.21':
            self._smallest_wait_secs_short = 64e-6
            self._smallest_wait_secs_long = 16384-6
        elif hw_version == '1.30':
            self._smallest_wait_secs_short = 128e-6
            self._smallest_wait_secs_long = 16384e-6
        else:
            raise RuntimeError('HW version %s not know.' % (hw_version, ))

    def __del__(self):
        self.uninit()

    def uninit(self):
        self._lj_thread.stop()

    def send_feedback_command(self, cmd):    # welches
        self._lj_thread.send_feedback_command(cmd)

    # --------------------------------------------------------------------------
    def wait_for_intrigger(self, base_level, n_trigger, chan_nr, chan_type):  # timeout unnecessary!
        #self.triggered = None
        base_level = bool(base_level)

        if chan_type == 'EIO':
            chan_nr = chan_nr + 8

        if chan_type == 'CIO':
            chan_nr = chan_nr + 16

        if n_trigger > 1:
            for i in range(0, n_trigger):
                while True:
                    time.sleep(0.01)
                    if self._lj_thread._device.getDIState(chan_nr) != base_level:
                        break

                if i == n_trigger-1:
                    return True 

                while True:
                    if self._lj_thread._device.getDIState(chan_nr) == base_level:
                        break  
        else:
            while True:
                if self._lj_thread._device.getDIState(chan_nr) != base_level:
                    return True
    # --------------------------------------------------------------------------                    
    # --------------------------------------------------------------------------    
    def intrigger_status(self, chan_nr, chan_type):
        #self.triggered = None
        if chan_type == 'EIO':
            chan_nr = chan_nr + 8

        if chan_type == 'CIO':
            chan_nr = chan_nr + 16

        return self._lj_thread._device.getDIState(chan_nr)        
    # -------------------------------------------------------------------------- 

    def get_wait(self, secs):
        commands = list()

        if secs <= 256 * self._smallest_wait_secs_short:
            commands.append(u3.WaitShort(int(math.floor(secs / self._smallest_wait_secs_short))))
        else:
            wait_cycles = int(math.floor(secs / self._smallest_wait_secs_long))
            if wait_cycles > 255:
                wait_cycles = 255

            commands.append(u3.WaitLong(wait_cycles))
            seconds_waited = wait_cycles * self._smallest_wait_secs_long
            seconds_remaining = secs - seconds_waited

            if seconds_remaining >= self._smallest_wait_secs_short:
                commands.extend(self.get_wait(seconds_remaining))

        return commands

class LabjackTrigger(object):
    def __init__(self, channel_group, method=TriggerMethod.MULTI, single_channel=None, num_bits=None):
        self._labjack = Labjack()
        if not isinstance(channel_group, ChannelGroup):
            raise TypeError('You must supply a channel group.')

        if not isinstance(method, TriggerMethod):
            raise TypeError('The method parameter must be of the TriggerMethod enum.')

        if not method == TriggerMethod.MULTI:
            if single_channel is None or single_channel < 0 or single_channel > 7:
                raise ValueError('You must set the single_channel parameter when using the SINGLE or PULSEWIDTH trigger method.')

        if method == TriggerMethod.PULSEWIDTH:
            if num_bits is None:
                raise ValueError('You must set the num_bits parameter when using the PULSEWIDTH trigger method.')
            if num_bits % 2 == 0:
                raise ValueError('num_bits must an uneven number.')

        self._channel_group = channel_group
        self._trigger_method = method
        self._current_command = None
        self.trigger_duration = 10e-3
        self.zero_duration = 20e-3
        self._single_channel = single_channel
        self._num_bits = num_bits
        self._command_chain = dict()
        # ---------------------------------------------------------------------------
        self.triggered = None
        # ---------------------------------------------------------------------------

    def __del__(self):
        self.uninit()

    def uninit(self):
        self._labjack.uninit()

    def create_trigger_command(self, trigger):
        command = Command(lj=self._labjack)

        if self._trigger_method == TriggerMethod.MULTI:
            states = [0, 0, 0]
            states[self._channel_group.value] = trigger
            command.append(u3.PortStateWrite(states))
            command.extend(self._labjack.get_wait(self.trigger_duration))
            command.append(u3.PortStateWrite([0, 0, 0]))
        elif self._trigger_method == TriggerMethod.SINGLE:
            states = [0, 0, 0]
            states[self._channel_group.value] = 2**self._single_channel
            command.append(u3.PortStateWrite(states))
            command.extend(self._labjack.get_wait(self.trigger_duration))
            command.append(u3.PortStateWrite([0, 0, 0]))
        elif self._trigger_method == TriggerMethod.PULSEWIDTH:
            io_number = (2 ** self._single_channel - 1) + self._channel_group.value*8
            bin_trigger = self._dec2bin(trigger)

            cur_high = 1
            for cur_bit in bin_trigger:
                command.append(u3.BitStateWrite(io_number, cur_high))
                if cur_bit:
                    command.extend(self._labjack.get_wait(self.trigger_duration))
                else:
                    command.extend(self._labjack.get_wait(self.zero_duration))

                cur_high = not cur_high

            command.append(u3.BitStateWrite(io_number, 0))

        return command

    def prepare_trigger(self, trigger, delay=0):
        self._command_chain[delay] = self.create_trigger_command(trigger)
        self._command_chain[delay].onset = delay
        self._schedule_trigger()

    def fire_trigger(self):
        self._labjack.send_feedback_command(self._current_command)

    # -------------------------------------------------------------------------
    def wait_for_intrigger(self, base_level, chan_nr, n_trigger, chan_type):
        self.triggered = self._labjack.wait_for_intrigger(chan_nr, base_level, n_trigger, chan_type)
        return self.triggered
    # -------------------------------------------------------------------------
    # -------------------------------------------------------------------------
    def intrigger_status(self, chan_nr, chan_type):
        self.triggered = self._labjack.intrigger_status(chan_nr, chan_type)
        return self.triggered
    # -------------------------------------------------------------------------
    
    def reset(self):
        self._command_chain = dict()
        self._current_command = []

    def _schedule_trigger(self):
        self._current_command = []

        if not self._command_chain:
            raise ValueError('No Triggers prepared.')

        current_onset = 0
        ordered_command_chain = collections.OrderedDict(sorted(self._command_chain.items()))
        for onset, item in ordered_command_chain.items():
            if onset > current_onset:
                if not self._current_command:
                    self._current_command.append(
                        Command([u3.PortStateWrite([0, 0, 0])], lj=self._labjack)
                    )

            self._current_command.append(item)

            current_onset = onset + item.duration

    def _dec2bin(self, value):

        if value >= 2**self._num_bits or value <= 0:
            raise ValueError('Invalid Trigger value')

        tmp_bin_representation = bin(value)[2:]
        bin_representation = [int(y) for y in tmp_bin_representation]
        bin_representation = [0]*(self._num_bits - len(bin_representation)) + bin_representation

        return bin_representation

def has_labjack():
    try:
        dev = u3.U3()
    except NullHandleException:
        return False

    dev.close()

    return True