classdef (Abstract) Base < handle & matlab.mixin.Copyable
  % This is the base class for all auditory stimuli.
  %
  % This means that:
  %
  % #. All auditory stimulus classes provide all the parameters and methods
  %    of this base class. Please refer to :doc:`/tutorial/o_ptb/triggers_sound`
  %    for details.
  % #. In order to create your own auditory stimulus class, you need to inherit
  %    from this base class.
  %
  % .. note ::
  %   All volume-related attributes (i.e., amplification_factor, rms, db and
  %   absmax) are related to each other. If you change one of them, the others
  %   reflect the new volume.
  %
  % .. note ::
  %   It is not possible to play sounds at a volume that would lead to clipping.
  %
  % .. note ::
  %   Sampling rate conversion is done automatically.
  %
  % Attributes
  % ----------
  %
  % amplification_factor : [float float]
  %   The factor by which each channel of the sound is amplified.
  %
  % rms : [float float]
  %   The root-mean-square of the two channels.
  %
  % db : [float float]
  %   The maximum amplitude of both channels expressed in dB. 0dB is the maximum
  %   volume.
  %
  % absmax : [float float]
  %   The maximum amplitude of both channels.
  %
  % muted_channels : int or array of ints
  %   If empty (i.e. []), both channels are played. If set to 1, the left
  %   channel is muted. If set to 2, the right channel is muted. If set to
  %   [1 2], both channels are muted.
  %
  % duration : float
  %   The duration of the sound in seconds.
  %
  % n_samples : int
  %   The number of samples of the sound.
  
  %Copyright (c) 2016-2017, Thomas Hartmann
  %
  % This file is part of the o_ptb class library, see: https://gitlab.com/thht/o_ptb
  %
  %    o_ptb is free software: you can redistribute it and/or modify
  %    it under the terms of the GNU General Public License as published by
  %    the Free Software Foundation, either version 3 of the License, or
  %    (at your option) any later version.
  %
  %    o_ptb is distributed in the hope that it will be useful,
  %    but WITHOUT ANY WARRANTY; without even the implied warranty of
  %    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  %    GNU General Public License for more details.
  %
  %    You should have received a copy of the GNU General Public License
  %    along with obob_ownft. If not, see <http://www.gnu.org/licenses/>.
  %
  %    Please be aware that we can only offer support to people inside the
  %    department of psychophysiology of the university of Salzburg and
  %    associates.
  
  properties (Access = public)
    muted_channels = [];
    amplification_factor = [1 1];
  end %properties
  
  properties (Access = public, Dependent=true)
    rms;
    absmax;
    db;
    duration;
    n_samples;
  end %properties
  
  properties (SetAccess = protected, GetAccess = public)
    s_rate;
  end
  
  properties (SetAccess = private, GetAccess = public)
    n_channels = 2;
  end %properties
  
  properties (Access = protected)
    sound_data;
  end %properties
  
  properties (Access = private)
    sound_data_resampled;
    s_rate_resampled;
  end %properties
  
  methods (Access = protected)
    function reset_cache(obj)
      obj.sound_data_resampled = [];
      obj.s_rate_resampled = [];
    end %function
    
    function samples = time2samples(obj, time)
      samples = round(time * obj.s_rate);
      if samples < 1
        samples = 1;
      end %if
      
    end %function
    
    function time = samples2time(obj, samples)
      time = samples / obj.s_rate;
      if time < 0
        time = 0;
      end %if
    end %function
    
    
    function filter(obj, f, a, dev)
      % Apply an optimal Parks-McClellan FIR filter according to the specs.
      %
      % Parameters
      % ----------
      %
      % f : vector of floats
      %   Edge frequencies
      %
      % a : vector of floats
      %   Desired amplitued at edge frequencies
      %
      % dev : vector of floats
      %   Maximum allowed ripple and deviation
      
      [n,fo,ao,w] = firpmord(f, a, dev, obj.s_rate);
      b = firpm(n,fo,ao,w);
      
      for chan = 1:obj.n_channels
        obj.sound_data(:, chan) = filtfilt(b, 1, obj.sound_data(:, chan));
      end %for
    end %function
  end %methods
  
  methods
    function obj = Base()
      obj.amplification_factor = [1 1];
    end %function
    
    function rms = get.rms(obj)
      rms = sqrt(mean((obj.sound_data.*repmat(obj.amplification_factor, size(obj.sound_data, 1), 1)).^2));
    end %function
    
    function set.rms(obj, rms)
      factor = rms./obj.rms;
      obj.amplify(factor);
    end %function
    
    function absmax = get.absmax(obj)
      absmax = max(abs(obj.sound_data.*repmat(obj.amplification_factor, size(obj.sound_data, 1), 1)));
    end %function
    
    function set.absmax(obj, absmax)
      factor = absmax./obj.absmax;
      obj.amplify(factor);
    end %function
    
    function db = get.db(obj)
      db = 20*log10(obj.absmax);
    end %function
    
    function set.db(obj, db)
      obj.absmax = 10.^(db./20);
    end %function
    
    function set.amplification_factor(obj, amp_fact)
      if length(amp_fact) > 2
        error('Volume adjustments must provide either one value or two values');
      end %if
      
      if length(amp_fact) == 1
        amp_fact = [amp_fact amp_fact];
      end %if
      
      if numel(obj.sound_data) > 0
        new_absmax = max(abs(obj.sound_data.*repmat(amp_fact, size(obj.sound_data, 1), 1)));
        
        if new_absmax > 1
          error('o_ptb:amp_too_high', 'The amplification is too high and will lead to clipping.');
        end %if
      end %if
      
      obj.amplification_factor = amp_fact;
    end %function
    
    function duration = get.duration(obj)
      duration = obj.n_samples ./ obj.s_rate;
    end %function
    
    function n_samples = get.n_samples(obj)
      n_samples = size(obj.sound_data, 1);
    end %function
    
    function set.sound_data(obj, data)
      % Setter function for the sound_data field. Takes care of clearing
      % the resampled fields.
      
      this_n_channels = size(data, 2);
      if this_n_channels > 2
        error('o_ptb can only handle audio data with one or two channels');
      end %if
      
      if this_n_channels == 1
        data = repmat(data, 1, 2);
      end %if
      
      obj.sound_data = data;
      obj.reset_cache();
    end %function
    
    function set.s_rate(obj, s_rate)
      obj.s_rate = s_rate;
      obj.reset_cache();
    end %function
    
    
    function set.muted_channels(obj, data)
      if ~isempty(data) && ~(any(data == [1 2]) && length(data) < 3)
        error('muted_channels can only be either [], 1 (for the left channel), 2 (for the right channel) or [1 2]');
      end %if
      obj.muted_channels = data;
    end %function
    
    
    function result = plus(a, b)
      % Add two sounds using the + operator.
      %
      % If you have two sounds ``sound_a`` and ``sound_b``, you can add the
      % two by doing this:
      %
      % .. code-block ::
      %
      %   new_sound = sound_a + sound_b;
      final_srate = a.s_rate;
      
      if b.s_rate > a.s_rate
        final_srate = b.s_rate;
      end %if
      
      data_a = a.get_sound_data(final_srate, 2);
      data_b = b.get_sound_data(final_srate, 2);
      
      final_n_samples = max(size(data_a, 1), size(data_b, 1));
      
      data_a(end:final_n_samples, :) = 0;
      data_b(end:final_n_samples, :) = 0;
      
      final_data = data_a + data_b;
      
      result = o_ptb.stimuli.auditory.FromMatrix(final_data', final_srate);
    end %function
    
    
    function data = get_sound_data(obj, s_rate, n_channels, duration)
      
      if isempty(obj.sound_data)
        error('No sound data available');
      end %if
      
      if nargin < 4
        duration = obj.duration;
      end %if
      
      if n_channels < 1 || n_channels > 2
        error('Only mono or stereo is supported');
      end %if
      
      if isempty(obj.sound_data_resampled) || isempty(obj.s_rate_resampled) || obj.s_rate_resampled ~= s_rate
        obj.sound_data_resampled = s_rate;
        if s_rate == obj.s_rate
          obj.sound_data_resampled = obj.sound_data;
        else
          obj.sound_data_resampled = resample(obj.sound_data, s_rate, obj.s_rate);
        end %if
        obj.s_rate_resampled = s_rate;
      end %if
      
      data = obj.sound_data_resampled .* repmat(obj.amplification_factor, size(obj.sound_data_resampled, 1), 1);
      
      if size(data, 2) > n_channels
        data = data(:, n_channels);
      elseif size(data, 2) < n_channels
        data = repmat(data, 1, n_channels);
      end %if
      
      requested_samples = ceil(duration*s_rate);
      
      while requested_samples > size(data, 1)
        data = repmat(data, ceil(requested_samples / size(data, 1)), 1);
      end %if
      
      if requested_samples < size(data, 1)
        data = data(1:requested_samples, :);
      end %if
      
      data(:, obj.muted_channels) = 0;
      
      % check for clipping...
      if max(abs(data(:))) > 1
        error('Sound volume will lead to clipping. Please lower the sound intensity.');
      end %if
    end %function
    
    
    function save_wav(obj, fname, srate)
      % Save the sound data to a wav file.
      %
      % Parameters
      % ----------
      %
      % fname : string
      %   The filename to save the data to.
      %
      % srate : int, optional
      %   Sampling rate. defaults to the sampling rate of the stimulus.
      
      if nargin < 3
        srate = obj.s_rate;
      end %if
      
      audiowrite(fname, obj.get_sound_data(srate, 2), srate);
    end %function
    
    
    function amplitude_modulate(obj, mod_freq, mod_depth)
      % Apply amplitude modulation to the sound.
      %
      % Parameters
      % ----------
      %
      % mod_freq : float
      %   Frequency of the modulation
      %
      % mod_depth : float
      %   Depth of the modulation
      
      if nargin < 3
        mod_depth = 1;
      end %if
      
      tmp_s_idx = 1:obj.n_samples;
      
      mod_sin = sin(2*pi*tmp_s_idx*(mod_freq/obj.s_rate))';
      mod_sin = (mod_sin ./ 2) + 0.5;
      mod_sin = mod_sin .* mod_depth;
      mod_sin = mod_sin + (1-mod_depth);
      mod_sin = repmat(mod_sin, 1, obj.n_channels);
      
      obj.sound_data = obj.sound_data .* mod_sin;
    end %function
    
    
    function flip_sound(obj)
      % Flip the sound so it will be played backwards.
      obj.sound_data = obj.sound_data(end:-1:1, :);
      obj.reset_cache;
    end %function
    
    
    function flip_polarity(obj)
      % Flip the polarity of the sound.
      obj.sound_data = obj.sound_data * -1;
      obj.reset_cache;
    end %function
    
    function amplify(obj, factor)
      % Amplify the sound.
      %
      % Parameters
      % ----------
      %
      % factor : float
      %   Amplification factor.
      
      obj.amplification_factor = obj.amplification_factor .* factor;
    end %function
    
    function amplify_db(obj, db)
      % Amplify the sound by dB.
      %
      % Parameters
      % ----------
      %
      % db : float
      %   dB to add to the volume.
      factor = 10.^(db/20);
      obj.amplify(factor);
    end %function
    
    function add_background(obj, background)
      background = copy(background);
      background.amplify_db(-obj.db);
      background_data = background.get_sound_data(obj.s_rate, obj.n_channels, obj.duration * 1.1);
      background_data = background_data(1:size(obj.sound_data, 1), :);
      
      obj.sound_data = obj.sound_data + background_data;
    end %function
    
    function apply_hanning(obj)
      % Apply a hanning window to the sound.
      
      obj.sound_data = obj.sound_data .* hanning(length(obj.sound_data));
    end %function
    
    function apply_sin_ramp(obj, duration)
      % Apply a sine ramp to the start and end of the sound.
      %
      % Parameters
      % ----------
      %
      % duration : float
      %   Duration of the ramp in seconds.
      
      nr = floor(obj.s_rate * duration);
      r = sin(linspace(0, pi/2, nr));
      r = [r, ones(1, obj.n_samples - nr * 2), fliplr(r)]';
      
      r = repmat(r, 1, obj.n_channels);
      
      obj.sound_data = obj.sound_data .* r;
    end %function
    
    
    function apply_cos_ramp(obj, duration)
      % Apply a cosine ramp to the start and end of the sound.
      %
      % Parameters
      % ----------
      %
      % duration : float
      %   Duration of the ramp in seconds.
      
      nr = floor(obj.s_rate * duration);
      r = 1 - cos(linspace(0, pi/2, nr));
      r = [r, ones(1, obj.n_samples - nr * 2), fliplr(r)]';
      
      r = repmat(r, 1, obj.n_channels);
      
      obj.sound_data = obj.sound_data .* r;
    end %function
    
    function vocode(obj, n_channels, freq_range)
      % Vocode the sound.
      %
      % Parameters
      % ----------
      %
      % n_channels : int
      %   Number of vocoder channels.
      %
      % freq_range : [float float], optional
      %   The frequency range to use for vocoding.
      
      if nargin < 3
        freq_range = [100 10000];
      end %if
      
      p = [];
      p.analysis_filters = filter_bands(freq_range, n_channels, obj.s_rate);
      
      for idx_channels = 1:obj.n_channels
        obj.sound_data(:, idx_channels) = vocode(obj.sound_data(:, idx_channels), obj.s_rate, p);
      end %if
    end %function
    
    function fadeinout(obj, fade_length)
      % Apply linear fade in and fade out.
      %
      % Parameters
      % ----------
      %
      % fade_length : float
      %   Duration of the fade in seconds.
      
      fade_samples = obj.time2samples(fade_length);
      fade_in = linspace(0, 1, fade_samples);
      fade_out = linspace(1, 0, fade_samples);
      
      for chan = 1:obj.n_channels
        obj.sound_data(1:fade_samples, chan) = obj.sound_data(1:fade_samples, chan) .* fade_in';
        obj.sound_data(end-(fade_samples-1):end, chan) = obj.sound_data(end-(fade_samples-1):end, chan) .* fade_out';
      end %for
    end %function
    
    function filter_lowpass(obj, freq, transition_width, max_passband_ripple, max_stopband_ripple)
      % Apply lowpass filter.
      %
      % Parameters
      % ----------
      %
      % freq : float
      %   Edge frequency
      %
      % transition_width: float, optional
      %   Bandwidth between the passband and the stopband. Default = freq *
      %   0.05
      %
      % max_passband_ripple : float, optional
      %   Maximum allowed passband ripple. Default = 3
      %
      % max_stopband_ripple : float, optional
      %   Maximum allowed stopband ripple. Default = 20
      
      if nargin < 3
        transition_width = freq * 0.05;
      end %if
      
      if nargin < 4
        max_passband_ripple = 3;
      end %if
      
      if nargin < 5
        max_stopband_ripple = 20;
      end %if
      
      f = [freq freq+transition_width];
      a = [1 0];
      
      dev_passband_mag = db2mag(max_passband_ripple);
      dev_passband = (dev_passband_mag-1) / (dev_passband_mag+1);
      
      dev_stopband = db2mag(-max_stopband_ripple);
      
      dev = [dev_passband dev_stopband];
      
      obj.filter(f, a, dev);
    end %function
    
    function filter_highpass(obj, freq, transition_width, max_passband_ripple, max_stopband_ripple)
      % Apply highpass filter.
      %
      % Parameters
      % ----------
      %
      % freq : float
      %   Edge frequency
      %
      % transition_width: float, optional
      %   Bandwidth between the passband and the stopband. Default = freq *
      %   0.05
      %
      % max_passband_ripple : float, optional
      %   Maximum allowed passband ripple. Default = 3
      %
      % max_stopband_ripple : float, optional
      %   Maximum allowed stopband ripple. Default = 20
      
      if nargin < 3
        transition_width = freq * 0.05;
      end %if
      
      if nargin < 4
        max_passband_ripple = 3;
      end %if
      
      if nargin < 5
        max_stopband_ripple = 20;
      end %if
      
      f = [freq-transition_width freq];
      a = [0 1];
      
      dev_passband_mag = db2mag(max_passband_ripple);
      dev_passband = (dev_passband_mag-1) / (dev_passband_mag+1);
      
      dev_stopband = db2mag(-max_stopband_ripple);
      
      dev = [dev_stopband, dev_passband];
      
      obj.filter(f, a, dev);
    end %function
    
    function filter_bandpass(obj, l_freq, h_freq, l_transition_width, h_transition_width, max_passband_ripple, max_stopband_ripple)
      % Apply bandpass filter.
      %
      % Parameters
      % ----------
      %
      % l_freq : float
      %   Low edge frequency
      %
      % h_freq : float
      %   High edge frequency
      %
      % l_transition_width: float, optional
      %   Bandwidth between the lower passband and the stopband. Default = l_freq *
      %   0.05
      %
      % h_transition_width: float, optional
      %   Bandwidth between the higher passband and the stopband. Default = h_freq *
      %   0.05
      %
      % max_passband_ripple : float, optional
      %   Maximum allowed passband ripple. Default = 3
      %
      % max_stopband_ripple : float, optional
      %   Maximum allowed stopband ripple. Default = 20
      
      if nargin < 4
        l_transition_width = l_freq * 0.05;
      end %if
      
      if nargin < 5
        h_transition_width = h_freq * 0.05;
      end %if
      
      if nargin < 6
        max_passband_ripple = 3;
      end %if
      
      if nargin < 7
        max_stopband_ripple = 20;
      end %if
      
      f = [l_freq-l_transition_width l_freq h_freq h_freq+h_transition_width];
      a = [0 1 0];
      
      dev_passband_mag = db2mag(max_passband_ripple);
      dev_passband = (dev_passband_mag-1) / (dev_passband_mag+1);
      
      dev_stopband = db2mag(-max_stopband_ripple);
      
      dev = [dev_stopband, dev_passband, dev_stopband];
      
      obj.filter(f, a, dev);
    end %function
    
    function filter_bandstop(obj, l_freq, h_freq, l_transition_width, h_transition_width, max_passband_ripple, max_stopband_ripple)
      % Apply bandstop filter.
      %
      % Parameters
      % ----------
      %
      % l_freq : float
      %   Low edge frequency
      %
      % h_freq : float
      %   High edge frequency
      %
      % l_transition_width: float, optional
      %   Bandwidth between the lower passband and the stopband. Default = l_freq *
      %   0.05
      %
      % h_transition_width: float, optional
      %   Bandwidth between the higher passband and the stopband. Default = h_freq *
      %   0.05
      %
      % max_passband_ripple : float, optional
      %   Maximum allowed passband ripple. Default = 3
      %
      % max_stopband_ripple : float, optional
      %   Maximum allowed stopband ripple. Default = 20
      
      if nargin < 4
        l_transition_width = l_freq * 0.05;
      end %if
      
      if nargin < 5
        h_transition_width = h_freq * 0.05;
      end %if
      
      if nargin < 6
        max_passband_ripple = 3;
      end %if
      
      if nargin < 7
        max_stopband_ripple = 20;
      end %if
      
      f = [l_freq-l_transition_width l_freq h_freq h_freq+h_transition_width];
      a = [1 0 1];
      
      dev_passband_mag = db2mag(max_passband_ripple);
      dev_passband = (dev_passband_mag-1) / (dev_passband_mag+1);
      
      dev_stopband = db2mag(-max_stopband_ripple);
      
      dev = [dev_passband, dev_stopband, dev_passband];
      
      obj.filter(f, a, dev);
    end %function    
    
    function plot_spectrum(obj)
      % Plot spectrum
      
      for chan = 1:obj.n_channels
        figure; pwelch(obj.sound_data(:, chan), [], [], [], obj.s_rate);
      end %for
    end %function
    
    function plot_waveform(obj)
      % Plot waveform
      
      for chan = 1:obj.n_channels
        figure; plot(obj.samples2time(1:obj.n_samples), obj.sound_data(:, chan));
      end %for
    end %function
    
    function debug_play_now(obj)
      % Plays the stimulus right now. Do not use in real experiment
      %
      % .. warning::
      %    This method should only be used to interactively check
      %    a stimulus. It should not be used in your real experiment
      %    script!
      
      ptb = o_ptb.PTB.get_instance();
      ptb.prepare_audio(obj);
      ptb.schedule_audio();
      ptb.play_without_flip();
    end %function
    
    function set_to_max_amplification(obj)
      % Set this stimulus to the maximum volume without clipping.
      
      amp_facts = [];
      for cur_chan = 1:obj.n_channels
        cur_absmax = max(abs(obj.sound_data(:, cur_chan)));
        
        amp_facts(cur_chan) = 1/cur_absmax;
      end %for
      
      obj.amplification_factor = amp_facts;
    end %function
  end
  
end
