function checkHowManyVisitsHavexlmfiles()
%% Reporting function - check data consistency
% This funciton checkes how many visits in each subjects
% have meta data about each session stored in a .xlm file
% it prints this information to a text file report

% output: xlsm_visit_report_summery.txt

fid = fopen('xlsm_visit_report_summery.txt', 'w+');

rootdir  = '/Volumes/Starr_Lab_H/Starr_Lab/BR_raw_data';
% get subject json
fnmsave = fullfile(rootdir, 'patients-^^^^-.json');
Patients = loadjson(fnmsave,'SimplifyCell',1); % this is how to read the data back in.
for p = 1:length(Patients)
    fprintf(fid,'Patient: %s\n',Patients(p).PatientFolderName)
    visitfnm = fullfile(rootdir, Patients(p).PatientFolderName,'visit-details-^^^^-.json');
    visits = loadjson(visitfnm,'SimplifyCell',1); % this is how to read the data back in.
    xlscnt = [];
    for v = 1:length(visits) % loop on each visit to find sesssions
        fldrsrc = fullfile(rootdir,...
            Patients(p).PatientFolderName,...
            visits(v).visitFolderName);
        ff = findFilesBVQX(fldrsrc,'*.xlsm');
        if ~isempty(ff)
            fprintf(fid,'\t[%0.2d]\t for visit %s \t\t\t\txlsm exists\n',...
                v,visits(v).visitFolderName);
            xlscnt(v) = 1;
        else
            fprintf(fid,'\t[%0.2d]\t for visit %s \t\t\t\txlsm DOES NOT exist\n',...
                v,visits(v).visitFolderName);
            xlscnt(v) = 0;
        end
    end
    fprintf(fid,'out of %d visits %d have .xlsm files\n\n',...
        length(xlscnt),sum(xlscnt));
end

% loop on each subject and get all the visits within this subject
% find all the session within this subject
end