function outdat= preproc_wrapper(varargin)
%% This function wrapps preproc data for one session of brain readio
% 1 - filename
% 2 - if data structure given, load data and concanteante with previous structure
brdb  = varargin{1};
params = varargin{2};
% load data
chans = [1 3];
areas = {'stn', 'm1'};
for a = 1:2
    dat = brdb.([areas{a} '_rawdata']){:};
    params.sr = brdb.sr; 
    preprocdata = run_data_prpeproc(dat,params);
    fnms = fieldnames(preprocdata);
    for f = 1:length(fnms)
        outdata.([areas{a} '_' fnms{f}]) = preprocdata.(fnms{f});
    end
end



if nargin == 3
    structconcat = varargin{3};
    outdat = [structconcat; outdata];
else
    outdat = outdata;
end

end