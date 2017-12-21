function MAIN_gpi_grant_phill()
% load /Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/database/database.mat
load /Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/interactive_plot_db/db_all_subs.mat
% idxuse = cellfun(@(x) strcmp(x,'montage'),datTabAll.task) & ... 
%          (cellfun(@(x) strcmp(x,'+E0-E1'),datTabAll.lfp_elec) | cellfun(@(x) strcmp(x,'+E2-E3'),datTabAll.lfp_elec) )& ...
%          cellfun(@(x) strcmp(x,'brpd10'),datTabAll.patient);
     
idxuse = cellfun(@(x) strcmp(x,'montage'),resTabAll.task) & ...
         (cellfun(@(x) strcmp(x,'+E0-E1'),resTabAll.lfp_elec) | cellfun(@(x) strcmp(x,'+E2-E3'),resTabAll.lfp_elec) )& ...
         cellfun(@(x) strcmp(x,'brpd10'),resTabAll.patient);
     
idxnums = find(idxuse==1); 

figure; 
ax1 = subplot(2,2,1); 
ax2 = subplot(2,2,2); 
ax3 = subplot(2,2,3); 
ax4 = subplot(2,2,4); 
hold on; 
for i = 1:length(idxnums) 
    clr = [0 0 1 0.8];
    dp = resTabAll(idxnums(i),:);
    if dp.med
        if strcmp(dp.lfp_elec{1},'+E2-E3')
            spblt = 1;
            ttl = 'med on GPe';
        else
            ttl = 'med on GPi';
            spblt = 2;
        end
    else
        if strcmp(dp.lfp_elec{1},'+E2-E3')
            spblt = 3;
            ttl = 'med off GPe';
        else
            ttl = 'med off GPi';
            spblt = 4;
        end
    end
   
    
    subplot(2,2,spblt); 
    hold on;
    plot(dp.psdlfpF{:},log10(dp.psdlfp{:}),...
        'Color',clr,...
        'LineWidth',2)
    title(ttl);
    xlabel('Frequency (Hz'); 
    ylabel('Power  (log_1_0\muV^2/Hz)');
%     
%     hold on;
%     plot(dp.psdecogF{:},log10(dp.psdecog{:}),...
%         'Color',clr,...
%         'LineWidth',2)
%     ax3 = subplot(2,2,[3 4]); 
end
linkaxes([ax1 ax2 ax3 ax4]);
xlim([5 100]);

%% med effect 3 week + 10 day
load /Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/interactive_plot_db/db_all_subs.mat
     
idxkeep = (cellfun(@(x) strcmp(x,'rest'),resTabAll.task) | cellfun(@(x) strcmp(x,'ipad'),resTabAll.task) | cellfun(@(x) strcmp(x,'walking'),resTabAll.task) )& ...
         cellfun(@(x) strcmp(x,'brpd10'),resTabAll.patient) & ...
         (cellfun(@(x) strcmp(x,'3 week'),resTabAll.visit) | cellfun(@(x) strcmp(x,'10 day'),resTabAll.visit));
     
tasksuse = {'rest','ipad','walking'}; 

%% plot freq patches 
hfig = figure; 
handles.axlfp = subplot(2,2,1);
handles.axecog = subplot(2,2,2);
handles.axcoher= subplot(2,2,[3 4]);
%% 
%%  
handles.freqranges = [1 4; 4 8; 8 13; 13 20; 20 30; 30 50; 50 90];
handles.freqnames  = {'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','LowGamma','HighGamma'}';

handles.freqranges = [12 30];
handles.freqnames  = {'Beta'}';

cuse = parula(size(handles.freqranges,1));
ydat = [1 1 -8 -8]; 
axesclr = [handles.axlfp,handles.axecog,handles.axcoher];
handles.axesclr = axesclr;
for a = 1:length(axesclr)
    for p = 1:size(handles.freqranges,1)
        freq = handles.freqranges(p,:);
        xdat = [freq(1) freq(2) freq(2) freq(1)];
        handles.hPatches(p,a) = patch('XData',xdat,'YData',ydat);
        handles.hPatches(p,a).Parent = axesclr(a);
        handles.hPatches(p,a).FaceColor = cuse(p,:);
        handles.hPatches(p,a).FaceAlpha = 0.3;
        handles.hPatches(p,a).EdgeColor = 'none';
        handles.hPatches(p,a).Visible = 'on';
    end
end
%% 
handles.axecog.XLim = [2 100];
handles.axlfp.XLim = [2 100];
handles.axcoher.XLim = [2 100];
%% 
%% set titles and axes 
xlabel(handles.axecog,'Frequency (Hz)');
ylabel(handles.axecog,'Power  (log_1_0\muV^2/Hz)');
title(handles.axecog,'ECOG');

