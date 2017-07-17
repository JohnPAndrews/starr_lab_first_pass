function MAIN_plot_measures_over_time_phill_grant()
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
%  plot_report_patient_conditions(params);

plot_some_intial_graphs(params);
return ;
for p = 1:length(patexist)
    params.patuse      = patexist{p};
%     plot_report_patient_conditions(params);
    plot_some_intial_graphs(params); 
%     plot_measures_over_time_m1_stn(params); % plot max values beta
%     plot_measures_over_time_coherence(params); % plot coherence values
end
% delete(p);
end

function [hfig, subposlin,sub_pos] = setupplotting()
%% set plotting paramaters
plotheight = 16;
plotwidth  = 12;
subplotsx  = 2;
subplotsy  = 6;
leftedge   = 1;
rightedge  = 1;
topedge    = 1;
bottomedge = 1.5;
spacex     = 1;
spacey     = 1;
fontsize   = 12;
sub_pos    = subplot_pos(plotwidth,plotheight,leftedge,rightedge,bottomedge,topedge,subplotsx,subplotsy,spacex,spacey);
subposlin = cell2mat(sub_pos(:));
hfig                   = figure('visible','on');
hfig.PaperPositionMode = 'manual';
hfig.PaperUnits        = 'inches';
hfig.PaperSize         = [plotwidth plotheight];
hfig.PaperPosition     = [0 0 plotwidth plotheight];

end

function    plot_report_patient_conditions(params)
[settings, params] = get_settings_params();
resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
unqvisits = {'OR_day',    'predis',  '10_day',...
    '03_wek',    '01_mnt',    '02_mnt',...
    '03_mnt',    '06_mnt',    '01_yer',...
    '02_yer'}';

patexist = ...
    {'brpd_01'
    'brpd_03'
    'brpd_05'
    'brpd_06'
    'brpd_07'
    'brpd_09'
    };

areasuse = {'stn', 'm1'};
condsuse = {'rest','walking','ipad'};
medstatus = {'on' ,'off'}; 
stimstatus = {'on','off'};
ylabels = {'stim on med on'; 'stim on med off'; 'stim off med on'; 'stim off med off'}; 
%% report elec found
for p = 1:length(patexist)
    params.patuse      = patexist{p};
    fnmsave = sprintf('P-%s_db.mat',params.patuse);
    load(fullfile(resultsdir,fnmsave),'brdb');
    for a = 1:length(areasuse)
        for c = 1:length(condsuse)
            for u = 1:length(unqvisits)
                for m = 1:length(medstatus)
                    for s = 1:length(stimstatus)
                        areaname = sprintf('%sexist',areasuse{a});
                        idxuse = strcmp(brdb.visitCategory, unqvisits{u}) & ...
                            strcmp(brdb.StimOn,stimstatus{s}) & ...
                            strcmp(brdb.ConditionTask,condsuse{c}) & ...
                            strcmp(brdb.Medication,medstatus{m}) & ...
                            brdb.(areaname) ==1 ; 
                        switch s % stim status 
                            case 1 % on 
                                mrk = 'd';
                                switch m % med status  
                                    case 1 % on 
                                        row = 1; clr = [27,158,119]/255;
                                    case 2 % off 
                                        row = 2; clr = [217,95,2]/255;
                                end
                            case 2 
                                mrk = 'o';
                                switch m 
                                    case 1 
                                        row = 3; clr = [27,158,119]/255;
                                    case 2 
                                        row = 4; clr = [217,95,2]/255;
                                end
                        end
                        pfnm = genvarname(params.patuse);
                        dataCount.(pfnm).(condsuse{c}).(areasuse{a}).counts(row,u) = sum(idxuse);
                        dataCount.(pfnm).(condsuse{c}).(areasuse{a}).countsCol{row,u} = clr; 
                        dataCount.(pfnm).(condsuse{c}).(areasuse{a}).countsMrk{row,u} = mrk;
                        strucname = sprintf('stim%s_meds%s',stimstatus{s},medstatus{m});
                        newdb = brdb(idxuse,:); 
                        if ~isempty(newdb)
                            for i = 1:size(newdb,1)
                                try % first time doesn't exists this structure 
                                    addfac = length(dataraw.(pfnm).(condsuse{c}).(areasuse{a}).(strucname).visit);
                                catch
                                    dataraw.(pfnm).(condsuse{c}).(areasuse{a}).(strucname).visit =[]; 
                                    addfac =0;
                                end
                                iuse = i +addfac; 
                                dataraw.(pfnm).(condsuse{c}).(areasuse{a}).(strucname).visit(iuse).name = unqvisits{u};
                                dataraw.(pfnm).(condsuse{c}).(areasuse{a}).(strucname).visit(iuse).serial = u;
                                sfnmuse = sprintf('%s_rawdata',areasuse{a});
                                dataraw.(pfnm).(condsuse{c}).(areasuse{a}).(strucname).visit(iuse).rawdat = newdb.(sfnmuse){i};
                                sfnmuse = sprintf('%s_electrodes',areasuse{a});
                                dataraw.(pfnm).(condsuse{c}).(areasuse{a}).(strucname).visit(iuse).elecuse = newdb.(sfnmuse){i};
                            end
                        end
