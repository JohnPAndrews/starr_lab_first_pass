function  MAIN_plot_visit_quick_figures(varargin)
% add this toolbox 
 
addpath(genpath(fullfile(pwd,'toolboxes' ,'jsonlab-1.5')))
% plot_brain_radio_figures()

organize_brain_radio_data(varargin)
get_idxs_brain_radio_clean_data(varargin)
save_brain_radio_results(varargin) % no plotting
% compare_on_off_meds()
% compare_on_off_stim()
% compare_on_off_meds_from_results()
end
% 
function organize_brain_radio_data(varargin)
if ~isempty(varargin{1})
    rootdir = varargin{1}{1};
    if ~any(exist(fullfile(rootdir,'protocol-details-^^^^.json'),'file'))
        fprintf('choose visit dir with brain radio text files (must be in one dir)\n');
        addBrainRadioVisit(rootdir);
    else
        fprintf('json file exist, choose visit dir \n');
    end
else
    %% organize brain radio files
    fprintf('choose visit dir for data saving \n');
    rootdir = uigetdir('choose visit dir to save data .mat');
    
    if ~any(exist(fullfile(rootdir,'protocol-details-^^^^.json'),'file'))
        fprintf('choose visit dir with brain radio text files (must be in one dir)\n');
        addBrainRadioVisit(rootdir);
    else
        fprintf('json file exist, choose visit dir \n');
    end
end
%% create data and figures folder
mkdir(fullfile(rootdir,'data'));
mkdir(fullfile(rootdir,'figures'));
datdir = fullfile(rootdir,'data');
figdir = fullfile(rootdir,'figures');
%% create table of data
sessiondirs = findFilesBVQX(rootdir,'s_*',...
    struct('dirs',1,'depth',1));
jsonfn = fullfile(rootdir,'protocol-details-^^^^.json');
visitjson = loadjson(jsonfn,'SimplifyCell',1); % this is how to read the data back in.
cnt = 1;
for s = 1:length(sessiondirs)
    filesfound = findFilesBVQX(sessiondirs{s},'*.txt');
    if length(filesfound) == 1 % could be raw file 
        [pn,fn,ext] = fileparts(filesfound{1});
        fileuse = fullfile(pn,[fn ext]);
        clear pn fn ext 
    elseif length(filesfound) == 2 % only choose the non raw file 
        [pn{1},fn{1},ext] = fileparts(filesfound{1});
        [pn{2},fn{2},ext] = fileparts(filesfound{2});
        fnuse = fn{~cellfun(@(x) any(strfind(x,'_raw')),fn)};
        pnuse = pn{1};
        fileuse = fullfile(pnuse,[fnuse ext]);
        clear pn fn ext 
    elseif length(filesfound) >= 3 & ~strcmp(visitjson(s).task,'montage')
        error('too many files in session')
    end
    
    % only loop on files if its a montage 
    if strcmp(visitjson(s).task,'montage')
        ffn = filesfound; 
        fnuse = ffn(~cellfun(@(x) any(strfind(x,'_raw')),ffn)); % get rid of raw files 
        ffn = fnuse; 
    else
        ffn{1} = fileuse; 
    end
    
    for ff = 1:length(ffn)
        fileuse = ffn{ff};
        [pn,fn,ext] = fileparts(fileuse);
        
        if any(strfind(fn,'raw')) % if its a raw file, get xml data from non raw xml
            xmlfnm = [fn(1:end-4) '.xml'];
        else
            xmlfnm = [fn '.xml'];
        end
        
        
        
        xmlstruc = xml2struct(fullfile(pn,xmlfnm));
        if isfield(xmlstruc,'RecordingItem')
            xmlstrucparsed = parseXMLstruc(xmlstruc);
        else
            xmlstrucparsed = parseXMLstruc2(xmlstruc);
        end
        xmldata = xmlstrucparsed.RecordingItem;
        
        data = importdata(fileuse);
        datout(cnt).patient   = fn(1:6);
        datout(cnt).sessionum = visitjson(s).num;
        datout(cnt).time      = visitjson(s).time;
        datout(cnt).duration  = visitjson(s).dur;
        datout(cnt).task      = visitjson(s).task;
        datout(cnt).med       = visitjson(s).med;
        datout(cnt).stim      = visitjson(s).stim;
        datout(cnt).sr        = getsampleratefromxml(xmlstrucparsed);
        datout(cnt).ecog      = data(:,3);
        datout(cnt).ecog_elec = sprintf('+%s-%s',...
            xmlstrucparsed.RecordingItem.SenseChannelConfig.Channel3.PlusInput,...
            xmlstrucparsed.RecordingItem.SenseChannelConfig.Channel3.MinusInput);
        datout(cnt).lfp       = data(:,1);
        datout(cnt).lfp_elec  = sprintf('+%s-%s',...
            xmlstrucparsed.RecordingItem.SenseChannelConfig.Channel1.PlusInput,...
            xmlstrucparsed.RecordingItem.SenseChannelConfig.Channel1.MinusInput);
        cnt = cnt +1;
        clear pn fn ext  
    end
    clear ffn 
