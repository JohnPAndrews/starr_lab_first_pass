function compare_psds_across_different_conditions()
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
resultsdir   = fullfile('..','results','mat_file_with_all_session_jsons');
figdir = fullfile('..','figures','showcasing_data_variability');
evalc('mkdir(figdir)');
[settings, params] = get_settings_params();
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
%% set params.
% inclusion criteria
logidxoverall = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.ConditionTask,'rest') & ...
    ~strcmp(sessiondb.visitCategory,'000000') & ...
    logical(strcmp(sessiondb.StimOn,'off') |  strcmp(sessiondb.StimOn,'on') ) & ...
    logical(strcmp(sessiondb.Medication,'off') |  strcmp(sessiondb.Medication,'on') ) & ...
    sessiondb.sr == 800;
newdb = sessiondb(logidxoverall,:);
avgeragechan = 1;
%{
% % what makes different graphs  (what to loop on)
% gg(1).fn = 'patientcode'; % loop on patient
% gg(2).fn = 'visitCategory'; % loop on visit
% % what to seperate within graphs
% condsgraph(1).fieldname = 'StimOn';
% % should you average within graph?
% averageconds = 1;  % yes or no.
% % XXX - add function to use
%
% unqsLa = unique(sessiondb.(gg(1).fn));
% unqsLB = unique(sessiondb.(gg(2).fn));
%
% params.groupingvarialbes = x; % groups that should be averaged
%}

%% plot all patients in one graph, rest, meds off / on
%{
uniqupat = (sessiondb.patientcode);
for i = 1:size(newdb,1)
    start = tic;
    data = importdata(newdb.datafullpath{i});
    data = data(:,1);
    params.sr = newdb.sr(i);
    data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
    data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
    zscore_dat = zscore(data_tr_prp); 
    figtitle = 'All Patients, Rest, Meds - Off, Stim - Off';
    [hfig, hplot] = plot_data_freq_domain(zscore_dat,params,figtitle); hold on;
    hplot.Color = [hplot.Color 0.3];
    fprintf('patient %s visit %s session %d in %f\n',...
        newdb.patientcode{i},...
        newdb.visitCategory{i},...
        newdb.sessionSerialNum(i),...
        toc(start));
end
figname = 'All_Patients_cat-Rest_Meds-off_Stim-Off-zscore';
save_figure(hfig,figname,figdir,'jpeg');
%}

%% plot all patietns, rest, meds off, stim off, seperate by colors by subject
%{
uniqupat = unique(sessiondb.patientcode);
colorspat = [101,135,205;...
112,168,69;...
163,97,199;...
182,143,64;...
198,92,138;...
74,172,141;...
204,90,67]/255;
for p = 1:length(uniqupat);
    logidx_pat =  strcmp(sessiondb.patientcode,uniqupat(p));
    logidxuse = logidxoverall & logidx_pat;
    newdb = sessiondb(logidxuse,:);
    for i = 1:size(newdb,1)
        start = tic;
        data = importdata(newdb.datafullpath{i});
        data = data(:,1);
        params.sr = newdb.sr(i);
        data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
        data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
        zscored_dat = zscore(data_tr_prp); 
        figtitle = 'All Patients, Rest, Meds -Off, Stim - Off';
        [hfig, hplot] = plot_data_freq_domain(zscored_dat,params,figtitle); hold on;
        hplot.Color = [colorspat(p,:) 0.3];
        fprintf('patient %s visit %s session %d in %f\n',...
            newdb.patientcode{i},...
            newdb.visitCategory{i},...
            newdb.sessionSerialNum(i),...
            toc(start));
    end
    legendttls{p} = strrep(uniqupat{p},'_',' ');
end
legend(legendttls,'FontSize',14,'FontWeight','bold');
figname = 'All_Patients_Seg_By_Color_cat-Rest_Meds-Off_Stim-Off_zscored';
save_figure(hfig,figname,figdir,'jpeg');
%}