%                         dat = {}; 
%                         if sum(idxuse) ~= 0 
%                             dat{1} = u; dat{2} = row; dat{3} = clr; dat{4} = mrk; dat{5} = sum(idxuse);
%                             if isempty
%                             dataCount.(pfnm).(condsuse{c}).(areasuse{a}).countplot{cnt,:} = dat; 
%                         end
                    end
                end
            end
        end
        fprintf('\n');
    end
end
resdir = fullfile('..','results','mat_file_with_all_session_jsons'); 
fnmsave = 'allsubs_raw_data_by_cond_and_area.mat'; 
ffnm = fullfile(resdir, fnmsave); 
save(ffnm,'dataraw','dataCount');

%% plot tables 
for c = 1:length(condsuse)
    hfig = figure; cntplt =1; 
    for p = 1:length(patexist)
        for a = 1:length(areasuse)
            dat = dataCount.(patexist{p}).(condsuse{c}).(areasuse{a}).counts;
            col = dataCount.(patexist{p}).(condsuse{c}).(areasuse{a}).countsCol;
            mrk = dataCount.(patexist{p}).(condsuse{c}).(areasuse{a}).countsMrk;
            subplot(6,2,cntplt); cntplt = cntplt + 1; 
            for r = 1:size(dat,1)
                datrow = dat(r,:);
                colrow = col(r,:);
                mrkrow = mrk(r,:);
                [x,y] = find(datrow ~=0);
                coluse = colrow(datrow~=0)';
                markuse = cell2mat(mrkrow(datrow~=0));
                if ~isempty(y)
                    hsca = scatter(y,x.*r, 150, cell2mat(coluse),markuse(1),'filled',...
                        'MarkerFaceAlpha',0.6,...
                        'MarkerEdgeColor',[0 0 0],...
                        'MarkerEdgeAlpha',0.6);
                    hold on;
                end
            end
            xlim([0 (length(unqvisits) +1)]);
            set(gca,'XTick',0:1:11);
            set(gca,'XTickLabel',[' ' ; strrep(unqvisits,'_',' '); ' '])
            set(gca,'XTickLabelRotation',45);
            ylim([0.5 4.5]);
            hline = line([4.5 4.5],[0.5, 4.5]);
            hline.LineWidth = 2;
            hline.Color = [ 0.5 0.5 0.5 0.6];
            hline.LineStyle = '--';
            yticklabels('');
            plotttl = sprintf('%s %s %s',...
                patexist{p}, areasuse{a}, condsuse{c});
            title(strrep( plotttl, '_',' '));
            
        end
    end
    suptitle(sprintf('cond %s', condsuse{c}));
    figdir = fullfile('..','figures' ,'json_file_reports'); 
    figname = sprintf('PatientCondCount-%s.pdf',condsuse{c}); 
    hfig.PaperPositionMode  = 'manual'; 
    hfig.PaperUnits = 'inches';
    hfig.PaperSize = [12, 16]; 
    hfig.PaperPosition =[ 0 0 12 16];
    print(hfig, fullfile(figdir,figname), '-dpdf');