xlabel(handles.axlfp,'Frequency (Hz)');
ylabel(handles.axlfp,'Power  (log_1_0\muV^2/Hz)');
title(handles.axlfp,'LFP');

xlabel(handles.axcoher,'Frequency (Hz)');
ylabel(handles.axcoher,'Coherence');
title(handles.axcoher,'Coherence between LFP-ECOG');
%%
xaxfnms = {'psdlfpF', 'psdecogF', 'coherfreq'};
yaxfnms = {'psdlfp','psdecog','cpherpower'};

%%
xaxfnms = {'psdlfpF', 'psdecogF', 'coherfreq'};
yaxfnms = {'psdlfp','psdecog','cpherpower'};
elcfnms = {'lfp_elec', 'ecog_elec','ecog_elec'};

%% start figure 
figdir = '/Users/roee/Starr_Lab_Folder/Grants/RO1_renewal /Figures/bnc2';
condsuse = {'rest','ipad','walking'};
for c = 1:length(condsuse)
    
    hfig = figure;
    handles.axlfp = subplot(2,2,1);
    handles.axecog = subplot(2,2,2);
    handles.axcoher= subplot(2,2,3);
    
    axuse   = [handles.axlfp handles.axecog handles.axcoher];
    % set titles and axes
    xlabel(handles.axecog,'Frequency (Hz)');
    ylabel(handles.axecog,'Power  (log_1_0\muV^2/Hz)');
    title(handles.axecog,'ECOG');
    
    xlabel(handles.axlfp,'Frequency (Hz)');
    ylabel(handles.axlfp,'Power  (log_1_0\muV^2/Hz)');
    title(handles.axlfp,'LFP');
    
    xlabel(handles.axcoher,'Frequency (Hz)');
    ylabel(handles.axcoher,'Coherence');
    title(handles.axcoher,'Coherence between LFP-ECOG');
    
    idxkeep = cellfun(@(x) strcmp(x,condsuse{c}),resTabAll.task) &...
        cellfun(@(x) strcmp(x,'brpd10'),resTabAll.patient) & ...
        (cellfun(@(x) strcmp(x,'3 week'),resTabAll.visit) | cellfun(@(x) strcmp(x,'10 day'),resTabAll.visit));
    
    for a = 1:length(axuse)
        for p = 1:size(handles.freqranges,1)
            freq = handles.freqranges(p,:);
            xdat = [freq(1) freq(2) freq(2) freq(1)];
            handles.hPatches(p,a) = patch('XData',xdat,'YData',ydat);
            handles.hPatches(p,a).Parent = axuse(a);
            handles.hPatches(p,a).FaceColor = cuse(p,:);
            handles.hPatches(p,a).FaceAlpha = 0.3;
            handles.hPatches(p,a).EdgeColor = 'none';
            handles.hPatches(p,a).Visible = 'on';
        end
    end
    
    plotidx = find(idxkeep == 1);
    
    for a = 1:3
        cnton = 1; cntoff = 1; 
        medson = []; medsoff = [];
        hax = axuse(a);
        for i = 1:size(plotidx,1)
            s = plotidx(i);
            f   = eval(sprintf('resTabAll.%s{s}',xaxfnms{a}));
            
            %% get psd to plot
            if a < 3
                psd = log10(eval(sprintf('resTabAll.%s{s}',yaxfnms{a})));
            else
                psd = eval(sprintf('resTabAll.%s{s}',yaxfnms{a})); % don't log10 for cohernce
            end
            %%
%             hlns(i,a) = line(f, psd,'Parent',hax,...
%                 'LineWidth',2);
            
            if resTabAll.med(s)
%                 hlns(i,a).Color = [0 0.9 0 0.7];
                medson(cnton,:) = psd;
                cnton = cnton + 1; 
            else
%                 hlns(i,a).Color = [0.9  0 0 0.8];
                medsoff(cntoff,:) = psd;
                cntoff = cntoff + 1; 
            end
            if resTabAll.stim(s)
%                 hlns(i,a).LineStyle = '-.';
            end
        end
        hfig.CurrentAxes = hax;
        hold on;
%         shadedErrorBar(f,medson,{@mean,@(x) std(x)/sqrt(size(medson,1)) },'lineprops',{'Color',[0 0.9 0 ],'LineWidth',2});
        h1 = plot(f,mean(medson,1),'Color',[0 0.9 0 ],'LineWidth',2);
        hold on;
