function compare_on_off_meds_3_week_for_report()
%udprs 3 week
addpath(genpath(fullfile(pwd,'toolboxes')));
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/results/mat_file_with_all_session_jsons';
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/figures/report_figs';

ff = findFilesBVQX(rootdir,'P-*.mat');

brpd_01 = [3 60]; % order is on, off 
brpd_03 = [17 23];
brpd_04 = [28 43];
brpd_05 = [10 30];
brpd_06 = [22 33];
brpd_07 = [2 3];
brpd_09 = [11 21];
medstat = {'on','off'};
areas   = {'m1' , 'stn'};
alph = 0.7;
clruse(1,:) = [0 0.9 0 alph];
clruse(2,:) = [0.9 0 0 alph];
params.lowcutoff = 1;
params.plottype = 'pwelch';
params.noisefloor = 1;
for f = 1:length(ff)
    load(ff{f});
    patuse = brdb.patientcode{1};
    hfig = figure;
    for a = 1:length(areas)
        lcnt = 1; legenduse = []; 
        for m = 1:length(medstat)
            aexist = logical(eval(sprintf('brdb.%sexist',areas{a})));
            idxuse = ...
                strcmp(brdb.Medication,medstat{m}) & ...
                strcmp(brdb.ConditionTask,'rest') & ...
                strcmp(brdb.visitCategory,'03_wek') & ...
                aexist;
            newdb = brdb(idxuse,{'visitCategory','m1_rawdata','stn_rawdata', 'stn_electrodes','m1_electrodes', 'ConditionTask','Medication','sr'});
            cgrad = linspace(0.5,1,size(newdb,1)); % to set gradient of color
            for s = 1%:size(newdb,1)
                params.sr = newdb.sr(s);
                data = eval(sprintf('newdb.%s_rawdata{s};',areas{a}));
                dat_hp = preproc_dc_offset_high_pass(data,params);
                dat_hp_tr = preproc_trim_data(dat_hp,5e3,800);
                dat_hp_tr_zcr = zscore(deleteoutliers(dat_hp_tr,0.05));
                [fftOut,f] = pwelch(dat_hp_tr_zcr,800,400,1:1:100,params.sr,'psd');
                
                outdat.(patuse).(areas{a}).(medstat{m})(s,:) = fftOut; 
                % plot 
                subplot(1,2,a); 
                hplt = plot(f,log10(fftOut));
                hplt.LineWidth = 3;
                clrtmp = clruse(m,:); 
                if m ==1
                    clrtmp(2) = cgrad(s);
                else 
                    clrtmp(1) = cgrad(s);
                end 
                hplt.Color = clrtmp;
                legenduse{lcnt} = sprintf('meds-%s-%s(%d)',medstat{m}, eval(sprintf('brdb.%s_electrodes{%d};',areas{a},s)),s);
                lcnt = lcnt + 1; 
                xtitle = 'Frequency (Hz)';
                ytitle = 'Power  (log_1_0\muV^2/Hz)';
                hxlabel = xlabel(xtitle);
                hylabel = ylabel(ytitle);
                hold on;
            end
        end
        legend(legenduse)
        ttltxt = sprintf('%s %s 3 weeks meds on / off',patuse,areas{a});
        title(strrep(ttltxt,'_','-'));
    end
    fnmsv = sprintf('%s_3week-same-elec',patuse);
    fnmsave = fullfile(figdir, fnmsv);
    hfig.PaperPositionMode = 'manual';
    hfig.PaperSize = [8.5*2 16/2];
    hfig.PaperPosition = [ 0 0 8.5*2 16/2];
    print(hfig,fnmsave,'-dpdf');
    close(hfig);
end
% plot udprs vs meds 
save('fft-3-week-all-pat-meds-on-off-andudprs.mat','outdat','brpd*');
pats = [1 3 4 5 6 7 9]; 
medstat = {'on','off'};
areas   = {'m1' , 'stn'};
frequse = 12:20; 
cnt = 1; 
for p = 1:length(pats) 
    for a = 1:length(areas)
        for m = 1:length(medstat)
            outdat.brpd_01.m1.on
            fftout = eval(sprintf('outdat.brpd_%0.2d.%s.%s;',...
                                  pats(p),areas{a},medstat{m})); 
            betafreq(m,:) = fftout(frequse); 
            tablePat(cnt).pat = pats(p);
            tablePat(cnt).med = medstat{m};
            tablePat(cnt).areas = areas{a};
            tablePat(cnt).updrs = eval(sprintf('brpd_%0.2d(%d);',pats(p),m));
            tablePat(cnt).freqs = 1:100;
            tablePat(cnt).fftot = fftout;
            tablePat(cnt).mean = mean(abs(fftout(frequse)));
            tablePat(cnt).auc = trapz(12:30,abs(fftout(12:30)));
            tablePat(cnt).median = median(abs(fftout(frequse)));
            tablePat(cnt).peak = max(abs(fftout(frequse)));
            cnt = cnt +1; 
        end
        
        % AUC 
        % mean 
        % median 
        % peak 
        % updrs 
        % table save 
    end
end
tbl = struct2table(tablePat);
save('fft-3-week-all-pat-meds-on-off-andudprs.mat','tbl','-append');
%% plot delta meds / updrs 
pats = [1 3 4 5 6 7 9]; 
medstat = {'on','off'};
areas   = {'m1' , 'stn'};
measures = {'auc','median','peak','mean'}; 

for v = 1:length(measures)
    hfig = figure; 
    for a = 1:length(areas)
        for p = 1:length(pats)
            for m = 1:length(medstat)
                idx(:,m) = strcmp(tbl.med,medstat{m}) & ...
                    strcmp(tbl.areas,areas{a}) & ...
                    tbl.pat == pats(p);
            end
            delta = table2array( tbl(idx(:,2),measures{v})) - ...
                table2array( tbl(idx(:,1),measures{v}));
            deltaupdrs = table2array( tbl(idx(:,2),'updrs')) - ...
                table2array( tbl(idx(:,1),'updrs'));
            subplot(1,2,a); 
            hs = scatter(deltaupdrs,delta,300,'filled');
            hold on; 
            legenduse{p} = sprintf('p%0.2d',pats(p));
        end
        subplot(1,2,a); 
        title(sprintf('%s',areas{a})); 
        xlabel('\Delta UPDRS'); 
        ylabel(sprintf('\\Delta %s',measures{v}));
        legend(legenduse); 
    end
    suptitle(sprintf('\\Delta %s \\beta vs \\Delta UDPRS',measures{v})); 
    % save 
    fnmsv = sprintf('MedsOn-Off-BetaVsUPDRS-3week-measure-%s12-20.pdf',measures{v});
    fnmsave = fullfile(figdir, fnmsv);
    hfig.PaperPositionMode = 'manual';
    hfig.PaperSize = [8.5*2 16/2];
    hfig.PaperPosition = [ 0 0 8.5*2 16/2];
    print(hfig,fnmsave,'-dpdf');
    close(hfig);
end
end