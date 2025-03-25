function [FlipStart, params, trial, ptb]=showtrial(params, trial, ptb)

% -- fixation onset
ptb.draw(params.fix_cross);
Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
params.t1=ptb.flip(params.trialStart+params.flipWait);

%%

if params.task == 1 && params.trialorderRandom3(trial) ~= 3      % auditory
this_sound=params.stimuli(params.trialorderRandom2(trial)).sound;
if params.trialorderRandom3(trial) == 1
this_sound.db = params.stimuli(params.trialorderRandom2(trial)).thr.current_probe_value;
elseif params.task == 1 && params.trialorderRandom3(trial) == 2
this_sound.db = -10;
end    
params.intensity = this_sound.db(1);
ptb.prepare_audio(this_sound);
ptb.schedule_audio;
elseif params.task == 1 && params.trialorderRandom3(trial) == 3
params.intensity = -Inf;
end

if params.task == 2 && params.trialorderRandom3(trial) ~= 3       % tactile
this_vib=params.stimuli(params.trialorderRandom2(trial)).tactile;
if params.trialorderRandom3(trial) == 1
this_vib.amplitude = params.stimuli(params.trialorderRandom2(trial)).thr.current_probe_value;
% ------------------------------------------------- v
this_vib.duration = params.stimon_duration/1000;
% ------------------------------------------------- ^
elseif params.task == 2 && params.trialorderRandom3(trial) == 2
this_vib.amplitude = params.max_tactile_intensity;
% ------------------------------------------------- v
this_vib.duration = params.stimon_duration/1000;
% ------------------------------------------------- ^

end    
params.intensity = this_vib.amplitude;
ptb.prepare_tactile(this_vib);
ptb.schedule_tactile();
elseif params.task == 2 && params.trialorderRandom3(trial) == 3
params.intensity = 0;
end

if params.task == 3 && params.trialorderRandom3(trial) ~= 3        % visual
this_gabor=params.stimuli(params.trialorderRandom2(trial)).gabor;
if params.trialorderRandom3(trial) == 1
this_gabor.contrast = params.stimuli(params.trialorderRandom2(trial)).thr.current_probe_value;
elseif params.task == 3 && params.trialorderRandom3(trial) == 2
this_gabor.contrast = params.max_visual_intensity;
end    
params.intensity = this_gabor.contrast;
elseif params.task == 3 && params.trialorderRandom3(trial) == 3
params.intensity = 0;
end

ptb.play_on_flip;

% ------- stimulus onset 
% auditory / somatosensory / visual stimulus onset

if params.task == 3 && params.trialorderRandom3(trial) ~= 3
ptb.draw(this_gabor); 
ptb.draw(params.fix_cross);
Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
params.t2=ptb.flip(params.t1+params.flip_prestim_jitter(trial));
else
ptb.draw(params.fix_cross); % auditory / tactile stimuli already scheduled; will be played on next flip
Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
params.t2=ptb.flip(params.t1+params.flip_prestim_jitter(trial));
end

% --- stimulus offset / poststim period  
ptb.draw(params.fix_cross);
Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
params.t3=ptb.flip(params.t2+params.stim_ontime);

% --- response period onset
  Screen('TextSize', ptb.win_handle, 20);
  DrawFormattedText(ptb.win_handle, '?', 'center', 'center', [0 0 0]);
  Screen('FrameRect', ptb.win_handle, [0 0 0], ptb.win_rect, params.framesize);
  params.t4=ptb.flip(params.t3+params.flip_poststim_jitter(trial));

FlipStart.t1=params.t1;
FlipStart.t2=params.t2;
FlipStart.t3=params.t3;
FlipStart.t4=params.t4;

end