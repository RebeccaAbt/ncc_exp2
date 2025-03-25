function [freqs, power] = spectrum(audio)
%SPECTRUM Summary of this function goes here
%   Detailed explanation goes here
max_f = audio.s_rate/2;

fft_audio = fft(audio.get_sound_data(audio.s_rate, 1));
freqs = linspace(0, max_f, audio.n_samples/2);
power = abs(fft_audio(1:length(freqs))) ./ (length(freqs)/2);
end

