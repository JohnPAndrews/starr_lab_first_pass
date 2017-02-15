function deleteAllSessionJsons()
%% This is a utility function... 
% use with caution.... 
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data';
ff = findFilesBVQX(rootdir,'*session*.json'); 
for f = 1:length(ff)
    delete(ff{f}); 
end
end