%     saveas(hfig, fullfile(figdir,figname)); 
end
return; 
end

function plot_some_intial_graphs(params)
resdir = fullfile('..','results','mat_file_with_all_session_jsons'); 
fnmsave = 'allsubs_raw_data_by_cond_and_area.mat'; 
ffnm = fullfile(resdir, fnmsave); 
load(ffnm,'dataraw','dataCount');
unqvisits = {'OR_day',    'predis',  '10_day',...
    '03_wek',    '01_mnt',    '02_mnt',...
    '03_mnt',    '06_mnt',    '01_yer',...
    '02_yer'}';

patexist = ...
    {'brpd_01'
    'brpd_03'
    'brpd_05'
    'brpd_06'
    'brpd_07'
    'brpd_09'
    };

areasuse = {'stn', 'm1'};
condsuse = {'rest'};%,'walking','ipad'};
medstatus = {'on' ,'off'}; 
clrs      = [[27,158,119]/255;[217,95,2]/255];% first row on, second off 

stimstatus = {'off'};
unqvisits = {'03_wek'};
 
[hfig, subposlin,sub_pos] = setupplotting();
sub_posf = flip(sub_pos,2);
for p = 1:length(patexist)
    for a = 1:length(areasuse) 
        for m = 1:length(medstatus)
            for s = 1:length(stimstatus)
                for u = 1:length(unqvisits)
                    sfnm = sprintf('stim%s_meds%s',stimstatus{s},medstatus{m});
                    subplot('Position',sub_posf{a,p}); 
                    ttlplot = sprintf('%s %s 3 week',patexist{p}, areasuse{a}); 
                    title(strrep(ttlplot,'_',' ')); 
                    dat = dataraw.(patexist{p}).(condsuse{1}).(areasuse{a}).(sfnm);
                    for v = 1:length(dat.visit)
                        if strcmp(dat.visit(v).name, unqvisits{u})
                            
                            data = dat.visit(v).rawdat;
                            [freq, power,pxxc,peaks] = preprocdata(data); 
                            logidx = freq > 13 & freq < 30;
                            plot(freq(logidx),power(logidx),...
                                'LineWidth',1.5,...
                                'Color',[clrs(m,:) 0.6]);
                            ylabel('power'); 
                            xlabel('freq'); 
                            if ~isempty(peaks)
                            end
                            hold on; 
                        end
                    end
                end
            end
        end
        hLegend = legend('on','off');
        hlt = text(...
            'Parent', hLegend.DecorationContainer, ...
            'String', 'med status:', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'Position', [0.5, 1.05, 0], ...
            'Units', 'normalized');
    end
end
figdir = fullfile('..','figures' ,'json_file_reports');
figname = sprintf('PatientPSds3week_MedOnVsOff_StimOff_%s_13-30.pdf',condsuse{1});
print(hfig, fullfile(figdir,figname), '-dpdf');
close(hfig); 

% plot 6 month stim on and off 
areasuse = {'stn', 'm1'};
condsuse = {'rest'};%,'walking','ipad'};
medstatus = {'off'}; 
clrs      = [[27,158,119]/255;[217,95,2]/255];% first row on, second off 

stimstatus = {'on','off'};
unqvisits = {'06_mnt'};
[hfig, subposlin,sub_pos] = setupplotting();
sub_posf = flip(sub_pos,2);

