function printBrainRadioReport()
rootdir     = '/Volumes/Starr_Lab_H/Starr_Lab/BR_raw_data';
patientJson = 'patients-^^^^-.json';
Patients    = loadjson(fullfile(rootdir,patientJson),'SimplifyCell',1); % this is how to read the data back in.
fid         = fopen('brainRadioPatientReport.txt','w+');
for i = 1:length(Patients)
    fprintf(fid,'Patient: %s, Patient ID: %s\n\n',...
        Patients(i).PatientFolderName, Patients(i).PatientCode);
    visitjsonfn = fullfile(rootdir, Patients(i).PatientFolderName, 'visit-details-^^^^-.json');
    Visits  = loadjson(visitjsonfn,'SimplifyCell',1); % this is how to read the data back in.
    fprintf(fid, 'FolderName\t VisitDate\t Days Since Implant\t Visit Category Guess \t Number of Unique Dates\t\n'); 
    for v = 1:length(Visits)
        fprintf(fid,'%s\t %s\t %d\t %s\t %d\t\n',...
            Visits(v).visitFolderName,...
            Visits(v).visitDate,...
            Visits(v).daysSinceImplant,...
            Visits(v).visitCategory,...
            Visits(v).uniqueDatesFoundInFolder);
    end
    fprintf(fid,'\n\n'); 
end
fclose(fid);
end