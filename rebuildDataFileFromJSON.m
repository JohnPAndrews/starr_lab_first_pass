function rebuildDataFileFromJSON(dirname)
% find json
% find data file
% change folder condition names
% change datTab condition name


load /Users/roee/Starr_Lab_Folder/Data_Analysis/1_tremor_visit/data/br_raw/data/dataBR_rebuilt.mat
params.PhaseFreqVector = 3:3:30; % for some reason peak apppears positive if its chopped at 30.
params.AmpFreqVector   = 3:3:30;
params.PhaseFreq_BandWidth   = 8;
params.AmpFreq_BandWidth   = 20;
params.useparfor   = 0;
params.regionnames = {'GPi','M1'};

% change tremor name s
% bernadet coupling betweeen 20-90hz - in data that filter. Berandet
% something 
% Paul - on/off med 
% only dyknesia - not tremor. 
% michael egger - not that keen regarding upgrade 

for d = [5 6 17 18]%1:size(datTab,1)
    clear data;
    data(1,:) = datTab.lfp{d};
    data(2,:) = datTab.ecog{d};
    idx = datTab.idxclean(d,:); 
    data = data(:,idx(1):idx(2));
    data(1,:) = data(1,:) - mean(data(1,:),2); 
    data(2,:) = data(2,:) - mean(data(2,:),2);
    pacres(d).res = computePAC(data,794,params);
    ttluse = sprintf('%s m-%d s-%d',...
        datTab.task{d},...
    datTab.med(d),...
    datTab.stim(d));
    suptitle(strrep(ttluse,'_',' '));
end
%}

%% temp 
rawdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/1_tremor_visit/data/br_raw';
addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/eeglab14_1_0b'));
ff = findFilesBVQX(rawdir,'s*',struct('dirs',1,'depth',1));
for f = 1:length(ff)
    fff= findFilesBVQX(ff{f},'*.bdf');
    if ~isempty(fff)
        b =1;
        bdffnms{b} = fff{1};
        start = tic;
        [pn,fn,ext] = fileparts(bdffnms{b});
        EEG = pop_biosig(bdffnms{b});
        labs = {EEG.chanlocs.labels};
        idxchan = find(cellfun(@(x) any(strfind(x,'EXG')),labs)==1) ;
        eegraw = [];
        for c = 1:length(idxchan)
            eegraw.(labs{idxchan(c)}) = EEG.data(idxchan(c),:);
        end
        idxchan = find(cellfun(@(x) any(strfind(x,'Erg')),labs)==1) ;
        for c = 1:length(idxchan)
            eegraw.(labs{idxchan(c)}) = EEG.data(idxchan(c),:);
        end
        eegraw.srate = EEG.srate;
        if isfield(EEG,'event')
            eegraw.event = EEG.event;
        end
        save(fullfile(pn,['EEGRAW_' fn '.mat']),'eegraw');
        fprintf('saved file %d out of %d in %f\n',b,length(bdffnms),toc(start));
    end
end
%% allign info  
for f = 1:length(ff)
    eegf= findFilesBVQX(ff{f},'BRRAW*.mat');
    brf= findFilesBVQX(ff{f},'EEGRAW*.mat');
    if ~isempty(eegf) & ~isempty(brf)
        load(eegf{1}); load(brf{1});
        alligninfo = threshold_beep_finder(eegraw,brraw);
        save(fullfile(ff{f},'ipad_allign_info.mat'),'alligninfo');
    end
end
%% create events table 

for f = 1:length(ff)
    eegf= findFilesBVQX(ff{f},'BRRAW*.mat');
    brf= findFilesBVQX(ff{f},'EEGRAW*.mat');
    alinf = findFilesBVQX(ff{f},'ipad_allign_info.mat');
    if ~isempty(eegf) & ~isempty(brf) & ~isempty(alinf);
        load(eegf{1}); load(brf{1});load(alinf{1});
        if isstruct(eegraw.event)
            eventTable = struct2table( eegraw.event);
            beepSecsEEG = eventTable.latency ./ alligninfo.eegsr  - alligninfo.eegsync(1) ./ alligninfo.eegsr;
            beepSecsBR  = beepSecsEEG + alligninfo.ecogsync(1) ./ alligninfo.ecogsr;
            eventTable.beepIdxBR   = round(beepSecsBR .* alligninfo.ecogsr);
            for t = 1:size(eventTable)
                cd = eventTable.type(t);
                if cd > 9 & cd < 15
                    eventTable.code(t) = cd - 10;
                    eventTable.string{t} = sprintf('left upper');
                elseif cd > 19 & cd < 25
                    eventTable.code(t) = cd - 20;
                    eventTable.string{t} = sprintf('right upper');
                elseif cd > 29 & cd < 35
                    eventTable.code(t) = cd - 30;
                    eventTable.string{t} = sprintf('left lower');
                elseif cd > 39 & cd < 45
                    eventTable.code(t) = cd - 40;
                    eventTable.string{t} = sprintf('right lower');
                end
            end
            save(fullfile(ff{f},'gui_event_indices.mat'),'eventTable');
            clear eventTable
        end
    end
