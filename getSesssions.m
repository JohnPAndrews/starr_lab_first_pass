function session = getSesssions(settings,session_num)
%% settings structure this function finds: 
% raw data files, xml files 
% parses xml file, as well as raw data file 
dataloc = fullfile(settings.raw_data_fold,settings.visits{session_num}); 
ff = findFilesBVQX(dataloc,'*.xml'); 
% loop on found files, read xml and read raw data file 
for f = 1:length(ff) 
    [pn,fn] = fileparts(ff{f});
    session(f).xmlstruc = parseXML(ff{f}); 
    session(f).data     = importdata(fullfile(pn,[fn, '.txt']));
    session(f).filename = fn; 
    session(f).pathname = pn; 
end
end