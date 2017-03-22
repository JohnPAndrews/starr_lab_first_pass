function compare_psds_on_off_meds_relative_calculation()
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
resultsdir   = fullfile('..','results','mat_file_with_all_session_jsons');
figdir = fullfile('..','figures','showcasing_data_variability');
evalc('mkdir(figdir)');
newfigdir = fullfile(figdir,'on_off_meds_by_visit_by_elect');
mkdir(newfigdir);
fid = fopen(fullfile(newfigdir,'readme.txt'),'w+');
fprintf(fid,'func %s.m \n path:\n %s \n used to create these graphs',...
    'compare_psds_on_off_meds_relative_calculation',...
    pwd);

[settings, params] = get_settings_params();
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
%% set params.
% inclusion criteria
logidxoverall = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.ConditionTask,'rest') & ...
    ~strcmp(sessiondb.visitCategory,'000000') & ...
    logical(strcmp(sessiondb.StimOn,'off') |  strcmp(sessiondb.StimOn,'off') ) & ...
    logical(strcmp(sessiondb.Medication,'off') |  strcmp(sessiondb.Medication,'on') ) & ...
    sessiondb.sr == 800;

visits = unique(sessiondb.visitCategory);
visitsuse = visits([10    11     9     7     2     4     6     8     3     5]);
labelarea{1} = 'stn'; labelarea{2} = 'm1';
chanidx = [1 3];
labelarea = {'stn', 'm1'};
for cc = 1:length(chanidx) %
    uniqupat = unique(sessiondb.patientcode);
    %% XX 
