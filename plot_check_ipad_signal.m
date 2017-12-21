function plot_check_ipad_signal(dirname)
%% set params
paramss.timeBeforeEvent = 4; % in sec
paramss.timeAfterEvent  = 4; % in ses
paramss.beepToGoCue     = 6;
paramss.plotwhat        = 'spect'; %plot 'line' or 'spect';
paramss.noformat        = [];
paramss.colorbaroff     = [];
%% load data 
addpath(genpath(fullfile(pwd,'toolboxes','xml2struct')));
eegraw = loadEEGdata(dirname); % load eeg data
brraw  = loadBRdata(dirname);  % load br data

%% allign eeg to brain radio using pulses 
% this no longer needed but may be useful for general purpose in the lab.
%eegtrig = selectTrigChan(eegraw);  % select the eeg stim pulse channel
%brtrig = selectTrigChan(brraw); % select t he brain radio stim pulse
% alligninfo = allignData(brtrig,eegtrig); % allign the ipad data
if exist(fullfile(dirname,'ipad_event_indices.mat'),'file')
    load(fullfile(dirname,'ipad_event_indices.mat'));
end
if exist(fullfile(dirname,'ipad_allign_info.mat'),'file')
    load(fullfile(dirname,'ipad_allign_info.mat'));
end


%% detect movement from ipad beeps 
ff = findFilesBVQX(dirname,'*.json');
if isempty(ff)
    error(sprintf('no json in this %s dir\n',dirname))
else
    if exist(fullfile(dirname,'ipad_event_indices_from_json.mat'),'file')
        load(fullfile(dirname,'ipad_event_indices_from_json.mat'));
    end
end

%% detect movement from ipad beeps 
if exist(fullfile(dirname,'ipad_event_indices_from_json.mat'),'file')
    load(fullfile(dirname,'ipad_event_indices_from_json.mat'));
end



[b,a]        = butter(3,[5 100] / (eegraw.srate/2),'bandpass'); % user 3rd order butter filter
dat.chan12 = filtfilt(b,a,double(eegraw.EXG2 - eegraw.EXG1)) ;
dat.chan34 = filtfilt(b,a,double(eegraw.EXG4 - eegraw.EXG3)) ;
dat.chan56 = filtfilt(b,a,double(eegraw.EXG6 - eegraw.EXG5)) ;
dat.chan78 = filtfilt(b,a,double(eegraw.EXG7 - eegraw.EXG8)) ;
if isfield(eegraw,'Erg1')
    dat.erg1 = filtfilt(b,a,double(eegraw.Erg1));
else
    dat.erg1 = dat.chan78;
end
if isfield(eegraw,'Erg2')
    dat.erg2 = filtfilt(b,a,double(eegraw.Erg2));
else
    dat.erg2 = dat.chan78;
end

paramss.labelfind = {'rest_ON','prep_ON','touch1_OFF'} ; % labels to start on 
colorsuse        = {[0 0 0 0.5],[0 0.9 0 0.5],[0 0 0.9 0.5]};
paramss.colorsuse = colorsuse; 
paramss.timebefr  = ceil([1.5 0.5 2].* 794); % start time 
paramss.timeaftr  = ceil([3.5 2.5 4].*794); % end time 
areasuse = {'lfp','ecog'};
windowsize = 256;
paramss.windowsize = windowsize;
paramss.leglines = {'hold', 'prep','move'};
idxrest = cellfun(@(x) strcmp(x,'rest_ON'),eventsTable.label);
idxprep = cellfun(@(x) strcmp(x,'prep_ON'),eventsTable.label);
idxmove = cellfun(@(x) strcmp(x,'touch1_OFF'),eventsTable.label);
idxuse = idxrest | idxprep | idxmove; 
eventsUse = eventsTable(idxuse,:);
idxrest = cellfun(@(x) strcmp(x,'rest_ON'),eventsUse.label);
eventsUse.Color(idxrest) = colorsuse(1);
idxprep = cellfun(@(x) strcmp(x,'prep_ON'),eventsUse.label);
eventsUse.Color(idxprep) = colorsuse(2);
idxprep = cellfun(@(x) strcmp(x,'touch1_OFF'),eventsUse.label);
eventsUse.Color(idxprep) = colorsuse(3);
eventsUse.eegsecs = eventsUse.eegidxtimestamp./ eegraw.srate;
eventsUse.brsecs = eventsUse.bridx./ alligninfo.ecogsr;



