function computeOnOffStimEffects()
% brpd 03 
% electrodes 0-3 9-10 
% nothing good from STN - a ton of artifacts 
% 16Hz, ecog, 11-40 range 
% not much at LFP 

% brpd 05 
% electrodes 03 - 9-11 
% nothing good from STN 
% movement beta 
% 1 year 
% 28hz ecog, 20-35 range 
% 25hz lfp,  16-36 range  

% brpd 06 - 1-2+ 10-11 stim - so no usable data on stim from STN 

% brpd 07 - 1-3 9-11

% brpd 09 - 0-2 9-10 

% brpd 10 - 1-3 9-11 

% M1 plots: 
% database = 
load /Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/database/predictors.mat
load /Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/database/database1.mat

%% 1. raw freqency plots
%{
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/figures/on_off_stim/raw_by_task';
visitorder = {'2 month','3 month','6 month','1 year', '2 year'}; 
patuse     = {'brpd03','brpd05','brpd06','brpd07','brpd09'}; 
elecs      = {'+E9-E10','+E9-E11','+E10-E11','+E9-E11','+E9-E10'};
taskuse    = {'rest'};%,'walking','ipad'}; 
colrorder  = [0.9 0 1 0.7; 0.9 0.2 0.5 0.7; 0.9 0.5 0 0.7];
cnt = 1; 
idxmed = ~resTabAll.med;
hrows = length(visitorder);
hcol  = length(taskuse);
for p = 1:length(patuse)
    hfig = figure();
    cnt = 1; 
    idxpat = cellfun(@(x) strcmp(x,patuse{p}),resTabAll.patient);
    idxelc = cellfun(@(x) strcmp(x,elecs{p}),resTabAll.ecog_elec);
    for v = 1:length(visitorder)
        idxvis = cellfun(@(x) strcmp(x,visitorder{v}),resTabAll.visit);
        for t = 1:length(taskuse)
            hsub = subplot(hrows,hcol,cnt); cnt = cnt + 1; 
            plotFreqPatches(hsub);
            hold on; 
            idxtask = cellfun(@(x) strcmp(x,taskuse{t}),resTabAll.task);
            idxstim = resTabAll.stim;
            idxuse = idxpat & idxvis & idxtask & idxelc & idxstim;
            dbuse = resTabAll(idxuse,:);
            dbsort = sortrows(dbuse,'sessionum');
            for s = 1:size(dbsort)
                if s > 2 
                    break; 
                end
                hp(s) = plot(dbsort.psdecogF{s},log10(dbsort.psdecog{s})); 
                if dbsort.stim(s)
                    stims = 'on stim';
                    hp(s).LineStyle = '-.';
                else
                    stims = 'off stim';
                end
                switch s 
                    case 1 
                        pfx = 'pre';
                    case 2 
                        pfx = 'mid';
                    case 3 
                        pfx = 'post';
                    otherwise
                        pfx = ' '; 
                end
                ttls{s} = sprintf('%d %s %s',s,pfx,stims);
                if s>3 
                    hp(s).Color = colrorder(3,:);
                else
                    hp(s).Color = colrorder(s,:);
                end
                hp(s).LineWidth = 2.5; 
            end
            if ~isempty(dbsort)
            hlg = legend(hp,ttls);
            hlg.FontSize = 8;
            axis tight 
            xlim([0 50]); 
            ttluse = sprintf('%s %s %s %s',patuse{p}, visitorder{v},taskuse{t},elecs{p});
            title(ttluse);
            xlabel('Frequency (Hz)');
            ylabel('Power');
            clear hp ttls 
            end
        end
    end
    hfig.PaperPositionMode = 'manual';
    hfig.PaperSize = [11 14];
    hfig.PaperPosition = [0 0 11 14];
    print(hfig,fullfile(figdir,['05_rest-pr-po-stim' patuse{p} '.jpeg']),'-djpeg','-r200');
    close(hfig);