for p = 1:length(patexist)
    for a = 1:length(areasuse) 
        for m = 1:length(medstatus)
            for s = 1:length(stimstatus)
                for u = 1:length(unqvisits)
                    sfnm = sprintf('stim%s_meds%s',stimstatus{s},medstatus{m});
                    acol = a; 
                    subplot('Position',sub_posf{acol,p}); 
                    ttlplot = sprintf('%s %s 6 month',patexist{p}, areasuse{a}); 
                    title(strrep(ttlplot,'_',' ')); 
                    try
                        dat = dataraw.(patexist{p}).(condsuse{1}).(areasuse{a}).(sfnm);
                        for v = 1:length(dat.visit)
                            if strcmp(dat.visit(v).name, unqvisits{u})
                                
                                data = dat.visit(v).rawdat;
                                [freq, power,pxxc,peaks] = preprocdata(data);
                                logidx = freq > 13 & freq < 30;
                                plot(freq(logidx),power(logidx),...
                                    'LineWidth',1.5,...
                                    'Color',[clrs(s,:) 0.6]);
                                ylabel('power');
                                xlabel('freq');
                                if ~isempty(peaks)
                                     for pp = size(peaks,1) 
                                         idx = find(peaks(pp,1) == freq(logidx));
%                                          scatter(idx,peaks(pp,2),300,'filled',...
%                                              'MarkerFaceAlpha', 0.5)
                                     end
                                     
                                end
                                hold on;
                            end
                        end
                    end
                end
            end
        end
        hLegend = legend('on','off');
        hlt = text(...
            'Parent', hLegend.DecorationContainer, ...
            'String', 'stim status:', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'Position', [0.5, 1.05, 0], ...
            'Units', 'normalized');
    end
end

figdir = fullfile('..','figures' ,'json_file_reports');
figname = sprintf('PatientPSds6months_stim_on-off_medsoff_%s_13-30.pdf',condsuse{1});
print(hfig, fullfile(figdir,figname), '-dpdf');
close(hfig); 
% figure;
% sub_posf = flip(sub_pos,2); 
% for c = 1:4
%     for r = 1:6
%     subplot('Position',sub_posf{c,r}); 
%     title(sprintf('r %d c %d',r,c)); 
%     end
% end

end

function [freq, power, pxxclog,pksout] = preprocdata(dat); 
params.sr = 800;
params.lowcutoff = 1;
% trim data
dattrim = preproc_trim_data(dat,5e3, params.sr);

% dc offset
data_tr_prp = preproc_dc_offset_high_pass(dattrim,params);

% Nicki ideas - use wrapper for EEG lab - wrapper - spectopo - see what
% settings it is using. They take the data and optamize the settings.
% Makes nice looking plots. 1024 is window, and 524. 

[psdout,freq,pxxc] = pwelch(data_tr_prp, hamming(400),200,5:2:150,params.sr,'psd');
power = log10(psdout);
pxxclog = log10(pxxc);
peaksfound = findPeaksFromPSDconf(psdout,freq, pxxc,0);% psd, conf intervals, plot (0 = no);
if ~isempty(peaksfound)
pkfnd = find(peaksfound(:,1) >= 15 & peaksfound(:,1) <= 30 == 1);
pksout = peaksfound(pkfnd,:);
else
    pksout = []; 
end
end

function plot_measures_over_time_m1_stn(params)
[settings, params] = get_settings_params();
resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
unqvisits = {...
    '03_wek',   ...
    '01_yer'    }';
patexist = ...
    {'brpd_01'
    'brpd_03'
    'brpd_05'
    'brpd_06'
    'brpd_07'
    'brpd_09'
    };

areasuse = {'stn', 'm1'};
condsuse = {'rest'};
freqsuse = {  'Beta' ...
    'HighGamma'};
freqranges = [
    13    30;...
    50    90];