%% plot all patietns, rest, meds off, stim off, seperate by colors by subject, in subplots
%{
uniqupat = unique(sessiondb.patientcode);
colorspat = [101,135,205;...
112,168,69;...
163,97,199;...
182,143,64;...
198,92,138;...
74,172,141;...
204,90,67]/255;
hfig = figure('Position',[811         312        1323         961]);
for p = 1:length(uniqupat);
    logidx_pat =  strcmp(sessiondb.patientcode,uniqupat(p));
    logidxuse = logidxoverall & logidx_pat;
    newdb = sessiondb(logidxuse,:);
    subplot(3,3,p);
    for i = 1:size(newdb,1)
        start = tic;
        data = importdata(newdb.datafullpath{i});
        data = data(:,1);
        params.sr = newdb.sr(i);
        data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
        data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
        zscored_dat = zscore(data_tr_prp); 
        [~, hplot] = plot_data_freq_domain(zscored_dat,params,'placeholder'); hold on;
        hplot.Color = [colorspat(p,:) 0.3];
        fprintf('patient %s visit %s session %d in %f\n',...
            newdb.patientcode{i},...
            newdb.visitCategory{i},...
            newdb.sessionSerialNum(i),...
            toc(start));
    end
    ylim([-9 -2]);
    title(strrep(uniqupat{p},'_',' '));
end
% rescasle axis 
hplots=get(gcf,'children');
for pp = 1:length(hplots) 
    hax = get(hplots(pp),'children');
    dat = hax.YData;
    minvals(pp) = min(dat);
    maxvals(pp) = max(dat);
end
hplots=get(gcf,'children');
for pp = 1:length(hplots) 
    hplots(pp).YLim  = [min(minvals) max(maxvals)];
end
% 

figtitle = 'All Patients, Rest, Meds -Off, Stim - Off';
figname = 'All_Patients_subplots_Meds-Off_Stim-Of_zscored';
hfig.PaperPositionMode = 'auto' ;
save_figure(hfig,figname,figdir,'jpeg');
%}
%%;

%% plot all patietns, rest, meds off, stim off, seperate by colors by subject, by electrode
%{
uniqupat = unique(sessiondb.patientcode);
colorspat = [101,135,205;...
112,168,69;...
163,97,199;...
182,143,64;...
198,92,138;...
74,172,141;...
204,90,67]/255;
hfig = figure('Position',[811         312        1323         961]);
for p = 1:length(uniqupat);
    logidx_pat =  strcmp(sessiondb.patientcode,uniqupat(p));
    logidxuse = logidxoverall & logidx_pat;
    newdb = sessiondb(logidxuse,:);
    unqelec = unique(newdb.stn_electrodes);
    subplot(3,3,p);
    legendcnt = 1;
    legendttl = {};
    for i = 1:size(newdb,1)
        start = tic;
        data = importdata(newdb.datafullpath{i});
        data = data(:,3);
        params.sr = newdb.sr(i);
        data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
        data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
        [~, hplot] = plot_data_freq_domain(data_tr_prp,params,'placeholder'); hold on;
        hplots(i) = hplot;
        hlegttl{i} = newdb.stn_electrodes{i};
        for c = 1:length(unqelec)
            if strcmp(unqelec{c},newdb.stn_electrodes{i});
                hplot.Color = [colorspat(c,:) 0.7];
                legendttl{c} = newdb.stn_electrodes{i};
            end
        end
        
        fprintf('patient %s visit %s session %d in %f\n',...
            newdb.patientcode{i},...
            newdb.visitCategory{i},...
            newdb.sessionSerialNum(i),...
            toc(start));
    end
    ylim([-9 -2]);
    title(strrep(uniqupat{p},'_',' '));
    [legstrs, idxsleg] = unique(hlegttl);
    hleg= legend(hplots(idxsleg),legstrs,'FontSize',14,'FontWeight','bold');
    clear hplots legstrs idxsleg hlegttl
end
figtitle = 'M1 All Patients, Rest, Meds -Off, Stim - Off';
figname = 'M1_All_Patients_subplots_Meds-Off_Stim-Off_by_electrode';
hfig.PaperPositionMode = 'auto' ;
save_figure(hfig,figname,figdir,'jpeg');
%}
%%;