end
% 6 visit by 3 conditions for each visit (marking pre and post) 
%}
%% 2. show progression over time 
%{
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/figures/on_off_stim/raw_by_task';
visitorder = {'1 month','2 month','3 month','6 month','1 year', '2 year'}; 
patuse     = {'brpd03','brpd05','brpd06','brpd07','brpd09'}; 
elecs      = {'+E9-E10','+E9-E11','+E10-E11','+E9-E11','+E9-E10'};
taskuse    = {'rest'};%,'walking','ipad'}; 
colrorder  = [gray(length(visitorder)) repmat(0.6,length(visitorder),1)];
cnt = 1; 
idxmed = ~resTabAll.med;
hrows = 2;%length(visitorder);
hcol  = 3;%length(taskuse);
hfig = figure();
cnt = 1;
for p = 1:length(patuse)
    idxpat = cellfun(@(x) strcmp(x,patuse{p}),resTabAll.patient);
    idxelc = cellfun(@(x) strcmp(x,elecs{p}),resTabAll.ecog_elec);
    hsub = subplot(hrows,hcol,cnt); cnt = cnt + 1; 
    plotFreqPatches(hsub);
    cntgrp =1;
    for v = 1:length(visitorder)
        idxvis = cellfun(@(x) strcmp(x,visitorder{v}),resTabAll.visit);
        for t = 1:length(taskuse)
            hold on; 
            idxtask = cellfun(@(x) strcmp(x,taskuse{t}),resTabAll.task);
            idxstim = resTabAll.stim;
            idxmed  = ~resTabAll.med;
            idxuse = idxpat & idxvis & idxtask & idxelc & idxstim & idxmed;
            dbuse = resTabAll(idxuse,:);
            dbsort = sortrows(dbuse,'sessionum');
            for s = 1:size(dbsort)
                if s > 1 
                    break; 
                end
                hp(cntgrp) = plot(dbsort.psdecogF{s},log10(dbsort.psdecog{s})); 
                if dbsort.stim(s)
                    stims = 'on stim';
                    hp(cntgrp).LineStyle = '-.';
                else
                    stims = 'off stim';
                end
                
                ttls{cntgrp} = sprintf('%d %s %s',v,visitorder{v},stims);
                hp(cntgrp).Color = colrorder(v,:);
                hp(cntgrp).LineWidth = 2.5; 
                cntgrp = cntgrp + 1;
            end
        end
    end
    hlg = legend(hp,ttls);
    hlg.FontSize = 8;
    axis tight
    xlim([0 50]);
    ttluse = sprintf('%s %s %s %s',patuse{p}, visitorder{v},taskuse{t},elecs{p});
    title(ttluse);
    xlabel('Frequency (Hz)');
    ylabel('Power');
    clear hp ttls dbsort 
end
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [18 14];
hfig.PaperPosition = [0 0 18 14];
print(hfig,fullfile(figdir,['077_all_sub_over_time' patuse{p} '.jpeg']),'-djpeg','-r200');
close(hfig);
%}
%% 3. subtractions 
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/figures/on_off_stim/raw_by_task';
visitorder = {'1 month','2 month','3 month','6 month','1 year', '2 year'}; 
visitorder = {'1 month','6 month','1 year'}; 
patuse     = {'brpd03','brpd05','brpd06','brpd07','brpd09'}; 
elecs      = {'+E9-E10','+E9-E11','+E10-E11','+E9-E11','+E9-E10'};
taskuse    = {'rest'};%,'walking','ipad'}; 
colrorder  = [gray(length(visitorder)) repmat(0.6,length(visitorder),1)];
cnt = 1; 
idxmed = ~resTabAll.med;
hrows = 2;%length(visitorder);
hcol  = 3;%length(taskuse);
hfig = figure();
cnt = 1;
t = 1; 
for p = 1:length(patuse)
    idxpat = cellfun(@(x) strcmp(x,patuse{p}),resTabAll.patient);
    idxelc = cellfun(@(x) strcmp(x,elecs{p}),resTabAll.ecog_elec);
    hsub = subplot(hrows,hcol,cnt); cnt = cnt + 1; 
    hold on;
    plotFreqPatches(hsub);
    cntgrp =1;
    for v = 1:length(visitorder)
        idxvis = cellfun(@(x) strcmp(x,visitorder{v}),resTabAll.visit);
        idxtask = cellfun(@(x) strcmp(x,taskuse{t}),resTabAll.task);
        idxmed  = ~resTabAll.med;
        % no stim 
        idxstim = ~resTabAll.stim;
        idxuse = idxpat & idxvis & idxtask & idxelc & idxstim & idxmed;
        dbuse = resTabAll(idxuse,:);
        dbsort1 = sortrows(dbuse,'sessionum');
        % stim 
        idxstim = resTabAll.stim;
        idxuse = idxpat & idxvis & idxtask & idxelc & idxstim & idxmed;
        dbuse = resTabAll(idxuse,:);
        dbsort2 = sortrows(dbuse,'sessionum');
        if ~isempty(dbsort1) & ~isempty(dbsort2)
            subtrac = log10(dbsort1.psdecog{1}) - log10(dbsort2.psdecog{1});
            hp(cntgrp) = plot(dbsort1.psdecogF{1},subtrac);
            hp(cntgrp).Color = colrorder(v,:);
            hp(cntgrp).LineWidth = 2.5;
            ttls{cntgrp} = sprintf('%d %s',v,visitorder{v});
            cntgrp = cntgrp + 1;
        end
    end
    hlg = legend(hp,ttls);
    hlg.FontSize = 8;
    axis tight
    xlim([0 50]);
    ttluse = sprintf('%s %s %s %s',patuse{p}, visitorder{v},taskuse{t},elecs{p});
    title(ttluse);
    xlabel('Frequency (Hz)');
    ylabel('Power');
    clear  hp ttls dbsort* 