end
datTab = struct2table(datout);
fnmsave = fullfile(datdir,'dataBR.mat');
save(fnmsave,'datTab');
end

function sr = getsampleratefromxml(xmlstrucparsed)
srraw = regexp(xmlstrucparsed.RecordingItem.SenseChannelConfig.TDSampleRate,'[0-9+]','match');
sr = str2num([srraw{1},srraw{2},srraw{3}]);
end

function plot_brain_radio_figures()
datadir = uigetdir('choose data dir');
[pn,fn,ext] = fileparts(datadir);
figdir  = fullfile(pn,'figures');
load(fullfile(datadir,'dataBR.mat'));

% loop on areas and plot brain radio figures
areas = {'ecog','lfp'};
for s = 1:size(datTab,1)
    for a = 1:length(areas)
        tmp   = datTab.(areas{a}){s};
        tmpt  = preproc_trim_data(tmp,5000,datTab.sr(s));
        params.sr = datTab.sr(s);
        params.lowcutoff = 1;
        tmpth = preproc_dc_offset_high_pass(tmpt,params);
        preproc.(areas{a}) = tmpth;
    end
    plotcoherence(preproc.ecog,preproc.lfp,datTab(s,:),figdir,s)
    plotpsd(preproc.ecog,preproc.lfp,datTab(s,:),figdir,s)
    plotPAC(preproc.ecog,preproc.lfp,datTab(s,:),figdir,s)
    %     plotSpectrogram(preproc.ecog,preproc.lfp,datTab(s,:))
end

end

function save_brain_radio_results(varargin)
if ~isempty(varargin{1})
    datadir = fullfile(varargin{1}{1},'data');
else
    fprintf('choose folder that contains that data .mat file \n');
    datadir = uigetdir('choose data dir');
end
[pn,fn,ext] = fileparts(datadir);
figdir  = fullfile(pn,'figures');
resdir  = fullfile(pn,'results');
mkdir(resdir);
load(fullfile(datadir,'dataBR.mat'));
% fid visit 
if any(strfind(pn,'OR_day'));visitstr = 'OR day';end;
if any(strfind(pn,'predis'));visitstr = '2 day';end;
if any(strfind(pn,'10_day'));visitstr = '10 day';end;
if any(strfind(pn,'03_wek'));visitstr = '3 week';end;
if any(strfind(pn,'01_mnt'));visitstr = '1 month';end;
if any(strfind(pn,'02_mnt'));visitstr = '2 month';end;
if any(strfind(pn,'03_mnt'));visitstr = '3 month';end;
if any(strfind(pn,'06_mnt'));visitstr = '6 month';end;
if any(strfind(pn,'01_yer'));visitstr = '1 year';end;
if any(strfind(pn,'02_yer'));visitstr = '2 year';end;


