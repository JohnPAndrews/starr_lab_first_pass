function fixRawDataTemp()
% fix a bug which saved each session twice in the data and results table
% structures 
%% Fix bug that this indtroudced-  only keeping the first file of each montage file 
%% 1. need to find all sessions that have montage 
%% 2. resave their data files by adding montage 
%% 3. rerun results analysis 

rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
%{
ff = findFilesBVQX(rootdir,'dataBR.mat');
for f = 1:length(ff)
    start = tic; 
    [pn,fn,ext] = fileparts(ff{f});
    [tmp,~,~] = fileparts(pn);
    [tmp,visit,~] = fileparts(tmp);
    [tmp,patient,~] = fileparts(tmp);
    load(ff{f}); 
    
    unqsess = unique(datTab.sessionum); 
    cnt = 1; 
    for s = 1:length(unqsess)
        idxs = find(datTab.sessionum == unqsess(s));
        idxsmontage = cellfun(@(x) any(strcmp(x,'montage')),datTab.task) & ...
            datTab.sessionum == unqsess(s);
        if sum(idxsmontage) == 1 % mistake with montage file 
            fixmontage = 1;  
        elseif sum(idxsmontage) == 6 % montage file fine 
            fixmontage = 0;
        end
        idxuse(cnt) = idxs(1); 
        cnt = cnt + 1; 
    end
    if fixmontage
        [pnn,fnn,ext] = fileparts(pn);
        origDataTab = datTab;
%         MAIN_plot_visit_quick_figures(pnn)
        load(ff{f});
            
        unqsess = unique(datTab.sessionum);
        datTab.idxclean = zeros(size(datTab,1),2);
        for s = 1:length(unqsess)
            idxclean = origDataTab.idxclean(find(origDataTab.sessionum == unqsess(s)),:);
            idxssession = find(datTab.sessionum == unqsess(s));
            datTab.idxclean(idxssession,:) = repmat(idxclean,size(idxssession,1),1);
        end
%         save(ff{f},'datTab');
        fprintf('montage fixed finished p - %s visit - %s file %s in %f \n',patient,visit,fn,toc(start));
    end
    if ~ismember('idxclean',datTab.Properties.VariableNames)
        [pnn,fnn,ext] = fileparts(pn);
        fprintf('idx clean fix  p - %s visit - %s file %s in %f \n',patient,visit,fn,toc(start));
%         MAIN_plot_visit_quick_figures(pnn);
    end
    
%     datTab = datTab(idxuse,:);
%     save(ff{f},'datTab');
%     fprintf('finished p - %s visit - %s file %s in %f \n',patient,visit,fn,toc(start));
    clear datTab idxuse
end
%}


%% fix results file that have only 1 montage file 
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
ff = findFilesBVQX(rootdir,'resultsBR.mat');
for f = 1:length(ff)
    start = tic; 
    [pn,fn,ext] = fileparts(ff{f});
    [visitdir,~,~] = fileparts(pn);
    [tmp,visit,~] = fileparts(visitdir);
    [tmp,patient,~] = fileparts(tmp);

    load(ff{f}); 
    
    unqsess = unique(resTab.sessionum);
    
    for s = 1:length(unqsess)
            idxsmontage = cellfun(@(x) any(strcmp(x,'montage')),resTab.task) & ...
                resTab.sessionum == unqsess(s);
        if sum(idxsmontage) == 1 % mistake with montage file
            fixmontage = 1;
        elseif sum(idxsmontage) == 6 % montage file fine
            fixmontage = 0;
        end
    end
    if fixmontage
         x = 2; 
         MAIN_plot_visit_quick_figures(visitdir);
         fprintf('finished p - %s visit - %s file %s in %f \n',patient,visit,fn,toc(start));
    end
    %     save(ff{f},'resTab');
    clear resTab idxuse
end

end