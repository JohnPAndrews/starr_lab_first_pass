function exportDataFromDBtoCSV()
load /Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/database/db1_freeman.mat
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_10';
ff  = findFilesBVQX(rootdir,'dataBR.mat'); 
ffr = findFilesBVQX(rootdir,'resultsBR.mat'); 
datOut = []; 
cnt = 1; 
for f = 2:length(ff) 
load(ff{f}); 
load(ffr{f}); 
rs = resTab;
idxuse  = rs.sr == 800 & ... 
          strcmp(rs.task,'rest') & ... 
          cellfun(@(x) any(strcmp(x, '+E1-E3')),rs.lfp_elec) & ... 
          cellfun(@(x) any(strcmp(x, '+E9-E11')),rs.ecog_elec);
dt = datTab(idxuse,:);
rsr = rs(idxuse,:);
bp = [16 19 ; 13 30; 13 20; 21 30]; 
normfrom = [5 50];
names = {'cs_beta','beta','low_beta','high_beta'}; 

bp = [8 12 ; 9 11];
normfrom = [5 50];
names = {'tremor_8_12','tremor_9_11'};

regions = {'lfp','ecog'}; 
for s = 1:size(dt,1)
    dr = dt(s,:); 
    drr = rsr(s,:);
    datout(cnt).patient = dr.patient;
    if f == 9 
        datout(cnt).visit = '6 month';
    else
        datout(cnt).visit = drr.visit;
    end
    datout(cnt).task = dr.task;
    datout(cnt).med = dr.med;
    datout(cnt).stim = dr.stim;
    datout(cnt).time = dr.time;
    datout(cnt).sessionum = dr.sessionum; 
    datout(cnt).duration = dr.duration;
    
    
    
    for r = 1:length(regions) 
        dat(:,r)     = dr.(regions{r}){:}(dr.idxclean(1):dr.idxclean(2)); 
        
        [fftOut,f]   = pwelch(dat(:,r)-mean(dat(:,r)),794*2,794*2/2,1:100,794,'psd');
        for b = 1:size(bp,1)
            for n = 1:2
                lg10 = log10(fftOut);
                idxb = f >= bp(b,1) &  f <= bp(b,2);
                idxnorm = f >= normfrom(1) &  f <= normfrom(2);
                normval = mean(lg10(idxnorm)); 
                if n == 1 % norm
                    fn = sprintf('%s_%s_%s_logpower',regions{r},names{b},'norm');
                    datout(cnt).(fn) = mean(lg10(idxb))./normval;
                elseif n ==2 % don't norm 
                    fn = sprintf('%s_%s_logpower',regions{r},names{b});
                    datout(cnt).(fn) = mean(lg10(idxb));
                end
            end
        end
    end
    
    
    % calc cohernece 
    for b = 1:size(bp,1)
        bpf = designfilt('bandpassiir',...
            'FilterOrder',4, ...
            'HalfPowerFrequency1',bp(b,1),...
            'HalfPowerFrequency2',bp(b,2), ...
            'SampleRate',794);
        bpdat = filtfilt(bpf,dat);
        [coh_mag_lin,coh_phase_lin, phase_coherence, phase_difference,phase_mean]  = calcCoherenceMeasures(bpdat');

        fn = sprintf('%s_%s_mag_sqr_coherence',regions{r},names{b});
        datout(cnt).(fn) = coh_mag_lin;
    end
    cnt = cnt + 1; 
    clear dat; 
end

end
tabout = struct2table(datout);
writetable(tabout,'brpd10-10hz-data.csv');
% beta, norm_beta, low_beta, high_beta, all_beta, coherence arctan coherence, abs_coherence, and phase_coherence 

% rs = resTabAll; 
% % conditions
% % (strcmp(rs.task,'rest') | strcmp(rs.task,'ipad') | strcmp(rs.task,'walking') ) & ... 
% idxuse  = rs.sr == 800 & ... 
%           strcmp(rs.task,'rest') & ... 
%           cellfun(@(x) any(strcmp(x, 'brpd10')),rs.patient) & ... 
%           cellfun(@(x) any(strcmp(x, '+E1-E3')),rs.lfp_elec) & ... 
%           cellfun(@(x) any(strcmp(x, '+E9-E11')),rs.ecog_elec);
% fdb = rs(idxuse,:); 

end

