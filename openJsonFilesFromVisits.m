function openJsonFilesFromVisits()
%% This function open visit jsons across subjects 
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data'; 
fp = findFilesBVQX(rootdir,'patients-^^^^-.json'); 
Patients = loadjson(fp{1},'SimplifyCell',1); 

for p = 1:length(Patients)
    patientdir = fullfile(rootdir, Patients(p).PatientFolderName); 
    fv = findFilesBVQX(patientdir,'visit*^^^^-.json'); 
    system(sprintf('open -a "TextWrangler" %s', fv{1})); 
end
end