%% plot all patietns, rest, meds off, stim off, seperate by task, choose most frequent electrode
%{
uniqupat = unique(sessiondb.patientcode);
colorspat = [101,135,205;...
112,168,69;...
163,97,199;...
182,143,64;...
198,92,138;...
74,172,141;...
204,90,67]/255;
hfig = figure('Position',[811         312        1323         961]);
for p = 1:length(uniqupat);
    logidx_pat =  strcmp(sessiondb.patientcode,uniqupat(p));
    % find most common electrode
    logidxuse = logidxoverall & logidx_pat;
    newdb = sessiondb(logidxuse,:);

    [uniqueXX, ~, J]=unique(newdb.stn_electrodes);
    occ = histc(J, 1:numel(uniqueXX));
    [~,idxmax] = max(occ);
    logidxmostcomelectrode = strcmp(sessiondb.stn_electrodes,uniqueXX(idxmax)) ;
    logidxuse = logidxoverall & logidx_pat & logidxmostcomelectrode;
    newdb = sessiondb(logidxuse,:);
    % find unq visits
    unqvisits = unique(newdb.visitCategory);
   
    
    subplot(3,3,p);
    legendttl = {};
    for i = 1:size(newdb,1)
        start = tic;
        data = importdata(newdb.datafullpath{i});
        data = data(:,3);
        params.sr = newdb.sr(i);
        data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
        data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
        [~, hplot] = plot_data_freq_domain(data_tr_prp,params,'placeholder'); hold on;
        hplots(i) = hplot;
        hlegttl{i} = strrep(newdb.visitCategory{i},'_',' ');
        for c = 1:length(unqvisits)
            if strcmp(unqvisits{c},newdb.visitCategory{i});
                hplot.Color = [colorspat(c,:) 0.7];
                legendttl{c} = newdb.visitCategory{i};
            end
        end
        
        fprintf('patient %s visit %s session %d in %f\n',...
            newdb.patientcode{i},...
            newdb.visitCategory{i},...
            newdb.sessionSerialNum(i),...
            toc(start));
    end
    ylim([-9 -2]);
    title(strrep(uniqupat{p},'_',' '));
    [legstrs, idxsleg] = unique(hlegttl);
    hleg= legend(hplots(idxsleg),legstrs,'FontSize',14,'FontWeight','bold');
    clear hplots legstrs idxsleg hlegttl
end
figtitle = 'M1 All Patients, Rest, Meds -Off, Stim - Off';
figname = 'M1_All_Patients_subplots_Meds-Off_Stim-Off_by_task_most_freq_elec';
hfig.PaperPositionMode = 'auto' ;
save_figure(hfig,figname,figdir,'jpeg');
%}
%%;

