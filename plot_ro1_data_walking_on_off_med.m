function plot_ro1_data_walking_on_off_med()

%% build data base
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
ff = findFilesBVQX(rootdir,'dataBR.mat');
tcnt = 1;
datTabAll = [];
for f = 1:length(ff)
    load(ff{f});
    idxuse = strcmp(datTab.task,'montage') & ~datTab.med & ~datTab.stim;
    %% get visit
    possstrings = {'OR day','2 day','10 day',...
        '3 week','1 month','2 month',...
        '3 month','6 month','1 year',...
        '2 year'};
    matcstr    =  { 'OR_day','predis','10_day',...
        '03_wek','01_mnt','02_mnt',...
        '03_mnt','06_mnt',...
        '01_yer','02_yer'};
    
    
    idxvisit = cellfun(@(x) any(strfind(ff{f},x)),matcstr);
    visitstr = possstrings(idxvisit);
    
    
    if strcmp(datTab.patient{1},'brpd10')
        if isempty(visitstr)
            visitstr ={' '};;
        end
        datTab.visit = repmat(visitstr,size(datTab,1),1);
        datTabAll = [datTabAll ; datTab];
    end
end
idxuse = strcmp(datTabAll.task,'walking') & ...
         (strcmp(datTabAll.visit,'10 day') | strcmp(datTabAll.visit,'3 week'));


%% plot 
hfig = figure; 
ds = datTabAll(idxuse,:); 
cntplt = 1; 
subplot(3,1,cntplt); cntplt = cntplt + 1; hold on;
% on off med lfp 
[fftOut1,f]   = pwelch(ds.lfp{1},794,794/2,1:100,794,'psd');
[fftOut2,f]   = pwelch(ds.lfp{3},794,794/2,1:100,794,'psd');
fftOutOffLFP = mean(fftOut1,fftOut2); 
hplt = plot(f,log10(fftOutOffLFP));
hplt.Color = [0.9 0 0 0.7]; 
hplt.LineWidth = 2; 

[fftOut1,f]   = pwelch(ds.lfp{2},794,794/2,1:100,794,'psd');
[fftOut2,f]   = pwelch(ds.lfp{4},794,794/2,1:100,794,'psd');
fftOutOnLFP = mean(fftOut1,fftOut2); 
hplt = plot(f,log10(fftOutOnLFP));
hplt.Color = [0 0.8 0 0.7]; 
hplt.LineWidth = 2; 
title('LFP');

% on off med ecog 
subplot(3,1,cntplt); cntplt = cntplt + 1; hold on;
[fftOut1,f]   = pwelch(ds.ecog{1},794,794/2,1:100,794,'psd');
[fftOut2,f]   = pwelch(ds.ecog{3},794,794/2,1:100,794,'psd');
fftOutOffLFP = mean(fftOut1,fftOut2); 
hplt = plot(f,log10(fftOutOffLFP));
hplt.Color = [0.9 0 0 0.7]; 
hplt.LineWidth = 2; 

[fftOut1,f]   = pwelch(ds.ecog{2},794,794/2,1:100,794,'psd');
[fftOut2,f]   = pwelch(ds.ecog{4},794,794/2,1:100,794,'psd');
fftOutOnLFP = mean(fftOut1,fftOut2); 
hplt = plot(f,log10(fftOutOnLFP));
hplt.Color = [0 0.8 0 0.7]; 
hplt.LineWidth = 2; 
title('ECOG');

% coherence 
subplot(3,1,cntplt); cntplt = cntplt + 1; hold on;

Fs = 794; 
[CxyOff1,F] = mscohere(ds.ecog{1},ds.lfp{1},...
    2^(nextpow2(Fs)),...
    2^(nextpow2(Fs/2)),...
    2^(nextpow2(Fs)),...
    Fs);

[CxyOff2,F] = mscohere(ds.ecog{3},ds.lfp{3},...
    2^(nextpow2(Fs)),...
    2^(nextpow2(Fs/2)),...
    2^(nextpow2(Fs)),...
    Fs);
avCxOff = mean([CxyOff1, CxyOff2],2); 
hplt = plot(F,avCxOff);
hplt.Color = [0.9 0 0 0.7]; 
hplt.LineWidth = 2; 

[CxyOff1,F] = mscohere(ds.ecog{2},ds.lfp{2},...
    2^(nextpow2(Fs)),...
    2^(nextpow2(Fs/2)),...
    2^(nextpow2(Fs)),...
    Fs);

[CxyOff2,F] = mscohere(ds.ecog{4},ds.lfp{4},...
    2^(nextpow2(Fs)),...
    2^(nextpow2(Fs/2)),...
    2^(nextpow2(Fs)),...
    Fs);
avCxOff = mean([CxyOff1],2); 
hplt = plot(F,avCxOff);
hplt.Color = [0 0.8 0 0.7]; 
hplt.LineWidth = 2; 

% [sl, slf, df, F] = cohere_bootstrap_signif_level( ds.ecog{2}, ds.lfp{2}, 0.05, 100 );

figure; 
wcoherence(ds.ecog{2},ds.lfp{2},seconds((1:1:length(ds.ecog{2}))./794),'PhaseDisplayThreshold',0.7);
figure;
wcoherence(ds.ecog{2},ds.lfp{2},seconds(60),'PhaseDisplayThreshold',0.2);

xlim([0 100]); 
xlabel('Freq (Hz)');
ylabel('coherence'); 
ylim([0 0.4]);
%%

cohere_bootstrap_signif_level
cohere_signif_level
% https://websites.pmc.ucsc.edu/~dmk/notes/cohere_signif/

end