function [coh_data,phase_mean,phase_difference] = get_phase_coherenceoutput_phases_share(data, s_rate, frequency_range)
% Data is continuous data [n_channels x n_samples]
% s_rate is sample rate of data (Hz)
% frequency_range is a 2-element vector. First element is the frequency to start at, second element is the frequency to end at.



if(size(data,1) > size(data,2))
  fprintf('\n\nWarning: transposing data matrix to channels x samples\n\n');
  data = data';
end

n_channels = size(data,1);
n_samples = size(data,2);

% Bandpass filter data
fprintf('\tBandpass filtering from %d Hz to %d Hz\t', frequency_range(1), frequency_range(end));
%bandpass_data = X_bandpassfft(data, s_rate, frequency_range(1), frequency_range(end));
bandpass_data = eegfilt(data,s_rate,frequency_range(1),frequency_range(end));
clear data;
fprintf('\n');

% Hilbert transform
fprintf('\tHilbert transforming\t');
hilbert_data = zeros(n_channels,n_samples);
for channel_n = 1:n_channels
    hilbert_data(channel_n,:) = hilbert(squeeze(bandpass_data(channel_n,:)));
end
clear bandpass_data;
phase_data = angle(hilbert_data);
clear hilbert_data;
fprintf('\n');

% Calculate phase coherence
fprintf('\tComputing phase coherence\n');
coh_data = zeros(n_channels,n_channels);
for channel_n1 = 1:n_channels
  data1 = squeeze(phase_data(channel_n1,:));
  for channel_n2 = (channel_n1+1):n_channels
    data2 = squeeze(phase_data(channel_n2,:));
    coh_data(channel_n1,channel_n2) = abs(sum(exp(1i * (data1 - data2)), 'double')) / length(data1);
    phase_difference = angle(exp(1i * (data1 - data2)));
  end
end

phase_mean = circ_mean(phase_difference);


% Copy values to opposite half of matrix to make it symmetric
for chan1 = 1:size(coh_data,1)
  coh_data(chan1,chan1,:) = 1;
  for chan2 = (chan1+1):size(coh_data,1)
    coh_data(chan2,chan1,:) = coh_data(chan1,chan2,:);
  end
end







