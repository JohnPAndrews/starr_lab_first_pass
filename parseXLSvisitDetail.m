function visitdetail = parseXLSvisitDetail(xlsfile, sessioname)
visitdetail = []; 

[num,txt,raw] = xlsread(xlsfile);
% this is the auto generated spreadsheet, read anothet worksheet
if strcmp(raw{1}, 'Spreadsheet Version: 2.0') 
   [num,txt,raw] = xlsread(xlsfile,'Recording List'); 
end
% find row with filename 
sessionrow = []; 
for r = 1:size(raw,1) 
    if strfind(raw{r},sessioname)
        sessionrow = r; 
        break;
    end
end
if isempty(sessionrow) % this file does not exist in xls file! 
    visitdetail = []; 
    return; 
end

% find row with headers: 
for r = 1:size(raw,1) 
    if strcmp(strrep(lower(raw{r}),' ',''),'filename')
        headerow = r; 
        break;
    end
end


% create structure with xls data using headers as filenames 
cnt = 1; 
for c = 1:size(raw,2) 
    if isnan(raw{headerow,c}) % if couldn't get a title from header, put something generic
        fnm = sprintf('notes%0.3d',cnt); cnt = cnt + 1; 
        visitdetail.(fnm) = raw{sessionrow,c};
    else
        visitdetail.(genvarname(raw{headerow,c})) = raw{sessionrow,c};
    end
    
end
end