function compare_meds_off_meds_on_quick_and_dirty()
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized/brpd_10/v02_predis/Session_2017_06_21_Wednesday';

meds_off_fn = 'brpd10_2017_06_21_13_38_52__MR_0.txt';
meds_on_fn  = 'brpd10_2017_06_21_16_59_47__MR_0.txt';

params.sr = 800;
params.msec2trim = 5e3; 
params.lowcutoff = 1; 
params.plottype = 'pwelch'; 
params.noisefloor = 400; 


%% meds on stn
hfig = figure;
areas = {'LFP','','ECOG'};
plotnum = [ 1 0 2];
for i = [ 1 3]
    subplot(1,2,plotnum(i)); 
    fn = fullfile(rootdir,meds_on_fn);
    dataraw = importdata(fn);
    data = dataraw(:,i); % stn
    data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
    data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
    plot_data_freq_domain(data,params,[]);
    % set(gca,'Color',[0 1 0]);
    hold on;
    fn = fullfile(rootdir,meds_off_fn);
    dataraw = importdata(fn);
    data = dataraw(:,i); % stn
    data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
    data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
    plot_data_freq_domain(data,params,[]);
    % set(gca,'Color',[1 0 0]);
    legend({'Meds On','Meds Off'})
    title(areas{i});
end



end