end
%% plot tremor by severity 
diruse = '/Users/roee/Starr_Lab_Folder/Data_Analysis/1_tremor_visit/data/br_raw/s_006_tsk-dynamic_tremor';
diruse = '/Users/roee/Starr_Lab_Folder/Data_Analysis/1_tremor_visit/data/br_raw/s_018_tsk-dynamic_tremor';
fmf = findFilesBVQX(diruse,'*.mat'); 
for f =1:length(fmf)
    load(fmf{f});
end

% plot treemory by severity  
hfig = figure;
areasuse = {'lfp','ecog'};
clrs = ...
    [217,148,0;
198,143,255;
58,92,8;
1,213,200]./256;
clrs = parula(4); 
for a = 1:length(areasuse)
    hsub(a) = subplot(1,2,a);
    hold on;
    dat = brraw.(areasuse{a});
    for s = 1:size(eventTable,1)
        idxbr = eventTable.beepIdxBR(s);
        idxuse = idxbr+794:1:idxbr+794*5;
        datuse = dat(idxuse); 
        datdc = datuse-mean(datuse);
        [fftOut,f]   = pwelch(datdc,256,256/2,1:100,794,'psd');
        hlines(s,a) = plot(f,log10(fftOut),...
            'Visible','on',...
            'Color',[clrs(eventTable.code(s),:)  0.8],...
            'LineWidth',4);
        legendttls{s} = sprintf('tremor %d',eventTable.code(s));
    end
    xlim([5 30]);
    xlabel('Frequency (Hz)');
    ylabel('Power  (log_1_0\muV^2/Hz)');
    title(areasuse{a});
end

areasuse = {'lfp','ecog'};
clrs = ...
    [217,148,0;
198,143,255;
58,92,8;
1,213,200]./256;
clrs = parula(4); 
for a = 1:length(areasuse)

[ttls,idx] = unique(legendttls);
legend(hlines(idx,1),ttls);
legend(hlines(idx,2),ttls);
set(hsub(1),'FontSize',16)
set(hsub(2),'FontSize',16)
end
%% look at beta filter over time 


% plot treemory by severioty 
hfig = figure;
areasuse = {'lfp','ecog'};
clrs = ...
    [217,148,0;
198,143,255;
58,92,8;
1,213,200]./256;

bpuse(1,:) = [ 7 12];% gpi 
bpuse(2,:) = [ 7 14];% ecog 
bpeeg = designfilt('bandpassiir',...
    'FilterOrder',4, ...
    'HalfPowerFrequency1',4,...
    'HalfPowerFrequency2',7, ...
    'SampleRate',794);

clrs = parula(4); 
nrow = 4; 
ncol = 1; 
for a = 1:length(areasuse)
    hsub(a) = subplot(nrow,ncol,a);
    title(areasuse{a});
    hold on; 
    dat = brraw.(areasuse{a});
    secs = (1:length(dat))./794; 
    secseeg = (1:length(eegraw.Erg1))./2048; 
    bp = designfilt('bandpassiir',...
        'FilterOrder',4, ...
        'HalfPowerFrequency1',bpuse(a,1),...
        'HalfPowerFrequency2',bpuse(a,2), ...
        'SampleRate',794);
    betafilt(a,:) = filtfilt(bp,dat);
    [uptemp, low ]= envelope(betafilt(a,:),794*8,'analytic'); % analytic rms
