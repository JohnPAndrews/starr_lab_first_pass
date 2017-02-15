function findSessionsWithinVisit_JSON(rootdir, visitstruc)
%% This function looks for Brain radio sessions within a specific visit.
%  ouutput: it writes a json file for each session (within the folder
%  with the data for that session) with the following information:
%  filename
%  recording date
%  patient condition (on / off meds)
%  stim condition   (on / off stim)
%  xml data stored as well (for now, did not do parsing of xml data).
%  rawfile name (empty if it doens't)
%  use for analysis (many raw files are not relvant / should not be used
%  for analysis at this point
%  task

%  Work still needed:
%  1.
%  Since much of this data has to be entered manually need a way to
%  semi automate including all the data from the .xlsm sheets that
%  currently exist
%  2. parse the .xml sheets for each session in the way that the .xlsm
%  sheets do.
%  3. include a field for notes, that will include all the notes that Nicki
%  wrote on each specific recording. Incorporate this into the .json file %
%  4. add datatype for patients that have concurrent EEG as well, denote if
%  another concurrent recording is present.

visitfolder = fullfile(rootdir, visitstruc.patientdir, visitstruc.visitFolderName);
ffs = findFilesBVQX(visitfolder,'brpd*MR*.txt');
% get rid of all the '_raw' files:
% files that the '_raw' suffix are:
% The raw files do not have the built in filters
% (.5 hz high pass and 400 hz lfp).
%  They are downloaded directly off the battery (active PC + S).
cnt = 1;
for f = 1:length(ffs)
    [pn,fn] = fileparts(ffs{f});
    if strcmp(ffs{f}(end-6:end-4),'raw') % skip this
    else
        ffnew{cnt} = ffs{f};
        cnt = cnt + 1;
    end
end

% either load existing jsons, or create them from scratch...
loadjsons = 0;
if loadjsons
    %% this works on existing jsons
    ffs = findFilesBVQX(visitfolder,'*session*.json');
    for i  = 1:length(ffs)
        session = loadjson(ffs{i},'SimplifyCell',1); % this is how to read the data back in.
        if ~strcmp(session.sessionDetailsFromXLS,'XLS_DoesNotExist')
            if ~strcmp(session.sessionDetailsFromXLS,'sessionNotExistInXLS')
                sessionDetailsFromXLS = session.sessionDetailsFromXLS;
                % possible synonyms for 'Medication' status:
                medsynms = {'meds','medication'};
                for snm = 1:length(medsynms)
                    if isfield(sessionDetailsFromXLS,medsynms{snm})
                        session.Medication = sessionDetailsFromXLS.(medsynms{snm});
                    end
                end
                %
                % possible synonyms for 'Condition / Task' :
                consynms = {'patientactivity','patientActivity','task',...
                    'condition0x2Ftask','con','condition','condiiton'};
                for snm = 1:length(consynms)
                    if isfield(sessionDetailsFromXLS,consynms{snm})
                        session.ConditionTask = sessionDetailsFromXLS.(consynms{snm});
                    end
                end
                %
                [conditionout, conditionnotes] = parseConditionTask(session.ConditionTask);
                session.ConditionTask = conditionout;
                session.ConditionNotes = conditionout;
                % possible synonms for stimulation / on off.
                %
                % if rest is part of montage recording, make a not of that
                % in condition task: 
                if strcmp(session.xmldata.RecordingType,'montage'); 
                    x = 2; 
                end
                savejson('',session, ffs{i});
            end
        end
    end
    %%
else
    %% this creates jsons from scratch but takes more time
    % loop on all raw data files found within visit
    for f = 1:length(ffnew) % loop on files (not including raw files)
        [pn, fn] = fileparts(ffnew{f});
        
        session.filename = fn;
        session.patientcode  = visitstruc.patientcode;
        session.visitCategory = visitstruc.visitCategory(5:end);
        session.recordingdate = visitstruc.visitDate;
        session.daysSinceImplant = visitstruc.daysSinceImplant;
        session.fulltemppath = ffnew{f};
        session.usevist     = visitstruc.usevist;
        
        
        %% document existence of raw files
        if exist(fullfile(pn,[fn '_raw.txt']),'file')
            session.rawfilename = [fn '_raw.txt']; % empty if unused
        else
            session.rawfilename = []; % empty if unused
        end
        
        %% try and extract informaion from .xls file if it exists
        % initialize some variables:
        session.Medication = [];
        session.StimOn = [];
        session.ConditionTask = [];
        session.ConditionNotes = [];
        session.RawConditionTask = [];
        
        
        if ~isempty(visitstruc.xlsfilename)
            % there is a .xls detailing file in visit
            sessionDetailsFromXLS = parseXLSvisitDetail(visitstruc.xlsfilename, session.filename);
            if isempty(sessionDetailsFromXLS) % this session doe not exit in xls
                session.sessionDetailsFromXLS = 'sessionNotExistInXLS';
            else
                % for debugging run this - it will open relevant .xls filename
                % system(['open -a "Microsoft Excel" ' visitstruc.xlsfilename])
                session.sessionDetailsFromXLS = sessionDetailsFromXLS;
                % possible synonyms for 'Medication' status:
                medsynms = {'meds','medication'};
                for snm = 1:length(medsynms)
                    if isfield(sessionDetailsFromXLS,medsynms{snm})
                        session.Medication = sessionDetailsFromXLS.(medsynms{snm});
                    end
                end
                % possible synonyms for 'Condition / Task' :
                consynms = {'patientactivity','patientActivity','task',...
                    'condition0x2Ftask','con','condition','condiiton'};
                for snm = 1:length(consynms)
                    if isfield(sessionDetailsFromXLS,consynms{snm})
                        session.RawConditionTask = sessionDetailsFromXLS.(consynms{snm});
                    end
                end
                [conditionout, conditionnotes] = parseConditionTask(session.RawConditionTask);
                
                if isempty(session.ConditionTask) & visitstruc.usevist
                    x = 2;
                end
                
                session.ConditionTask = conditionout;
                session.ConditionNotes = conditionout;
            end
        else
            session.sessionDetailsFromXLS = 'XLS_DoesNotExist';
        end
        
        
        %% remidner re what each channel means in text file
        session.channelinfo = {'STN_time_domain','STN_power', 'M1_time_domain','M1_power', 'decoder1','decoder2'};
        
        %% get data from brain radio xml
        xmlfnm = [fn '.xml'];
        xmlstruc = xml2struct(fullfile(pn,xmlfnm));
        xmlstruc = xmlstruc.RecordingItem;
        xmlstruc = parseXMLstruc(xmlstruc);
        session.xmldata = xmlstruc;
        
        %% save the .json with the same name as the file name to move.
        jsonfn = sprintf('%s_session_details-^^^^-.json',session.filename);
        savejson('',session,fullfile(pn, jsonfn));
    end
end
end

function [conditionout, conditionnotes] = parseConditionTask(ConditionTask)
% this function tries to create standardized condition task names
conditionnotes = [];
conditionout = [];
%% find rest conditions
if strfind(ConditionTask,'rest')
    conditionout = 'rest';
    if length(ConditionTask) > 4
        conditionnotes = ConditionTask;
    end
end
if strfind(ConditionTask,'resst')
    conditionout = 'rest';
    if length(ConditionTask) > 4
        conditionnotes = ConditionTask;
    end
end
if strfind(ConditionTask,'Rest')
    conditionout = 'rest';
    if length(ConditionTask) > 4
        conditionnotes = ConditionTask;
    end
end
%% find montage conditions (where they cycle between electrode pairs
if strfind(ConditionTask,'montage')
    conditionout = 'montage';
    if length(ConditionTask) > 4
        conditionnotes = ConditionTask;
    end
end
%% find ipad conditions
if strfind(ConditionTask,'ipad')
    conditionout = 'ipad';
    if length(ConditionTask) > 4
        conditionnotes = ConditionTask;
    end
end
%% find talking conditions
if strfind(ConditionTask,'talking')
    conditionout = 'talking';
    if length(ConditionTask) > 6
        conditionnotes = ConditionTask;
    end
end
%% find walking conditions
if strfind(ConditionTask,'walking')
    conditionout = 'walking';
    if length(ConditionTask) > 6
        conditionnotes = ConditionTask;
    end
end
%% home recordings
if strfind(ConditionTask,'home')
    conditionout = 'homeRecording';
    if length(ConditionTask) > 4
        conditionnotes = ConditionTask;
    end
end
%% exclude flags: 
% if any of these words exist, exclude file: 
wordsMarkExclude = {'practice','restart',...
    '10 sec move','false','wash'};
for e = 1:length(wordsMarkExclude)
    if strfind(ConditionTask,wordsMarkExclude{e})
        conditionout = 'exclude';
        if length(ConditionTask) > 4
            conditionnotes = ConditionTask;
        end
    end
end
end