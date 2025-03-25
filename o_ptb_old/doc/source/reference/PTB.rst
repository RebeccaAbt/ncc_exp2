PTB
===

.. autoclass:: +o_ptb.PTB

    .. rubric:: The constructor method:
    .. automethod:: +o_ptb.PTB.get_instance

    .. rubric:: Methods to set up the different subsystems:
    .. automethod:: +o_ptb.PTB.setup_screen
    .. automethod:: +o_ptb.PTB.setup_audio
    .. automethod:: +o_ptb.PTB.setup_trigger
    .. automethod:: +o_ptb.PTB.setup_response
    .. automethod:: +o_ptb.PTB.setup_tactile
    .. automethod:: +o_ptb.PTB.setup_eyetracker

    .. rubric:: Methods to schedule stimuli:
    .. automethod:: +o_ptb.PTB.draw
    .. automethod:: +o_ptb.PTB.prepare_audio
    .. automethod:: +o_ptb.PTB.schedule_audio
    .. automethod:: +o_ptb.PTB.set_audio_background
    .. automethod:: +o_ptb.PTB.stop_audio_background
    .. automethod:: +o_ptb.PTB.prune_audio
    .. automethod:: +o_ptb.PTB.prepare_trigger
    .. automethod:: +o_ptb.PTB.schedule_trigger
    .. automethod:: +o_ptb.PTB.prepare_tactile
    .. automethod:: +o_ptb.PTB.schedule_tactile

    .. rubric:: Methods to emit stimuli:
    .. automethod:: +o_ptb.PTB.play_without_flip
    .. automethod:: +o_ptb.PTB.play_on_flip
    .. automethod:: +o_ptb.PTB.flip

    .. rubric:: Methods to handle responses:
    .. automethod:: +o_ptb.PTB.wait_for_keys
    .. automethod:: +o_ptb.PTB.start_record_keys
    .. automethod:: +o_ptb.PTB.stop_record_keys
    .. automethod:: +o_ptb.PTB.get_recorded_keys

    .. rubric:: Methods to control the Eyetracker
    .. automethod:: +o_ptb.PTB.eyetracker_verify_eye_positions
    .. automethod:: +o_ptb.PTB.eyetracker_calibrate
    .. automethod:: +o_ptb.PTB.start_eyetracker
    .. automethod:: +o_ptb.PTB.stop_eyetracker
    .. automethod:: +o_ptb.PTB.save_eyetracker_data

    .. rubric:: Other methods:
    .. automethod:: +o_ptb.PTB.deinit
    .. automethod:: +o_ptb.PTB.is_screen_ready
    .. automethod:: +o_ptb.PTB.screen
    .. automethod:: +o_ptb.PTB.screenshot
    .. automethod:: +o_ptb.PTB.wait_for_stimulators
