function plot_ipad_data_semi_auto(varargin)

if nargin < 1
    ipadir = uigetdir('choose ipad dir');
else
    ipadir = varargin{1};
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
    save(fullfile(ipadir,'ipad_allign_info.mat'));
end
return 
%% detect movement from emg 
if exist(fullfile(ipadir,'ipad_event_indices.mat'),'file')
    load(fullfile(ipadir,'ipad_event_indices.mat'));
elseif exist(fullfile(ipadir,'eeg_movement_detect.mat'),'file')
    load(fullfile(ipadir,'eeg_movement_detect.mat'));
else
    movepoint = emg_movement_detect(eegraw);
    save(fullfile(ipadir,'eeg_movement_detect.mat'));
end

fprintf('computed sr %d\n',alligninfo.ecogsr); 
% return;
% beepsfound = detectIpadBeeps(eegraw); % detect ipad beeps
[beepsInIdxs] = createEventMatrices(alligninfo,movepoint,brraw,params);   % for now just using ipad beeps

% movepoint.startidx
% movepoint.endidx
save(fullfile(ipadir,'ipad_event_indices.mat'),...
    'movepoint','brraw','eegraw','alligninfo');

addpath(genpath(fullfile(pwd,'from_nicki')));
% plot_ipad_data_nicki(beepsInIdxs,brraw,alligninfo.ecogsr,ipadir) 
% validateEventIdxs()
% plotIpadData(eventMatrices);

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
    end
end
end

function alligninfo = allignData(brdata,eegdata)
bfecog = detectThreshBeeps(brdata);
bfeeg = detectThreshBeeps(eegdata);
[locEcogS,pksstr, locEcogE,pksend] = getPeaksDat(brdata.data, brdata.srate); %
[locEmgS,pksstr, locEmgE,pksend] = getPeaksDat(eegdata.data, eegdata.srate); %

% figure;
% plot(zscore(data.br_ecog));
% hold on;
% scatter(locEcog,pksstr,300);
% hold on;
% scatter(locend,pksend,300);
% title('ecog');
ecogsec = (locEcogS-(locEcogS(1)-brdata.srate/2))./brdata.srate;
emgsecs = (locEmgS-(locEmgS(1)-eegdata.srate/2))./eegdata.srate;
maxsecs = [0 max( [max(ecogsec) max(emgsecs)])+1];
hfig = figure;
hsub1 = subplot(2,1,1);
title('ecog');
for h = 1:length(ecogsec)
    hline(h) = line([ecogsec(h) ecogsec(h)],[0 1],...
        'LineWidth',2,...
        'UserData',ecogsec(h),...
        'ButtonDownFcn','line1pushed');
    xlim(maxsecs)
end
hsub2 = subplot(2,1,2);
title('emg');
for h = 1:length(emgsecs)
    hline(h) = line([emgsecs(h) emgsecs(h)],[0 1],...
        'LineWidth',2,...
        'UserData',emgsecs(h),...
        'ButtonDownFcn','line2pushed');
    xlim(maxsecs)
end
linkaxes([hsub1 hsub2]);

    function line1pushed(obj,eventdata)
        x=2; 
    end

    function line2pushed(obj,eventdata)
        x=2;
    end
%%%%%%%%%
%% NEED TO FIX THIS WITH APPROVAL / MANUAL DEBUGGING / BEEPS FEEDBACK 
%% XXXX 
%%%%%%%%%
[emglocoutS ,ecogpulseoutS] = allignPulses(locEmgS,eegdata.srate,locEcogS,brdata.srate);
[emglocoutE ,ecogpulseoutE] = allignPulses(locEmgE,eegdata.srate,locEcogE,brdata.srate);

Diffecog = ecogpulseoutE(1)- ecogpulseoutS(1); % XXX just use first point consider changing
Diffemg = emglocoutE(1)- emglocoutS(1);
ecogSR  = (eegdata.srate * Diffecog ) / Diffemg;
ecogsr = round(ecogSR);
alligninfo = [];
alligninfo.emglocoutS = emglocoutS;
alligninfo.ecogpulseoutS = ecogpulseoutS;
alligninfo.emglocoutE = emglocoutE;
alligninfo.ecogpulseoutE = ecogpulseoutE;
alligninfo.ecogsr = ecogsr;
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

function [beepIdxBR] = createEventMatrices(alligninfo,beepsfound,brraw,params);
beepSecsEEG = beepsfound.startidx ./ alligninfo.eegsr  - alligninfo.eegsync(1) ./ alligninfo.eegsr;
beepSecsBR  = beepSecsEEG + alligninfo.ecogsync(1) ./ alligninfo.ecogsr;
beepIdxBR   = round(beepSecsBR .* alligninfo.ecogsr);

