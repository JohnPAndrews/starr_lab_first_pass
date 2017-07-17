function computeNoiseFloor()

rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized/brpd_10/noisefloor'; 
ff = findFilesBVQX(rootdir, 'br*MR_0.txt'); 
[settings, params] = get_settings_params();
hfig = figure; 
dat = importdata(ff{1}); 
data_raw(:,1) = dat(:,1); 
data_raw(:,2) = dat(:,3); 
labels{1} = 'lfp'; labels{2} = 'ecog'; 
pltcnt = 1; 
hfig = figure; 
for d = 1:size(data_raw,2)
    %% plot raw data 
    subplot(2,3,pltcnt);pltcnt =pltcnt + 1; 
    plot([1:length(data_raw)]./800, data_raw(:,d))
    title(sprintf('raw data %s',labels{d}));
    %% plot trimmed data 
    subplot(2,3,pltcnt);pltcnt =pltcnt + 1; 
    dat_trimmed = preproc_trim_data(data_raw(:,d),5e3,800);
    title(sprintf('trimmed raw data %s',labels{d}));
    params.sr = 800;
    %% freq domain 
    subplot(2,3,pltcnt);pltcnt =pltcnt + 1; 
    plot_data_freq_domain(dat_trimmed,params,[]);
end
end