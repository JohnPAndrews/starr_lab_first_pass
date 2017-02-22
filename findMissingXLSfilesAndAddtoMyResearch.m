function findMissingXLSfilesAndAddtoMyResearch()
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data';
myresarchdir = '/Volumes/pstarr_shared/ECOG data';
ffxls =  findFilesBVQX(rootdir,'*.xls');
ffxlsx   = findFilesBVQX(rootdir,'*.xlsx');
ffxlsm   = findFilesBVQX(rootdir,'*.xlsm');
ff = [ffxls; ffxlsx; ffxlsm];
pjson = loadjson(fullfile(rootdir, 'patients-^^^^-.json'),'SimplifyCell',1);
for f = 1:length(ff)
    newfloc = strrep(ff{f},rootdir,myresarchdir);
    if ~exist(newfloc,'file')
        copyfile(ff{f},newfloc);
        fprintf('copied file %s\n',newfloc);
    end
end
end