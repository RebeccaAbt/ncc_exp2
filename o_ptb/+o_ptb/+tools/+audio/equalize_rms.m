function equalize_rms(stims, max_amp)
% Set all stimuli to the same RMS value.
%
% All stimuli in the cell array ``stims`` will be set to the maximum RMS value
% of all stimuli in the array. In order to avoid clipping, no sound will be louder
% than ``max_amp``.
%
% Parameters
% ----------
%
% stims : cell array of :class:`+o_ptb.+stimuli.+auditory.Base`
%   Cell array of the stimuli to equalize.
%
% max_amp : float
%   Maximum amplitude of any sound.

if nargin < 2
  max_amp = 0.9;
end %if

all_rms = [];
all_absmax = [];

for idx_stim = 1:length(stims)
  cur_stim = stims{idx_stim};
  if ~isa(cur_stim, 'o_ptb.stimuli.auditory.Base')
    error('Stims must be a cell array of o_ptb.stimuli.auditory.Base');
  end %if

  all_rms(end+1) = cur_stim.rms(1);
end %for

% equalize rms
max_rms = max(all_rms);

for idx_stim = 1:length(stims)
  cur_stim = stims{idx_stim};
  cur_stim.rms = max_rms;
end %for

% scale to avoid clipping
for idx_stim = 1:length(stims)
  cur_stim = stims{idx_stim};
  if ~isa(cur_stim, 'o_ptb.stimuli.auditory.Base')
    error('Stims must be a cell array of o_ptb.stimuli.auditory.Base');
  end %if

  all_absmax(end+1) = cur_stim.absmax(1);
end %for

max_absmax = max(all_absmax);

for idx_stim = 1:length(stims)
  cur_stim = stims{idx_stim};
  cur_stim.amplify(max_amp/max_absmax);
end %for

end
