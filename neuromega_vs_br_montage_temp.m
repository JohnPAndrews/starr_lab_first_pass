function neuromega_vs_br_montage_temp()
%% nuero omega data 
neuromegafn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/1_intraop_data_analysis/data/neuro_omega_raw_data/BR10_05_postlead_LecogLlfp_rest_raw_ecog.mat';
% neuromegafn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/1_intraop_data_analysis/data/neuro_omega_raw_data/BR10_06_postlead_LecogLlfp_ipad_ecog_filt.mat';
% [dataTbl,anaTbl] = convertNeuroOmegaECOGtoTable(neuromegafn);
load(neuromegafn)
f1 = 422; 
f2 = 22e3; 
contactType = {'lfp','ecog'}; 
for c = 1:2
    for i = 1:4
        dat = eval( sprintf('%s.contact(%d).raw_signal',contactType{c},i));
        datNO{c,i} =resample(dat,f1,f2);
        datNOnr{c,i} = dat; % not resampled 
    end
end
% Bipolar: 
bpairs(:,:) = [0 1; 0 2; 0 3; 1 2; 1 3; 2 3] + 1; 
for c = 1:2 % loop on ecog / lfp 
    for b = 1:size(bpairs,1) % loop on all pairs 
        dataNObp(b,:,c)  = datNO{c,bpairs(b,1)} - datNO{c,bpairs(b,2)};
        datzsc = zscore(deleteoutliers(dataNObp(b,:,c),0.05));
        
        [psdNO(b,:,c),f ]= pwelch(dataNObp(b,:,c),512,256,1:150,f1);
        [psdNOzsc(b,:,c),f ]= pwelch(datzsc,512,256,1:150,f1);
        
        dataNObpnr(b,:,c)  = datNOnr{c,bpairs(b,1)} - datNOnr{c,bpairs(b,2)};
        datzsc = zscore(deleteoutliers(dataNObpnr(b,:,c),0.05));
        [psdNOnrzsc(b,:,c),f ]= pwelch(datzsc,22e3,22e3/2,1:150,22e3);
        
    end
end



%% pc +s data 
pcsdatafold = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized/brpd_10/v01_OR_day/Session_2017_06_20_Tuesday/s_001_tsk-montage';
ff = findFilesBVQX(pcsdatafold,'*.txt'); 
chidx = [1 3]; 
for b = 1:6
    dat = importdata(ff{b});
    for c = 1:2
        datBRbp(b,:,c) = dat(:,chidx(c));
        datTr = preproc_trim_data(datBRbp(b,:,c) ,2e3, f1); 
        
        [psdBR(b,:,c),f ]= pwelch(datBRbp(b,:,c),512,256,1:150,f1);
        datzsc = zscore(deleteoutliers(datTr,0.05));
        [psdBRzsc(b,:,c),f ]= pwelch(datzsc,512,256,1:150,f1);
    end
end
labes(:,1) = {'0-1'    '0-2'     '0-3'     '1-2'     '1-3'     '2-3' };
labes(:,2) = {'8-9'    '8-10'    '8-11'    '9-10'    '9-11'    '10-11'}; 

%% plot comparison 
hfig = figure; 
pltcnt = 1; 
al = 0.7;
clrsus = [1 0 0 al; 0 0 1 al];
for b = 1:6
    for c = 1:2
        subplot(6,2,pltcnt); pltcnt = pltcnt + 1; 
        idxuse = 1:length(f); 
%         idxuse = f>5 & f < 50; 
        hp = plot(f(idxuse),log10(psdBRzsc(b,idxuse,c))); 
        hp.LineWidth = 2;
        hp.Color = clrsus(1,:);

        hold on; 
        hp = plot(f(idxuse),log10(psdNOnrzsc(b,idxuse,c))); 
        hp.LineWidth = 2; 
        hp.Color = clrsus(2,:); 
        xtitle = 'Frequency (Hz)';
        ytitle = 'Power  (log_1_0\muV^2/Hz)';
        xlabel(xtitle);
        ylabel(ytitle); 
        title(sprintf('%s %s',contactType{c},labes{b,c})); 
        ylims = get(gca,'YLim');
        fill([12 30 30 12],[ylims(1) ylims(1) ylims(2) ylims(2)],'g','EdgeColor','none','FaceAlpha',0.3);
        fill([70 150 150 70],[ylims(1) ylims(1) ylims(2) ylims(2)],'y','EdgeColor','none','FaceAlpha',0.3)
%         xlim([5 50]); 
        kids = get(gca,'Children');        %# Get the child object handles
        set(gca,'Children',flipud(kids));  %# Set them to the reverse order

        legend(fliplr({'INS','Neuro Omega' ,'\beta 12-30','\gamma 70-150'})); 
    end
end
%% 
hfig.PaperPositionMode = 'manual'; 
hfig.PaperSize = [11 ,16];
hfig.PaperPosition = [0 0 11 16];
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/1_intraop_data_analysis/figures/OR_day/NeuroOmegaVsBrainRadio';
fnuse = fullfile(figdir, '01_NO-422_BR-22k_zscore_noresampling.pdf'); 
print(hfig,fnuse,'-dpdf');  
close(hfig); 
return; 
