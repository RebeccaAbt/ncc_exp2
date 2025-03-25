function ptb_config = config_ptb()

ptb_config = th_ptb.PTB_Config();

ptb_config.fullscreen     = false;
ptb_config.window_scale   = 0.5;
ptb_config.skip_sync_test = true;
ptb_config.crappy_screen  = true;
ptb_config.hide_mouse     = false;
ptb_config.internal_config.blend_function = {'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'};
%ptb_config.internal_config.blend_function = {'GL_SRC_ALPHA', 'GL_ONE'};
ptb_config.background_color = 0;

ptb_config.datapixxresponse_config.button_mapping('button_press') = ptb_config.datapixxresponse_config.Green;
ptb_config.keyboardresponse_config.button_mapping('button_press') = KbName('space');

ptb_config.corticalmetrics_config.cm_dll = fullfile('C:\Users\gaetan\Documents\cm', 'CM.dll');
ptb_config.corticalmetrics_config.stimulator_mapping('left') = 'CM6-0034003E5931570620393639';
ptb_config.corticalmetrics_config.trigger_mapping('left') = 128;

end %function