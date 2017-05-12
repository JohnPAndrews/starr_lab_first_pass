function findTxtFilesMissingJSON()
rootdir = fullfile('..','..','Raw_Data','BR_raw_data'); 
ftxfiles = findFilesBVQX(rootdir,'brpd*MR*.txt'); 
for f = 1:length(ftxfiles)
    [fp,fn,ext] = fileparts(ftxfiles{f});
    if strcmp(fn(end-2:end),'raw')
        fn =  fn(1:end-4);
    end
    if ~exist(fullfile(fp,[fn '_session_details-^^^^-.json']),'file')
        fprintf('json not exist for file %s\n',ftxfiles{f});
    end
end
end