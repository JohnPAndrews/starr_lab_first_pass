function [outdat] =  loadBRdatToStruc(varargin)
%% This function loads pc+s to a structure
% input:
% 1 - filename
% 2 - if data structure given, load data and concanteante with previous structure

if isempty(varargin)
    [fn,pn] = uigetfile('*.txt');
    filename = fullfile(pn,fn);
else
    filename  = varargin{1};
end
% load data
try
    data = dlmread(filename);
catch
    data = importdata(filename);
end
chans = [1 3];
areas = {'stn', 'm1'};
for a = 1:2
    if sum(data(:,chans(a)))~=0
        alldat.([areas{a} 'exist']) = 1;
        alldat.([areas{a} '_rawdata']) = data(:,chans(a));
    else
        alldat.([areas{a} 'exist']) = 0;
        alldat.([areas{a} '_rawdata']) = [];
    end
end

if nargin == 2
    structconcat = varargin{2};
    outdat = [structconcat; alldat];
else
    outdat = alldat;
end

end