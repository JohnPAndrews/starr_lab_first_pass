function checkHowManyVisitsDoNotHaveXLSorXLSMfiles()
%% Reporting function - check data consistency
% This funciton checkes how many visits in each subjects
% have meta data about each session stored in a .xlm file
% it prints this information to a text file report

% output: xlsm_visit_report_summery.txt

fid = fopen('xls_absent_report_summery.txt', 'w+');

rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data';
% get subject json
fnmsave = fullfile(rootdir, 'patients-^^^^-.json');
Patients = loadjson(fnmsave,'SimplifyCell',1); % this is how to read the data back in.
for p = 1:length(Patients)
    fprintf(fid,'Patient: %s\n',Patients(p).PatientFolderName);
    sprintf('Patient: %s\n',Patients(p).PatientFolderName)
    visitfnm = fullfile(rootdir, Patients(p).PatientFolderName,'visit-details-^^^^-.json');
    visits = loadjson(visitfnm,'SimplifyCell',1); % this is how to read the data back in.
    xlscnt = [];
    cnt = 1; 
    for v = 1:length(visits) % loop on each visit to find sesssions
        if isempty(visits(v).xlsfilename)
            fprintf(fid,'\t[%0.2d]\t for visit %s \t\t\t\txlsm DOES NOT exist\n',...
                cnt,visits(v).visitFolderName);
            sprintf('\t[%0.2d]\t for visit %s \t\t\t\txlsm DOES NOT exist\n',...
                cnt,visits(v).visitFolderName)
            cnt = cnt + 1; 
        end 
    end
end

% loop on each subject and get all the visits within this subject
% find all the session within this subject
end