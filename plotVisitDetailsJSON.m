function plotVisitDetailsJSON()
%% This function plots visit progression across subjects 
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data'; 
fp = findFilesBVQX(rootdir,'patients-^^^^-.json'); 
Patients = loadjson(fp{1},'SimplifyCell',1); 

rawvisits = {'vOR_day','v10_day','v03_wek','v01_mnt','v02_mnt','v03_mnt','v06_mnt','v01_yer','v02_yer'};
realnames = {'OR day','10 day','3 weeks','1 month','2 month','3 month','6 month','1 year','2 year'};

for p = 1:length(Patients)
    patientdir = fullfile(rootdir, Patients(p).PatientFolderName); 
    fv = findFilesBVQX(patientdir,'visit*^^^^-.json'); 
    visits = loadjson(fv{1},'SimplifyCell',1); 
    pout(p).name = Patients(p).PatientFolderName; 
    pout(p).code = Patients(p).PatientCode; 
    
    for v = 1:length(visits)
        visit = visits(v); 
        if visit.usevist
            for rv = 1:length(rawvisits)
                if strcmp(rawvisits{rv}(2:end),visit.visitCategory(5:end))
                    pout(p).(rawvisits{rv}) = 1; 
                end
            end
        end
       
    end
end
tout = struct2table(pout);
end