%% plotting 

hfig = figure('Position',[1000         131         823        1207]);
cnt = 1; 
pb = uicontrol(hfig,'Style','pushbutton','String','>>',...
                'Position',[150 20 60 40],'Callback',@moveright);
            
            
pb = uicontrol(hfig,'Style','pushbutton','String','<<',...
                'Position',[50 20 60 40],'Callback',@moveleft);

%% eeg 
fnms = fieldnames(dat); 
secseeg = (1:length(dat.chan12))./eegraw.srate;
lineseeg = alligninfo.eegsync./eegraw.srate;
fprintf('diff secs eeg %0.2f\n',lineseeg(2) - lineseeg(1));

for f = 1:length(fnms)
    hsub(cnt) = subplot(8,1,cnt); cnt = cnt + 1; 
    hold on; 
    hp(cnt) = plot(secseeg,dat.(fnms{f}));
    miny = min(dat.(fnms{f}));
    maxy = max(dat.(fnms{f}));
    plot([lineseeg(1) lineseeg(1)],[miny maxy],'LineWidth',4,'Color',[0.9 0 0 0.5]);
    plot([lineseeg(2) lineseeg(2)],[miny maxy],'LineWidth',4,'Color',[0.9 0 0 0.5]);
    for e = 1:size(eventsUse)
        plot([eventsUse.eegsecs(e) eventsUse.eegsecs(e)],[miny maxy],'LineWidth',4,'Color',eventsUse.Color{e});
    end
    
    title(fnms{f}); 
    axis tight 
    axis 'auto y';
end
linesecog = alligninfo.ecogsync./alligninfo.ecogsr;
fprintf('diff secs ecog %0.2f\n',linesecog(2) - linesecog(1));
%% br 
fnms = fieldnames(brraw); 
secsbr = (1:length(brraw.lfp))./alligninfo.ecogsr;
% lfp 
hbr(1) = subplot(8,1,cnt); cnt = cnt + 1;
hold on; 
% line plot 
if strcmp(paramss.plotwhat,'line')
    hplotbr(1) = plot(secsbr,brraw.lfp);
    miny = min(brraw.lfp);
    maxy = max(brraw.lfp);
else
    % spect
    paramss.sr = alligninfo.ecogsr;
    paramss.contouroff = [];
    plot_data_time_domain_spectrogram(brraw.lfp,paramss,'');
    miny = 0;
    maxy = 100;
end

plot([linesecog(1) linesecog(1)],[miny maxy],'LineWidth',4,'Color',[0.9 0 0 0.5]);
plot([linesecog(2) linesecog(2)],[miny maxy],'LineWidth',4,'Color',[0.9 0 0 0.5]);
for e = 1:size(eventsUse)
    plot([eventsUse.brsecs(e) eventsUse.brsecs(e)],[miny maxy],'LineWidth',4,'Color',eventsUse.Color{e});
end

axis tight 
% axis 'auto y';
title('lfp');
% ecog 
hbr(2) = subplot(8,1,cnt); cnt = cnt + 1;
hold on; 
% line plot 
if strcmp(paramss.plotwhat,'line')
    hplotbr(1) = plot(secsbr,brraw.ecog);
    miny = min(brraw.ecog);
    maxy = max(brraw.ecog);
else
    % spect
    plot_data_time_domain_spectrogram(brraw.ecog,paramss,'');
    miny = 0;
    maxy = 100;
end

plot([linesecog(1) linesecog(1)],[miny maxy],'LineWidth',4,'Color',[0.9 0 0 0.5]);
plot([linesecog(2) linesecog(2)],[miny maxy],'LineWidth',4,'Color',[0.9 0 0 0.5]);
axis tight 
% axis 'auto y';
for e = 1:size(eventsUse)
    plot([eventsUse.brsecs(e) eventsUse.brsecs(e)],[miny maxy],'LineWidth',4,'Color',eventsUse.Color{e});