%         shadedErrorBar(f,medsoff,{@mean,@(x) std(x)/sqrt(size(medsoff,1)) },'lineprops',{'Color',[0.9  0 0 ],'LineWidth',2});        
        h2 = plot(f,mean(medsoff,1),'Color',[0.9 0 0 ],'LineWidth',2);
        legend([h1, h2],{'on med','off med'})
    end
    
    
    
    set(axuse(1),'XLim',[1 100]);
    set(axuse(1),'YLim',[-8 -5.5]);
    set(axuse(2),'XLim',[1 100]);
    set(axuse(2),'YLim',[-8 -4.9]);
    set(axuse(3),'XLim',[1 100]);
    set(axuse(3),'YLim',[0 1]);
    
    set(findall(hfig,'-property','FontSize'),'FontSize',12)
    % suptitle(ttlfig);
    hfig.PaperPositionMode = 'manual';
    hfig.PaperSize = [14 8];
    hfig.PaperPosition = [0 0 14 8];
    fnmsv = sprintf('111_%s_-avg.jpeg',condsuse{c});
    print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r600');
    fnmsv = sprintf('111_%s_-avg.pdf',condsuse{c});
    print(hfig,fullfile(figdir,fnmsv),'-dpdf');

end
%%

%% tremor 
clear all;
diruse = uigetdir();

ff = findFilesBVQX(diruse,'EEGRAW_*.mat'); load(ff{1});
ff = findFilesBVQX(diruse,'analyzed_ipad_data.mat'); load(ff{1});
ff = findFilesBVQX(diruse,'BRRAW_*.mat'); load(ff{1});
ff = findFilesBVQX(diruse,'ipad_event_indices.mat'); load(ff{1});

acc = eegraw.Erg1;
% acc = eegraw.EXG4 - eegraw.EXG3;
bp = designfilt('highpassiir',...
    'FilterOrder',3, ...
    'PassbandFrequency',2,...
    'SampleRate',2048);
acc = filtfilt(bp,double(acc));
acc = acc - mean(acc);


sr = eegraw.srate;

%% resample data
brdat(1,:) = brraw.lfp(alligninfo.ecogsync(1):end);
brdat(2,:) = brraw.ecog(alligninfo.ecogsync(1):end);

accAlgn     = double(acc(alligninfo.eegsync(1):end));
[P,Q]  = rat(ecogsr/eegraw.srate);
accAlgnRS = resample(accAlgn,P,Q);
% trim data to match 
if size(brdat,2) > size(accAlgnRS,2)
    brdat = brdat(:,1:size(accAlgnRS,2));
elseif size(brdat,2) < size(accAlgnRS,2)
    accAlgnRS = accAlgnRS(1:size(brdat,2));
end
%% plot raw data 
figure; 
x1 = subplot(3,1,1);
secs = [1:length(accAlgnRS) ]./794;
plot(secs,accAlgnRS);
title('acc'); 
x2 = subplot(3,1,2);
plot(secs,brdat(1,:));
title('lfp'); 
x3 = subplot(3,1,3);
plot(secs,brdat(2,:));
title('ecog'); 
linkaxes([x1 x2 x3],'x');

%% plot pwelch
idxuse = [10*794 length(accAlgnRS)-10*794];
accAlgnRS = accAlgnRS(idxuse(1):idxuse(2));
brdat = brdat(:,idxuse(1):idxuse(2));
sr = ecogsr;
[fftOut,f]   = pwelch(accAlgnRS,sr,sr/2,1:100,sr,'psd');
hfig = figure;
% acc 
subplot(3,1,1);
plot(f,log10(fftOut),'LineWidth',2);
title('accleremator');
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
% br 
subplot(3,1,2);
sr = alligninfo.ecogsr;
[fftOut,f]   = pwelch(brdat(1,:),sr,sr/2,1:100,sr,'psd');
plot(f,log10(fftOut),'LineWidth',2);
title('brain radio lfp');
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');

dat = brraw.ecog(5e3:end-5e3);
subplot(3,1,3);
sr = alligninfo.ecogsr;
[fftOut,f]   = pwelch(brdat(1,:),sr,sr/2,1:100,sr,'psd');
plot(f,log10(fftOut),'LineWidth',2);
title('brain radio ecog');
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');

%% plot spectorgram 



%% compute pac 
params.regionnames = {'GPi','M1'};
params.AmpFreqVector = 2:2:40;
params.PhaseFreqVector = 2:2:10;
params.PhaseFreq_BandWidth = 4;
params.AmpFreq_BandWidth = 10;

computePAC(brdat,ecogsr,params);

params.regionnames = {'m1','acc'};
params.AmpFreqVector = 2:2:40;
params.PhaseFreqVector = 2:2:10;
params.PhaseFreq_BandWidth = 2;
params.AmpFreq_BandWidth = 8;

data(1,:) = brdat(2,:);
data(2,:) = accAlgnRS;
computePAC(data,ecogsr,params);

params.regionnames = {'lfp','acc'};
params.AmpFreqVector = 2:2:40;
params.PhaseFreqVector = 2:2:10;
params.PhaseFreq_BandWidth = 2;
params.AmpFreq_BandWidth = 8;

