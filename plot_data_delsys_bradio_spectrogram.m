function plot_data_delsys_bradio_spectrogram(varargin)
plottt0data  = 1;
if nargin < 1
    diruse = uigetdir('choose ipad dir');
elseif nargin == 1
    diruse = varargin{1};
elseif nargin ==2
    diruse = varargin{1};
    plottt0data = varargin{2};
end
%% find and load data 
% load delsys 
ff = findFilesBVQX(diruse,'*.csv.mat'); 
if isempty(ff)
    error('delsys file does not exist load with convertDelsysToMat.m')' 
else
    load(ff{1}); 
end
% load brain radio 
ff = findFilesBVQX(diruse,'BRRAW*.mat'); 
if isempty(ff)
    error('brain radio file does not exist load with loadBRdata.m')' 
else
    load(ff{1}); 
end
% load alling info data 
ff = findFilesBVQX(diruse,'ipad_allign_info.mat'); 
if isempty(ff)
    error('allignemnt has not been done load with threshold_beep_finder.m')' 
else
    load(ff{1}); 
end
%% plot data
ecogidx = alligninfo.ecogsync(1); 
ecogdat = brraw.ecog; 
secsraw = 0:1/794:size(brraw.ecog,1)/794; 
secsraw = secsraw(1:end-1); 
secsbr = seconds(secsraw - secsraw(ecogidx)); 
%% delsys sampling rates 
eegidx = alligninfo.eegsync(1); 
dellen = size(dataraw.L_cervical_EMG3_IM_,1);
srate = 15/0.0135;
secs = 0:1/srate:(dellen/srate); 
secs = secs(1:end-1); 
secsdelsys = seconds(secs - secs(eegidx)); 
%% draw plot 
secstart = seconds(4); 
secend   = seconds(104); 
idxusebr = secsbr > secstart & secsbr < secend; 
numplt = 5; 
cntplt = 1; 
hfig = figure;
hax1 = subplot(numplt,1,cntplt); cntplt = cntplt +1; 
plot(secsbr(idxusebr),ecogdat(idxusebr)); 
title('ecog');


hax2 = subplot(numplt,1,cntplt); cntplt = cntplt +1; 
plot(secsbr(idxusebr),brraw.lfp(idxusebr)); 
title('lfp');


hax3 = subplot(numplt,1,cntplt); cntplt = cntplt +1; 
[s,f,t,p] = spectrogram(ecogdat(idxusebr),1e3,ceil(0.8750*1e3),1:50,794,...
    'yaxis','power');
surf(seconds(t), f, 10*log10(p), 'EdgeColor', 'none');
shading interp 
view(2);
title('ecog');


hax4 = subplot(numplt,1,cntplt); cntplt = cntplt +1; 
[s,f,t,p] = spectrogram(brraw.lfp(idxusebr),1e3,ceil(0.8750*1e3),1:50,794,...
    'yaxis','power');
surf(seconds(t), f, 10*log10(p), 'EdgeColor', 'none');
shading interp 
view(2);
xlim([secstart secend]);
title('lfp');

idxusedel = secsdelsys > secstart & secsdelsys < secend; 
hax5 = subplot(numplt,1,cntplt); cntplt = cntplt +1; 
plot(secsdelsys(idxusedel),dataraw.L_GA_EMG8_IM_(idxusedel)); 
linkaxes([hax1 hax2 hax3 hax4 hax5],'x'); 
% touch sensor 26/0.0135
% emg 15/0.0135
% acc/gyro 2/0.0135



end