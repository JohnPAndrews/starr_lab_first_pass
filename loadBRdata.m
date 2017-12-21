function datout  = loadBRdata(dirwithdata)
addpath(genpath(fullfile(pwd,'toolboxes','xml2struct')));
bdffnms = findFilesBVQX(dirwithdata,'*.bdf');
ff = findFilesBVQX(dirwithdata,'BRRAW_*.mat');
if ~isempty(ff)
    load(ff{1});
    datout = brraw;
    skipthis = 1;
else
    skipthis = 0;
end
if ~skipthis
    [pn,fn,ext] = fileparts(dirwithdata);
    s = cellfun(@(x) str2num(x), regexp(fn,'[0-9]+','match'));
    jsonfn = fullfile(pn,'protocol-details-^^^^.json');
    addpath(genpath(fullfile(pwd,'toolboxes','json')))
    visitjson = loadjson(jsonfn,'SimplifyCell',1); % this is how to read the data back in.
    jsoninfo = visitjson(s);
    filesfound = findFilesBVQX(dirwithdata,'*.txt',struct('depth',1));
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
    % find visit str 
    [~,fn2,ext] = fileparts(pn);
    visitstr = fn2(11:end);
    data = importdata(filesfound{1}); % import the actual data
    datout(cnt).sessionum = visitjson(s).num;
    datout(cnt).time      = visitjson(s).time;
    datout(cnt).visit     = visitstr;
    datout(cnt).duration  = visitjson(s).dur;
    datout(cnt).task      = visitjson(s).task;
    datout(cnt).med       = visitjson(s).med;
    datout(cnt).stim      = visitjson(s).stim;
    srraw = regexp(xmlstrucparsed.RecordingItem.SenseChannelConfig.TDSampleRate,'[0-9+]','match');
    datout(cnt).sr        = str2num([srraw{1},srraw{2},srraw{3}]);
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