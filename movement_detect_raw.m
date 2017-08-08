function movement_detect_raw()
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized/brpd_10/v04_03_wek/s_005_tsk-ipad/EEGRAW_off-meds-ipad.mat';
load(fn); 
[b,a]        = butter(3,2 / (eegraw.srate/2),'high'); % user 3rd order butter filter
handles.chan12 = filtfilt(b,a,double(eegraw.EXG2 - eegraw.EXG1)) ; 
handles.chan34 = filtfilt(b,a,double(eegraw.EXG4 - eegraw.EXG3)) ; 
handles.chan56 = filtfilt(b,a,double(eegraw.EXG6 - eegraw.EXG5)) ; 
handles.erg1 = filtfilt(b,a,double(eegraw.Erg1)) ; 
handles.erg2 = filtfilt(b,a,double(eegraw.Erg2)); 

dat = handles.chan56; 
srate = eegraw.srate; 
secs = [1:1:length(dat)]./srate;

%% set params 
% start / end time 
params.start      =  47; % in seconds 
params.end        =  251; 
params.idxuse     = secs > params.start & secs < params.end; 
params.thresh1    = 60; % threshold (+-) of noise 
params.thresh2    = 80; % threshold to detect signal 

%% plot stuff 

wt = modwt(dat(params.idxuse),'haar',4);
mra = modwtmra(wt,'haar');
% [PTS_OPT,KOPT,T_EST] = wvarchg(mra,length(mra),2000)

% MORE WAVELET TESTS 
x = dat(params.idxuse);
x = x(1:40e3);
wname = 'db3'; lev = 1;
[c,l] = wavedec(x,lev,wname);
det = wrcoef('d',c,l,wname,1);
y = sort(abs(det));
v2p100 = y(fix(length(y)*0.98));
ind = find(abs(det)>v2p100);
det(ind) = mean(det);
[pts_Opt,kopt,t_est] = wvarchg(det(1:5000),40e3,2000);
sprintf('The estimated change points are %d and %d\n',pts_Opt)
 
datuse = dat(params.idxuse); 
secs   = secs(params.idxuse); 



params.winsize = 500; % points 

hfig = figure; 
hplt = plot(secs,zscore(datuse)); % raw data 
hplt.LineWidth = 0.5;
hplt.Color     = [0 0 1 0.1];
xlim([params.start, params.end])
hold on; 
M1 = movvar(datuse,[1000 200]);

M2 = movmad(datuse,[1000 200]);
% windowSize = 500; 
% b = (1/windowSize)*ones(1,windowSize);
% y = filter(b,a,datuse);
Mcomp = mean([zscore(M1) ;zscore(M2)]);
Mcomp2 = movmedian(Mcomp,[1000 1000]);
hplt = plot(secs,zscore(Mcomp2),...
    'LineWidth',1,...
    'Color',[0 0.9 0 0.8]); 


plot(secs(params.idxuse), zscore(mra(4,:)),...
    'LineWidth',0.5,...
    'Color',[0 0.9 0 0.1]); 

[PTS_OPT,KOPT,T_EST] = wvarchg(Y,K,D)

databs = abs(dat(params.idxuse)); 
databszero = databs; 
databszero(databs < params.thresh1) = 0; 
figure;plot(databszero);
