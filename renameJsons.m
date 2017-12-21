function renameJsons()
rawdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/ipad-jsons/Ipad files ';
destdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/ipad-jsons/ipad_files_renamed';
ff = findFilesBVQX(rawdir,'*.json');
for f = 1:length(ff)
    start = tic; 
    [pn,fn, ext] = fileparts(ff{f}); 
    src = ff{f};
    len = length(fn);
    dest =  fullfile(destdir,[fn(len-18:end) '.json']);
    copyfile(src,dest); 
    fprintf('moved %0.3d out of %0.3d in %0.2f secs\n',...
        f, length(ff), toc(start));
end
end