%% plot all patietns, rest, meds ON vs OFF , stim off, seperate by task, choose most frequent electrode
%{
uniqupat = unique(sessiondb.patientcode);
colorspat = [1 0 0;0 1 0];
hfig = figure('Position',[811         312        1323         961]);
for p = 1:length(uniqupat);
    logidx_pat =  strcmp(sessiondb.patientcode,uniqupat(p));
    % restrict to first 3 visit 
    logvisituse = strcmp(sessiondb.visitCategory,{'OR_day'}) | ...
        strcmp(sessiondb.visitCategory,{'predis'}) | ...
        strcmp(sessiondb.visitCategory,{'10_day'}) | ...
        strcmp(sessiondb.visitCategory,{'03_wek'});

    % find most common electrode in those 3 weeks 
    logidxuse = logidxoverall & logidx_pat & logvisituse;
    newdb = sessiondb(logidxuse,:);

    [uniqueXX, ~, J]=unique(newdb.stn_electrodes);
    occ = histc(J, 1:numel(uniqueXX));
    [~,idxmax] = max(occ);
    logidxmostcomelectrode = strcmp(sessiondb.stn_electrodes,uniqueXX(idxmax)) ;
    % create pateitn database 
    logidxuse = logidxoverall & logidx_pat & logvisituse & logidxmostcomelectrode;
    newdb = sessiondb(logidxuse,:);
    % find unq medicaiton visit
    unqmeds = unique(newdb.Medication);
   
    
    subplot(3,3,p);
    legendttl = {};
    for i = 1:size(newdb,1)
        start = tic;
        data = importdata(newdb.datafullpath{i});
        data = data(:,1);
        params.sr = newdb.sr(i);
        data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
        data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
        [~, hplot] = plot_data_freq_domain(data_tr_prp,params,'placeholder'); hold on;
        hplots(i) = hplot;
        hlegttl{i} = strrep(newdb.Medication{i},'_',' ');
        for c = 1:length(unqmeds)
            if strcmp(unqmeds{c},newdb.Medication{i});
                hplot.Color = [colorspat(c,:) 0.7];
                legendttl{c} = newdb.Medication{i};
            end
        end
        
        fprintf('patient %s visit %s session %d in %f\n',...
            newdb.patientcode{i},...
            newdb.visitCategory{i},...
            newdb.sessionSerialNum(i),...
            toc(start));
    end
    ylim([-9 -2]);
    title(strrep(uniqupat{p},'_',' '));
    [legstrs, idxsleg] = unique(hlegttl);
    hleg= legend(hplots(idxsleg),legstrs,'FontSize',14,'FontWeight','bold');
    clear hplots legstrs idxsleg hlegttl
end
figtitle = 'STM All Patients, Rest, Meds -On vs Off, Stim - Off';
figname = 'STN_All_Patients_subplots_Meds-OnvsOff_Stim-Off_first3weeks_most_freq_elec';
hfig.PaperPositionMode = 'auto' ;
save_figure(hfig,figname,figdir,'jpeg');
%}
%%;

%% plot all patietns, rest, meds ON vs OFF , stim off, seperate by task, choose most frequent electrode + make GIF
%
uniqupat = unique(sessiondb.patientcode);
colorspat = [1 0 0;0 1 0];
for p = 1:length(uniqupat);
    logidx_pat =  strcmp(sessiondb.patientcode,uniqupat(p));
    % find most common electrode
    logidxuse = logidxoverall & logidx_pat;
    newdb = sessiondb(logidxuse,:);
    
    [uniqueXX, ~, J]=unique(newdb.stn_electrodes);
    occ = histc(J, 1:numel(uniqueXX));
    [~,idxmax] = max(occ);
    logidxmostcomelectrode = strcmp(sessiondb.stn_electrodes,uniqueXX(idxmax)) ;
    % find visits
    unqvisits = unique(sessiondb.visitCategory);
    for v = 2:length(unqvisits)
        hfig = figure('Position',[811         312        1323         961]);
        logidxunqvisit = strcmp(sessiondb.visitCategory,unqvisits{v});
        logidxuse = logidxoverall & logidx_pat  & logidxunqvisit ;%& logidxmostcomelectrode;
        newdb = sessiondb(logidxuse,:);
        % find unq medications
        [unqmeds,idxfound] = unique(newdb.Medication);
