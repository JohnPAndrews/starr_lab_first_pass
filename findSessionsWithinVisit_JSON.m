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
for f = 1:length(ffnew) % loop on files (not including raw files) 
    [pn, fn] = fileparts(ffnew{f});
    
    session.filename = fn; 
    session.fulltemppath = ffnew{f};
    session.recordingdate = visitstruc.visitDate; 
    session.channelinfo = {'STN_time_domain','STN_power', 'M1_time_domain','M1_power', 'decoder1','decoder2'}; 
    
    
    % document existence of raw files 
    if exist(fullfile(pn,[fn '_raw.txt']),'file')
        session.rawfilename = [fn '_raw.txt']; % empty if unused 
    else
        session.rawfilename = []; % empty if unused 
    end
    
    session.Medication = []; 
    session.StimOn = []; 
    session.ConditionTask = []; 
    
    % try and extract informaion from .xls file if it exists 
    if ~isempty(visitstruc.xlsfilename) 
        % there is a .xls detailing file in visit 
        sessionDetailsFromXLS = parseXLSvisitDetail(visitstruc.xlsfilename, session.filename);
        if isempty(sessionDetailsFromXLS) % this session doe not exit in xls 
            session.sessionDetailsFromXLS = 'sessionNotExistInXLS';
        else
            % for debugging run this - it will open relevant .xls filename 
            % system(['open -a "Microsoft Excel" ' visitstruc.xlsfilename])
            session.sessionDetailsFromXLS = sessionDetailsFromXLS;
            if isfield(sessionDetailsFromXLS,'meds')
                session.Medication = sessionDetailsFromXLS.meds;
            end
            if isfield(sessionDetailsFromXLS,'patientactivity')
                session.ConditionTask = sessionDetailsFromXLS.patientactivity;
            end
            if isfield(sessionDetailsFromXLS,'medication')
                session.Medication = sessionDetailsFromXLS.medication;
            end
            if isfield(sessionDetailsFromXLS,'condition0x2Ftask')
                session.ConditionTask = sessionDetailsFromXLS.condition0x2Ftask;
            end
            if isfield(sessionDetailsFromXLS,'condition')
                session.ConditionTask = sessionDetailsFromXLS.condition;
            end
        end
    else
        session.sessionDetailsFromXLS = 'XLS_DoesNotExist'; 
    end
    
    
    
    % get data from brain radio xml
    xmlfnm = [fn '.xml']; 
    xmlstruc = xml2struct(fullfile(pn,xmlfnm)); 
    xmlstruc = xmlstruc.RecordingItem;
    xmlstruc = parseXMLstruc(xmlstruc);
    session.xmldata = xmlstruc;
    
    % XXX save the .json with the same name as the file name to move. 
    jsonfn = sprintf('%s_session_details-^^^^-.json',session.filename);
    savejson('',session,fullfile(pn, jsonfn));
end

end 