% alligninfo.ecogpulseoutS;
% alligninfo.emglocoutS ./ beepsfound.srate;
% emgSsec = alligninfo.emglocoutS(1)./beepsfound.srate;
% beepsfoundDiffStartSec = beepsfound.beepsloc - emgSsec; 
% ecogSsec = alligninfo.ecogpulseoutS(1)./alligninfo.ecogsr; % make sure to use computed not reported sr! 
% beepsSecEcog = beepsfoundDiffStartSec + ecogSsec; % beeps in second in ecog time 
% beepsPlusGoTime = beepsSecEcog + params.beepToGoCue; 
% beepsInIdxs = round(beepsPlusG oTime.* alligninfo.ecogsr);
% idxbfr  = params.timeBeforeEvent *alligninfo.ecogsr; 
% idxafr  = params.timeBeforeEvent *alligninfo.ecogsr; 
% timevec = [fliplr((1:1:idxbfr) ./alligninfo.ecogsr .*-1000),  ...
%                   (1:1:idxbfr) ./alligninfo.ecogsr];
% % generate movement indices 
% idxs = []; 
% for i = 1:length(beepsInIdxs)
%     idxusebfr = beepsInIdxs(i)-idxbfr : 1 : beepsInIdxs(i)-1;
%     idxusebfr = beepsInIdxs(i):1: beepsInIdxs(i)-1+idxafr;
%     idxaft = [idxusebfr idxusebfr];
%     idxs(i,:) = idxaft; 
% end
% % get event matrices 
% areas = {'ecog','lfp'}; 
% for a = 1:length(areas)
% %     size(brraw.ecog(idxs))
% end
% eventmatrices = []; 
end

function [locstrt,pksstr, locend,pksend] = getPeaksDat(dat, sr)

% find start pulses for ecog and emg
dat = abs(dat); 
zerovec = zeros(length(dat),1); % create zero vec
idxstart = 3*sr:30*sr;% put zscored seconds 3-30 seconds in zero vec
zerovec(idxstart) = zscore(dat(idxstart)); % zscore this start;
idxLargerThan2    = zerovec<4; % find idx smaller than 2 std.
zerovec(idxLargerThan2) = 0; % zero everything smaller than 2 STD

[pksstr,locstrt] = findpeaks(zerovec,...
    'MinPeakDistance',0.45*sr); % locstart in seconds

zerovec = zeros(length(dat),1); % create zero vec
idxend = (length(dat)-30*sr):length(dat);% put zscored seconds 3-30 seconds in zero vec
zerovec(idxend) = zscore(dat(idxend)); % zscore this start;
idxLargerThan2    = zerovec<4; % find idx smaller than 2 std.
zerovec(idxLargerThan2) = 0; % zero everything smaller than 2 STD

[pksend,locend] = findpeaks(zerovec,...
    'MinPeakDistance',0.45*sr); % locstart in seconds


end

function [emgout ,ecgout] =  allignPulses(emgpulse,emgsr,ecogpulse,ecogsr)
% This function takes two difference vectors, and allings them.
ecd = diff(ecogpulse)./ecogsr;
emd = diff(emgpulse)./emgsr;

if length(ecd) == length(emd)
    diffsum = sum(abs(ecd - emd));
    emgout = emgpulse;
    ecgout = ecogpulse;
    if diffsum > 0.2
        warning('problems with allignment of pulse sequences');
    end
else
    if length(ecd) > length(emd)
        sidx = 1; eidx = length(emd); cnt = 1 ;
        while eidx <= length(ecd)
            dloc(cnt,1)  = sidx;
            dloc(cnt,2) =  eidx;
            dloc(cnt,3) = sum(abs(emd-ecd(sidx:eidx)));
            sidx = sidx + 1;
            eidx = eidx + 1;
            cnt = cnt + 1;
        end
        [~, midx] = min(dloc(:,3));
        emgout = emgpulse;
        ecgout = ecogpulse(dloc(midx,1):dloc(midx,2)+1);
    elseif length(emd) > length(ecd)
        sidx = 1; eidx = length(ecd); cnt = 1 ;
        while eidx <= length(emd)
            dloc(cnt,1)  = sidx;
            dloc(cnt,2) =  eidx;
            dloc(cnt,3) = sum(abs(ecd-emd(sidx:eidx)));
            sidx = sidx + 1;
            eidx = eidx + 1;
            cnt = cnt + 1;
        end
        [~, midx] = min(dloc(:,3));
        emgout = emgpulse(dloc(midx,1):dloc(midx,2)+1);
        ecgout = ecogpulse;
    end
end
% validation
ecd = diff(ecgout)./ecogsr;
emd = diff(emgout)./emgsr;
diffsum = sum(abs(ecd - emd));
if diffsum > 0.2
    warning('problems with allignment of pulse sequences');
end
% move small vector along larger vector to find match
% make a little plot of allignemnt 
emgsecs = emgout./emgsr - emgout(1)/emgsr;
ecosecs = ecgout./ecogsr -  ecgout(1)/ecogsr; 



end

function sr = getsampleratefromxml(xmlstrucparsed)
srraw = regexp(xmlstrucparsed.RecordingItem.SenseChannelConfig.TDSampleRate,'[0-9+]','match');
sr = str2num([srraw{1},srraw{2},srraw{3}]);
end