end
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [18 14];
hfig.PaperPosition = [0 0 18 14];
print(hfig,fullfile(figdir,['08_subtractions' patuse{p} '.jpeg']),'-djpeg','-r200');
close(hfig);

%% 2. shaded error bars freq plots 

%% 3. notbox plot average bins, max bins, norm bins 
%{
addpath(genpath(fullfile('toolboxes/notBoxPlot/')));
resTabAll = struct2table(sout);
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/figures/on_off_stim/raw_by_task';
visitorder = {'1 month','2 month','3 month','6 month','1 year', '2 year'}; 
visitorder = {'1 month','6 month','1 year'}; 
patuse     = {'brpd03','brpd05','brpd06','brpd07','brpd09'}; 
elecs      = {'+E9-E10','+E9-E11','+E10-E11','+E9-E11','+E9-E10'};
taskuse    = {'rest'};%,'walking','ipad'}; 
colrorder  = [gray(length(visitorder)) repmat(0.6,length(visitorder),1)];
cnt = 1; 
idxmed = ~resTabAll.med;
hrows = 2;%length(visitorder);
hcol  = 3;%length(taskuse);
hfig = figure();
cnt = 1;
t = 1; 
stimc = [0.9 0 0; 0 0.8 0];
for p = 1:length(patuse)
    idxpat = cellfun(@(x) strcmp(x,patuse{p}),resTabAll.patient);
    idxelc = cellfun(@(x) strcmp(x,elecs{p}),resTabAll.ecog_elec);
    idxtask = cellfun(@(x) strcmp(x,taskuse{t}),resTabAll.task);
    idxmed  = ~resTabAll.med;
    idxvisit1 = ~cellfun(@(x) strcmp(x,'2 day'),resTabAll.visit);
    idxvisit2 = ~cellfun(@(x) strcmp(x,'3 week'),resTabAll.visit);
    idxvisit3 = ~cellfun(@(x) strcmp(x,'10 day'),resTabAll.visit);
    idxuse = idxpat & idxelc & idxtask & idxvisit1 & idxvisit2 & idxvisit3 & idxmed;
    db = resTabAll(idxuse,:);
    [ux,idx,idxx] = unique(db.visit)
%     tbluse = db.ecogavgBeta','visit'});
    figure;notBoxPlot(db.ecogavgBeta,idxx);
    for s = 1:2
        if s == 1 % stim on 
            idxuse = db.stim; 
            
        else
        end
    end
end
    
    hsub = subplot(hrows,hcol,cnt); cnt = cnt + 1; 
    hold on;
    plotFreqPatches(hsub);
    cntgrp =1;
    for v = 1:length(visitorder)
        idxvis = cellfun(@(x) strcmp(x,visitorder{v}),resTabAll.visit);
        idxtask = cellfun(@(x) strcmp(x,taskuse{t}),resTabAll.task);
        idxmed  = ~resTabAll.med;
        % no stim 
        idxstim = ~resTabAll.stim;
        idxuse = idxpat & idxvis & idxtask & idxelc & idxstim & idxmed;
        dbuse = resTabAll(idxuse,:);
        dbsort1 = sortrows(dbuse,'sessionum');
        % stim 
        idxstim = resTabAll.stim;
        idxuse = idxpat & idxvis & idxtask & idxelc & idxstim & idxmed;
        dbuse = resTabAll(idxuse,:);
        dbsort2 = sortrows(dbuse,'sessionum');
        if ~isempty(dbsort1) & ~isempty(dbsort2)
            subtrac = log10(dbsort1.psdecog{1}) - log10(dbsort2.psdecog{1});
            hp(cntgrp) = plot(dbsort1.psdecogF{1},subtrac);
            hp(cntgrp).Color = colrorder(v,:);
            hp(cntgrp).LineWidth = 2.5;
            ttls{cntgrp} = sprintf('%d %s',v,visitorder{v});
            cntgrp = cntgrp + 1;
        end
    end
    hlg = legend(hp,ttls);
    hlg.FontSize = 8;
    axis tight
    xlim([0 50]);
    ttluse = sprintf('%s %s %s %s',patuse{p}, visitorder{v},taskuse{t},elecs{p});
    title(ttluse);
    xlabel('Frequency (Hz)');
    ylabel('Power');
    clear  hp ttls dbsort* 
