function buildDataBase()

rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
outdir  = fullfile('..','data','database');
ff = findFilesBVQX(rootdir,'dataBR.mat');
possstrings = {'OR day','2 day','10 day',...
    '3 week','1 month','2 month',...
    '3 month','6 month','1 year',...
    '2 year'};
matcstr    =  { 'OR_day','predis','10_day',...
    '03_wek','01_mnt','02_mnt',...
    '03_mnt','06_mnt',...
    '01_yer','02_yer'};

datTabAll = table();
for f = 1:length(ff)
    start = tic; 
    load(ff{f});
    [pn,fn] = fileparts(ff{f}); 
    idxvisit = cellfun(@(x) any(strfind(pn,x)),matcstr);
    visitstr = possstrings(idxvisit);
    datTab.visit = repmat(visitstr,size(datTab,1),1);
    datTabAll = [datTabAll; datTab];
    clear datTab idxvisit 
    fprintf('file %d out of %d done in %f\n',f,length(ff),toc(start));
end
save(fullfile(outdir,'databaseRaw.mat'),'datTabAll');

end

