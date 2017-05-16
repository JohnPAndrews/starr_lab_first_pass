function MAIN_plot_beta_over_time()
%% This function plots beta over time across different subjects
% Its aim is to create summery graphs of the various subjects
[settings, params] = get_settings_params();
resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
patexist = unique(sessiondb.patientcode);
%% set params
params.loaddat                    = 0; % load data into database or 0 just load mat file
params.preprocdata                = 0; % preprocess the data
params.plotMaxValbeta             = 0; % plot max values beta
params.plotMaxValbetaMostFreqElec = 0; % plot max values beta only in most freq electrdoe 
params.plotMaxValbetaMFEpsd       = 1; % plot max values beta only in most freq. electrode full psds 

%% loop on subjects (faster to parpool for loading and saving
% p = parpool('mac');
for p = 1:length(patexist)
    params.patuse      = patexist{p};
    loadAndPreprocessData(params)
    plot_patient_data_beta_from_database(params); % plot max values beta
    plot_patient_data_beta_from_database_most_freq_elect(params); % plot only the most frequ electrode
    plot_patient_data_beta_from_database_most_freq_elect_psd(params); % plot only the most frequ electrode PSD's
end
% delete(p);
end

function loadAndPreprocessData(params)
[settings, ~] = get_settings_params();
resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
fnmsave = sprintf('P-%s_db.mat',params.patuse);
if params.loaddat    
    
    %%
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

function  plot_patient_data_beta_from_database(params)
if params.plotMaxValbeta
    [settings, ~] = get_settings_params();
    resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
    load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
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
        figname = sprintf('%s_%s',params.patuse,measureuse{m});
        cntplt = 1;
        for a = 1:length(areasuse)
            for c = 1:length(condsuse)
                logidxoverall = ...
                    logical(strcmp(brdb.StimOn,'on') |  strcmp(brdb.StimOn,'off') ) & ...
                    logical(strcmp(brdb.Medication,'on')| strcmp(brdb.Medication,'off')) & ...
                    logical(strcmp(brdb.ConditionTask,condsuse{c})) ;
                
                newdb  = brdb(logidxoverall,:);
                sfnm   = sprintf('%s_%s',areasuse{a},measureuse{m});
                hsub(cntplt) = subplot(2,3,cntplt); cntplt = cntplt + 1;
                
                plotttl = strrep(...
                    sprintf('%s %s %s %s #sess = %d',...
                    params.patuse,areasuse{a},condsuse{c}, measureuse{m},size(newdb,1)),...
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
                ylimssp(cntplt-1,:) =  hsub(cntplt-1).YLim ;
            end
        end
        for ss = 1:length(hsub)
            hsub(ss).YLim = [min(ylimssp(:)) max(ylimssp(:))];
        end
        figdir = fullfile('..','figures','beta_over_time');
        hfig.PaperOrientation = 'landscape';
        hfig.PaperSize = [16 8.5] .*2;
        save_figure(hfig,figname,figdir, 'pdf');
    end
end
end

function  plot_patient_data_beta_from_database_most_freq_elect(params)
if params.plotMaxValbetaMostFreqElec
    [settings, ~] = get_settings_params();
    resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
    load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
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
        figname = sprintf('%s_%s_uniqe_elec',params.patuse,measureuse{m});
        cntplt = 1;
        for a = 1:length(areasuse)
            for c = 1:length(condsuse)     
                % data selection 
                logidxoverall = ...
                    logical(strcmp(brdb.StimOn,'on') |  strcmp(brdb.StimOn,'off') ) & ...
                    logical(strcmp(brdb.Medication,'on')| strcmp(brdb.Medication,'off')) & ...
                    logical(strcmp(brdb.ConditionTask,condsuse{c})) ;
                
                allelecs = brdb.([areasuse{a} '_electrodes']);
                unqelec  = unique(allelecs); 
                fprintf('found % d unq elecs\n',length(unqelec));
                for ue = 1:length(unqelec)
                    cnt(ue) = sum(strcmp(allelecs,unqelec{ue}));
                    fprintf('%s, cnt = %d\n',unqelec{ue},cnt(ue));
                end
                [~,maxidx] = max(cnt);
                fprintf('plotting %s elec with count %d\n',...
                    unqelec{maxidx}, cnt(maxidx)); 
                logidxunqelec = strcmp( brdb.([areasuse{a} '_electrodes']),unqelec{maxidx}); 
                
                clear cnt; % so still works for next subpllot 
                
                logidxoverall = logidxunqelec & logidxoverall;% bcs max electrodfes 
                newdb  = brdb(logidxoverall,:);
                
                sfnm   = sprintf('%s_%s',areasuse{a},measureuse{m});
                hsub(cntplt) = subplot(2,3,cntplt); cntplt = cntplt + 1;
                plotttl = strrep(...
                    sprintf('%s %s %s %s #sess = %d',...
                    params.patuse,areasuse{a},condsuse{c}, measureuse{m},size(newdb,1)),...
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
                ylimssp(cntplt-1,:) =  hsub(cntplt-1).YLim ;
            end
        end
        for ss = 1:length(hsub)
            hsub(ss).YLim = [min(ylimssp(:)) max(ylimssp(:))];
        end
        
        figdir = fullfile('..','figures','beta_over_time');
        hfig.PaperOrientation = 'landscape';
        hfig.PaperSize = [16 8.5] .*2;
        save_figure(hfig,figname,figdir, 'pdf');
        
    end
end
end

function  plot_patient_data_beta_from_database_most_freq_elect_psd(params)
if params.plotMaxValbetaMFEpsd
    [settings, ~] = get_settings_params();
    resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
    load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
    fnmsave = sprintf('pP-%s_db.mat',params.patuse);
    load(fullfile(resultsdir,fnmsave),'brdb');
    unqvisits = {'OR_day',    'predis',  '10_day',...
        '03_wek',    '01_mnt',    '02_mnt',...
        '03_mnt',    '06_mnt',    '01_yer',...
        '02_yer'}';
    
    
    areasuse = {'stn', 'm1'};
    condsuse = {'rest', 'walking','ipad'};
    measureuse = {'beta_peak_zscore'};
    
    close all;
    for m = 1:length(measureuse) % loop on measure use
        hfig = figure;
        hfig.Position = [ 52         162        2383        1160];
        figname = sprintf('%s_%s_uniqe_elec_overlayed_psd',params.patuse,measureuse{m});
        cntplt = 1;
        for a = 1:length(areasuse)
            for c = 1:length(condsuse)     
                % data selection 
                logidxoverall = ...
                    logical(strcmp(brdb.StimOn,'on') |  strcmp(brdb.StimOn,'off') ) & ...
                    logical(strcmp(brdb.Medication,'on')| strcmp(brdb.Medication,'off')) & ...
                    logical(strcmp(brdb.ConditionTask,condsuse{c})) ;
                
                allelecs = brdb.([areasuse{a} '_electrodes']);
                unqelec  = unique(allelecs); 
                fprintf('found % d unq elecs\n',length(unqelec));
                for ue = 1:length(unqelec)
                    cnt(ue) = sum(strcmp(allelecs,unqelec{ue}));
                    fprintf('%s, cnt = %d\n',unqelec{ue},cnt(ue));
                end
                [~,maxidx] = max(cnt);
                fprintf('plotting %s elec with count %d\n',...
                    unqelec{maxidx}, cnt(maxidx)); 
                logidxunqelec = strcmp( brdb.([areasuse{a} '_electrodes']),unqelec{maxidx}); 
                
                clear cnt; % so still works for next subpllot 
                
                logidxoverall = logidxunqelec & logidxoverall;% bcs max electrodfes 
                newdb  = brdb(logidxoverall,:);
                
                sfnm    = sprintf('%s_%s',areasuse{a},measureuse{m});
                sfnmpsd = sprintf('%s_beta_psdoutlog_zscore',areasuse{a});


                hsub(cntplt) = subplot(2,3,cntplt); cntplt = cntplt + 1;
                plotttl = strrep(...
                    sprintf('%s %s %s %s #sess = %d',...
                    params.patuse,areasuse{a},condsuse{c}, measureuse{m},size(newdb,1)),...
                    '_',' ');
                for v = 1:size(newdb,1)
                    idxx = find(strcmp(newdb.visitCategory(v), unqvisits) == 1);
                    med  = newdb.Medication{v};
                    stim  = newdb.StimOn{v};
                    % XX 
                    sfnmpsdfreq = sprintf('%s_psdoutlogfreq_zscore',areasuse{a});
                    
                    if iscell(newdb.(sfnm)(v))
                        val  = cell2mat(newdb.(sfnm)(v));
                        psduse = newdb.(sfnmpsd){v};
                        freqidx = newdb.(sfnmpsdfreq){v} > 13 & newdb.(sfnmpsdfreq){v} < 30;
                    else
                        val  = double(newdb.(sfnm)(v));
                        psduse = newdb.(sfnmpsd)(v,:);
                        freqidx = newdb.(sfnmpsdfreq)(v,:) > 13 & newdb.(sfnmpsdfreq)(v,:) < 30;
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
                        hold on;
                        % only take 10 50 freq range 
                        psduse = psduse(freqidx);
                        xcenOnidx    = linspace(idxx-0.4,idxx+0.4,length(psduse));
                        powerOnHeigt = psduse-mean(psduse)+val; 
                        hplt = plot(xcenOnidx,powerOnHeigt);
                        hplt.Color = [clr 0.8];
                        hplt.LineWidth = 2;
                        if strcmp(mrk,'d')
                            hplt.LineStyle =':';
                        end
                    end
                end
                set(gca,'XTickLabelRotation',45);
                xlim([0 (length(unqvisits) +1)]);
                set(gca,'XTickLabel',[' ' ; strrep(unqvisits,'_',' '); ' '])
                title(plotttl);
                ylabel('max \beta power (13-30Hz)');
                ylimssp(cntplt-1,:) =  hsub(cntplt-1).YLim ;
            end
        end
        for ss = 1:length(hsub)
            hsub(ss).YLim = [min(ylimssp(:)) max(ylimssp(:))];
        end
        
        figdir = fullfile('..','figures','beta_over_time');
        hfig.PaperOrientation = 'landscape';
        hfig.PaperSize = [16 8.5] .*2;
        save_figure(hfig,figname,figdir, 'pdf');
        
    end
end
end
