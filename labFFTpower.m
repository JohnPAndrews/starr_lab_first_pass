function [f, fftOut]= labFFTpower(data, samplingRate)
% [f,fftout]=labFFT(data, samplingRate) returns the power of the different frequencies in the data
%   - data - amplitude over time. 
%   - samplingRate - the sampling rate of the data
% returns :
%   - fftOut - the power of the different frequencies 
%   - f - the frequencies

fftOut = fft(data);  

datalen=length(data);
fftlen=length(fftOut);

f = samplingRate/2*linspace(0,1,fftlen/2+1);

fftOut = (abs(fftOut(1:length(f))).^2) / datalen; % return the power of the frequencies
