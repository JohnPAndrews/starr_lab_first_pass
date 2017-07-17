function MAIN_plot_measures_over_time()
%% This function plots measures over time
% Its aim is to create summery graphs of the various subjects
[settings, params] = get_settings_params();
resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
% addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/from_andy/eeglab14_1_0b'));
patexist = unique(sessiondb.patientcode);
%% set params
params.loaddat                    = 0; % load data into database or 0 just load mat file
params.preprocdata                = 0; % preprocess the data
params.plotPatCoher               = 0; % plot pat coherence linear
params.plotPatCoherPhase          = 0; % plot pat coherence linear
params.fontsize                   = 12;
%% loop on subjects (faster to parpool for loading and saving
% p = parpool('mac');
patexist = ...
{   'brpd_01'
    'brpd_03'
    'brpd_05'
    'brpd_06'
    'brpd_07'
    'brpd_09'
};
for p = 1:length(patexist)
    params.patuse      = patexist{p};
%     plot_measures_over_time_m1_stn(params); % plot max values beta
    plot_measures_over_time_coherence(params); % plot coherence values
end
% delete(p);
end

function [hfig, subposlin] = setupplotting()
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
hfig                   = figure('visible','off');
hfig.PaperPositionMode = 'manual';
hfig.PaperUnits        = 'inches';
hfig.PaperSize         = [plotwidth plotheight];
hfig.PaperPosition     = [0 0 plotwidth plotheight];

end

function plot_measures_over_time_m1_stn(params)
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
freqsuse = {    'Delta'    'Theta' 'Alpha'...
    'LowBeta' 'HighBeta' 'Beta' ...
    'LowGamma'    'HighGamma'};
freqranges = [  1     4;...
    4     8;...
    8    13;...
    13    20;...
    20    30;...
    13    30;...
    30    50;...
    50    90];
sumsused  = {'avg','max'};



cntplt = 1;
for s = 1:length(sumsused) % loop on avg / max
    for f = 1:length(freqsuse) % loop on freq used
        [hfig, subposlin] = setupplotting(); % set up a new figure
        figname = sprintf('%s_%s_%s_zscore',...
            params.patuse,  freqsuse{f},sumsused{s});
        for c = 1:length(condsuse) % plot each cond (rest / ipad / walking in a subplot)
            for a = 1:length(areasuse) % plot each area in subplot (seperate row
                sfnm = sprintf('%s_%s_%s',...
                    areasuse{a}, freqsuse{f},sumsused{s});
                sfraw = sprintf('%s_psd_tr_ofst_out_zscr',...
                    areasuse{a});
                % data selection
                logidxoverall = ...
                    logical(strcmp(brdb.StimOn,'on') |  strcmp(brdb.StimOn,'off') ) & ...
                    logical(strcmp(brdb.Medication,'on')| strcmp(brdb.Medication,'off')) & ...
                    logical(strcmp(brdb.ConditionTask,condsuse{c}));
                
                newdb  = brdb(logidxoverall,:);
                
                %% plot number
                switch c; case 1; pos =1; case 2; pos =2; case 3; pos =3; end
                if a ~= 1; pos = pos + 3; end;
                hsub(pos) = subplot('Position',subposlin(pos,:));
                hsub(pos).FontSize = params.fontsize;
                
                plotttl = strrep(...
                    sprintf('%s %s %s %s #sess = %d',...
                    params.patuse,areasuse{a},condsuse{c}, freqsuse{f},size(newdb,1)),...
                    '_',' ');
                for v = 1:size(newdb,1)
                    idxx = find(strcmp(newdb.visitCategory(v), unqvisits) == 1);
                    med  = newdb.Medication{v};
                    stim  = newdb.StimOn{v};
                    if iscell(newdb.(sfraw))
                        datraw   = newdb.(sfraw){v};
                    else
                        datraw   = newdb.(sfraw)(v,:);
                    end
                    if ~isempty(datraw) 
                        valsuse = datraw(freqranges(f,1):freqranges(f,2));
                        if strcmp(sumsused{s},'avg');
                            val = mean(valsuse); 
                        elseif strcmp(sumsused{s},'max');
                            val = max(valsuse); 
                        end
                    else
                        val = []; 
                    end
                    %% old version with filtering 
%                     if iscell(newdb.(sfnm)(v))
%                         val  = cell2mat(newdb.(sfnm)(v));
%                     else
%                         val  = double(newdb.(sfnm)(v));
%                     end
                    %% 
                    
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
                        hsca = scatter(idxx,val,150,clr,mrk,'filled',...
                            'MarkerFaceAlpha',0.6,...
                            'MarkerEdgeColor',[0 0 0],...
                            'MarkerEdgeAlpha',0.6);
                    end
                    hold on;
                end
                set(gca,'XTickLabelRotation',45);
                xlim([0 (length(unqvisits) +1)]);
                set(gca,'XTick',0:1:11);
                set(gca,'XTickLabel',[' ' ; strrep(unqvisits,'_',' '); ' '])
                title(plotttl);
                yltxt = sprintf('%s %s (%d-%dHz)',...
                    sumsused{s}, strrep(freqsuse{f},'_', ' '),...
                    freqranges(f,:));
                ylabel(yltxt);
            end
        end
        
        for ss = 1:length(hsub)
            ylims(ss,:) = hsub(ss).YLim ;
        end
        for ss = 1:length(hsub)
            hsub(ss).YLim = [min(ylims(:,1)) max(ylims(:,2))];
        end
        figdir = fullfile('..','figures','beta_over_time',params.patuse);
        mkdir(figdir);
        %% save figure
        %         hfig.PaperOrientation = 'landscape';
        spttltxt = sprintf('%s %s %s zscore',...
            params.patuse, freqsuse{f},sumsused{s});
        suptitle(strrep(spttltxt,'_', ' '));
        save_figure(hfig,figname,figdir, 'pdf');
        close(hfig);
    end
end
end


function plot_measures_over_time_coherence(params);
[settings, ~] = get_settings_params();
resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
fnmsave = sprintf('pP-%s_db.mat',params.patuse);
load(fullfile(resultsdir,fnmsave),'brdb');
unqvisits = {'OR_day',    'predis',  '10_day',...
    '03_wek',    '01_mnt',    '02_mnt',...
    '03_mnt',    '06_mnt',    '01_yer',...
    '02_yer'}';


condsuse = {'rest', 'walking','ipad'};
coheruse = {'coh_mag_lin','phase_coherence'};
freqsuse = {    'Delta'    'Theta' 'Alpha'...
    'LowBeta' 'HighBeta' 'Beta' ...
    'LowGamma'    'HighGamma'};
freqranges = [  1     4;...
    4     8;...
    8    13;...
    13    20;...
    20    30;...
    13    30;...
    30    50;...
    50    90];
sumsused  = {'avg','max'};


cntplt = 1;
for f = 1:length(freqsuse) % loop on freq used
    [hfig, subposlin] = setupplotting(); % set up a new figure
    figname = sprintf('%s_%s_coherence',...
        params.patuse,  freqsuse{f});
    for c = 1:length(condsuse) % plot each cond (rest / ipad / walking in a subplot)
        for a = 1:length(coheruse) % plot each area in subplot (seperate row
            sfnm = sprintf('%s_%s',...
                freqsuse{f},coheruse{a});
            % data selection
            logidxoverall = ...
                logical(strcmp(brdb.StimOn,'on') |  strcmp(brdb.StimOn,'off') ) & ...
                logical(strcmp(brdb.Medication,'on')| strcmp(brdb.Medication,'off')) & ...
                logical(strcmp(brdb.ConditionTask,condsuse{c}));
            
            newdb  = brdb(logidxoverall,:);
            
            %% plot number
            switch c; case 1; pos =1; case 2; pos =2; case 3; pos =3; end
            if a ~= 1; pos = pos + 3; end;
            hsub(pos) = subplot('Position',subposlin(pos,:));
            hsub(pos).FontSize = params.fontsize;
            
            plotttl = strrep(...
                sprintf('%s %s %s %s #sess = %d',...
                params.patuse,coheruse{a},condsuse{c}, freqsuse{f},size(newdb,1)),...
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
                    hsca = scatter(idxx,val,150,clr,mrk,'filled',...
                        'MarkerFaceAlpha',0.6,...
                        'MarkerEdgeColor',[0 0 0],...
                        'MarkerEdgeAlpha',0.6);
                end
                hold on;
            end
            set(gca,'XTickLabelRotation',45);
            xlim([0 (length(unqvisits) +1)]);
            set(gca,'XTick',0:1:11);
            set(gca,'XTickLabel',[' ' ; strrep(unqvisits,'_',' '); ' '])
            title(plotttl);
            yltxt = strrep(...
                sprintf('%s a.u. %s (%d-%dHz)',...
                 coheruse{a}, freqsuse{f},...
                freqranges(f,:)),'_',' ');
            ylabel(yltxt);
        end
    end
    
    for ss = 1:length(hsub)
        ylims(ss,:) = hsub(ss).YLim ;
    end
    for ss = 1:length(hsub)
        if ss > 3 
            hsub(ss).YLim = [min(ylims(4:6,1)) max(ylims(4:6,2))];
        else
            hsub(ss).YLim = [min(ylims(1:3,1)) max(ylims(1:3,2))];
        end
    end
    figdir = fullfile('..','figures','beta_over_time',params.patuse);
    mkdir(figdir);
    %% save figure
    %         hfig.PaperOrientation = 'landscape';
    spttltxt = sprintf('%s %s coherence',...
        params.patuse, freqsuse{f});
    suptitle(strrep(spttltxt,'_', ' '));
    save_figure(hfig,figname,figdir, 'pdf');
    close(hfig);
end

end


