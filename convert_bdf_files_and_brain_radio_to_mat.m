function convert_bdf_files_and_brain_radio_to_mat()
% params:
params.reportToAnayze = 1;

rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
patdir  = findFilesBVQX(rootdir,'brpd_*',struct('dirs',1,'depth',1));
% fidanalyze = fopen('report_missing_files_ipad_task.txt','w+');
cnt = 1;
for p = 1:length(patdir)
    [pn,patstr] = fileparts(patdir{p});
    visitdir = findFilesBVQX(patdir{p},'v*',struct('dirs',1,'depth',1));
    for v = 1:length(visitdir)
        [pn,visitstr] = fileparts(visitdir{v});
        ipaddir = findFilesBVQX(visitdir{v},'*tsk-ipad*',struct('dirs',1,'depth',1));
        if ~isempty(ipaddir)
            for i = 1:length(ipaddir)
                [pn,ipadsess] = fileparts(ipaddir{i});
                bdffile = findFilesBVQX(ipaddir{i},'*.bdf');
                if params.reportToAnayze
                    if ~isempty(bdffile)
                        eventfile = findFilesBVQX(ipaddir{i},'ipad_event_indices.mat');
                        if  isempty(eventfile)
                            start = tic; 
                            [~] = loadEEGdata(ipaddir{i});
                            [~] = loadBRdata(ipaddir{i});
                            fprintf('%0.2d p-%s v-%s s-%s done in %f\n',...
                                cnt,patstr,visitstr,ipadsess,toc(start));
                            cnt = cnt + 1; 
                        end
                    end
                end
            end
        end
    end
end
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

function sr = getsampleratefromxml(xmlstrucparsed)
srraw = regexp(xmlstrucparsed.RecordingItem.SenseChannelConfig.TDSampleRate,'[0-9+]','match');
sr = str2num([srraw{1},srraw{2},srraw{3}]);
end