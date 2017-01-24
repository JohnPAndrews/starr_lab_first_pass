function data = simulateTimeDomainSignal()
Fs = 800;             % Sampling frequency
T = 1/Fs;             % Sampling period
L = 1000;             % Length of signal
t = (0:L-1)*T;        % Time vector
%Form a signal containing a 50 Hz sinusoid of amplitude 0.7 and a 120 Hz sinusoid of amplitude 1.
S = 0.7*sin(2*pi*60*t) + sin(2*pi*140*t);

%Corrupt the signal with zero-mean white noise with a variance of 4.
data = S + 2*randn(size(t));
end