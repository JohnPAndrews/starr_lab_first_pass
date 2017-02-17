function stimon = checkIfStimOnDataDriven(data,session,params)
%% This function uses a data driven approach to check if DBS stimulation is on 
% It does so by looking for stimulation artifcats 

% input: 
% data - matrix of [ time points x channels] (6 channels, PC + S
% params - a structure with fields: 
% params.minlength - min length of file in seconds 
% session a structure (read from json) with fields: 
% session.sr - sampling rate 
% convention); 
stimon = 0;
session.sr = str2num(strrep(session.xmldata.SenseChannelConfig.TDSampleRate,'Hz',''));
if session.sr > 399 && session.sr < 430 % range of stim 
    freqbandcheck = [100 200]; 
elseif session.sr > 799 && session.sr < 830 % range of stim 
    freqbandcheck = [100 200]; 
elseif session.sr > 99 && session.sr < 230
    freqbandcheck = [50 100]; 
end

params.sr = session.sr;
params.plottype = 'reg';
plot_data_freq_domain(data(:,1),params,'test')


L=length(data(:,1));
NFFT=1024;
X=fft(data(:,1),NFFT);
Px=X.*conj(X)/(NFFT*L); %Power of each freq components
fftOut = log10(Px(1:NFFT/2));
f=params.sr*(0:NFFT/2-1)/NFFT;

idxfreq = logical(f > freqbandcheck(1)) &  logical(f < freqbandcheck(2)); 

[peaks,loc,widths,proms] = findpeaks(fftOut(idxfreq));
minpeak = 3; % min peak height in log scale to declare  stim on 
minwidh = 10;  % min peak width (frequency range) to declare stim on; 
% figure
% findpeaks(fftOut(idxfreq),f(idxfreq),'MinPeakProminence',3,'Annotate','extents','MinPeakWidth',10)
[maxpeak, idxpeak] = max(peaks); 
if maxpeak > -5; % bcs in log10 scale - more negative = larger peack. 
     stimon = 1; 
end
% if widths(idxpeak)> minwidh && proms(idxpeak) > minpeak
%     stimon = 1; 
% else
%     stimon = 0; 
% end


end