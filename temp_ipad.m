load /Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_10/v03_10_day/s_009_tsk-ipad/analyzed_ipad_data.mat
zertf_off10day = zertf; 
load /Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_10/v03_10_day/s_012_tsk-ipad/analyzed_ipad_data.mat
zertf_on10day = zertf; 
load /Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_10/v04_03_wek/s_005_tsk-ipad/analyzed_ipad_data.mat
zertf_off3week = zertf;
load /Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_10/v04_03_wek/s_009_tsk-ipad/analyzed_ipad_data.mat
zertf_on3week = zertf;
figdir = '/Users/roee/Starr_Lab_Folder/Grants/RO1_renewal /Figures/bnc2';



hfig = figure; 
h1 = subplot(2,1,1); 
ch_plot = 2; 
zertf  = (zertf_off3week + zertf_off10day)./2;
idxuse = epoch_time > -3000;
cmax=3;%max(abs(squeeze(zertf(:))));
cmin=-cmax;
tempmat=double(squeeze(zertf(:,idxuse,condition,ch_plot)));
pcolor(epoch_time(idxuse)/1000,center_frequencies,tempmat);
shading interp;
caxis([cmin cmax]);
hc1 = colorbar;
hold on;
hold off;
hold on;
hl1 = line([0 0],[5.0000 130.4805],...
    'LineWidth',2.5,...
    'Color',[0.1 0.1 0.1 0.6]);      
ylim([5.0000 130.4805]);
h1.XTick = [];
ylabel('Frequency (Hz)');
% xlabel('Time (sec)')
ht1 = title('Off Medication');
hold on;

% on medication 
h2 = subplot(2,1,2); 
zertf  = (zertf_on3week + zertf_on10day)./2;
cmax=3;%max(abs(squeeze(zertf(:))));
cmin=-cmax;
tempmat=double(squeeze(zertf(:,idxuse,condition,ch_plot)));
pcolor(epoch_time(idxuse)/1000,center_frequencies,tempmat);
shading interp;
caxis([cmin cmax]);
hc2 = colorbar;
hold on;
hold off;
hold on;
hl2 = line([0 0],[5.0000 130.4805],...
    'LineWidth',2.5,...
    'Color',[0.1 0.1 0.1 0.6]);      
ylim([5.0000 130.4805]);
ylabel('Frequency (Hz)');
xlabel('Time (sec)')
ht2 = title('On Medication');
hold on;

% hc1.Visible = 'off';
% hc2.Visible = 'off';
% hl1.Visible = 'off';
% hl2.Visible = 'off';
% h1.XTick = [];
% h2.XTick = [];
% h1.YTick = [];
% h2.YTick = [];
% h1.YLabel.String = '';
% h2.YLabel.String = '';
% h1.XLabel.String = '';
% h2.XLabel.String = '';
% h1.Title.String = '';
% h2.Title.String = '';

hfig.PaperPositionMode = 'manual'; 
hfig.PaperSize = [10 8]; 
hfig.PaperPosition = [0 0 10 8]; 
fnmsv = sprintf('1_ipad_test1.fig');
saveas(hfig,fullfile(figdir,fnmsv)); 

fnmsv = sprintf('1_ipad_spectrogram_test.jpeg');
print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r600');
fnmsv = sprintf('1_ipad_image.pdf');
hfig.Renderer='opengl';
print(hfig,fullfile(figdir,fnmsv),'-dpdf','-r600');




% contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,Coreshaped',30,'lines','none')
%% plot
meds = 'off';
hfig = figure;
for ch_plot = 1:num_channels
    for condition=1:1
        h = subplot(2,2,ch_plot);
        cmax=3;%max(abs(squeeze(zertf(:))));
        cmin=-cmax;
        tempmat=double(squeeze(zertf(:,:,condition,ch_plot)));
        pcolor(epoch_time,center_frequencies,tempmat);
        shading interp;
        caxis([cmin cmax]);
        colorbar;
        hold on;
        %         contour(epoch_time,center_frequencies,tempmat,...
        %             threshold*[1 1],'k');
        %         contour(epoch_time,center_frequencies,tempmat,...
        %             -threshold*[1 1],'r');
        hold off;
        if ecog.med; meds = 'on'; else meds = 'off'; end
        if ecog.stim; stims = 'on'; else stims = 'off'; end
        elec = ecog.(sprintf('%s_elec',areas{ch_plot}));
        ttluse = sprintf('%s %s meds %s stim e %s',...
            areas{ch_plot},meds,stims,elec);
        title(ttluse, 'FontWeight', 'bold','FontSize',16);
        hold on;
        set(h,'YScale','log');
        set(h,'YTick',[2.5 4 8 16 32 64 128 250]);
        %         plot(ones(1,length(center_frequencies)).*500,center_frequencies);
        %         hold on;
        plot(zeros(1,length(center_frequencies)),center_frequencies,...
            'LineWidth',2,...
            'Color',[0.1 0.1 0.1 0.7]);
        hold on;
        xlabel('time (msec)');
        ylabel('power'); 

        h=subplot(2,2,ch_plot+2);
        cmax=3;%max(abs(squeeze(zertf(:))));
        cmin=-cmax;
        tempmat=double(squeeze(zertf(:,:,condition,ch_plot)));
        pcolor(epoch_time,center_frequencies,tempmat);
        shading interp;
        caxis([cmin cmax]);
        colorbar;
        hold on;
        %         contour(epoch_time,center_frequencies,tempmat,...
        %             threshold*[1 1],'k');
        %         contour(epoch_time,center_frequencies,tempmat,...
        %             -threshold*[1 1],'r');
        hold off;
        title(ttluse, 'FontWeight', 'bold','FontSize',16);
        hold on;
        %                 set(h,'YScale','log');
        %                 set(h,'YTick',[2.5 4 8 16 32 64 128 250]);
        %         plot(ones(1,length(center_frequencies)).*500,center_frequencies);
        %         hold on;

        plot(zeros(1,length(center_frequencies)),center_frequencies,...
            'LineWidth',2,...
            'Color',[0.1 0.1 0.1 0.7]);        xlabel('time (msec)'); 
        ylabel('power'); 
        hold on;
    end
end

ttlfig = sprintf('iPad %s meds %s stim',meds,stims);
set(findall(hfig,'-property','FontSize'),'FontSize',12)
% suptitle(ttlfig);
fnmsv = sprintf('ipad_spectrogram_%s-meds-%stim.fig',meds,stims);
saveas(hfig,fullfile(figdir,fnmsv)); 
hfig.PaperPositionMode = 'manual'; 
hfig.PaperSize = [14 8]; 
hfig.PaperPosition = [0 0 14 8]; 
fnmsv = sprintf('1_ipad_spectrogram_%s-meds-%stim.jpeg',meds,stims);
print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r600');
fnmsv = sprintf('1_ipad_spectrogram_%s-meds-%stim.pdf',meds,stims);
hfig.Renderer='Painters';
print(hfig,fullfile(figdir,fnmsv),'-dpdf');
% print(hfig,fullfile(figdir,fnmsv),'-dpdf');

close(hfig);