strfind(pn,'predis')
% loop on areas and plot brain radio figures
areas = {'ecog','lfp'};
rowskeep = [1:7 9 11];
resTab = datTab(:, {'patient'    'sessionum'    'time'    'duration'    'task'    'med'    'stim'    'sr'      'ecog_elec'    'lfp_elec'});
for s = 1:size(datTab,1)
    for a = 1:length(areas)
        tmp   = datTab.(areas{a}){s};
        if isnan(datTab.idxclean(s,1))
            tmpt   = tmp(datTab.sr(s)*3 : end - datTab.sr(s)*3 ); % remove first and last 3 seconds 
        else
        tmpt   = tmp(datTab.idxclean(s,1):datTab.idxclean(s,2));
        end
        %         tmpt  = preproc_trim_data(tmp,5000,datTab.sr(s));
        params.sr = datTab.sr(s);
        params.lowcutoff = 1;
        tmpth = preproc_dc_offset_high_pass(tmpt,params);
        preproc.(areas{a}) = tmpth;
    end
    resTab.visit{s} = visitstr; 
    %% coherence
    [Cxy,F] = mscohere(preproc.ecog,preproc.lfp,...
        2^(nextpow2(datTab.sr(s))),...
        2^(nextpow2(datTab.sr(s)/2)),...
        2^(nextpow2(datTab.sr(s))),...
        datTab.sr(s));
    idxplot = F > 0 & F < 100;
    resTab.coherfreq{s} = F;
    resTab.cpherpower{s} = Cxy;
    %% psd
    [fftOut,f] = pwelch(preproc.ecog,datTab.sr(s),datTab.sr(s)/2,1:round(datTab.sr(s))/2,datTab.sr(s),'psd');
    resTab.psdecogF{s} = f;
    resTab.psdecog{s} = fftOut;
    
    [fftOut,f] = pwelch(preproc.lfp,datTab.sr(s),datTab.sr(s)/2,1:round(datTab.sr(s))/2,datTab.sr(s),'psd');
    resTab.psdlfpF{s} = f;
    resTab.psdlfp{s} = fftOut;
    
    skipthis = 1;
    if ~skipthis
        %% pac
        PhaseFreqVector=[4:2:50];
        AmpFreqVector=[4:4:150];
        bad_times = [];
        skip = [];
        Fs = sr;
        beta_start = 8;
        beta_end = 30;
        
        % error checking
        if isempty(figtitle)
            hfig = [];
        else
            hfig = figure('Position',[1000         673         908         665],'Visible','on');
        end
        
        signal = data; % make sure data is a row vector
        if size(data,2) < size(data,1)
            signal = data';
        end
        
        % initialize variables
        Comodulogram = NaN(length(PhaseFreqVector),length(AmpFreqVector),size(signal,1));
        mean_Comodulogram = NaN(1,size(signal,1));
        mean_beta_PSD = NaN(1,size(signal,1));
        
        [n1_b, n1_a]=butter(3,2*[102 108]/Fs,'stop'); %120hz
        signal(1,:)=filtfilt(n1_b, n1_a, signal(1,:));
        [Comodulogram(:,:)] = pac_art_reject_surr(signal(1,:),Fs,PhaseFreqVector,AmpFreqVector,bad_times,skip);
        mean_Comodulogram(1) = mean(mean(Comodulogram(:,:,1)));
        %% beta burst
    end
    %     plotSpectrogram(preproc.ecog,preproc.lfp,datTab(s,:))
end
save(fullfile(resdir,'resultsBR.mat'),'resTab');

end

function get_idxs_brain_radio_clean_data(varargin)
if ~isempty(varargin{1})
    datadir = fullfile(varargin{1}{1},'data');
else
    fprintf('choose folder that contains that data .mat file for start end choice \n');
    datadir = uigetdir('choose data dir');
end
[pn,fn,ext] = fileparts(datadir);
load(fullfile(datadir,'dataBR.mat'));
logclean = strcmp(datTab.task,'rest') | strcmp(datTab.task,'ipad')  | strcmp(datTab.task,'walking') ;
totalfiles = sum(logclean);
cntcln = 1; 
for s = 1:size(datTab,1)
    data =  [datTab.lfp{s}'; datTab.ecog{s}'];
    logclean = strcmp(datTab.task{s},'rest') | strcmp(datTab.task{s},'ipad')  | strcmp(datTab.task{s},'walking') ;
    if logclean
        idxclean(s,:) = round(select_clean_data_chunk(data));
        fprintf('file %d out of %d done task - %s time -%s \n',...
            cntcln,totalfiles,...
            datTab.task{s},datTab.time{s});
        cntcln = cntcln + 1;
    else
        idxclean(s,:)  = [NaN NaN];
    end
