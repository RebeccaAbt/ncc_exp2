%% clear...
clear all global
close all
restoredefaultpath;

%% add path
addpath('/home/th/git/o_ptb'); % change this to point to o_ptb

o_ptb.init_ptb('/home/th/git_other/Psychtoolbox-3/');

%% configure o_ptb
ptb_cfg = o_ptb.PTB_Config;
ptb_cfg.fullscreen = false;
ptb_cfg.window_scale = 0.2;
ptb_cfg.skip_sync_test = true;
ptb_cfg.hide_mouse = false;
ptb_cfg.internal_config.trigger_subsystem = @o_ptb.subsystems.trigger.LSL;
ptb_cfg.lsltrigger_config.liblsl_matlab_path = '/home/th/git/lsl/liblsl-Matlab';
ptb_cfg.lsltrigger_config.trigger_type = 'int';

ptb = o_ptb.PTB.get_instance(ptb_cfg);

ptb.setup_trigger();
ptb.setup_screen();

%% play some visual stimuli....
fixcross = o_ptb.stimuli.visual.FixationCross();

n_trials = 40;
iti = 1;
iti_jitter = 0.3;
stim_on_screen = 0.5;

now = GetSecs();

for idx_trial = 1:n_trials
  ptb.draw(fixcross);
  ptb.prepare_trigger(100);
  ptb.schedule_trigger();
  ptb.play_on_flip();
  
  now = ptb.flip(now + stim_on_screen);
  
  text = o_ptb.stimuli.visual.Text(sprintf('%d', idx_trial));
  ptb.draw(text);
  ptb.prepare_trigger(idx_trial);
  ptb.schedule_trigger();
  ptb.play_on_flip();
  
  this_iti = RandLim(1, iti-iti_jitter, iti+iti_jitter);
  
  now = ptb.flip(now + this_iti);
end %for