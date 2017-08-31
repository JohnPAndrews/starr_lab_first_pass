function addBrainRadioVisit(varargin)
%% Function brain radio visit
% This function takes an existing folder with brain radio visits
% And organizes it.
% What it does: 
% 1) Adds the files into subfolders based on time 
% 2) creates a protocol json in the parent folder (needs to be edited with
% task names
% 3) Creates session jsons that must be populated as well. 

% if dir exist, use that, otehrwise, ask for dir
if nargin == 1
    dirorganize = varargin{1};
else
    dirorganize = uigetdir('choose dir to organize');
end
%% find files, extract times, find montage status
fftxt = findFilesBVQX(dirorganize,'*_MR_*.txt');
%% get times and find raw files
for f = 1:length(fftxt)
    [pn,fn,ext] = fileparts(fftxt{f});
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
    [Y, M, D, H, MN, S] = datevec(xmldata.RecordingDuration,'HH:MM:SS');
    recDurSec = H*3600+MN*60+S; 
    dat(f).pn = pn;
    dat(f).fn = fn;
    dat(f).ff = fftxt{f};
    dat(f).time = datetime(datevec(xmldata.SPTimeStamp,'mm/dd/yyyy HH:MM:SS PM'));
    dat(f).RecDurSecs = recDurSec; 
    dat(f).israw  =  any(strfind(fn,'raw'));
    dat(f).ismontage = strcmp(xmldata.RecordingType,'Montage');
end
datTable = struct2table(dat);
%% create groupings
tablSort = sortrows(datTable, 'time');
exts = {'.txt','.xml','_raw.txt','_LOG','_RT'};
f = 1;
grpcnt = 1;
logexc = cellfun(@any, strfind( tablSort.fn,'raw'));
tablSort = tablSort(~logexc,:); 
while f <= size(tablSort,1)
    prot(grpcnt).num = grpcnt; 
    prot(grpcnt).Fn = tablSort.fn{f};
    prot(grpcnt).Date = tablSort.time(f);
    prot(grpcnt).Dur = datetime(datevec(seconds(tablSort.RecDurSecs(f))),'Format','mm:ss') ;
    prot(grpcnt).Task = '';
    prot(grpcnt).Med = '';
    prot(grpcnt).Stim = '';

    if tablSort.ismontage(f)
        prot(grpcnt).Task = 'montage'; 
        dirmove = fullfile(tablSort.pn{f},sprintf('s_%0.3d_tsk-%s',grpcnt,'montage'));
        mkdir(dirmove);
        idxm = f;
        for i = idxm:idxm+5
            for s = 1:5
                src = fullfile(tablSort.pn{i},[tablSort.fn{i} exts{s}]);
                des = fullfile(dirmove,[tablSort.fn{i} exts{s}]);
                try
                    movefile(src,des);
                end
            end
        end
        f = idxm+6;
    else
        if f > size(tablSort,1)
            break;
        end
        dirmove = fullfile(tablSort.pn{f},sprintf('s_%0.3d_tsk-XXXX',grpcnt));
        mkdir(dirmove);
        for s = 1:5
            src = fullfile(tablSort.pn{f},[tablSort.fn{f} exts{s}]);
            des = dirmove; 
            try
                movefile(src,des);
            end
        end
        f = f+1;
    end    
    grpcnt = grpcnt + 1;
end
%% open relevant exctel if it exists 
xlsfile = findFilesBVQX(dirorganize,'*.xls*');
if ~isempty(xlsfile)
system(['open -a "Microsoft Excel" ' xlsfile{1}])
end
protTable = struct2table(prot); 
%% get assign conditions 
compTable = getVisitDetails(protTable); % user input visit conditions - med, stim, task status; 
compTab = cell2table(compTable);
compTab.Properties.VariableNames = {'fn','time','dur','task','med','stim'};
%% rename folders acording to task names 
ff = findFilesBVQX(dirorganize,'s*',struct('dirs',true,'depth',1));
for d = 1:size(compTab)
    [pn,fn,ext] = fileparts(ff{d});
    if any(strfind(fn,'XXXX')) 
        movefile(ff{d},...
        fullfile(pn,...
            strrep(fn,'XXXX',compTab.task{d})));
    end
end
%% create protocol json 
jsontable = [protTable(:,1) compTab(:,2:end)];
savejson('',table2struct( jsontable),fullfile(dirorganize, 'protocol-details-^^^^.json'));

%% move extra files:
endings = {'txt','xml'};
extradir = fullfile(dirorganize,'z-logs-misc');
mkdir(extradir);

for e = 1:length(endings)
    ff = findFilesBVQX(dirorganize,sprintf('*%s',endings{e}),...
        struct('depth',1));
    for d = 1:length(ff)
        [pn,fn,ext] = fileparts(ff{d});
        movefile(ff{d},fullfile(extradir,[fn ext]));
    end
end

%% create session json (inhereting from protocol) 

%% create some figures 

%% XXXX 
% Need to add protocol files off this, add recording time 
% Need to create jsons for each individual file. 
% Need to create mechanism to edit json file to include, med, stim state 
% As well as UDPRS scores. 
% Need to create function that will create graphs of each step (including
% IPad!. 

%% create protocol file to be edited
end