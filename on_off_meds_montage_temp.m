function on_off_meds_montage_temp()
onmedsfn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/1_intraop_data_analysis/data/montage_files_on_meds/brpd10_2017_06_21_16_48_33___results_allmontage_files.mat';
load(onmedsfn,'PSD_all','channel_lables','signal');
psd_on = PSD_all;


offmedsfn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/1_intraop_data_analysis/data/montage_files_postop_off_meds/brpd10_2017_06_21_13_11_55___results_allmontage_files.mat';
load(offmedsfn,'PSD_all');
psd_off = PSD_all;
clear PSD_all;

figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/1_intraop_data_analysis/figures/post_op_day'; 
colors = ['g' 'r' ];
colors = [
    [196,92,162];...
    [84,167,123]];
alphause = 0.8;
colors = [colors./255 , repmat(alphause,2,1)];
medvars = {'psd_on','psd_off'};
for ch_plot = 1:size(signal,1)
    for file_plot = 1:6
        hfig = figure;
        for medidx = 1:2
            PSD_all = eval(medvars{medidx});
            hplot = plot((PSD_all(:,2,ch_plot,file_plot)),log10(PSD_all(:,1,ch_plot,file_plot)));
            hold on;
            hplot.LineWidth = 1.5;
            hplot.Color = colors(medidx,:);
            
        end
        legend({'on meds','off meds'}); 
        if ch_plot == 1
            ttluse = sprintf('%s %s','LFP',channel_lables{ch_plot,file_plot});
            title(ttluse);
        else
            ttluse = sprintf('%s %s','ECOG',channel_lables{ch_plot,file_plot});
            title(ttluse);
        end
        xlabel('Frequency (Hz)');
        ylabel('power');
        fignm = [ttluse '.pdf'];
        print(hfig,fullfile(figdir,fignm),'-dpdf');
        close(hfig);
    end
end
close all

