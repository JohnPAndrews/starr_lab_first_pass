function openSampleJsonFilesFromEachSubject()
%% This is a utility function that helps openning json files

% This function open one sample session json file from each subject, and each visit.

rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data';
% add toolboxes:
addpath(genpath(pwd));
% get subject json
fnmsave = fullfile(rootdir, 'patients-^^^^-.json');
Patients = loadjson(fnmsave,'SimplifyCell',1); % this is how to read the data back in.
patient = Patients;

for p = 1:length(patient)
    visitfnm = fullfile(rootdir, patient(p).PatientFolderName,'visit-details-^^^^-.json');
    visits = loadjson(visitfnm,'SimplifyCell',1); % this is how to read the data back in.
    for v = 1:length(visits)
        visit = visits(v);
        % find session detail jsons within the visits:
        if ~exist(visit.xlsfilename,'file')
            pn = fullfile(rootdir, patient(p).PatientFolderName, visit.visitFolderName);
        else
            [pn,fn] = fileparts(visit.xlsfilename);
        end
        ff = findFilesBVQX(pn, '*_session_details-^^^^-.json');

        system(sprintf('open -a "TextWrangler" %s', ff{1})); % only open one sample file
        
    end
end
end

function patient = choosePatient(Patients)
fprintf('choose patient number you want to open:\n')
for p = 1:length(Patients)
    fprintf('[%0.2d]\t %s\n',p,Patients(p).PatientFolderName)
end
pidx = input('which number? ');
patient = Patients(pidx);
end

function visit = chooseVisit(visits)
fprintf('choose visit number you want to open:')
for v = 1:length(visits)
    fprintf('[%0.2d]\t %s\n',v,visits(v).visitFolderName)
end
vidx = input('which number? ');
visit = visits(vidx);
end