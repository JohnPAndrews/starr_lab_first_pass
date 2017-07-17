function  MAIN_plot_visit_quick_figures()
% organize_brain_radio_data()
plot_brain_radio_figures()


end

function organize_brain_radio_data()
%% organize brain radio files 
rootdir = uigetdir('choose visit dir'); 
if ~any(exist(fullfile(rootdir,'protocol-details-^^^^.json'),'file'))
    addBrainRadioVisit(rootdir);
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
    for f = 1:length(filesfound) 
        [pn,fn,ext] = fileparts(filesfound{f});
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
        data = importdata(filesfound{f});
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
    end
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
figdir  = 
uigetdir 
plotpsd()
plotcoherence()
plotPAC()
plotSpectrogram() 

% on / off meds 
% on / off stim comparisons 


preproc_trim_data()
preproc_dc_offset_high_pass()

end