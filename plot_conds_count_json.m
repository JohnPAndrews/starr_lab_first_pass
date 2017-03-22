rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
resultsdir   = fullfile('..','results','mat_file_with_all_session_jsons');
evalc('mkdir(resultsdir)');
outdir   = fullfile('..','results','xls_files_of_session_db_by_patient');
evalc('mkdir(outdir)');

[settings, params] = get_settings_params();
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');

tblout = varfun(@median,sessiondb,'InputVariables','recordingduraton','GroupingVariables',{'patientcode','ConditionTask'});
unqpat = unique(tblout.patientcode);
hfig = figure('Position',[1           1        1440         804]); 
for i = 1:length(unqpat)
    subplot(3,3,i); 
    logpat = strcmp(unqpat{i},tblout.patientcode);
    pattbl = tblout(logpat,:);
    hbar = bar(pattbl.GroupCount);
    set(gca,'XTickLabel',pattbl.ConditionTask);
    set(gca,'XTickLabelRotation',45);
    title(strrep( unqpat{i},'_',' ')); 
    xlabel('conds'); 
    ylabel('Count of sessions'); 
end
save_figure(hfig,figname,figdir,'jpeg');