end
datTab.idxclean = idxclean;
save(fullfile(datadir,'dataBR.mat'),'datTab');

end

function compare_on_off_meds()
datadir = uigetdir('choose data dir');
[pn,fn,ext] = fileparts(datadir);
figdir  = fullfile(pn,'figures','on-off-meds');
mkdir(figdir);
resdir  = fullfile(pn,'results');
load(fullfile(datadir,'dataBR.mat'));
% tasks
conds = {'rest', 'ipad','walking'};
% analysis
areas = {'ecog','lfp'};
plotWhat = {'PSD','COH'};
% plotWhat = {'COH'};
for p = 1:length(plotWhat)
    for c = 1:length(conds)
        idxlog = strcmp(datTab.task,conds{c});
        datUse = datTab(idxlog,:);
        hfig = figure();
        for s = 1:size(datUse,1)
            for a = 1:length(areas)
                tmp   = datUse.(areas{a}){s};
                tmpt   = tmp(datUse.idxclean(s,1):datUse.idxclean(s,2));
                %                 tmpt  = preproc_trim_data(tmp,5000,datUse.sr(s));
                params.sr = datUse.sr(s);
                params.lowcutoff = 1;
                tmpth = preproc_dc_offset_high_pass(tmpt,params);
                preproc.(areas{a}) = zscore(tmpth);
            end
            switch plotWhat{p}
                case 'PSD'
                    plotpsdOnOff(preproc.ecog,preproc.lfp,datUse(s,:),figdir,s)
                case 'COH'
                    plotcoherenceoOnOff(preproc.ecog,preproc.lfp,datUse(s,:),figdir,s)
            end
            
        end
        ttlfig = sprintf('%s %s on-off meds',conds{c},plotWhat{p});
        suptitle(ttlfig);
        fnmsv = sprintf('task-%s-%s.fig',conds{c},plotWhat{p});
        saveas(hfig,fullfile(figdir,fnmsv));
        hfig.PaperPositionMode = 'manual';
        hfig.PaperSize = [14 8];
        hfig.PaperPosition = [0 0 14 8];
        fnmsv = sprintf('task-%s-%s.jpeg',conds{c},plotWhat{p});
        print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r600');
        close(hfig);
    end
end

%% montage
plotWhat = {'PSD','COH'};
plotWhat = [];
for p = 1:length(plotWhat)
    for m = 1:6
        idxlog = strcmp(datTab.task,'montage');
        datMon = datTab(idxlog,:);
        datMonOn = datMon(logical(datMon.med),:);
        datMonOff = datMon(~logical(datMon.med),:);
        datUse = [datMonOn(m,:); datMonOff(m,:)];
        hfig = figure();
        for s = 1:size(datUse,1)
            for a = 1:length(areas)
                tmp   = datUse.(areas{a}){s};
                tmpt   = tmp(datUse.idxclean(s,1):datUse.idxclean(s,2));
                %                 tmpt  = preproc_trim_data(tmp,5000,datUse.sr(s));
                params.sr = datUse.sr(s);
                params.lowcutoff = 1;
                tmpth = preproc_dc_offset_high_pass(tmpt,params);
                preproc.(areas{a}) = tmpth;
            end
            switch plotWhat{p}
                case 'PSD'
                    plotpsdOnOff(preproc.ecog,preproc.lfp,datUse(s,:),figdir,s)
                case 'COH'
                    plotcoherenceoOnOff(preproc.ecog,preproc.lfp,datUse(s,:),figdir,s)
            end
            
        end
        ttlfig = sprintf('%s %d %s on-off meds','MON',m,plotWhat{p});
        suptitle(ttlfig);
        fnmsv = sprintf('task-%s-%d-%s.fig','MON',m,plotWhat{p});
        saveas(hfig,fullfile(figdir,fnmsv));
        hfig.PaperPositionMode = 'manual';
        hfig.PaperSize = [14 8];
        hfig.PaperPosition = [0 0 14 8];
        fnmsv = sprintf('task-%s-%d-%s.jpeg','MON',m,plotWhat{p});
        print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r600');
        close(hfig);
    end
