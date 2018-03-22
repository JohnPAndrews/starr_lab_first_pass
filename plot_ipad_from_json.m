function plot_ipad_from_json(varargin) 
plottt0data  = 1;
if nargin < 1
    ipadir = uigetdir('choose ipad dir');
elseif nargin == 1
    ipadir = varargin{1};
elseif nargin ==2
    ipadir = varargin{1};
    plottt0data = varargin{2};
end
%% set params
params.timeBeforeEvent = 4; % in sec
params.timeAfterEvent  = 4; % in ses
params.beepToGoCue     = 6;
%% load data 
addpath(genpath(fullfile(pwd,'from_nicki')));
addpath(genpath(fullfile(pwd,'toolboxes','xml2struct')));
eegraw = loadEEGdata(ipadir); % load eeg data
brraw  = loadBRdata(ipadir);  % load br data

%% allign eeg to brain radio using pulses 
% this no longer needed but may be useful for general purpose in the lab.
%eegtrig = selectTrigChan(eegraw);  % select the eeg stim pulse channel
%brtrig = selectTrigChan(brraw); % select t he brain radio stim pulse
% alligninfo = allignData(brtrig,eegtrig); % allign the ipad data
if exist(fullfile(ipadir,'ipad_event_indices.mat'),'file')
    load(fullfile(ipadir,'ipad_event_indices.mat'));
elseif exist(fullfile(ipadir,'ipad_allign_info.mat'),'file')
    load(fullfile(ipadir,'ipad_allign_info.mat'));
else
    alligninfo = threshold_beep_finder(eegraw,brraw);
    save(fullfile(ipadir,'ipad_allign_info.mat'),'alligninfo');
end
%% detect movement from ipad beeps 
ff = findFilesBVQX(ipadir,'*.json');
if isempty(ff)
    error(sprintf('no json in this %s dir\n',ipadir))
else
    if exist(fullfile(ipadir,'ipad_event_indices_from_json.mat'),'file')
        load(fullfile(ipadir,'ipad_event_indices_from_json.mat'));
    else
        timeDat = readIpadJson(ff{1});
        eventsTable = transformJsonDatToEEGidx(timeDat, eegraw);
        [beepsInIdxs] = createEventMatrices(alligninfo,eventsTable.eegidxtimestamp,brraw,params);   % for now just using ipad beeps
        eventsTable.bridx = beepsInIdxs;
        save(fullfile(ipadir,'ipad_event_indices_from_json.mat'),'eventsTable');
    end
end


fprintf('computed sr %d\n',alligninfo.ecogsr); 
% return;
% beepsfound = detectIpadBeeps(eegraw); % detect ipad beeps

% rest_ON % start hold 
% prep_ON % hold start  
% target1_ON  % can move to target 
% touch1_OFF % taret touched for first time 
% target_touched % every time target touched 
if plottt0data
    % hold on
    timeparams.start_epoch_at_this_time    = -2000;%-8000; % ms relative to event (before), these are set for whole analysis
    timeparams.stop_epoch_at_this_time     =  5000; % ms relative to event (after)
    timeparams.start_baseline_at_this_time = -2000;%-6500; % ms relative to event (before), recommend using ~500 ms *note in the msns folder there is a modified version where you can set baseline bounds by trial (good for varible times, ex. SSD)
    timeparams.stop_baseline_at_this_time  = 0;%5-6000; % ms relative to event
    timeparams.extralines                  = 1; % plot extra line
    timeparams.extralinesec                = 3000; % extra line location in seconds
    timeparams.analysis                    = 'hold_center';
    timeparams.filtertype                  = 'ifft-gaussian' ; % 'ifft-gaussian' or 'fir1' 
    idxuse = cellfun(@(x) strcmp(x,'prep_ON'),eventsTable.label);
    beepsInIdxs = eventsTable.bridx(idxuse);
    beepsInIdxs = beepsInIdxs(~isnan(beepsInIdxs));
    addpath(genpath(fullfile(pwd,'from_nicki')));
    plot_ipad_data_nicki_json(beepsInIdxs,brraw,alligninfo.ecogsr,ipadir,timeparams)
end
return ;
timeparams.start_epoch_at_this_time    = -400;%-8000; % ms relative to event (before), these are set for whole analysis
timeparams.stop_epoch_at_this_time     =  400; % ms relative to event (after)
timeparams.start_baseline_at_this_time = -200;%-6500; % ms relative to event (before), recommend using ~500 ms *note in the msns folder there is a modified version where you can set baseline bounds by trial (good for varible times, ex. SSD)
timeparams.stop_baseline_at_this_time  =  200;%5-6000; % ms relative to event
timeparams.extralines                  = 0; % plot extra line 
timeparams.extralinesec                = 3000; % extra line location in seconds 
timeparams.analysis                    = 'target_touched';
idxuse = cellfun(@(x) strcmp(x,'prep_ON'),eventsTable.label);
beepsInIdxs = eventsTable.bridx(idxuse);
addpath(genpath(fullfile(pwd,'from_nicki')));
plot_ipad_data_nicki_json(beepsInIdxs,brraw,alligninfo.ecogsr,ipadir,timeparams) 

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

