function createBrainRadioSubject_JSON()
%% This function creats a JSON for brain radion patients
%  The purpose of this function is to create machine readable
%  directory walkers for Brain radion patients.
%  in the future, it can also be used to easily save
%  brain radio in annonmyzed, structured way.

% input - below - names of patients and other details

% output - json with above information

% relies on this toolbox:


% add brain radio patients to json 
% addPatient(struct2concatenate, name, id) 
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data';
Patients = addPatient([],      'Kilinski_brpd01','brpd_01'); 
Patients = addPatient(Patients,'Ryder',          'brpd_03'); 
Patients = addPatient(Patients,'Carges',         'brpd_04'); 
Patients = addPatient(Patients,'Hathaway',       'brpd_05'); 
Patients = addPatient(Patients,'Egger',          'brpd_06'); 
Patients = addPatient(Patients,'Kizer',          'brpd_07'); 
Patients = addPatient(Patients,'robinson',       'brpd_09'); 
% options for json 
opt.ForceRootName = 0; 
fnmsave = fullfile(rootdir, 'patients-^^^^-.json'); 
savejson('',Patients,fnmsave); 


end

function Ps = addPatient(Ps, name,id)
patients.PatientFolderName = name; 
patients.PatientCode       = id; 
Ps = [Ps, patients]; 
end