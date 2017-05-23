function [coh,coh_angle] = get_linear_coherence_eegfilt_share(data, s_rate, center_frequency)
% Data is continuous data [n_channels x n_samples]
% s_rate is sample rate of data (Hz)
% frequency_range is a 2-element vector. First element is the frequency to start at, second element is the frequency to end at.

addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/from_andy/eeglab14_1_0b'));

if(size(data,1) > size(data,2))
    fprintf('\n\nWarning: transposing data matrix to channels x samples\n\n');
    data = data';
end

n_channels = size(data,1);
n_samples = size(data,2);

% Bandpass filter data
fprintf('\tBandpass filtering from %d Hz to %d Hz\t', center_frequency);
%bandpass_data = X_bandpassfft(data, s_rate, frequency_range(1), frequency_range(end));
for channel_n = 1:n_channels
    %  hilbert_data(channel_n,:)=...
    %             gaussian_filter_signal(...
    %             'output_type',...
    %             'analytic_signal',...
    %             'raw_signal',...
    %             data(channel_n,:),...
    %             'sampling_rate',...
    %             s_rate,...
    %             'center_frequency',...y
    %             center_frequency,...
    %             'fractional_bandwidth',...
    %             fractional_bandwidth);
    
    filtorder = 0; % choose defaults 
    revfilt = 0; % choose d efault 
    epochframes = 0; 
    firtypeuse = 'fir1'; 
%     data,srate,locutoff,hicutoff,epochframes,filtorder,revfilt,firtype,causal
    hilbert_data(channel_n,:) = hilbert(...
        eegfilt(data(channel_n,:),s_rate,center_frequency(1),center_frequency(2),...
        epochframes,filtorder, revfilt, firtypeuse)); 
end
%bandpass_data = eegfilt(data,s_rate,frequency_range(1),frequency_range(end));
clear data;
fprintf('\n');

% Hilbert transform
fprintf('\tHilbert transforming\t');

%clear bandpass_data;

fprintf('\n');

% Calculate phase coherence
fprintf('\tComputing phase coherence\n');
%coh_data = zeros(n_channels,n_channels);

%calculte cross spectra
cross_spect = hilbert_data(1,:).*conj(hilbert_data(2,:));

%normalize by autospectra, summed over time
coh_complex = sum(cross_spect)./(sqrt(sum(abs(hilbert_data(1,:)).^2).*(sum(abs(hilbert_data(2,:)).^2))));

%take magnitide
coh = abs(coh_complex);
%take phase
coh_angle = angle(coh_complex);

end