data(1,:) = brdat(1,:);
data(2,:) = accAlgnRS;
computePAC(data,ecogsr,params);
%%

% bp data 
bp = designfilt('bandpassiir',...
    'FilterOrder',2, ...
    'HalfPowerFrequency1',5-1,...
    'HalfPowerFrequency2',5+1, ...
    'SampleRate',ecogsr);
dat1 = filtfilt(bp,accAlgnRS);
[accBP, low] = envelope(dat1,120,'analytic'); % analytic rms


bp = designfilt('bandpassiir',...
    'FilterOrder',2, ...
    'HalfPowerFrequency1',5-1,...
    'HalfPowerFrequency2',5+1, ...
    'SampleRate',ecogsr);
datlfp = filtfilt(bp,data(2,:));
[lfpBP, low] = envelope(datlfp,120,'analytic'); % analytic rms

idx = 800:1:size(lfpBP,2);
p1 = (lfpBP(idx) - min(lfpBP(idx))) / ( max(lfpBP(idx)) - min(lfpBP(idx)) );
p2 = (accBP(idx) - min(accBP(idx))) / ( max(accBP(idx)) - min(accBP(idx)) );
figure;plot(p1);hold on; plot(p2);
[r, p] = corrcoef(p1',p2');

[r,lags] = xcorr ( p1 -mean(p1),p2-mean(p2),10e3,'coeff');
figure;plot(lags,r);


%% tremor analyssi 
load /Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/interactive_plot_db/db_all_subs.mat
     
idxkeep = (cellfun(@(x) strcmp(x,'rest'),resTabAll.task) | cellfun(@(x) strcmp(x,'ipad'),resTabAll.task) | cellfun(@(x) strcmp(x,'walking'),resTabAll.task) )& ...
         cellfun(@(x) strcmp(x,'brpd10'),resTabAll.patient) & ... 
         cellfun(@(x) strcmp(x,'ipad'),resTabAll.task);
idxnums = find(idxkeep== 1); 
patdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_10';
% find the raw data  
possstrings = {'OR day','2 day','10 day',...
                '3 week','1 month','2 month',...
                '3 month','6 month','1 year',...
                '2 year'};
matcstr    =  { 'OR_day','predis','10_day',...
                '03_wek','01_mnt','02_mnt',...
                '03_mnt','06_mnt',...
                '01_yer','02_yer'};
fdirs = findFilesBVQX(patdir,'*',struct('dirs',1,'depth',1));

hfig = figure; 
printLine = @(x) fprintf('%s\n',x);
for i = 1:length(idxnums)
    dp = resTabAll(idxnums(i),:);
    visitstr = matcstr(strcmp(dp.visit,possstrings));
    idxvisit = cellfun(@(x) any(strfind(x,visitstr)),fdirs);
    visitdir = fdirs(idxvisit);
    sessdir  = findFilesBVQX(visitdir,sprintf('s_%0.3d*',dp.sessionum),struct('dirs',1,'depth',1));
    eegrawfn = findFilesBVQX(sessdir,'EEGRAW*.mat');
    if ~isempty(eegrawfn)
        load(eegrawfn{1});
        [b,a]        = butter(3,[1 40] / (eegraw.srate/2),'bandpass'); % user 3rd order butter filter
        sr = eegraw.srate;
        secschop = 20; 
        idx = secschop*sr : length(eegraw.EXG2)- secschop*sr;
        dat.chan12 = filtfilt(b,a,double(eegraw.EXG2(idx) - eegraw.EXG1(idx))) ;
        dat.chan34 = filtfilt(b,a,double(eegraw.EXG4(idx) - eegraw.EXG3(idx))) ;
        dat.chan56 = filtfilt(b,a,double(eegraw.EXG6(idx) - eegraw.EXG5(idx))) ;
        dat.chan78 = filtfilt(b,a,double(eegraw.EXG7(idx) - eegraw.EXG8(idx))) ;
        dat.erg1 = filtfilt(b,a,double(eegraw.Erg1(idx)));
        dat.erg2 = filtfilt(b,a,double(eegraw.Erg2(idx)));
        chanNames = {'chan12', 'chan34','chan56','chan78','erg1','erg2'};
        for c = 1:length(chanNames)
            subplot(2,3,c); hold on;
            [fftOut,f]   = pwelch(dat.(chanNames{c}),sr,sr/2,1:20,sr,'psd');
            hp = plot(f,log10(fftOut),'LineWidth',2);
            title(chanNames{c});
            xlabel('Frequency (Hz)');
            ylabel('Power  (log_1_0\muV^2/Hz)');
            if dp.med
                hp.Color = [0 0.9 0 0.7];
            else
                hp.Color = [0.9  0 0 0.8];
            end
            if dp.stim
                hp.LineStyle = '-.';
            end
        end
    end
end
        


     

end