function [beepIdxBR] = createEventMatrices(alligninfo,beepsfound,brraw,params)
beepSecsEEG = beepsfound ./ alligninfo.eegsr  - alligninfo.eegsync(1) ./ alligninfo.eegsr;
beepSecsBR  = beepSecsEEG + alligninfo.ecogsync(1) ./ alligninfo.ecogsr;
beepIdxBR   = round(beepSecsBR .* alligninfo.ecogsr);

end

function eventsTable = transformJsonDatToEEGidx(timeDat, eegraw)
usegui = 1;
if usegui
    locuse = peakFinder(eegraw);
else
    approvd = 0;
    setsecs = 0;
    while ~approvd
        hfig = figure;
        if setsecs
            idxuse = secs > startsecs & secs < endsecs;
            dat = dat(idxuse);
            secs = secs(idxuse);
        else
            fielduse = 'Erg1';
            dat = zscore(eegraw.(fielduse));
            secs = [1:length(dat)]./eegraw.srate;
            thresh = 3;
        end
        
        hp = plot(secs,dat);
        hold on;
        
        
        [pksuse,locuse,~,~] = findpeaks(dat,secs,...
            'MinPeakDistance',2,...
            'MinPeakHeight', thresh);
        
        for s = 1:length(pksuse)
            handles.scattereeg(s) = ...
                scatter(...
                locuse(s),pksuse(s),...
                400,'r',...
                'UserData',1);
            %         'ButtonDownFcn',@ScatterPressed,...
            
        end
        approvd = input('do you approve (1/0)?');
        setsecs  = input('set secs (1/0)?');
        if setsecs
            startsecs  = input('start? ');
            endsecs  = input('end? ');
            thresh    = input('thresh? ');
            setsecs = 1;
        else
            if ~approvd
                fielduse = 'Erg2';
                close(hfig);
            end
        end
        
    end
end

fsv  = {'sound',... % Sound
        'start',...
        'rest_ON',...% Rest epoch Beg Fixation point ON red dot
        'rest_OFF',...% Rest epoch End Fixation point OFF red dot
        'rest_error',...  % Rest epoch Error Fixation error by mvt
        'prep_ON',...% Preparation epoch Beg ON Cue ON blue dot
        'prep_OFF',...% Preparation epoch End Cue OFF blue dot
        'prep_error',... % Preparation  epoch error by mvt
        'target1_ON',... % Target1 ON
        'touch1_OFF',...% Touch1 
        'prep_error',...% Error_touch 
        'target_appear',...% target appers (all targets)  
        'target_touched'% target touched (all targets) 
        };
events = struct();
cnt = 1;
% for f = 1:length(fsv)
%     dat = timeDat.(fsv{f})./1000;
%     for t = 1:length(dat)
%         events(cnt).label = fsv{f};
%         events(cnt).timestamp = dat(t);
%         if strcmp(fsv{f},'sound')
%             events(cnt).eegtimestamp = locuse(t);
%         else 
%             events(cnt).eegtimestamp = NaN;
%         end
%         cnt = cnt +1;
%     end
% end
for f = 1:length(fsv)
    dat = timeDat.(fsv{f})./1000;
    for t = 1:length(dat)
        events(cnt).label = fsv{f};
        events(cnt).timestamp = dat(t);
        events(cnt).eegtimestamp = NaN;
        cnt = cnt +1;
    end
end

% calculate sound time stamps 

eventsTable = struct2table(events);
eventsTable = sortrows(eventsTable,'timestamp');
idxfound = cellfun(@(x) strcmp(x,'sound'),eventsTable.label);
idxuse = find(idxfound==1); 
ipadtime = eventsTable.timestamp(idxuse);
outidx =  allignSoundFromJsonAndEEG(locuse,ipadtime);
eventsTable.eegtimestamp( idxuse(outidx.ipad)) = locuse(outidx.eeg);
eventsTable.useNewLineUp = repmat(1,size(eventsTable,1),1);
curidx = 1; 
soundidx = find(cellfun(@(x) strcmp(x,'sound'),eventsTable.label)==1,1);
%% loop on sounds idx - using only non NaNs 
while curidx <= size(eventsTable,1)
    if ~strcmp(eventsTable.label{curidx},'sound')
        if soundidx > curidx
            eventsTable.eegtimestamp(curidx) = eventsTable.eegtimestamp(soundidx) - ...
                (eventsTable.timestamp(soundidx) - eventsTable.timestamp(curidx));
        elseif soundidx < curidx
            eventsTable.eegtimestamp(curidx) = eventsTable.eegtimestamp(soundidx) + ...
                (eventsTable.timestamp(curidx) - eventsTable.timestamp(soundidx) );

        end
    else
        soundidx = curidx; 
    end
    curidx = curidx +1;
end
eventsTable.eegidxtimestamp = ceil(eventsTable.eegtimestamp .* eegraw.srate);
end

function sr = getsampleratefromxml(xmlstrucparsed)
srraw = regexp(xmlstrucparsed.RecordingItem.SenseChannelConfig.TDSampleRate,'[0-9+]','match');
sr = str2num([srraw{1},srraw{2},srraw{3}]);
end

