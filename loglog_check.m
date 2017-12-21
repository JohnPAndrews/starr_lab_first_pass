function loglog_check()
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/log_log/Orr/LT1D-2.468F0003.mat';
load(fn);
convertNeuroOmegaECOGtoTable(fn);
load /Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/log_log/epilepsy/data Utrecht/EEG_pat1_ecog.mat


load /Volumes/pstarr_shared/Witney/data Utrecht/EEG_pat1_ecog.mat
% module 1 (chan 1-14)- ECOG 
% module 2 (chan 1-14)- ECOG 
% module 4 (chan 1-4) - STN 

moduse = 1; 
chanuse = 14; 

% get data 
idxuse = dataTbl.module_num == moduse & ...
         dataTbl.modul_chan <= chanuse;
     
dataUse = dataTbl(idxuse,:);    
% get data 
for i = 1:size(dataUse,1)
    data(i,:) = dataUse.data(i,:);
end
% plot raw data 
figure; 
for i = 1:14
    subplot(4,4,i);
    plot(dataGran(i,:));
    title(sprintf('chan %0.2d',i));
end
hpval = 1; 
sr    = 22e3; 
uselog = 1; 
%% plot bipolar referenced data 
cnt = 1; 
for i = 2:14 
    dataBip(cnt,:) = data(i-1,:) - data(i,:);
    cnt = cnt + 1; 
end
figure('Position',[404         408        1616         896]);
for i = 1:13
    hAx(i) = subplot(4,4,i);
    [b,a]        = butter(3,hpval / (sr/2),'high'); % user 3rd order butter filter
    datafilt     = filtfilt(b,a,dataBip(i,:)); %filter all signal<1hz using butterworth
    [fftOut,f] = pwelch(datafilt,sr,sr/2,1:1000,sr,'psd');
    if uselog 
        f = log10(f);
        xlims = log10([1 130]);
    else
        xlims = [0 130];
    end
    hP(i) = plot(f,log10(fftOut));
    hP(i).LineWidth = 3;
    xlim(xlims);
    title(sprintf('bipolar chan %0.2d',i));
    xtitle = 'Frequency (Hz)';
    ytitle = 'Power  (log_1_0\muV^2/Hz)';
    hxlabel = xlabel(xtitle);
    hylabel = ylabel(ytitle);
end
linkaxes(hAx,'x');
clear hAx;
%% plot grand average data 
dataGran = data;% - mean(data,1);
figure('Position',[404         408        1616         896]);
hpval = 1; 
sr    = 22e3; 
for i = 1:14
    hAx(i) = subplot(4,4,i);
    [b,a]        = butter(3,hpval / (sr/2),'high'); % user 3rd order butter filter
%     datafilt     = filtfilt(b,a,dataGran(i,:)); %filter all signal<1hz using butterworth
    datafilt     = dataGran(i,:); %filter all signal<1hz using butterworth
    [fftOut,f]   = pwelch(datafilt,sr,sr/2,0:1000,sr,'psd');
    if uselog 
        f = log10(f);
        xlims = log10([0 130]);
    else
        xlims = [0 130];
    end
    hP(i) = plot(f,log10(fftOut));
    hP(i).LineWidth = 3; 
    xlim(xlims);
    title(sprintf('grand avg chan %0.2d',i));
    xtitle = 'Frequency (Hz)';
    ytitle = 'Power  (log_1_0\muV^2/Hz)';
    hxlabel = xlabel(xtitle);
    hylabel = ylabel(ytitle);
end
linkaxes(hAx,'x');

%% utrecht data 
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/log_log/epilepsy/data Utrecht/EEG_pat1_ecog.mat');
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/log_log/epilepsy/data Utrecht/EEG_pat1.mat');
dataM1 = EEG.data([87 88 92 93 94],:);
dataS1 = EEG.data([68 69 70 76 77],:);
dataGran = dataM1;

figure('Position',[404         408        1616         896]);
hpval = 1; 
sr    = 512; 
uselog = 1;
for i = 1:size(dataGran,1)
    hAx(i) = subplot(4,4,i);
    [b,a]        = butter(3,hpval / (sr/2),'high'); % user 3rd order butter filter
%     datafilt     = filtfilt(b,a,dataGran(i,:)); %filter all signal<1hz using butterworth
    datafilt     = dataGran(i,:); %filter all signal<1hz using butterworth
    [fftOut,f]   = pwelch(datafilt,sr,sr/2,0:150,sr,'psd');
    if uselog 
        f = log10(f);
        xlims = log10([0 130]);
    else
        xlims = [0 130];
    end
    hP(i) = plot(f,log10(fftOut));
    hP(i).LineWidth = 3; 
    xlim(xlims);
    title(sprintf('Utreect chan %0.2d',i));
    xtitle = 'Frequency (Hz)';
    ytitle = 'Power  (log_1_0\muV^2/Hz)';
    hxlabel = xlabel(xtitle);
    hylabel = ylabel(ytitle);
end
linkaxes(hAx,'x');
end