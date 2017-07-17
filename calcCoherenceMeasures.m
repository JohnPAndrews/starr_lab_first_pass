function [coh_mag_lin,coh_phase_lin, phase_coherence, phase_difference,phase_mean]  = calcCoherenceMeasures(dat)
%% This function calcluates coherence measures 
% It assumes that data has already been filtered in the frequency range you
% want 
% It takes as input a matrix of 2 x data point of tilered data. 
% e.g. row 1 has one channel by all data point 
% row 2 has the other channels by all data points 
% This adapts some code written by Nicki 
addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/CircStat2012a'));
%% linear coherence 
for nc = 1:2 
    hilbert_data(nc,:) = hilbert(dat(nc,:));
end

%calculte cross spectra
cross_spect = hilbert_data(1,:).*conj(hilbert_data(2,:));

%normalize by autospectra, summed over time
coh_complex = sum(cross_spect)./(sqrt(sum(abs(hilbert_data(1,:)).^2).*(sum(abs(hilbert_data(2,:)).^2))));

%take magnitide
coh_mag_lin = abs(coh_complex);% magnitiude of the cohereence % plot this 
%take phase
coh_phase_lin = angle(coh_complex); % phase in radians of magniatiude coherence 
% this one takes into account ampllitude 
 
%% phase coherence  fix later 
phase_data = angle(hilbert_data);


% what I am currently plotting is the coalling phase coherhence is acually 
% the phase in radians. 
phase_coherence = abs(sum(exp(1i * (phase_data(1,:) - phase_data(2,:))), 'double')) / size(phase_data,2); % pllot this this is the phase coherence 
phase_difference = angle(exp(1i * (phase_data(1,:) - phase_data(2,:)))); % huge matrix for each datapoint % use rose 
phase_mean = circ_mean(phase_difference'); % the phase coherehce value (one number) % in radians 
% this just takes into account phase 



end