%     [uptemp, low ]= abs(hilbert(betafilt(a,:),794*8); % analytic rms
    up(a,:) = uptemp(1,:);
    hsbeeg(1) = subplot(nrow,ncol,3);
    hold on;
    hsbeeg(2) = subplot(nrow,ncol,4);
    hold on;
    adjustsecs = eventTable.latency(1)/2048 - eventTable.beepIdxBR(1)/794;
    for s = 1:size(eventTable,1)-1
        idxbr = eventTable.beepIdxBR(s):1:eventTable.beepIdxBR(s+1) ;
        plot(hsub(a),secs(idxbr),betafilt(a,idxbr),'Color',[0 0 0 0.5],'LineWidth',0.2);
        plot(hsub(a),secs(idxbr),up(a,idxbr),'Color',clrs(eventTable.code(s),:),'LineWidth',3);
        % just for legend 
        hlines(s,a) = plot(hsub(a),13,0,...
            'Visible','on',...
            'Color',[clrs(eventTable.code(s),:)  1],...
            'LineWidth',4);
        legendttls{s} = sprintf('updrs %d',eventTable.code(s));
        % plot erg 1 + 2
        if a == 1
            title(hsbeeg(1),'erg1');
            idxeeg = eventTable.latency(s):1:eventTable.latency(s+1) ;
            plot( hsbeeg(1),secseeg(idxeeg)-adjustsecs,filtfilt(bpeeg, double(eegraw.Erg1(idxeeg)) ),'Color',clrs(eventTable.code(s),:),'LineWidth',3);
            title(hsbeeg(2),'erg2');
            plot( hsbeeg(2),secseeg(idxeeg)-adjustsecs, filtfilt(bpeeg, double(eegraw.Erg2(idxeeg))),'Color',clrs(eventTable.code(s),:),'LineWidth',3);
        end
        
    end
end
[ttls,idx] = unique(legendttls);
linkaxes([hsub hsbeeg],'x');
legend(hlines(idx,1),ttls);
legend(hlines(idx,2),ttls);
set(hsub(1),'FontSize',16)
set(hsub(2),'FontSize',16)
set(hsbeeg(1),'FontSize',16)
set(hsbeeg(2),'FontSize',16)

%% check eeg
hfig = figure; 
hsub(1) = subplot(2,1,1); hold on; title('erg1');
hsub(2) = subplot(2,1,2); hold on; title('erg2');
bp = designfilt('bandpassiir',...
    'FilterOrder',4, ...
    'HalfPowerFrequency1',4,...
    'HalfPowerFrequency2',7, ...
    'SampleRate',794);

for s = 1:size(eventTable,1)-1
    idxeeg = eventTable.latency(s):1:eventTable.latency(s+1) ;
    if length(idxeeg) > 2048*5;
    [fftOut,f]   = pwelch(eegraw.Erg1(idxeeg),2048,2048/2,1:100,2048,'psd');
    plot( hsub(1),f,fftOut,'Color',clrs(eventTable.code(s),:),'LineWidth',3);
    xlim(hsub(1),[0 10]);
    [fftOut,f]   = pwelch(eegraw.Erg2(idxeeg),2048,2048/2,1:100,2048,'psd');
    plot( hsub(2),f,fftOut,'Color',clrs(eventTable.code(s),:),'LineWidth',3);
    xlim(hsub(2),[0 10]);
    end
end

%% plot coherence 
clear data; 
d = 6; 
data(1,:) = datTab.lfp{d};
data(2,:) = datTab.ecog{d};
idx = datTab.idxclean(d,:);
data = data(:,idx(1):idx(2));
data(1,:) = data(1,:) - mean(data(1,:),2);
data(2,:) = data(2,:) - mean(data(2,:),2);

plot_data_coherence(data(1,:),data(2,:),794,'test');

%% .cross correlate
bpuse(1,:) = [ 7 12];% gpi 
bpuse(2,:) = [ 7 14];% ecog 
bpeeg = designfilt('bandpassiir',...
    'FilterOrder',4, ...
    'HalfPowerFrequency1',4,...
    'HalfPowerFrequency2',7, ...
    'SampleRate',794);

clrs = parula(4); 
d = 6; 
clear betafilt up
for a = 1:length(areasuse)
    clear dat data 
    dat = datTab.(areasuse{a}){d};
    idxclean = datTab.idxclean(d,:);
    data = dat(idxclean(1):1:idxclean(2));
    data = data - mean(data); 
    bp = designfilt('bandpassiir',...
        'FilterOrder',4, ...
        'HalfPowerFrequency1',bpuse(a,1),...
        'HalfPowerFrequency2',bpuse(a,2), ...
        'SampleRate',794);
    betafilt(a,:) = filtfilt(bp,double(data));
    [uptemp, low ]= envelope(betafilt(a,:),794*8,'analytic'); % analytic rms
    %     [uptemp, low ]= abs(hilbert(betafilt(a,:),794*8); % analytic rms
    up(a,:) = uptemp(1,:);

    clear data dat 
end
[r,lags] = xcorr ( betafilt(1,:),betafilt(2,:),10e3,'coeff');
[r,lags] = xcorr ( up(1,:)-mean(up(1,:)),up(2,:)-mean(up(2,:)),10e3,'unbiased');
figure;

plot((lags./794).*1000,r);

ylabel('r value');
xlabel('time (msecs)');


%% plot rms along signal, in 1 sec, non overlapping blocks  
clear all
addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/notBoxPlot'));
diruse = '/Users/roee/Starr_Lab_Folder/Data_Analysis/1_tremor_visit/data/br_raw/s_006_tsk-dynamic_tremor';
diruse = '/Users/roee/Starr_Lab_Folder/Data_Analysis/1_tremor_visit/data/br_raw/s_018_tsk-dynamic_tremor';
diruse = '/Users/roee/Starr_Lab_Folder/Data_Analysis/1_tremor_visit/data/br_raw/s_002_tsk-dynamic_tremor';
fmf = findFilesBVQX(diruse,'*.mat'); 
for f =1:length(fmf)
    load(fmf{f});
end

bpuse(1,:) = [ 7 12];% gpi 
bpuse(2,:) = [ 7 14];% ecog 
bpeeg = designfilt('bandpassiir',...
    'FilterOrder',4, ...
    'HalfPowerFrequency1',4,...
    'HalfPowerFrequency2',7, ...
    'SampleRate',794);

clrs = parula(4); 
clear betafilt up ergs dat updrsvec
areasuse = {'lfp','ecog'};
for a = 1:length(areasuse)
    title(areasuse{a});
    hold on; 
    dat = brraw.(areasuse{a});
    updrsvec(a,:) = zeros(1,size(dat,1));
    secs = (1:length(dat))./794; 
    secseeg = (1:length(eegraw.Erg1))./2048; 
    bp = designfilt('bandpassiir',...
        'FilterOrder',4, ...
        'HalfPowerFrequency1',bpuse(a,1),...
        'HalfPowerFrequency2',bpuse(a,2), ...
        'SampleRate',794);
    betafilt(a,:) = filtfilt(bp,dat);
    [uptemp, low ]= envelope(betafilt(a,:),794*8,'analytic'); % analytic rms
%     [uptemp, low ]= abs(hilbert(betafilt(a,:),794*8); % analytic rms
    up(a,:) = uptemp(1,:);
    % eeg 
    ergs(1,:) = filtfilt(bpeeg, double(eegraw.Erg1) );
    ergs(2,:) = filtfilt(bpeeg, double(eegraw.Erg2) );
    adjustsecs = eventTable.latency(1)/2048 - eventTable.beepIdxBR(1)/794;
    
    for s = 1:size(eventTable,1)-1
        idxbr = eventTable.beepIdxBR(s):1:eventTable.beepIdxBR(s+1) ;
        updrsvec(a,idxbr) = eventTable.code(s);        
    end
end

jump = 1; % jump in secs 
start = 13.08;
curmark = start; 
secseegadjus = secseeg - adjustsecs;
cnt = 1;
clear datout
while curmark < max(secs) - jump
    % br data 
    idxusebr  = secs > curmark & secs < curmark + jump; 
    idxuseeeg  = secseegadjus > curmark & secseegadjus < curmark + jump; 
    if length(unique(updrsvec(1,idxusebr)))==1
        if  unique(updrsvec(1,idxusebr)) ~=0
            datout.betafilt(cnt,1) = rms(betafilt(1,idxusebr));
            datout.betafilt(cnt,2) = rms(betafilt(2,idxusebr));
            datout.env(cnt,1) = rms(up(1,idxusebr));
            datout.env(cnt,2) = rms(up(2,idxusebr));
            
            datout.sums(cnt,1) = sum(abs(up(1,idxusebr)));
            datout.sums(cnt,2) = sum(abs(up(2,idxusebr)));

            % eeg
            datout.erg1(cnt,1) = rms(ergs(1,idxuseeeg));
            datout.erg2(cnt,2) = rms(ergs(2,idxuseeeg));
            % updrs
            datout.updrs(cnt) = unique(updrsvec(1,idxusebr));
            datout.colors(cnt,:) = clrs( datout.updrs(cnt),:);
            cnt = cnt + 1;
        end
    end
    curmark = curmark + jump;  
end
hfig = figure('Position',[517         518        1136         756]);
hsub(1) = subplot(3,2,1); 
notBoxPlot(datout.env(:,1),datout.updrs)
xlabel('updrs scores');
ylabel('rms'); 
title(sprintf('GPi rms of env in %0.2f sec blocks',jump))
hsub(1).FontSize = 16; 

hsub(2) = subplot(3,2,2); 
notBoxPlot(datout.env(:,2),datout.updrs)
xlabel('updrs scores');
ylabel('rms'); 
title(sprintf('M1 rms of env in %0.2f sec blocks',jump))
hsub(2).FontSize = 16; 

hsub(3) = subplot(3,2,3); 
hold on; 
for s = 1:size(datout.env,1)
scatter(datout.env(s,1),datout.env(s,2),50,...
    'filled','MarkerFaceColor',  datout.colors(s,:),...
    'MarkerFaceAlpha',0.7);
end
xlabel('GPi rms of envelope');
ylabel('M1'); 
title('RMS of envelope gpi/m1')
hsub(3).FontSize = 16; 

hsub(4) = subplot(3,2,4); 
notBoxPlot(datout.erg2(:,2),datout.updrs)
xlabel('updrs scores');
ylabel('rms'); 
title(sprintf('erg1 rms of env in %0.2f sec blocks',jump))
hsub(4).FontSize = 16; 

hsub(5) = subplot(3,2,5); 
hold on; 
for s = 1:size(datout.env,1)
scatter(datout.erg2(s,2),datout.env(s,1),50,...
    'filled','MarkerFaceColor',  datout.colors(s,:),...
    'MarkerFaceAlpha',0.7);
end
xlabel('GPi rms of envelope');
ylabel('Erg1 rms of envelope'); 
title('rms of erg1 vs GPi')
hsub(5).FontSize = 16; 

hsub(6) = subplot(3,2,6); 
hold on; 
for s = 1:size(datout.env,1)
scatter(datout.erg2(s,2),datout.env(s,2),50,...
    'filled','MarkerFaceColor',  datout.colors(s,:),...
    'MarkerFaceAlpha',0.7);
end
xlabel('M1 rms of envelope');
ylabel('Erg1 rms of envelope'); 
title('rms of erg1 vs M1')
hsub(6).FontSize = 16; 

hfig = figure;
hold on; 
for s = 1:size(datout.env,1)
scatter3(datout.erg1(s,1),datout.env(s,2),datout.env(s,1),50,...
    'filled','MarkerFaceColor',  datout.colors(s,:),...
    'MarkerFaceAlpha',0.7);
end
xlabel('M1 rms of envelope');
ylabel('Erg1 rms of envelope');
zlabel('GPi rms of envelope');
title('rms of erg1 vs M1')
set(gca,'FontSize',16);
%% plot mask 
% 1. power of scatter in gpi vs m1 


for f = 1:length(ff)
    loadBRdata(ff{f});
end

for f = 21:length(ff)
    eegf= findFilesBVQX(ff{f},'BRRAW*.mat');
    brf= findFilesBVQX(ff{f},'EEGRAW*.mat');
    if ~isempty(eegf) & ~isempty(brf)
            load(eegf{1}); load(brf{1});
            alligninfo = threshold_beep_finder(eegraw,brraw);
            save(fullfile(ff{f},'ipad_allign_info.mat'),'alligninfo');
    end
end

load /Users/roee/Starr_Lab_Folder/Data_Analysis/1_tremor_visit/data/br_raw/data/dataBR.mat
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/1_tremor_visit/data/br_raw/protocol-details-^^^^.json';
exporder    = loadjson(fn,'SimplifyCell',1); % this is how to read the
jsonTab = struct2table(exporder);
for s = 1:size(datTab,1)
    datTab.task{s} = jsonTab.task{s};
    datTab.med(s) = jsonTab.med(s);
    datTab.stim(s) = jsonTab.stim(s);
end
save('/Users/roee/Starr_Lab_Folder/Data_Analysis/1_tremor_visit/data/br_raw/data/dataBR_rebuilt.mat','datTab');
% plot
hfig = figure();
hfig.Position = [753         611        1524         710];
areasuse = {'lfp','ecog'};
for a = 1:length(areasuse)
    hsub(a) = subplot(1,2,a);
    title(areasuse{a});
    ylabel('Power  (log_1_0\muV^2/Hz)');
    xlabel('Frequency (Hz)');
    hold on;
    for s = 1:size(datTab,1);
        dat = datTab.(areasuse{a}){s};
        idxclean = datTab.idxclean(s,:);
        dat = dat(idxclean(1):idxclean(2));
        datdc = dat-mean(dat);
        %         [fftOut,f]   = pwelch(datdc,256,256/2,1:100,794,'psd');
        [fftOut,f]   = pwelch(datdc,512,512/2,1:100,794,'psd');
        row = table2struct( datTab(s,:));
        hlines(s,a) = plot(f,log10(fftOut),...
            'ButtonDownFcn',@whichline,...
            'UserData',row,...
            'Visible','on');
        if row.med; clr = [0 0.9 0 0.5]; else;clr = [0.9 0 0 0.5]; end;
        if row.stim; mrk = '--'; else;mrk = '-'; end;
        hlines(s,a).LineWidth = 2;
        hlines(s,a).Color = clr;
        hlines(s,a).LineStyle = mrk;
    end
end
datf.idxvistask = ones(size(hlines,1),1);
datf.idxvismed = ones(size(hlines,1),1);
datf.idxvisstim = ones(size(hlines,1),1);
datf.hlines = hlines;
hfig.UserData = datf;
htask = uicontrol(hfig);
htask.String = unique(datTab.task);
htask.Style = 'listbox';
htask.Position = [20 100 100 100];
htask.Max = length(htask.String);
htask.Callback = @taskselect;
htask.TooltipString = 'select task';

hmed = uicontrol(hfig);
hmed.String = unique(datTab.med);
hmed.Style = 'listbox';
hmed.Position = [20 250 100 50];
hmed.Max = length(hmed.String);
hmed.Callback = @medselect;
hmed.TooltipString = 'select med';


hstim = uicontrol(hfig);
hstim.String = unique(datTab.stim);
hstim.Style = 'listbox';
hstim.Position = [20 500 100 50];
hstim.Max = length(hstim.String);
hstim.Callback = @stimselect;
hstim.TooltipString = 'select stim';


end

function whichline(obj,event)
task = obj.UserData.task;
meds = obj.UserData.med;
stim = obj.UserData.stim;
fprintf('%s m=%d s=%d\n',...
    task,meds,stim);
end

function taskselect(obj,event)
hfig = get(obj,'Parent');
taskuse = obj.String(obj.Value);
hlns = hfig.UserData.hlines;
for i = 1:size(hlns,1)
    row = hlns(i,1).UserData;
    if sum(cellfun(@(x) any(strcmp(x,row.task)),taskuse)) >0
        hfig.UserData.idxvistask(i) = 1;
    else
        hfig.UserData.idxvistask(i)  = 0;
    end
end
updatevis();
end
function stimselect(obj,event)
hfig = get(obj,'Parent');
stimuse = str2num(obj.String(obj.Value));
hlns = hfig.UserData.hlines;
for i = 1:size(hlns,1)
    row = hlns(i,1).UserData;
    if sum(ismember(row.stim,stimuse)) >0
        hfig.UserData.idxvisstim(i)  = 1;
    else
        hfig.UserData.idxvisstim(i) = 0;
    end
end
updatevis();
end

function medselect(obj,event)
hfig = get(obj,'Parent');
meduse = str2num(obj.String(obj.Value));
hlns = hfig.UserData.hlines;
for i = 1:size(hlns,1)
    row = hlns(i,1).UserData;
    if sum(ismember(row.med,meduse)) >0
        hfig.UserData.idxvismed(i) = 1;
    else
        hfig.UserData.idxvismed(i) = 0;
    end
end
updatevis();
end

function updatevis()
hfig = gcf;
idxuse = hfig.UserData.idxvistask & ... 
    hfig.UserData.idxvismed & ... 
    hfig.UserData.idxvisstim; 
hlns = hfig.UserData.hlines;

for i = 1:size(hlns,1)
    for j = 1:size(hlns,2)
        row = hlns(i,j).UserData;
        if idxuse(i)
            hlns(i,j).Visible = 'on';
        else
            hlns(i,j).Visible = 'off';
        end
    end
end

end