sumsused  = {'avg','max'};
medstatus = {'off' ,'on'};
fontsize   = 12;
%% report elec found
for a = 1:length(areasuse)
    for p = 1:length(patexist)
        params.patuse      = patexist{p};
        fnmsave = sprintf('P-%s_db.mat',params.patuse);
        load(fullfile(resultsdir,fnmsave),'brdb');
        for u = 1:length(unqvisits)
            for m = 1:length(medstatus)
                elecuse = [];
                if m == 1 % off meds
                    idxuse = strcmp(brdb.visitCategory, unqvisits{u}) & ...
                        strcmp(brdb.StimOn,'off') & ...
                        strcmp(brdb.ConditionTask,'rest') & ...
                        strcmp(brdb.Medication,medstatus{m})  ;
                    fprintf('%s pat %s visit %s med %s | count %0.2d\n',...
                        areasuse{a},params.patuse,unqvisits{u}, medstatus{m}, sum(idxuse));
                    newdb = brdb(idxuse,:);
                    if sum(idxuse) == 0
                        elecuse = [];
                    else
                        elecuse = newdb.([areasuse{a} '_electrodes']){:};
                    end
                else % on meds
                    if isempty(elecuse)
                        idxuse = strcmp(brdb.visitCategory, unqvisits{u}) & ...
                            strcmp(brdb.StimOn,'off') & ...
                            strcmp(brdb.ConditionTask,'rest') & ...
                            strcmp(brdb.Medication,medstatus{m})  &...
                            strcmp(brdb.([areasuse{a} '_electrodes']),elecuse); % electroede
                        fprintf('%s pat %s visit %s med %s | count %0.2d\n',...
                            areasuse{a},params.patuse,unqvisits{u}, medstatus{m}, sum(idxuse));
                    else
                        idxuse = strcmp(brdb.visitCategory, unqvisits{u}) & ...
                            strcmp(brdb.StimOn,'off') & ...
                            strcmp(brdb.ConditionTask,'rest') & ...
                            strcmp(brdb.Medication,medstatus{m}); % just give me everything you have
                        fprintf('pat %s visit %s med %s | count %0.2d\n',...
                            params.patuse,unqvisits{u}, medstatus{m}, sum(idxuse));
                        
                    end
                end
            end
        end
        fprintf('\n');
    end
end
%%
return;


for f = 1:length(freqsuse)
    for s = 1:length(sumsused)
        for a = 1:length(areasuse)
            [hfig, subposlin,sub_pos] = setupplotting();
            figname = sprintf('%s_%s_%s',...
                freqsuse{f},sumsused{s},areasuse{a});
            for p = 1:length(patexist)
                params.patuse      = patexist{p};
                fnmsave = sprintf('pP-%s_db.mat',params.patuse);
                load(fullfile(resultsdir,fnmsave),'brdb');
                for u = 1:length(unqvisits)
                    for m = 1:length(medstatus)
                        if m == 1 % off meds
                            idxuse = strcmp(brdb.visitCategory, unqvisits{u}) & ...
                                strcmp(brdb.StimOn,'off') & ...
                                strcmp(brdb.ConditionTask,'rest') & ...
                                strcmp(brdb.Medication,medstatus{m})  ;
                            newdb = brdb(idxuse,:);
                            elecuse = newdb.([areasuse{a} '_electrodes']){:};
                            clr = [217,95,2]/255;
                        else % on meds
                            idxuse = strcmp(brdb.visitCategory, unqvisits{u}) & ...
                                strcmp(brdb.StimOn,'off') & ...
                                strcmp(brdb.ConditionTask,'rest') & ...
                                strcmp(brdb.Medication,medstatus{m})  &...
                                strcmp(brdb.([areasuse{a} '_electrodes']),elecuse); % electroede
                            newdb = brdb(idxuse,:);
                            clr = [27,158,119]/255;
                        end
                        if u == 1; row =1; else row = 2; end; % set row for sub plot
                        col = p;% set column for subplot
                        hsub = subplot('Position',sub_pos{row,col});
                        hsub.FontSize = fontsize;
                        
                        for nb = 1:size(newdb,1)
                            sfy = sprintf('%s_psd_tr_ofst',areasuse{a});
                            sfx = sprintf('%s_psd_tr_ofst_freq',areasuse{a});
                            freq = newdb.(sfx){nb};
                            dat = newdb.(sfy){nb};
                            plot(freq(5:60),dat(5:60),...
                                'Color',[clr 0.5],'LineWidth',1);
                            hold on;
                        end
                    end
                end
            end
        end
    end
end



cntplt = 1;
for s = 1:length(sumsused) % loop on avg / max
    for f = 1:length(freqsuse) % loop on freq used
        [hfig, subposlin] = setupplotting(); % set up a new figure
        figname = sprintf('%s_%s_%s',...
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


