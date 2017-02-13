function annonamize_And_Reorganize_Data_Using_JSON()
%% This function uses .json files used to charactarize data to organize data 
%% In an annonmized fashion that is machine readable. 

% input: 
% json files of at level of patient, visit and session 

% output: annonmized diretcotories with levels: 
% patient, visit, session (each a subfolder, nested in above level). 


rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data';
outdir   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized'; 
% add toolboxes:
addpath(genpath(pwd));
% get subject json
fnmsave = fullfile(rootdir, 'patients-^^^^-.json');
Patients = loadjson(fnmsave,'SimplifyCell',1); % this is how to read the data back in.
patient = Patients;

savejson('',Patients,fullfile(outdir, 'patients-^^^^-.json')); % save patient json 

for p = 1:length(Patients)
    patient = Patients(p); % get one patient; 
    patientdirin  = fullfile(rootdir, patient.PatientFolderName); 
    patientdirout = fullfile(outdir, patient.PatientCode); 
    evalc('mkdir(patientdirout)'); % supress dir already exists warning 
    visitfnm = fullfile(rootdir, Patients(p).PatientFolderName,'visit-details-^^^^-.json');
    visits = loadjson(visitfnm,'SimplifyCell',1); % this is how to read the data back in.
    savejson('',Patients,fullfile(patientdirout, 'visit-details-^^^^-.json')); % save visit jsons 
    for v = 1:length(visits) % loop on visit 
        visit = visits(v);
        visitdirin  = fullfile(patientdirin,visit.visitFolderName);
        visitdirout = fullfile(patientdirout,visit.visitCategory);
        % find session detail jsons within the visits:
        ff = findFilesBVQX(visitdirin, '*_session_details-^^^^-.json');
        if ~isempty(ff)
            % only create a visit directory if this is sessions within that
            % visit 
            evalc('mkdir(visitdirout)'); % supress dir already exists warning
            for s = 1:length(ff) % loop on sessions 
                start = tic; 
                session  = loadjson(ff{s},'SimplifyCell',1); % this is how to read the data back in.
                sessionName = sprintf('session_%0.3d',s);
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
                % save the .json file 
                [~,fn] = fileparts(ff{s});
                sessionfn = [fn, '.json']; 
                savejson('',session,fullfile(sessionoutdir, sessionfn)); % save session jsons to session dir 
                fprintf('finished moving patient %s visit %s session %s in %f secs \n', ...
                   patient.PatientCode,visit.visitCategory,session.filename,toc(start)); 
            end
        end
        
        
    end
end

end