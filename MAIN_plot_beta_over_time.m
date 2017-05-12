function MAIN_plot_beta_over_time()
%% This function plots beta over time across different subjects
% Its aim is to create summery graphs of the various subjects
[settings, params] = get_settings_params();
resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
patexist = unique(sessiondb.patientcode);
% p = parpool('mac');
for p = 1:length(patexist)
    loadAndPreprocessData(patexist{p})
    plot_patient_data_beta_from_database(patexist{p});
end
% delete(p);
end

function loadAndPreprocessData(patuse)
[settings, params] = get_settings_params();
resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');

%%
params.patuse      = patuse;
params.loaddat     = 0; % load data into database or 0 just load mat file
params.preprocdata = 0; % preprocess the data
logidxoverall = ...
    sessiondb.usevisit == 1 & ...
    ~strcmp(sessiondb.visitCategory,'000000') & ...
    logical(strcmp(sessiondb.StimOn,'on') |  strcmp(sessiondb.StimOn,'off') ) & ...
    logical(strcmp(sessiondb.Medication,'on')| strcmp(sessiondb.Medication,'off')) & ...
    logical(strcmp(sessiondb.patientcode,params.patuse)) &  ...
    sessiondb.sr == 800;
newdb = sessiondb(logidxoverall,:);
fprintf('found %d files\n',size(newdb,1));

%% load and save data
fnmsave = sprintf('P-%s_db.mat',params.patuse);
if params.loaddat
    for s = 1:size(newdb,1)
        start = tic;
        if s == 1
            outdat = loadBRdatToStruc(newdb.datafullpath{s});
        else
            outdat = loadBRdatToStruc(newdb.datafullpath{s},outdat);
        end
        fprintf('%d out of %d data loaded in %f \n',...
            s, size(newdb,1),toc(start));
    end
    dattable = struct2table(outdat);
    brdb   = [newdb, dattable];
    save(fullfile(resultsdir,fnmsave),'brdb');
else
    load(fullfile(resultsdir,fnmsave),'brdb');
end

%% preprocess data
chans = [1 3];
areas = {'stn', 'm1'};
if params.preprocdata
    for s = 1:size(newdb,1)
        start = tic;
        if s == 1
            preprocdat = preproc_wrapper(brdb(s,:),params);
        else
            preprocdat = preproc_wrapper(brdb(s,:),params,preprocdat);
        end
        fprintf('%d out of %d data loaded in %f \n',...
            s, size(newdb,1),toc(start));
    end
    dattable = struct2table(preprocdat);
    brdb   = [brdb, dattable];
    fnmsave = sprintf('pP-%s_db.mat',params.patuse); % XXX
    save(fullfile(resultsdir,fnmsave),'brdb');
else
    load(fullfile(resultsdir,fnmsave),'brdb');
end

% axis to seperate on:
% inclusion criteria:
% 800 hz
% rest
% stim on / stim off
% meds on / meds off
% use most frequet electrode
% if missing data, just dont' plot it.


% data analysis:
% take each of these graphs and seperate them by time (linear)
% or superimpose (one page).
% create one pdf with a report for each patient.

% steps:
% 1. get data to analayze
% 2. run through all preprocessing - create output table of data with a line
%   for preprocessed data. [parralalize this], and extra line for each step of preprocessing.
% 3. This just happenes for each subject.

% additional task: run through one ipad task
% run coherence analyis in time

end

function  plot_patient_data_beta_from_database(patuse)
[settings, params] = get_settings_params();
resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
params.patuse      = patuse;
fnmsave = sprintf('pP-%s_db.mat',params.patuse);
load(fullfile(resultsdir,fnmsave),'brdb');
unqvisits = {'OR_day',    'predis',  '10_day',...
    '03_wek',    '01_mnt',    '02_mnt',...
    '03_mnt',    '06_mnt',    '01_yer',...
    '02_yer'}';


areasuse = {'stn', 'm1'};
condsuse = {'rest', 'walking','ipad'};
measureuse = {'beta_peak_zscore', 'beta_psdoutlog'};

close all;
for m = 1:length(measureuse) % loop on measure use
    hfig = figure;
    hfig.Position = [ 52         162        2383        1160];
    figname = sprintf('%s_%s',patuse,measureuse{m});
    cntplt = 1; 
    for a = 1:length(areasuse)
        for c = 1:length(condsuse)
            logidxoverall = ...
                logical(strcmp(brdb.StimOn,'on') |  strcmp(brdb.StimOn,'off') ) & ...
                logical(strcmp(brdb.Medication,'on')| strcmp(brdb.Medication,'off')) & ...
                logical(strcmp(brdb.ConditionTask,'rest')) ;
            
            newdb  = brdb(logidxoverall,:);
            sfnm   = sprintf('%s_%s',areasuse{a},measureuse{m});
            subplot(2,3,cntplt); cntplt = cntplt + 1; 
            plotttl = strrep(...
                        sprintf('%s %s %s %s',...
                        patuse,areasuse{a},condsuse{c}, measureuse{m}),...
                        '_',' '); 
            for v = 1:size(newdb,1)
                idxx = find(strcmp(newdb.visitCategory(v), unqvisits) == 1);
                med  = newdb.Medication{v};
                stim  = newdb.StimOn{v};
                if iscell(newdb.(sfnm)(v))
                    val  = cell2mat(newdb.(sfnm)(v));
                else
                    val  = double(newdb.(sfnm)(v));
                end
                switch med
                    case 'on'
                        clr = [27,158,119]/255;
                    case 'off'
                        clr = [217,95,2]/255;
                end
                switch stim
                    case 'on'
                        mrk = 'd';
                    case 'off'
                        mrk = 'o';
                end
                if ~isempty(val) & isnumeric(val)
                    s = scatter(idxx,val,300,clr,mrk,'filled',...
                        'MarkerFaceAlpha',0.6,...
                        'MarkerEdgeColor',[0 0 0],...
                        'MarkerEdgeAlpha',0.6);
                end
                hold on;
            end
            set(gca,'XTickLabelRotation',45);
            xlim([0 (length(unqvisits) +1)]);
            set(gca,'XTickLabel',[' ' ; strrep(unqvisits,'_',' '); ' '])
            title(plotttl);
            ylabel('max \beta power (13-30Hz)');
        end
    end
    figdir = fullfile('..','figures','beta_over_time');
    hfig.PaperOrientation = 'landscape'; 
    hfig.PaperSize = [16 8.5] .*2;
    save_figure(hfig,figname,figdir, 'pdf');
end
end

