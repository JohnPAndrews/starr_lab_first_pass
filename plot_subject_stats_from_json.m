function plot_subject_stats_from_json()
%% set params. 
outdir = fullfile('..','figures','json_file_reports'); 
params.outdir = outdir; 
params.sessionmatfile  = fullfile('..','results','mat_file_with_all_session_jsons','all_session_strucs-REORGANIZED.mat');
evalc('mkdir(outdir)'); 


%% 

% plot_subject_progress(params); % plot progress from all visits 
% plot_days_since_implant_per_visit(params); % 
% plot_most_common_electrode(params); % plot most common electrode combo for each subject 
plot_recording_duration_per_subject(); % plot total duration of recording per subject 



end

function plot_subject_progress(params)
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
resultsdir   = fullfile('..','results','mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');

% inclusion criteria:
patients = unique(sessiondb.patientcode);
visits = unique(sessiondb.visitCategory);
visitsuse = visits([10    11     9     7     2     4     6     8     3     5]);


cnt = 1; 
for p = 1:length(patients)
    for v = 1:length(visitsuse)
        rowsselect = ...
            sessiondb.usevisit == 1 & ...
            strcmp(sessiondb.patientcode,patients(p)) & ...
            strcmp(sessiondb.visitCategory,visitsuse{v}) ;
        newdb = sessiondb(rowsselect,:);
        if size(newdb,1) > 1 
            outmaty(cnt) = p;
            outmatx(cnt) = v; 
            cnt = cnt + 1; 
        end
    end
end
allvisitsuse = [{' '}; visitsuse;{' '}];
allpatients = [{' '}; patients;{' '}];
outmaty = outmaty + 1; 
outmatx = outmatx + 1; 

hfig = figure; 
hplot = scatter(outmatx,outmaty,5,'r','filled'); 
hplot.MarkerFaceAlpha = 0.5;
hplot.SizeData = 200; 
hxlabel = xlabel('Visit');
hylabel = ylabel('Patients');
ax = ancestor(hplot, 'axes');
hyrule = ax.YAxis;
hxrule = ax.XAxis;
hxrule.TickLabelRotation = 45;

xlim([1 12])
ylim([1 9])
set(gca,'XTickLabel',strrep(allvisitsuse,'_',' '))
set(gca,'YTickLabel',strrep(allpatients,'_',' '))
box off;
htitle = title('Brain Radio Patient Visit Status'); 
formatPlot(htitle,hxlabel,hylabel,hxrule,hyrule,hplot)
save_figure(hfig,'all_patients_visit_overview',params.outdir,'jpeg')
end

function plot_days_since_implant_per_visit(params)
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
resultsdir   = fullfile('..','results','mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');

%% some exapmples of sorting, data selections:
% inclusion criteria:
patients = unique(sessiondb.patientcode);
visits = unique(sessiondb.visitCategory);
visitsuse = visits([10    11     9     7     2     4     6     8     3     5]);
chanuse = 1; % 1 = stn, 2 = m1
labelarea{1} = 'stn'; labelarea{2} = 'm1';
chanidx = [1 3];
% hfig = figure('Position',[497         447        1186         826]); 
cnt = 1;
for v = 1:length(visitsuse)
    %% inclusion criteria
    rowsselect = ...
        sessiondb.usevisit == 1 & ...
        strcmp(sessiondb.visitCategory,visitsuse(v));
    newdb = sessiondb(rowsselect,:);
    for i = 1:size(newdb,1)
        outdatmat(cnt)  = newdb.daysSinceImplant(i);
        catnames{cnt} = visitsuse{v};
        cnt = cnt + 1; 
    end
    outdat.(['v_' visitsuse{v}]) = newdb.daysSinceImplant;
end

hfig = figure;
boxplot(outdatmat,catnames);
hplot = gca;
hxlabel = xlabel('Visit');
hylabel = ylabel('Days since implant');
ax = ancestor(hplot, 'axes');
hyrule = ax.YAxis;
hxrule = ax.XAxis;
hxrule.TickLabelRotation = 45;
htitle = title('Brain Radio Days Since Implant Per Visit'); 
formatPlot(htitle,hxlabel,hylabel,hxrule,hyrule,hplot)
save_figure(hfig,'all_patients_days_since_implant',params.outdir,'jpeg')


end

function plot_most_common_electrode(params)
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
resultsdir   = fullfile('..','results','mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');



%% some exapmples of sorting, data selections:
% inclusion criteria:
patients = unique(sessiondb.patientcode);
visits = unique(sessiondb.visitCategory);
visitsuse = visits([10    11     9     7     2     4     6     8     3     5]);
visitsuse = visitsuse(8); 
chanuse = 1; % 1 = stn, 2 = m1
labelarea{1} = 'stn'; labelarea{2} = 'm1';
chanidx = [1 3];
hfig = figure('Position',[497         447        1186         826]); 
for p = 1:length(patients)
    %% inclusion criteria
    rowsselect = ...
        sessiondb.usevisit == 1 & ...
        strcmp(sessiondb.patientcode,patients(p)) & ...
        strcmp(sessiondb.ConditionTask,'rest') ;
    newdb = sessiondb(rowsselect,:);
    unqelec = unique(newdb.m1_electrodes);
    for e = 1:length(unqelec)
        counts(e) = sum(strcmp(newdb.m1_electrodes,unqelec{e}));
    end
    subplot(3,3,p); 
    bar(1:length(counts),counts); 
    xlabel('Electrodes'); 
    ylabel('# of recordings'); 
    title(strrep(patients(p),'_',' ')); 
    set(gca,'XTickLabel',unqelec);
    set(gca,'XTickLabelRotation',45);
    clear counts unqelec 
end
set(findall(hfig,'-property','FontSize'),'FontSize',14)
figname = 'electrodes_used_per_patient_M1';
hfig.PaperPositionMode = 'auto' ; 
save_figure(hfig,figname, params.outdir,'jpeg');

end

function plot_recording_duration_per_subject(params)
outdir = fullfile('..','figures','json_file_reports'); 
params.outdir = outdir; 
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
resultsdir   = fullfile('..','results','mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
ntb = varfun(@sum,sessiondb,'InputVariables','recordingduraton','GroupingVariables','patientcode'); 
rechours = ntb.sum_recordingduraton/3600;
hfig = figure;
bar(1:length(rechours),rechours);
set(gca,'XTickLabel',strrep(ntb.patientcode,'_',' ')); 
xlabel('Patients');
ylabel('Hours'); 
title('Sum of Recording Hours Per Subject'); 
set(findall(hfig,'-property','FontSize'),'FontSize',14)
figname = 'recording_hours_per_subject';
hfig.PaperPositionMode = 'auto' ; 
save_figure(hfig,figname, params.outdir,'jpeg');

end