end
title('ecog');

linkaxes(hsub,'x');
xlim(hsub(1),[lineseeg(1)-1 lineseeg(2) + 1]);

linkaxes(hbr,'x');
xlim(hbr(1),[linesecog(1)-1 linesecog(2) + 1]);

hdls.eventsUse = eventsUse;
hdls.curevent  = 0; 
hdls.dat = dat; 
hdls.linesecog = linesecog;
hdls.lineseeg = lineseeg;
hdls.alligninfo = alligninfo;
hdls.hbr = hbr; 
hdls.hsub = hsub; 
hdls.xlimbrfirst = [linesecog(1)-1 linesecog(2) + 1];
hdls.xlimeegfirst = [lineseeg(1)-1 lineseeg(2) + 1];
hfig.UserData = hdls;


end


function eegraw = loadEEGdata(rootdir)
%% step 1 - convert .bdf to EEG format
bdffnms = findFilesBVQX(rootdir,'*.bdf');
ff = findFilesBVQX(rootdir,'EEGRAW_*.mat');
if ~isempty(ff)
    load(ff{1});
    eegraw = eegraw;
    skipthis = 1;
else
    skipthis = 0;
end
if ~skipthis
    for b = 1:length(bdffnms)
        addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/eeglab14_1_0b'));
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
        save(fullfile(pn,['EEGRAW_' fn '.mat']),'eegraw');
        fprintf('saved file %d out of %d in %f\n',b,length(bdffnms),toc(start));
        restoredefaultpath;
        rmpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/eeglab14_1_0b'));
    end
    
end
end


function datout  = loadBRdata(ipadir);
addpath(genpath(fullfile(pwd,'toolboxes','xml2struct')));
bdffnms = findFilesBVQX(ipadir,'*.bdf');
ff = findFilesBVQX(ipadir,'BRRAW_*.mat');
if ~isempty(ff)
    load(ff{1});
    datout = brraw;
    skipthis = 1;
else
    skipthis = 0;
end
if ~skipthis
    [pn,fn,ext] = fileparts(ipadir);
    s = cellfun(@(x) str2num(x), regexp(fn,'[0-9]+','match'));
    jsonfn = fullfile(pn,'protocol-details-^^^^.json');
    addpath(genpath(fullfile(pwd,'toolboxes','json')))
    visitjson = loadjson(jsonfn,'SimplifyCell',1); % this is how to read the data back in.
    jsoninfo = visitjson(s);
    filesfound = findFilesBVQX(ipadir,'*.txt');
    [pn,fn,ext] = fileparts(filesfound{1});
    cnt = 1;
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
    data = importdata(filesfound{1}); % import the actual data
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
    brraw = datout; 
    save(fullfile(pn,['BRRAW_' fn '.mat']),'brraw');
end
end


function moveright(obj,event)
win = 10;
hfig = obj.Parent;
hdls = hfig.UserData;
if hdls.curevent+1 < size(hdls.eventsUse,1)
    hdls.curevent = hdls.curevent + 1;
    
    x = hdls.eventsUse.eegsecs(hdls.curevent);
    xlim(hdls.hsub(1),[x-win x + win]);
    
    x = hdls.eventsUse.brsecs(hdls.curevent);
    xlim(hdls.hbr(1),[x-win x + win]);
    
end
hfig.UserData = hdls;
end

function moveleft(obj,event)
win = 10;
hfig = obj.Parent;
hdls = hfig.UserData;
if hdls.curevent-1 > 0
    hdls.curevent = hdls.curevent - 1;
    x = hdls.eventsUse.eegsecs(hdls.curevent);
    xlim(hdls.hsub(1),[x-win x + win]);
    
    x = hdls.eventsUse.brsecs(hdls.curevent);
    xlim(hdls.hbr(1),[x-win x + win]);
elseif hdls.curevent-1 == 0 
    hdls.curevent = hdls.curevent - 1;
    xlim(hdls.hsub(1),hdls.xlimeegfirst);
    xlim(hdls.hbr(1),hdls.xlimbrfirst);

end
hfig.UserData = hdls;
end