end

end

function compare_on_off_stim()
datadir = uigetdir('choose data dir');
[pn,fn,ext] = fileparts(datadir);
figdir  = fullfile(pn,'figures','on-off-stim');
mkdir(figdir);
resdir  = fullfile(pn,'results');
load(fullfile(datadir,'dataBR.mat'));
% tasks
conds = {'rest', 'ipad','walking'};
% analysis
areas = {'ecog','lfp'};
plotWhat = {'PSD','COH'};
% plotWhat = {'COH'};
for p = 1:length(plotWhat)
    for c = 1:length(conds)
        idxlog = strcmp(datTab.task,conds{c});
        datUse = datTab(idxlog,:);
        hfig = figure();
        for s = 1:size(datUse,1)
            for a = 1:length(areas)
                tmp   = datUse.(areas{a}){s};
                tmpt   = tmp(datUse.idxclean(s,1):datUse.idxclean(s,2));
                %                 tmpt  = preproc_trim_data(tmp,5000,datUse.sr(s));
                params.sr = datUse.sr(s);
                params.lowcutoff = 1;
                tmpth = preproc_dc_offset_high_pass(tmpt,params);
                preproc.(areas{a}) = tmpth;
            end
            switch plotWhat{p}
                case 'PSD'
                    plotpsdOnOff(preproc.ecog,preproc.lfp,datUse(s,:),figdir,s)
                case 'COH'
                    plotcoherenceoOnOff(preproc.ecog,preproc.lfp,datUse(s,:),figdir,s)
            end
            
        end
        ttlfig = sprintf('%s %s on-off stim',conds{c},plotWhat{p});
        suptitle(ttlfig);
        fnmsv = sprintf('task-%s-%s.fig',conds{c},plotWhat{p});
        saveas(hfig,fullfile(figdir,fnmsv));
        hfig.PaperPositionMode = 'manual';
        hfig.PaperSize = [14 8];
        hfig.PaperPosition = [0 0 14 8];
        fnmsv = sprintf('task-%s-%s.jpeg',conds{c},plotWhat{p});
        print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r600');
        close(hfig);
    end
end

%% montage
plotWhat = {'PSD','COH'};
plotWhat = [];
for p = 1:length(plotWhat)
    for m = 1:6
        idxlog = strcmp(datTab.task,'montage');
        datMon = datTab(idxlog,:);
        datMonOn = datMon(logical(datMon.med),:);
        datMonOff = datMon(~logical(datMon.med),:);
        datUse = [datMonOn(m,:); datMonOff(m,:)];
        hfig = figure();
        for s = 1:size(datUse,1)
            for a = 1:length(areas)
                tmp   = datUse.(areas{a}){s};
                tmpt   = tmp(datUse.idxclean(s,1):datUse.idxclean(s,2));
                %                 tmpt  = preproc_trim_data(tmp,5000,datUse.sr(s));
                params.sr = datUse.sr(s);
                params.lowcutoff = 1;
                tmpth = preproc_dc_offset_high_pass(tmpt,params);
                preproc.(areas{a}) = tmpth;
            end
            switch plotWhat{p}
                case 'PSD'
                    plotpsdOnOff(preproc.ecog,preproc.lfp,datUse(s,:),figdir,s)
                case 'COH'
                    plotcoherenceoOnOff(preproc.ecog,preproc.lfp,datUse(s,:),figdir,s)
            end
            
        end
        ttlfig = sprintf('%s %d %s on-off meds','MON',m,plotWhat{p});
        suptitle(ttlfig);
        fnmsv = sprintf('task-%s-%d-%s.fig','MON',m,plotWhat{p});
        saveas(hfig,fullfile(figdir,fnmsv));
        hfig.PaperPositionMode = 'manual';
        hfig.PaperSize = [14 8];
        hfig.PaperPosition = [0 0 14 8];
        fnmsv = sprintf('task-%s-%d-%s.jpeg','MON',m,plotWhat{p});
        print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r600');
        close(hfig);
    end
end
end