end
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [18 14];
hfig.PaperPosition = [0 0 18 14];
print(hfig,fullfile(figdir,['08_subtractions' patuse{p} '.jpeg']),'-djpeg','-r200');
close(hfig);
%}

%% 5. scatter plots across time 
resTabAll = struct2table(sout);
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/figures/on_off_stim/raw_by_task';
visitorder = {'1 month','2 month','3 month','6 month','1 year', '2 year'}; 
patuse     = {'brpd03','brpd05','brpd06','brpd07','brpd09'}; 
elecs      = {'+E9-E10','+E9-E11','+E10-E11','+E9-E11','+E9-E10'};
taskuse    = {'rest'};%,'walking','ipad'}; 
measureuse = 'ecogmaxLowBeta';
colrorder  = [gray(length(visitorder)) repmat(0.6,length(visitorder),1)];
colrouse   = [0.9 0 1 ; 0 0.9 0 ; 0 0 0.9 ];

cnt = 1; 
idxmed = ~resTabAll.med;
hrows = 2;%length(visitorder);
hcol  = 3;%length(taskuse);
hfig = figure();
cnt = 1;
for p = 1:length(patuse)
    idxpat = cellfun(@(x) strcmp(x,patuse{p}),resTabAll.patient);
    idxelc = cellfun(@(x) strcmp(x,elecs{p}),resTabAll.ecog_elec);
    hsub = subplot(hrows,hcol,cnt); cnt = cnt + 1; 
    hold on;
%     plotFreqPatches(hsub);
    cntgrp =1;
    for v = 1:length(visitorder)
        idxvis = cellfun(@(x) strcmp(x,visitorder{v}),resTabAll.visit);
        for t = 1:length(taskuse)
            hold on; 
            idxtask = cellfun(@(x) strcmp(x,taskuse{t}),resTabAll.task);
            
            idxmed  = ~resTabAll.med;
            idxuse = idxpat & idxvis & idxtask & idxelc  & idxmed;
            dbuse = resTabAll(idxuse,:);
            dbsort = sortrows(dbuse,'sessionum');
            for s = 1:size(dbsort)
                
                hp(cntgrp) = scatter(v,dbsort.(measureuse)(s),300);
                if dbsort.stim(s)
                    stims = 'on stim';
                    hp(cntgrp).Marker = 'o';
                else
                    hp(cntgrp).Marker = 'd';
                    stims = 'off stim';
                end
                
                ttls{cntgrp} = sprintf('%d %s %s',v,visitorder{v},stims);
                hp(cntgrp).MarkerFaceColor = colrouse(s,:);
                hp(cntgrp).MarkerFaceAlpha = 0.7;
                cntgrp = cntgrp + 1;
            end
        end
    end
%     hlg = legend(hp,ttls);
%     hlg.FontSize = 8;
%     axis tight
%     xlim([0 50]);
    ttluse = sprintf('%s %s %s %s',patuse{p},taskuse{t},elecs{p}, measureuse);
    title(ttluse);
%     xlabel('Frequency (Hz)');
    ylabel(measureuse);
    clear hp ttls dbsort 
    hsub.XLim = [0 length(visitorder)+1];
    hsub.XTickLabel = [' ' visitorder ' '];
    hsub.XTickLabelRotation = 45;
end
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [18 14];
hfig.PaperPosition = [0 0 18 14];
print(hfig,fullfile(figdir,['11_all_sub_over_time_' measureuse  patuse{p} '.jpeg']),'-djpeg','-r200');
close(hfig);

%% 5. ipad data (average pre-on/off/on stim) 

%% 6. 



end

