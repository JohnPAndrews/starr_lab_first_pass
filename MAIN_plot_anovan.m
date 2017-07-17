function MAIN_plot_anovan()
%% This function plots beta over time across different subjects
% Its aim is to create summery graphs of the various subjects
% addpath(genpath(pwd));
[settings, params] = get_settings_params();
resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
patexist = unique(sessiondb.patientcode);
%% set params
params.patexist                   = patexist;
params.loaddat                    = 0; % load data into database or 0 just load mat file
params.preprocdata                = 0; % preprocess the data
params.calcCoherence              = 1; % calc coherence 
params.computeAnovaN              = 0; % plot pat coherence linear

%% loop on subjects (faster to parpool for loading and saving
% p = parpool('mac');
patexist = {'brpd_04'};
patexist = ...
{   'brpd_05'
    'brpd_06'
    'brpd_07'
    'brpd_09'};
for p = 1:length(patexist)
    params.patuse      = patexist{p};
    loadAndPreprocessData(params)
end
computeAnovaN(params); % plot max values beta
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
    for s = 1:size(brdb,1)
        start = tic;
        if s == 1
            preprocdat = preproc_wrapper(brdb(s,:),params);
        else
            preprocdat = preproc_wrapper(brdb(s,:),params,preprocdat);
        end
        fprintf('%d out of %d data loaded in %f \n',...
            s, size(brdb,1),toc(start));
    end
    dattable = struct2table(preprocdat);
    brdb   = [brdb, dattable];
    fnmsave = sprintf('pP-%s_db.mat',params.patuse); % XXX
    save(fullfile(resultsdir,fnmsave),'brdb');
else
    load(fullfile(resultsdir,fnmsave),'brdb');
end

%% calc coherence 
areas = {'stn', 'm1'};
freqs =    {'Delta'
            'Theta'
            'Alpha'
            'LowBeta'
            'HighBeta'
            'Beta'
            'LowGamma'
            'HighGamma'};
dat = [];
if params.calcCoherence
    fnmsave = sprintf('pP-%s_db.mat',params.patuse); % XXX
    load(fullfile(resultsdir,fnmsave),'brdb');
    for s = 1:size(brdb,1)
        start = tic;
        for fr = 1:length(freqs)
            datmiss = 0; 
            for a = 1:length(areas) 
                fnmuse = sprintf('%s_%s_raw',areas{a},freqs{fr}); 
                rawdat = brdb.(fnmuse){s}; 
                if isempty(rawdat) | isnan(rawdat)
                    datmiss = 1; 
                    break; 
                end
                try  % edge case in whihh curropt file not equal number of poitns in each channel 
                    dat(a,:) = rawdat;
                catch 
                    datmiss = 1;
                end
            end
            if datmiss
                fnmcret = sprintf('%s_coh_mag_lin',freqs{fr});
                brdb.(fnmcret)(s) = NaN;
                fnmcret = sprintf('%s_coh_phase_lin',freqs{fr});
                brdb.(fnmcret)(s) = NaN;
                fnmcret = sprintf('%s_phase_difference',freqs{fr});
                brdb.(fnmcret){s} = NaN;
                fnmcret = sprintf('%s_phase_coherence',freqs{fr});
                brdb.(fnmcret)(s) = NaN;
                fnmcret = sprintf('%s_phase_mean',freqs{fr});
                brdb.(fnmcret)(s) = NaN;
            else
                [coh_mag_lin,coh_phase_lin,phase_coherence, phase_difference,phase_mean] = calcCoherenceMeasures(dat);
                fnmcret = sprintf('%s_coh_mag_lin',freqs{fr});
                brdb.(fnmcret)(s) = coh_mag_lin;
                fnmcret = sprintf('%s_coh_phase_lin',freqs{fr});
                brdb.(fnmcret)(s) = coh_phase_lin;
                fnmcret = sprintf('%s_phase_difference',freqs{fr});
                brdb.(fnmcret){s} = phase_difference;
                fnmcret = sprintf('%s_phase_coherence',freqs{fr});
                brdb.(fnmcret)(s) = phase_coherence;
                fnmcret = sprintf('%s_phase_mean',freqs{fr});
                brdb.(fnmcret)(s) = phase_mean;
            end
            clear dat coh_mag_lin coh_phase_lin
        end
        fprintf('%d out of %d data loaded in %f \n',...
            s, size(brdb,1),toc(start));
    end
    fnmsave = sprintf('pP-%s_db.mat',params.patuse); % XXX
    save(fullfile(resultsdir,fnmsave),'brdb');
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


function  computeAnovaN(params)
close all;
%% set plotting paramaters
plotheight = 8.5*3;
plotwidth  = 16*3;
subplotsx  = 3;
subplotsy  = 3;
leftedge   = 1;
rightedge  = 1; 
topedge    = 1;
bottomedge = 1.5;
spacex     = 0.1;
spacey     = 3;
fontsize   = 24;
sub_pos    = subplot_pos(plotwidth,plotheight,leftedge,rightedge,bottomedge,topedge,subplotsx,subplotsy,spacex,spacey);
subposlin = cell2mat(sub_pos(:));

hfig                   = figure('visible','off');
hfig.PaperPositionMode = 'manual';
hfig.PaperUnits        = 'inches';
hfig.PaperSize         = [plotwidth plotheight];
hfig.PaperPosition     = [0 0 plotwidth plotheight];


% clf(f);

if params.computeAnovaN
    for pp = 1:length(params.patexist)
        params.patuse      = params.patexist{pp};
        
        [settings, ~] = get_settings_params();
        resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
        load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
        fnmsave = sprintf('pP-%s_db.mat',params.patuse);
        load(fullfile(resultsdir,fnmsave),'brdb');
        
        %% roc example
        loguse = strcmp(brdb.StimOn,'off');
        logarr =[]; logidx = []; 
        brdb = brdb(loguse,:);
        dat = [brdb.stn_Beta_avg, brdb.m1_Beta_avg];
        for i = 1:size(dat,1)
            for j = 1:size(dat,2)
                if ~isnumeric(dat{i,j})
                    logarr(i,j) = 0;
                elseif isempty(dat{i,j})
                    logarr(i,j) = 0;
                else
                    logarr(i,j) = 1;
                end
            end
        end
        logidx = logarr(:,1) + logarr(:,2) == 2; 
        pred = cell2mat(dat(logidx,:));
        resp = strcmp(brdb.Medication(logidx),'on');
        figure;scatter(pred(resp,1),pred(resp,2)); hold on; scatter(pred(~resp,1),pred(~resp,2));
        mdl = fitglm(pred,resp,'Distribution','binomial','Link','logit');
        scores = mdl.Fitted.Probability;
        [X,Y,T,AUC] = perfcurve(resp,scores,1);
        hfig = figure; 
        plot(X,Y)
        xlabel('False positive rate')
        ylabel('True positive rate')
        title('ROC for Classification by Logistic Regression')
        % logistic regression 
        mdl = fitglm(pred,resp,'Distribution','binomial','Link','logit');
        score_log = mdl.Fitted.Probability; % Probability estimates
        [Xlog,Ylog,Tlog,AUClog] = perfcurve(resp,score_log,'true');
        %svm 
        mdlSVM = fitcsvm(pred,resp,'Standardize',true);
        [~,score_svm] = resubPredict(mdlSVM);
        [Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(resp,score_svm(:,mdlSVM.ClassNames),'true');
        mdlNB = fitcnb(pred,resp);
        [~,score_nb] = resubPredict(mdlNB);
        [Xnb,Ynb,Tnb,AUCnb] = perfcurve(resp,score_nb(:,mdlNB.ClassNames),'true');
        hfig2 = figure; 
        plot(Xlog,Ylog)
        hold on
        plot(Xsvm,Ysvm)
        plot(Xnb,Ynb)
        legend('Logistic Regression','Support Vector Machines','Naive Bayes','Location','Best')
        xlabel('False positive rate'); ylabel('True positive rate');
        title('ROC Curves for Logistic Regression, SVM, and Naive Bayes Classification')
        AUClog
        AUCsvm
        AUCnb
        
        hold off
        

        %% set up anova
        measureuse = 'stn_beta_peak_zscore';
        if ~iscell(brdb.(measureuse))
            logchoose = ~isnan(brdb.(measureuse));
        else
        logchoose = ~cellfun('isempty', brdb.(measureuse)) & ...
            cellfun(@isnumeric, brdb.(measureuse));
        end
        
        if iscell(brdb.(measureuse))
            y = cell2mat(brdb.(measureuse)(logchoose));
        else
            y = brdb.(measureuse)(logchoose); 
        end
        
        groupsuse = {brdb.Medication(logchoose),...
            brdb.StimOn(logchoose),...
            brdb.visitCategory(logchoose),...
            brdb.stn_electrodes(logchoose)...
            };
        varnames = {'Med','Stim','Visit','Electrode'};
        [p, tbl, stats, terms] = anovan(y,groupsuse,...
            'varnames',varnames,...
            'display','off');
        
        %% compute sum of squares, display main effects that are significanc with astrix, plus include omega squared
        lablesuse ={};
        pievals = cell2mat(tbl(2:end-1,2))./cell2mat(tbl(end,2));
        for v = 1:length(varnames)
            lablesuse{v} = sprintf('%s, %%%.1f p = %.2f',...
                varnames{v},pievals(v)*100, p(v));
        end
        lablesuse = [lablesuse , 'error'];
        
        hsub(pp) = subplot('Position',subposlin(pp,:));
        hsub(pp).FontSize = fontsize;

        hpie = pie(pievals,lablesuse);
        for hh = 1:length(hpie)
            try
                hpie(hh).FontSize = fontsize; 
            end
        end
        title(sprintf('%s %s',...
            strrep(params.patuse,'_',' '),...
            strrep(measureuse,'_',' ')),...
            'FontSize',fontsize        ); 
    end
    figname = sprintf('anova_%s',measureuse); 
    figdir = fullfile('..','figures','beta_over_time','group');
    save_figure(hfig,figname,figdir, 'pdf');

    %%
    
    %% compare ipad rest, walking rest for ROI, seperate by visit
    
    %% plot beta meds on vs meds off all data set (equality line)
    
    %% compute personalized beta peak
    
    %% create GLM with coherence, m1 beta, stn beta
    
    
end
end

function  plot_patient_coherence_phase(params)
%% set plotting paramaters
plotheight = 8.5;
plotwidth  = 16;
subplotsx  = 3;
subplotsy  = 2;
leftedge   = 1;
rightedge  = 1;
topedge    = 1;
bottomedge = 1.5;
spacex     = 1;
spacey     = 1;
fontsize   = 12;
sub_pos    = subplot_pos(plotwidth,plotheight,leftedge,rightedge,bottomedge,topedge,subplotsx,subplotsy,spacex,spacey);
subposlin = cell2mat(sub_pos(:));


% clf(f);

if params.plotPatCoherPhase
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
    measureuse = {'_rawdata'};
    m = 1;
    cntco =  1;
    close all;
    screensize = get( groot, 'Screensize' );
    hfig                   = figure('visible','off');
    hfig.PaperPositionMode = 'manual';
    hfig.PaperUnits        = 'inches';
    hfig.PaperSize         = [plotwidth plotheight];
    hfig.PaperPosition     = [0 0 plotwidth plotheight];
    
    
    figname = sprintf('%s_coherence_linear',params.patuse);
    cntplt = 1;
    for c = 1:length(condsuse)
        % data selection
        logidxoverall = ...
            logical(strcmp(brdb.StimOn,'on') |  strcmp(brdb.StimOn,'off') ) & ...
            logical(strcmp(brdb.Medication,'on')| strcmp(brdb.Medication,'off')) & ...
            logical(strcmp(brdb.ConditionTask,condsuse{c}));
        %% select uniq elec
        %{
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
        %}
        %%
        
        newdb  = brdb(logidxoverall,:);
        
        %% loop on visits found
        for pp = 1:2 % loop on phase / mag coherence
            %% plot number
            switch c; case 1; pos =1; case 2; pos =2; case 3; pos =3; end
            if pp ~= 1; pos = pos + 3; end;
            hsub(pos) = subplot('Position',subposlin(pos,:));
            hsub(pos).FontSize = fontsize;
            
            %                 hsub(cntplt).Position = sub_pos{xpos,ypos};
            cntplt = cntplt + 1;
            if pp == 1
                plotttl = strrep(...
                    sprintf('Mag coherence %s %s %s #sess = %d',...
                    params.patuse,condsuse{c}, measureuse{m},size(newdb,1)),...
                    '_',' ');
                
            elseif pp == 2
                plotttl = strrep(...
                    sprintf('Phase coherence %s %s %s #sess = %d',...
                    params.patuse,condsuse{c}, measureuse{m},size(newdb,1)),...
                    '_',' ');
            end
            
            for v = 1:size(newdb,1)
                idxx = find(strcmp(newdb.visitCategory(v), unqvisits) == 1);
                med  = newdb.Medication{v};
                stim  = newdb.StimOn{v};
                misschan = 0;
                for a = 1:length(areasuse)
                    sfnm   = sprintf('%s%s',areasuse{a},measureuse{m});
                    if iscell(newdb.(sfnm)(v))
                        val  = cell2mat(newdb.(sfnm)(v));
                    else
                        val  = double(newdb.(sfnm)(v));
                    end
                    params.sr = 793;
                    if isempty(val)
                        misschan = 1;
                    else
                        % trim data
                        valtr = preproc_trim_data(val,params.msec2trim, params.sr);
                        % dc offset
                        valdc = preproc_dc_offset_high_pass(valtr,params);
                        if size(valdc,1) > size(valdc,2) % somtiems need to transpote
                            valdc = valdc';
                        end
                        datacohere(a,:) = valdc;
                    end
                end
                if ~misschan
                    %                     [coh,coh_angle] = get_linear_coherence_eegfilt_share(datacohere, params.sr, [13 30]);
                    [coh_data,phase_mean,phase_difference] = get_phase_coherenceoutput_phases_share(datacohere, params.sr, [13 30]);
                    coh_all(cntco) = coh;
                    coh_angle_all(cntco) = coh_angle;
                    cntco = cntco + 1;
                    clear datacohere
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
                    if ~misschan
                        if pp ==1 % use mag
                            cohuse = coh;
                        elseif pp == 2
                            cohuse = coh_angle;
                        end
                        
                        s = scatter(idxx,cohuse,300,clr,mrk,'filled',...
                            'MarkerFaceAlpha',0.6,...
                            'MarkerEdgeColor',[0 0 0],...
                            'MarkerEdgeAlpha',0.6);
                    end
                    hold on;
                else
                    clear datacohere cohuse;
                end
            end
            
            set(gca,'XTickLabelRotation',45);
            xlim([0 (length(unqvisits) +1)]);
            set(gca,'XTick',0:(length(unqvisits) +1));
            set(gca,'XTickLabel',[' ' ; strrep(unqvisits,'_',' '); ' '])
            
            if pp ==1
                ylabel('Mag. \beta (13-30Hz) coherence');
            else
                ylabel('Phase \beta (13-30Hz) coherence');
            end
            title(plotttl);
        end
    end
    for ss = 1:3
        hsub(ss).YLim = [min(coh_all)*1.1  ; max(coh_all)*1.1];
    end
    
    for ss = 4:6
        hsub(ss).YLim = [min(coh_angle_all)*1.1 ; max(coh_angle_all)*1.1];
    end
    %parameters for figure and panel size
    
    %setting the Matlab figure
    
    
    figdir = fullfile('..','figures','beta_over_time');
    %         hfig.PaperOrientation = 'landscape';
    save_figure(hfig,figname,figdir, 'pdf');
    
    
    pause(0.1);
    close(hfig);
end
end
