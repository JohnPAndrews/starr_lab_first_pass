function [reject, rejectreason] = checkDataFromSession(data,session, params)
%% This function checks data from a particular session activa PC + S 
%  and determins if it should be rejected. 

% input: 
% data - matrix of [ time points x channels] (6 channels, PC + S
% params - a structure with fields: 
% params.minlength - min length of file in seconds 
% session a structure (read from json) with fields: 
% session.sr - sampling rate 
% convention); 


% output: 
% reject - boolean - reject true false 
% rejectreason - string - reason for rejection. empty if recommend not to
% reject

% get sampling rate 
reject = 0; 
rejectreason = []; 
session.sr = str2num(strrep(session.xmldata.SenseChannelConfig.TDSampleRate,'Hz',''));
%% reject if data is too short
if size(data,1) < ((params.minlength/1e3)*session.sr)
    reject = 1; 
    rejectreason = sprintf('file is %0.2f secs long, min file len is %0.2f secs',...
        size(data,1)/session.sr,params.minlength/1e3);
end
%% reject if only have zeros in STN and / or motor cortex time domain 
if sum(data(:,1)) == 0 % stn 
   reject = 1; 
   rejectreason = 'stn time domain channel empty';
end
if sum(data(:,3)) == 0 % cortex 
    reject = 1; 
    rejectreason = 'motor cortex time domain channel empty';
end
if sum(data(:,1)) == 0 && sum(data(:,3)) == 0 
    reject = 1; 
    rejectreason = 'stn and motor cortex time domain channel empty';
end


end