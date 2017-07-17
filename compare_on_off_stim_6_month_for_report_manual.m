function compare_on_off_stim_6_month_for_report_manual()
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual'; 
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/figures/report_figs';

fp = findFilesBVQX(rootdir,'br*',struct('depth',1,'dirs',1)); 
conds = {'chronic stim', 'off stim', 'accute stim'}; 
alph = 0.7;
clruse(1,:) = [0 0.5 0 alph]; % chronic stim 
clruse(2,:) = [0.9 0 0 alph]; % off stim 
clruse(3,:) = [0 0.9 0 alph]; % accute stim 

chans = [1 3]; 
areas = {'stn','m1'}; 
params.lowcutoff = 1;
params.plottype = 'pwelch';
params.noisefloor = 1;
params.sr = 800; 

% loop on patients 
for p = 1:length(fp)
    % find rest dirs 
    
    diruse = findFilesBVQX(fp{p},'s_*_tsk-rest',...
        struct('dirs',1));
    [pn,panme,ext] = fileparts(fp{p});
    panme = strrep(panme,'_','-'); 
    hfig = figure; 
    legenduse = {};
    for d = 1:length(diruse)
        datafn = findFilesBVQX(diruse{d},...
            'brpd*MR_*.txt'); 
        dat = importdata(datafn{1});
        for a = 1:2  
            dat_hp = preproc_dc_offset_high_pass(dat(:,chans(a)),params);
            dat_hp_tr = preproc_trim_data(dat_hp,5e3,800);
            %                 dat_hp_tr_zcr = zscore(deleteoutliers(dat_hp_tr,0.05));
            [fftOut,f] = pwelch(dat_hp_tr,800,400,1:1:100,params.sr,'psd');
            
            % plot
            subplot(1,2,a);
            hplt = plot(f,log10(fftOut));
            hplt.LineWidth = 3;
            hplt.Color = clruse(d,:);
            legenduse{d} = sprintf('%s',conds{d});
            xtitle = 'Frequency (Hz)';
            ytitle = 'Power  (log_1_0\muV^2/Hz)';
            hxlabel = xlabel(xtitle);
            hylabel = ylabel(ytitle);
            hold on;
            title(sprintf('%s stim on/off ',areas{a})); 
        end
        legend(legenduse);
    end  
           
    suptitle(sprintf('%s 6 month stim on vs off',panme));
    fnmsv = sprintf('%s_06month_stim-on-off-manual',panme);
    fnmsave = fullfile(figdir, fnmsv);
    hfig.PaperPositionMode = 'manual';
    hfig.PaperSize = [8.5*2 16/2];
    hfig.PaperPosition = [ 0 0 8.5*2 16/2];
    print(hfig,fnmsave,'-dpdf');
    close(hfig);
    
end
end