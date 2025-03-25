classdef SoundTests < helpers.TestCase
  %SOUNDTESTS Summary of this class goes here
  %   Detailed explanation goes here
  
  methods(Test)
    function test_add_sounds(testCase)
      sound_a = o_ptb.stimuli.auditory.Sine(440, 1);
      sound_a.fadeinout(0.05);
      sound_a.db = -20;
      sound_b = o_ptb.stimuli.auditory.Sine(550, 2);
      sound_b.fadeinout(0.05);
      sound_b.db = -30;
      
      % add sounds...
      new_sound = sound_a + sound_b;
      
      % get individual sounds....
      sound_a_data = sound_a.get_sound_data(96000, 2);
      sound_b_data = sound_b.get_sound_data(96000, 2);
      
      sound_a_data(size(sound_a_data, 1)+1:size(sound_b_data, 1), :) = 0;
      
      new_sound_data = new_sound.get_sound_data(96000, 2);
      
      % assert
      data_cmp_sum = sound_a_data + sound_b_data;
      data_cmp_new = new_sound_data;
      
      data_cmp_sum(192000, :) = 0;
      data_cmp_sum(96000, :) = 0;
      data_cmp_new(192000, :) = 0;
      data_cmp_new(96000, :) = 0;
      testCase.assertEqual(data_cmp_new, data_cmp_sum, 'RelTol', 1e-10);
      
    end %function
    
    function test_adjust_volume(testCase)
      audio = o_ptb.stimuli.auditory.Sine(440, 1);
      
      % query all properties....
      audio.rms
      audio.amplification_factor
      audio.absmax
      audio.db
      
      % set all...
      audio.rms = 0.5;
      audio.rms = [0.3 0.4];
      audio.db = -20;
      audio.db = [-21 -13];
      audio.absmax = 1;
      audio.absmax = [0.9 0.99];
      
      % do stuff that should fail....
      testCase.verifyError(@() testCase.set_too_high_amp1(audio), 'o_ptb:amp_too_high');
      testCase.verifyError(@() testCase.set_too_high_amp2(audio), 'o_ptb:amp_too_high');
      
      % play...
      audio.absmax = 0.01;
      
      ptb = o_ptb.PTB.get_instance();
      ptb.prepare_audio(audio);
      ptb.schedule_audio();
      
      ptb.play_without_flip();
      WaitSecs(1.1);
      
    end %function
    
    function test_save_to_wav(testCase)
      wav_fname = sprintf('%s.wav', tempname);
      wav_fname_lowsrate = sprintf('%s.wav', tempname);
      wav_srate = 48000;
      
      
      audio = o_ptb.stimuli.auditory.Sine(440, 1);
      audio.db = -20;
      
      audio.save_wav(wav_fname);
      audio.save_wav(wav_fname_lowsrate, wav_srate);
      
      [audio_from_wav, Fs] = audioread(wav_fname);
      [audio_from_wav_lowsrate, Fs_lowsrate] = audioread(wav_fname_lowsrate);
      
      testCase.assertEqual(single(audio.get_sound_data(Fs, 2)), single(audio_from_wav), 'absTol', single(1e-3));
      testCase.assertEqual(single(audio.get_sound_data(Fs_lowsrate, 2)), single(audio_from_wav_lowsrate), 'absTol', single(1e-3));
    end %function
    
    function test_amp_mod(testCase)
      sound_freq = 440;
      mod_freq = 40;
      mod_depth = 0.4;
      audio = o_ptb.stimuli.auditory.Sine(sound_freq, 1);
      [freqs, power] = helpers.spectrum(audio);
      [~, idx_peaks] = findpeaks(power, 'MinPeakHeight', 0.01);
      
      testCase.assertEqual(sound_freq, freqs(idx_peaks), 'relTol', 1e-3);
      
      audio.amplitude_modulate(mod_freq);
      
      [freqs, power] = helpers.spectrum(audio);
      [~, idx_peaks] = findpeaks(power, 'MinPeakHeight', 0.01);
      
      all_freqs = sort([sound_freq, sound_freq-mod_freq, sound_freq+mod_freq]);
      testCase.assertEqual(all_freqs, freqs(idx_peaks), 'relTol', 1e-3);
      testCase.assertEqual([0.5, 1, 0.5]', power(idx_peaks), 'relTol', 1e-3)
      
      audio = o_ptb.stimuli.auditory.Sine(sound_freq, 1);
      audio.amplitude_modulate(mod_freq, mod_depth);
      
      [freqs, power] = helpers.spectrum(audio);
      [~, idx_peaks] = findpeaks(power, 'MinPeakHeight', 0.01);
      
      all_freqs = sort([sound_freq, sound_freq-mod_freq, sound_freq+mod_freq]);
      testCase.assertEqual(all_freqs, freqs(idx_peaks), 'relTol', 1e-3);
      testCase.assertEqual([0.5*mod_depth, 1+(1-mod_depth), 0.5*mod_depth]', power(idx_peaks), 'relTol', 1e-3)
    end %function
  end %Test methods
  
  methods(Access=protected)
    function set_too_high_amp1(obj, audio)
      audio.absmax = 1.1;
    end %function
    
    function set_too_high_amp2(obj, audio)
      audio.db = 1;
    end %function
  end %protected methods
end