function compare_on_off_meds_from_results()
fprintf('choose patient directory\n'); 
datadir = uigetdir('choose data dir');
rfs = findFilesBVQX(datadir,'resultsBR.mat');
for rf = 1:length(rfs)
    load(rfs{rf}); 
    if rf ==1 
        resTabAll = resTab; 
    else
        resTabAll = [resTabAll; resTab];
    end
end

end

function plotpsd(ecog,lfp,metadata,figdir,idx)
hfig = figure;
params.plottype = 'pwelch';
params.sr = metadata.sr;
params.noisefloor = 100;
%% plot lfp
subplot(1,2,1)
hold on;
[~,hplot] = plot_data_freq_domain(lfp',params,[]);
hax1 = gca;
hplot.LineWidth = 2;
legend(metadata.lfp_elec{1})
if metadata.med
    hplot.Color = [0 0.9 0 0.8];
    
else
    hplot.Color = [0.9  0 0 0.8];
end
if metadata.stim
    hplot.LineStyle = '-.';
end
title('LFP');
%% plot ecog
subplot(1,2,2)
hold on;
[~,hplot] = plot_data_freq_domain(ecog',params,[]);
hplot.LineWidth = 2;
legend(metadata.ecog_elec{1})
if metadata.med
    hplot.Color = [0 0.9 0 0.8];
else
    hplot.Color = [0.9  0 0 0.8];
end
if metadata.stim
    hplot.LineStyle = '-.';
end
title('ECOG');
hax2 = gca;
linkaxes([hax1 hax2]);
%% save figure
ttlfig = sprintf('PSD - %s',metadata.task{1});
suptitle(ttlfig);
fnmsv = sprintf('%0.2d-%d-task-%s-PSD.fig',metadata.sessionum(1),...
    idx,metadata.task{1});
saveas(hfig,fullfile(figdir,fnmsv));
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [14 8];
hfig.PaperPosition = [0 0 14 8];
fnmsv = sprintf('%0.2d-%d-task-%s-PSD.jpeg',metadata.sessionum(1),...
    idx,metadata.task{1});
print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r600');

end

function plotpsdOnOff(ecog,lfp,metadata,figdir,idx)
params.plottype = 'pwelch';
params.sr = metadata.sr;
params.noisefloor = 100;
if metadata.med; meds = 'on'; else meds = 'off'; end
if metadata.stim; stims = 'on'; else stims = 'off'; end

%% plot lfp
subplot(1,2,1)
hold on;
[~,hplot] = plot_data_freq_domain(lfp',params,[]);
hax1 = gca;
hplot.LineWidth = 2;
% set legend
legstr = sprintf('%s M %s S %s',...
    meds,stims,metadata.lfp_elec{1});
if isempty(get(hax1,'Legend'))
    legend(legstr)
else
    curstr = get(hax1,'Legend');
    curstr.String{end} = legstr;
end
% set color
if metadata.med
    hplot.Color = [0 0.9 0 0.8];
else
    if length(hax1.Legend.String) ==3 
        hplot.Color = [0.8  0.56 0.38 0.8];
    else
        hplot.Color = [0.9  0 0 0.8];
    end
end
if metadata.stim
    hplot.LineStyle = '-.';
end

title('LFP');
%% plot ecog
subplot(1,2,2)
hold on;
[~,hplot] = plot_data_freq_domain(ecog',params,[]);
hax2 = gca;
hplot.LineWidth = 2;
% set legend
legstr = sprintf('%s M %s S %s',...
    meds,stims,metadata.ecog_elec{1});
if isempty(get(hax2,'Legend'))
    legend(legstr)
else
    curstr = get(hax2,'Legend');
    curstr.String{end} = legstr;
end
% set color
if metadata.med
    hplot.Color = [0 0.9 0 0.8];
else
    if length(hax1.Legend.String) ==3 
        hplot.Color = [0.8  0.56 0.38 0.8];
    else
        hplot.Color = [0.9  0 0 0.8];
    end
end
if metadata.stim
    hplot.LineStyle = '-.';
end



title('ECOG');
hax2 = gca;
linkaxes([hax1 hax2]);


end

function plotPAC(ecog,lfp,metadata,figdir,idx)
hfig = figure;
%% plot lfp
subplot(1,2,1)
[~,hplot] = plot_data_PAC(lfp,metadata.sr,[]);
hax1 = gca;
if metadata.med; meds = 'on'; else meds = 'off'; end
if metadata.stim; stims = 'on'; else stims = 'off'; end
ttlstr = sprintf('%s med - %s stim - %s e - %s',...
    'LFP',meds,stims,metadata.lfp_elec{1});
title(ttlstr);
xlabel('Freq Phase');
ylabel('Freq Amp');
%% plot ecog
subplot(1,2,2);
[~,hplot] = plot_data_PAC(ecog,metadata.sr,[]);
hax2 = gca;
if metadata.med; meds = 'on'; else meds = 'off'; end
if metadata.stim; stims = 'on'; else stims = 'off'; end
ttlstr = sprintf('%s med - %s stim - %s e - %s',...
    'LFP',meds,stims,metadata.ecog_elec{1});
title(ttlstr);
xlabel('Freq Phase');
ylabel('Freq Amp');
linkaxes([hax1 hax2]);
%% save figure
ttlfig = sprintf('PAC - %s',metadata.task{1});
suptitle(ttlfig);
fnmsv = sprintf('%0.2d-%d-task-%s-PAC.fig',metadata.sessionum(1),...
    idx, metadata.task{1} );
saveas(hfig,fullfile(figdir,fnmsv));
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [16 8];
hfig.PaperPosition = [0 0 16 8];
fnmsv = sprintf('%0.2d-%d-task-%s-PAC.jpeg',...
    metadata.sessionum(1),idx,metadata.task{1});
print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r600');
close(hfig);
end

function  plotSpectrogram(ecog,lfp,metadata,figdir)
% plot_data_time_domain_spectrogram(data,params,figtitle);
end

function  plotcoherence(ecog,lfp,metadata,figdir,idx)
hfig = figure;
[~,hplot] = plot_data_coherence(ecog,lfp,metadata.sr,[]);
hplot.LineWidth = 2;
if metadata.med
    hplot.Color = [0 0.9 0 0.8];
    
else
    hplot.Color = [0.9  0 0 0.8];
end
if metadata.stim
    hplot.LineStyle = '-.';
end
ttlstr = sprintf('%s %s %s %s',...
    'coherence',metadata.task{1}, ...
    metadata.ecog_elec{1},...
    metadata.lfp_elec{1});
title(ttlstr);
%% save figure
ylim([0 1]);
fnmsv = sprintf('%0.2d-%d-task-%s-COH.fig',metadata.sessionum(1),...
    idx,metadata.task{1});
saveas(hfig,fullfile(figdir,fnmsv));
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [10 8];
hfig.PaperPosition = [0 0 10 8];
fnmsv = sprintf('%0.2d-%d-task-%s-COH.jpeg',metadata.sessionum(1),...
    idx,metadata.task{1});
print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r600');
close(hfig);

end

function plotcoherenceoOnOff(ecog,lfp,metadata,figdir,idx)
if metadata.med; meds = 'on'; else meds = 'off'; end
if metadata.stim; stims = 'on'; else stims = 'off'; end

[~,hplot] = plot_data_coherence(ecog,lfp,metadata.sr,[]);
hold on;
hplot.LineWidth = 2;
hax1 = gca; 
% set legend
legstr = sprintf('%s M %s S',...
    meds,stims);
if isempty(get(hax1,'Legend'))
    legend(legstr)
else
    curstr = get(hax1,'Legend');
    curstr.String{end} = legstr;
end
% set color
if metadata.med
    hplot.Color = [0 0.9 0 0.8];
else
    if length(hax1.Legend.String) ==3 
        hplot.Color = [0.8  0.56 0.38 0.8];
    else
        hplot.Color = [0.9  0 0 0.8];
    end
end
if metadata.stim
    hplot.LineStyle = '-.';
end

ttlstr = sprintf('%s %s %s %s',...
    'coherence',metadata.task{1}, ...
    metadata.ecog_elec{1},...
    metadata.lfp_elec{1});
title(ttlstr);
ylim([0 1]);
end


