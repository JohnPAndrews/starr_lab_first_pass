function outdat = getVisitDetails(protTable)
%% This function open a gui that allows experimenter to report experimental conditions 
%  For Activa PC + S 

% input: table of found files in visit from function addBrainRadioVisit.mn 

% output: a completed protocol with med + stim + task details in table
% format 

%%% 

for r = 1:size(protTable)
    outdata{r,1} = protTable.Fn{r};
    outdata{r,2} = char(protTable.Date(r));
    outdata{r,3} = char(protTable.Dur(r));
    outdata{r,4} = protTable.Task{r};
    outdata{r,5} = logical(0);
    outdata{r,6} = logical(0);
end
% protCell = [ protTable.Fn cellstr(char(protTable.Date)) cellstr(char(protTable.Dur))...
%     protTable.Task ...
%     logical(zeros(length(protTable.Med),1)) ... 
%     logical(zeros(length(protTable.Stim),1))];

hfig = figure('Position', [100 100 752 250]);
t = uitable('Parent', hfig, 'Position', [25 50 700 200]);
t.Data = outdata;%protCell; 
t.ColumnName = {'fn','date','duration','task','med','stim'}; 
t.ColumnEditable = [false false false true true true];

% t.ColumnFormat = {[] [] [] {'montage', 'ipad', 'walking', 'rest','home recording','error','other'},...
%                            {'on','off'},...
%                            {'on','off'}};
t.ColumnFormat = {[] []  [] {'montage', 'ipad', 'walking', 'rest','home-recording','washout','washin','error','other'},...
                           [],...
                           []};

% hsurf    = uicontrol('Style','pushbutton',...
%                      'String','Done',...
%                      'Position',[100,100,70,25],...
%                      'Callback',{@donebutton_Callback});

ansuse = input('done editing table?[1] ');
outdat = t.Data; 
close(hfig); 
end

function donebutton_Callback(source,eventdata)

end