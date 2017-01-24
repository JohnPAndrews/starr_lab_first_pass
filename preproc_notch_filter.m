function dataout = preproc_notch_filter(data,params)
%% Notch filter data 
%
% input: 
% data matrix 
% params.notch_filter  - matrix with filter to notch 
% params.filterorder   - scalar with butterworth filter order 
% params.delta_notch   - 

for f = 1:length(params.notch_filter) % loop on filters to notch 
    % filter params 
    n = params.filterorder; 
    filterange = [params.notch_filter(f) - params.delta_notch ...
                  params.notch_filter(f) + params.delta_notch]; 
    % creat filter 
    [b, a ]  =butter(n, filterange / (params.sr/2),'stop'); 
    % filter data 
    data  = filtfilt(b,a,data); 
end
dataout = data; 
end