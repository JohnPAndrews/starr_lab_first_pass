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
rootdir  = '/Volumes/Starr_Lab_H/Starr_Lab/BR_raw_data'; 
Patients = addPatient([],      'Kilinski_brpd01','brpd_01'); 
Patients = addPatient(Patients,'Carges',         'brpd_02'); 
Patients = addPatient(Patients,'Ryder',          'brpd_04'); 
Patients = addPatient(Patients,'Hathaway',       'brpd_05'); 
Patients = addPatient(Patients,'Egger',          'brpd_06'); 
Patients = addPatient(Patients,'Kizer',          'brpd_07'); 
Patients = addPatient(Patients,'robinson',       'brpd_09'); 
% options for json 
opt.ForceRootName = 0; 
rootdir = '/Volumes/Starr_Lab_H/Starr_Lab/BR_raw_data'; 
fnmsave = fullfile(rootdir, 'patients-^^^^-.json'); 
savejson('',Patients,fnmsave); 


end

function Ps = addPatient(Ps, name,id)
patients.PatientFolderName = name; 
patients.PatientCode       = id; 
Ps = [Ps, patients]; 
end