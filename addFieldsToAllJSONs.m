function addFieldsToAllJSONs()
%% This function adds fields to all jsons in rootdir and can also reorder the fields. 
[settings, params] = get_settings_params();
ff = findFilesBVQX(settings.rootdir,'*session*.json');
for f = 1:length(ff)
    start = tic;
    [pn, ~] =fileparts(ff{f});
    session  = loadjson(ff{f},'SimplifyCell',1);
    newsession = session; 
    newsession.rejectsesssion = 0; 
    newsession.reasonrejected = ''; 
    newsession.sessionLengthInSec = []; 
    newsession.MedicationNotes = '';
    fieldnamesused = fieldnames(newsession); 
    for s = 1:length(fieldnamesused)
        fprintf('%0.2d\t %s\n',s,fieldnamesused{s})
    end
    neworder = [1     2     3     7     4     5     9    20    10    11    12    13    17    18    19    14    15    16     6     8];
    newsession = orderfields(newsession,neworder); 
    savejson('',newsession,ff{f});
    fprintf('session %s saved in %f\n',session.filename,toc(start));
end
end