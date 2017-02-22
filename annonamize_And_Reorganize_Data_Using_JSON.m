function annonamize_And_Reorganize_Data_Using_JSON()
%% This function uses .json files used to charactarize data to organize data 
%% In an annonmized fashion that is machine readable. 

% input: 
% json files of at level of patient, visit and session 

% output: annonmized diretcotories with levels: 
% patient, visit, session (each a subfolder, nested in above level). 

% define input and output dirs 
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data';
outdir   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized'; 
% add toolboxes:
addpath(genpath(pwd));
% get subject json
fnmsave = fullfile(rootdir, 'patients-^^^^-.json');
Patients = loadjson(fnmsave,'SimplifyCell',1); % this is how to read the data back in.

for p = 1:length(Patients) % loop on patietns 
    %% get patient info 
    patient = Patients(p); % get one patient; 
    patientdirin  = fullfile(rootdir, patient.PatientFolderName); 
    patientdirout = fullfile(outdir, patient.PatientCode); 
    evalc('mkdir(patientdirout)'); % supress dir already exists warning 
    visitfnm = fullfile(rootdir, Patients(p).PatientFolderName,'visit-details-^^^^-.json');
    visits = loadjson(visitfnm,'SimplifyCell',1); % this is how to read the data back in.
    savejson('',visits,fullfile(patientdirout, 'visit-details-^^^^-.json')); % save visit jsons 
    
    for v = 1:length(visits) % loop on visit 
        %% get visit info 
        visit = visits(v);
        visitdirin  = fullfile(patientdirin,visit.visitFolderName);
        visitdirout = fullfile(patientdirout,visit.visitCategory);
        % find session detail jsons within the visits:
        foundsessions = findFilesBVQX(visitdirin, '*_session_details-^^^^-.json');
        protocol = struct(); 
        idxsort = []; 
        sessionTimes = {}; 
        recordmode = {}; 
        if ~isempty(foundsessions) % only create a visit directoy if their are session in the visit 
            %% create a visit diretory 
            evalc('mkdir(visitdirout)'); % supress dir already exists warning
            
            %% sort session so they are in the right order 
            for s = 1:length(foundsessions) % loop on sessions and find montage sessions to group together. 
                session  = loadjson(foundsessions{s},'SimplifyCell',1); % this is how to read the data back in.
                recordmode{s} = session.xmldata.RecordingConfig.RecordingMode; 
                sessionTimes{s} = session.xmldata.INSTimeStamp;
            end
            [~,idxsort] = sort(sessionTimes); % this insures that session are taken in order in whihc they were recorded  
            foundsessions = foundsessions(idxsort); 
            recordmode = recordmode(idxsort); 
            sortedsessionfiles = foundsessions;
            clear foundsessions 
            %% organize session so montage files are in one group 
            % orgnaize montages so they are in only one group
            % XXXXXX FIX THIS ..... 
            % loup on gropu nubmer to determin the files that go together. 
            

            cnt = 1; 
            grpnum = 1; groupFiles = [];
            ss=1;
            while ss <= length(sortedsessionfiles)
                if strcmp(recordmode{ss},'Montage')
                    groupFiles(ss) = grpnum;
                    % if the next file is not a montage file, increment
                    if (ss+1) < length(sortedsessionfiles)
                        if ~strcmp(recordmode{ss+1},'Montage')
                            grpnum = grpnum + 1;
                        end
                    end
                else
                    groupFiles(ss) = grpnum;
                    grpnum = grpnum + 1;
                end
               
                ss = ss + 1;
            end
            
            %% fir this printing: 
            for ii = 1:length(sortedsessionfiles)
                fprintf('%0.2d %d %s %s\n',ii,groupFiles(ii), sessionTimes{ii},recordmode{ii});
            end
            unqfolders = unique(groupFiles);
            
            %% loop on session folders, move session jsons, raw txt files, xmls and create protcol json: 
            for uqf = unqfolders % loop on session folders 
                ff = sortedsessionfiles(groupFiles == uqf);
                for s = 1:length(ff); % loop on files within session 
                    start = tic;
                    session  = loadjson(ff{s},'SimplifyCell',1); % this is how to read the data back in.
                    if ~isempty(session.ConditionTask)
                        sessionName = sprintf('s_%0.3d_tsk-%s',uqf,session.ConditionTask);
                    else
                        sessionName = sprintf('s_%0.3d',uqf);
                    end
         
                    
                    sessionoutdir = fullfile(visitdirout,sessionName);
                    evalc('mkdir(sessionoutdir)'); % supress dir already exists warning
                    [pn, ~] = fileparts(session.fulltemppath);
                    filetomove = session.fulltemppath;
                    destinationfile = fullfile(sessionoutdir, [session.filename '.txt']);
                    copyfile(filetomove,destinationfile)
                    % try to also move the '_raw file'
                    if ~isempty(session.rawfilename)
                        filetomove = fullfile(pn,session.rawfilename);
                        destinationfile = fullfile(sessionoutdir, session.rawfilename );
                        copyfile(filetomove,destinationfile)
                    end
                    % try to also move the 'xml file'
                    xmlfn = fullfile(pn,[session.filename '.xml']);
                    if exist(xmlfn,'file')
                        filetomove = xmlfn;
                        destinationfile = fullfile(sessionoutdir, [session.filename '.xml'] );
                        copyfile(filetomove,destinationfile)
                    end
                    % save the .json file
                    [~,fn] = fileparts(ff{s});
                    sessionfn = [fn, '.json'];
                    savejson('',session,fullfile(sessionoutdir, sessionfn)); % save session jsons to session dir
                    fprintf('finished moving patient %s visit %s session %s in %f secs \n', ...
                        patient.PatientCode,visit.visitCategory,session.filename,toc(start));
                    % create protocol file only if its the first file in
                    % session group (to deal with cases of montage files,
                    % in which there are 6 files in one session fodler
                    if s == 1;
                        protocol(uqf).sessionNum = uqf;
                        if strcmp(session.xmldata.RecordingConfig.RecordingMode,'Montage')
                            protocol(uqf).sessionTask = 'montageRecording';
                        else
                            protocol(uqf).sessionTask = session.ConditionTask;
                        end
                        
                        protocol(uqf).medication  = session.Medication;
                        protocol(uqf).StimOn  = session.StimOn;
                    end
                end
                clear ff; 
            end
        end
        % save the protocol file
        savejson('',protocol,fullfile(visitdirout, 'protocol-details-^^^^.json')); % save session jsons to session dir
        protocol = [];
    end
end
% save the json for the patients in the top directory 
savejson('',Patients,fullfile(outdir, 'patients-^^^^-.json')); % save session jsons to session dir

end