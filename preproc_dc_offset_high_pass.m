function dataout = preproc_dc_offset_high_pass(data,params)
%% Preprocess the data by applying high pass and dc offset 
% 
% input: 
% data - matrix of data in time domain 
% params - structure with params.sr specifying sampling rate 
% 
% ouptput: 
% dataout - filtered data with dc offset removed 

% old way of doing filter 
[b,a]        = butter(3,params.lowcutoff / (params.sr/2),'high'); % user 3rd order butter filter
datafilt     = filtfilt(b,a,data); %filter all signal<1hz using butterworth

% better way of doing it using optimal paramater selection, need to explore
% further 
% fs = params.sr;         % Sampling frequency
% Wp = [350]/(fs/2);      % Pass band frequencies (as normalized frequency)
% Ws = [3]/(fs/2);        % Stop band frequencies
% Rp = 3;                 % Ripple at pass band
% Rs = 10;                % Ripple at stop band
% 
% [n, Wn] = buttord(Wp, Ws, Rp, Rs);     % Get order and omega vector
% [z, p, k] = butter(n, Wn, 'high'); % Design filter accordingly
% [sos, g] = zp2sos(z, p, k);            % Convert to state matrix
% Hd = dfilt.df2sos(sos, g);             % Create the filter object
% 
% datafilt = filter(Hd, data);

% remove d/c offset (normalize to zero 
dataout = datafilt -mean(datafilt); %remove d/c offset

end