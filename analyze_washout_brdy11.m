% plot spectrogram data 
%% load data 
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brdy_11/v09_03_mnt/raw_files/s_009_tsk-washout/';
fn = 'BRDY11_2018_04_18_10_22_58__MR_2.txt';
rawdat = importdata(fullfile(rootdir,fn));
%%
hfig = figure;
params.sr = 800; 
figtitle = 'Washout BRDY11'; 
hax1 = subplot(2,1,1); 
plot_data_time_domain_spectrogram(rawdat(:,1),params,[]); 
title('pallidum'); 

hax2 = subplot(2,1,2); 
plot_data_time_domain_spectrogram(rawdat(:,3),params,[]); 
title('M1'); 

linkaxes([hax1 hax2],'x'); 
ylim([0 20])