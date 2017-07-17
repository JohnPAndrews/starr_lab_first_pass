function plot_ipat_data_automatically(data)
%% This funciton attempts to automate plotting ipad data 
% input - a structure 'data' with fields:
% data.br_lfp  = matrix with raw brain radio data in which pulse sequences can be seen 
% data.br_ecog = matrix with raw brain radio data in which pulse sequences can be seen 
% data.br_sr   = brain radio data hypothesized sampling rate (this is not always stable) 
% data.brps    = 'lfp' / 'ecog' % channel on which pulse sequence can be seen 
% data.emg_sr  = emg sampling rate 
% data.emg1    = emg data with pulse sequences (usually) 
% data.emg2    = emg data with movements (usually ecr)
% data.emg3    = emg data with movements (usually deltoid) 
load('temp-ipad-data.mat','data'); 
[locEcogS,pksstr, locEcogE,pksend] = getPeaksDat(data.br_ecog, data.br_sr); % 
% figure; 
% plot(zscore(data.br_ecog)); 
% hold on;
% scatter(locEcog,pksstr,300);
% hold on; 
% scatter(locend,pksend,300);
% title('ecog'); 

[locEmgS,pksstr, locEmgE,pksend] = getPeaksDat(data.emg1.*(-1), data.emg_sr); % 
[emglocoutS ,ecogpulseoutS] = allignPulses(locEmgS,data.emg_sr,locEcogS,data.br_sr);
[emglocoutE ,ecogpulseoutE] = allignPulses(locEmgE,data.emg_sr,locEcogE,data.br_sr);

Diffecog = ecogpulseoutE(1)- ecogpulseoutS(1); % XXX just use first point consider changing 
Diffemg = emglocoutE(1)- emglocoutS(1); 
ecogSR  = (data.emg_sr * Diffecog ) / Diffemg;
ecogsr = round(ecogSR); 

%% extract movement onsets from emg files 
figure; 
for i = 1:3; 
subplot(1,3,i); 
plot(data.(sprintf('emg%d',i)));
end

%% extract movement onsets from ipad files 

%% extact epochs from files 

%% compute spectrograms 


figure; 
plot(zscore(data.emg1.*(-1))); 
hold on;
scatter(locstrt,pksstr,300);
hold on; 
scatter(locend,pksend,300);
title('emg'); 


end

function [locstrt,pksstr, locend,pksend] = getPeaksDat(dat, sr)

% find start pulses for ecog and emg 
zerovec = zeros(length(dat),1); % create zero vec 
idxstart = 3*sr:30*sr;% put zscored seconds 3-30 seconds in zero vec 
zerovec(idxstart) = zscore(dat(idxstart)); % zscore this start; 
idxLargerThan2    = zerovec<4; % find idx smaller than 2 std. 
zerovec(idxLargerThan2) = 0; % zero everything smaller than 2 STD

[pksstr,locstrt] = findpeaks(zerovec,...
    'MinPeakDistance',0.45*sr); % locstart in seconds 
    
zerovec = zeros(length(dat),1); % create zero vec
idxend = (length(dat)-30*sr):length(dat);% put zscored seconds 3-30 seconds in zero vec 
zerovec(idxend) = zscore(dat(idxend)); % zscore this start; 
idxLargerThan2    = zerovec<4; % find idx smaller than 2 std. 
zerovec(idxLargerThan2) = 0; % zero everything smaller than 2 STD

[pksend,locend] = findpeaks(zerovec,...
    'MinPeakDistance',0.45*sr); % locstart in seconds 


end

function [emgout ,ecgout] =  allignPulses(emgpulse,emgsr,ecogpulse,ecogsr)
% This function takes two difference vectors, and allings them. 
ecd = diff(ecogpulse)./ecogsr; 
emd = diff(emgpulse)./emgsr;

if length(ecd) == length(emd) 
    diffsum = sum(abs(ecd - emd));
    emgout = emgpulse; 
    ecgout = ecogpulse; 
    if diffsum > 0.2 
        warning('problems with allignment of pulse sequences');
    end
else
    if length(ecd) > length(emd)
        sidx = 1; eidx = length(emd); cnt = 1 ;
        while eidx <= length(ecd)
            dloc(cnt,1)  = sidx;
            dloc(cnt,2) =  eidx;
            dloc(cnt,3) = sum(abs(emd-ecd(sidx:eidx)));
            sidx = sidx + 1;
            eidx = eidx + 1;
            cnt = cnt + 1;
        end
        [~, midx] = min(dloc(:,3));
        emgout = emgpulse;
        ecgout = ecogpulse(dloc(midx,1):dloc(midx,2)+1);
    elseif length(emd) > length(ecd)
        sidx = 1; eidx = length(ecd); cnt = 1 ;
        while eidx <= length(emd)
            dloc(cnt,1)  = sidx; 
            dloc(cnt,2) =  eidx; 
            dloc(cnt,3) = sum(abs(ecd-emd(sidx:eidx)));
            sidx = sidx + 1; 
            eidx = eidx + 1; 
            cnt = cnt + 1; 
        end
        [~, midx] = min(dloc(:,3));
        emgout = emgpulse(dloc(midx,1):dloc(midx,2)+1);
        ecgout = ecogpulse; 
    end
end
% validation 
ecd = diff(ecgout)./ecogsr; 
emd = diff(emgout)./emgsr;
diffsum = sum(abs(ecd - emd));
if diffsum > 0.2
    warning('problems with allignment of pulse sequences');
end
% move small vector along larger vector to find match 



end