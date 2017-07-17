function moveBrainRadioVisits()
%% this is a temp function to move brain radio visits from unorganized folder to organize 
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data'; 
destdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual'; 
visits =   {
    'OR_day'
    'predis'
    '10_day'
    '03_wek'
    '01_mnt'
    '02_mnt'
    '03_mnt'
    '06_mnt'
    '01_yer'
    '02_yer'
    };
visitmove = '01_mnt'; 


ff = findFilesBVQX(rootdir,'visit-details-^^^^-.json'); 
for v = 1:length(ff)
    [pn,fn,ext] = fileparts(ff{v});
    visitjson = loadjson(ff{v},'SimplifyCell',1); % this is how to read the data back in.
    idxv  = cellfun(@(x) any(strfind(x,visitmove)),{visitjson.visitCategory}'); 
    switch v 
        case 3 % hatway 
            idxv(6)= 0; 
    end     
       
    foldsrc = fullfile(pn,visitjson(idxv).visitFolderName); 
    txtfiles = findFilesBVQX(foldsrc,'*.txt'); 
    xmlfiles = findFilesBVQX(foldsrc,'*.xml'); 
    % get desttioation 
    pat = visitjson(1).patientcode; 
    visit = fullfile( visitjson(idxv).visitCategory); 
    dest = fullfile(destdir,pat,visit); 
    mkdir(dest); 
    % copy files 
    cellfun(@(x) copyfile(x,dest),txtfiles);
    cellfun(@(x) copyfile(x,dest),xmlfiles);
end
end