%     uniqupat = uniqupat(2); 
    %% XX 
    for p = 1:length(uniqupat)
        logidx_pat =  strcmp(sessiondb.patientcode,uniqupat(p));
        hfig = figure('Position',[811         312        1323         961],'Visible','off');
        cntplt = 1;


        for v = 2:length(visitsuse) % loop on visits
            plotgraphs = 1; % default is plot graphs, find reasons not to below
            
            % add some initial conditions (set up top)
            logidxunqvisit = strcmp(sessiondb.visitCategory,visitsuse{v});
            logidxpatvisit = logidx_pat  & logidxunqvisit; 
            logwalkingAndOnMeds = strcmp(sessiondb.ConditionTask,'walking') & ...
                                  strcmp(sessiondb.StimOn,'off');
            logwalking = logidxpatvisit & logwalkingAndOnMeds; 
            logidxuse = logidxoverall & logidx_pat  & logidxunqvisit ;
            newdb = sessiondb(logidxuse,:);
            % find unq medications
            [unqmeds,idxfound] = unique(newdb.Medication);
            if isempty(newdb)
                plotgraphs = 0;
            end
            if length(unqmeds) < 2
                plotgraphs = 0;
            else
                % loop on off medications in database, and try to find electrodes
                % that match for on.
                % step 1, find unique elecrodes for off medications:
                logoff = strcmp(newdb.Medication,newdb.Medication(idxfound(1)));
                logon = strcmp(newdb.Medication,newdb.Medication(idxfound(2)));
                idxon = find(logon == 1);
                newdb.([labelarea{cc} '_electrodes'])(logoff,:)
                [offelecs, ~] = unique(newdb.([labelarea{cc} '_electrodes'])(logoff,:));
                for e = 1:length(offelecs)
                    elecstr = offelecs{e};
                    for xx = 1:length(idxon)
                        if strcmp(elecstr,newdb.([labelarea{cc} '_electrodes'])(idxon(xx)))
                            logcase = ...
                                (strcmp(newdb.Medication,'off') | strcmp(newdb.Medication,'on') ) & ...
                                strcmp(newdb.([labelarea{cc} '_electrodes']),elecstr);
                        end
                    end
                end
                newdb = newdb(logcase,:);
            end
            
            
            % find unq medications (need to run this again bcs
            % I recreatred newdb so idxfoudn doesn't fit anymore
            [unqmeds,idxfound] = unique(newdb.Medication);
            if length(unqmeds) < 2
                plotgraphs = 0;
            end
            %% XXX
            % find a walking file
            % find an ipad file
            
            %% plot figure - only do this if no rejects met
            if plotgraphs
                subplot(2,3,cntplt);
                cntplt = cntplt + 1;
                legendttl = {};
                cntleg = 1;
                colorspat = [1 0 0;0 1 0]; % set color for on / off meds 
                for i = 1:size(newdb,1)
                    start = tic;
                    data = importdata(newdb.datafullpath{i});
                    data = data(:,(chanidx(cc)));
                    params.sr = newdb.sr(i);
                    data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
                    data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
                    [~, hplot] = plot_data_freq_domain(data_tr_prp,params,'placeholder'); hold on;
                    hplots(cntleg) = hplot;
                    hlegttl{cntleg} = strrep(newdb.Medication{i},'_',' ');
                    for c = 1:length(unqmeds)
                        if strcmp(unqmeds{c},newdb.Medication{i})
                            hplot.Color = [colorspat(c,:) 0.7];
                            legendttl{cntleg} = sprintf('%s %d', newdb.Medication{i},i);
                        end
                    end
                    cntleg = cntleg + 1;
                    fprintf('patient %s visit %s session %d in %f\n',...
                        newdb.patientcode{i},...
                        newdb.visitCategory{i},...
                        newdb.sessionSerialNum(i),...
                        toc(start));
                end
                
                %% plot walking 
                % also plot walking on meds, off stim
                colorspat = [199,90,147;204,95,67]./255;
                walkdb = sessiondb(logwalking,:);
                logcase = strcmp(walkdb.([labelarea{cc} '_electrodes']),elecstr);
                walkdb = walkdb(logcase,:); % make sure use same electrode as above 
                if ~isempty(walkdb)
                    for i = 1:size(walkdb)
                        start = tic;
                    data = importdata(walkdb.datafullpath{i});
                    data = data(:,(chanidx(cc)));
                    params.sr = walkdb.sr(i);
                    data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
                    data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
                    [~, hplot] = plot_data_freq_domain(data_tr_prp,params,'placeholder'); hold on;
                    hplots(cntleg) = hplot;
                    hlegttl{cntleg} = strrep(walkdb.Medication{i},'_',' ');
                    for c = 1:length(unqmeds)
                        if strcmp(unqmeds{c},walkdb.Medication{i})
                            hplot.Color = [colorspat(c,:) 0.7];
                            legendttl{cntleg} = sprintf('Walk %s %d', walkdb.Medication{i},i);
                        end
                    end
                    cntleg = cntleg + 1;
                    fprintf('patient %s visit %s session %d in %f\n',...
                        walkdb.patientcode{i},...
                        walkdb.visitCategory{i},...
                        walkdb.sessionSerialNum(i),...
                        toc(start));
                    end
                end
                
                
                ylim([-9 -2]);
                [legstrs, idxsleg] = unique(hlegttl);
                hleg= legend(hplots,legendttl,'FontSize',14,'FontWeight','bold');
                clear hplots legstrs idxsleg hlegttl legendttl
                %% fix fig title
                figtitle = [labelarea{cc} ' All Patients, Rest, Meds -On vs Off, Stim - Off'];
                
                figline1 =  strrep(...
                    sprintf('%s-p-%s-v-%s',...
                    labelarea{cc},newdb.patientcode{i}, newdb.visitCategory{i}),...
                    '_','-');
                
                figline2 = strrep(...
                    sprintf('e-%s-meds-onVsoff',...
                    newdb.([labelarea{cc} '_electrodes']){i}),...
                    '_','-');
                
                
                figtitle = {figline1 ; figline2};
                title(figtitle);
                figname = sprintf('%s_p-%s_v-%s_meds_on_vs_off',...
                    labelarea{cc},...
                    newdb.patientcode{i},...
                    newdb.visitCategory{i});
                
            end
            
        end
        
        hfig.PaperPositionMode = 'auto' ;
        save_figure(hfig,figname,newfigdir,'jpeg');
        
    end
end