%         if length(unqmeds)~=2
%             break;
%         end
        subplot(3,3,p);
        legendttl = {};
        cntleg = 1; 
        for i = idxfound'
            start = tic;
            data = importdata(newdb.datafullpath{i});
            data = data(:,1);
            params.sr = newdb.sr(i);
            data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
            data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
            [~, hplot] = plot_data_freq_domain(data_tr_prp,params,'placeholder'); hold on;
            hplots(cntleg) = hplot;
            hlegttl{cntleg} = strrep(newdb.Medication{i},'_',' ');
            cntleg = cntleg + 1; 
            for c = 1:length(unqmeds)
                if strcmp(unqmeds{c},newdb.Medication{i});
                    hplot.Color = [colorspat(c,:) 0.7];
                    legendttl{c} = newdb.Medication{i};
                end
            end
            
            fprintf('patient %s visit %s session %d in %f\n',...
                newdb.patientcode{i},...
                newdb.visitCategory{i},...
                newdb.sessionSerialNum(i),...
                toc(start));
        end
        ylim([-9 -2]);
        title(strrep(uniqupat{p},'_',' '));
        [legstrs, idxsleg] = unique(hlegttl);
        hleg= legend(hplots(idxsleg),legstrs,'FontSize',14,'FontWeight','bold');
        clear hplots legstrs idxsleg hlegttl
        %% fix fig title
        figtitle = 'STM All Patients, Rest, Meds -On vs Off, Stim - Off';
        figname = 'STN_All_Patients_subplots_Meds-OnvsOff_Stim-Off_by_task_most_freq_elec';
        figname = sprintf('STN_p-%s_v-%s_e-%s_meds_on_vs_off',...
                newdb.patientcode{i},...
                newdb.visitCategory{i},...
                newdb.stn_electrodes{i});
        hfig.PaperPositionMode = 'auto' ;
        newfigdir = fullfile(figdir,'gifs_stn'); 
        mkdir(newfigdir);
        save_figure(hfig,figname,newfigdir,'jpeg');
        
    end
end
%}
%%;

%% compute and save power database
%{
logidxoverall = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.ConditionTask,'rest') & ...
    ~strcmp(sessiondb.visitCategory,'000000') & ...
    logical(strcmp(sessiondb.StimOn,'off') |  strcmp(sessiondb.StimOn,'on') ) & ...
    logical(strcmp(sessiondb.Medication,'off') |  strcmp(sessiondb.Medication,'on') ) & ...
    sessiondb.sr == 800;
newdb = sessiondb(logidxoverall,:);
for s = 1:size(sessiondb)
    if logidxoverall(s)
        % import data
        data = importdata(sessiondb.datafullpath{s});
        datam1 = data(:,3);
        datastn = data(:,1);
        % m1
        if ~isempty(datam1)
            params.sr = sessiondb.sr(s);
            data_tr = preproc_trim_data(datam1,params.msec2trim,params.sr);
            data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
            
            NFFT = 512;
            segLength = 1024;
            [fftOut,f] = pwelch(data_tr_prp,ones(segLength,1),0,NFFT,params.sr,'psd');
            f = f(f<params.noisefloor);  % frequncies
            fftOut = log10(fftOut(f<params.noisefloor));
            powerdat(s).m1_welch_powr = fftOut;
            powerdat(s).m1_welch_freq = f;
        end
        % stn
        if ~isempty(datastn)
            start = tic;
            params.sr = sessiondb.sr(s);
            data_tr = preproc_trim_data(datastn,params.msec2trim,params.sr);
            data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
            
            NFFT = 512;
            segLength = 1024;
            [fftOut,f] = pwelch(data_tr_prp,ones(segLength,1),0,NFFT,params.sr,'psd');
            f = f(f<params.noisefloor);  % frequncies
            fftOut = log10(fftOut(f<params.noisefloor));
            powerdat(s).stn_welch_powr = fftOut;
            powerdat(s).stn_welch_freq = f;
            fprintf('patient %s visit %s session %d in %f\n',...
                sessiondb.patientcode{s},...
                sessiondb.visitCategory{s},...
                sessiondb.sessionSerialNum(s),...
                toc(start));

        end
    end
end
save(fullfile(resultsdir,'all_session_powerand_celldb.mat'),'outdb','sessiondb','symptomcat','powerdat');
%}
%%

return

end