function checkDifferentTaskNames()
%% This function reports the variability in task names 
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data'; 
ffs = findFilesBVQX(rootdir,'*session*^^^^-.json'); 
cnt = 1; 
for s = 1:length(ffs) 
    session  = loadjson(ffs{s},'SimplifyCell',1); 
    if isstr(session.ConditionTask)
        conditionsout{cnt,1} = session.RawConditionTask;
        conditionsout{cnt,2} = session.ConditionTask;
        cnt = cnt + 1; 
    end
end
conraw = conditionsout(:,1);
coninter = conditionsout(:,2); 
[sortconds,idx] = unique(conditionsout(:,1)); 
for c = 1:length(sortconds)
    condraw = sortconds{c}; 
    condinter = conditionsout{idx(c),2};
    count = sum(strcmp(conraw,condraw)); 
    fprintf('[%0.2d]\t  %0.3d\t  %s\t  %s \n',...
        c,  count, condraw,condinter);
end
unique(sortconds);
end