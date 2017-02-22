function compare_on_off_meds_3_week_visit_psd()
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
resultsdir   = fullfile('..','results','mat_file_with_all_session_jsons');
figdir = fullfile('..','figures','on-off-meds-psd-first-pass');
evalc('mkdir(figdir)');
[settings, params] = get_settings_params();
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
for p = 5%1:length(patients)
    for v = 1:length(visitsuse) % loop on visits
        visituse = visitsuse{v}; % loop on patients
        %% inclusion criteria
        rowsselect = ...
            sessiondb.usevisit == 1 & ...
            strcmp(sessiondb.patientcode,patients(p)) & ...
            strcmp(sessiondb.ConditionTask,'rest') & ...
            strcmp(sessiondb.visitCategory,visituse);
        newdb = sessiondb(rowsselect,:);
        [patientdb,~] = sortrows(newdb,{'patientcode','sessionSerialNum'},{'ascend','ascend'});
        if isempty(patientdb)
            break;
        end
        %% set figure title
        figname  = sprintf('on_off_meds_p-%s_v-%s_a-%s',...
            patients{p},...
            visituse,...
            labelarea{chanuse});
        figtitle = sprintf('on/off meds p - %s v- %s %s',...
            strrep(patients{p},'_',' '),...
            strrep(visituse,'_',' '),...
            labelarea{chanuse});
        lgndcnt = 1;
        legendttls = {};
        %% medication off
        rowsselect = strcmp(patientdb.Medication,'off');
        offmedsdb = patientdb(rowsselect,:);
        cgrad = linspace(0.5,1,size(offmedsdb,1)); % to set gradient of color
        for i = 1:size(offmedsdb,1)
            data = importdata(offmedsdb.datafullpath{i});
            data = data(:,chanuse);
            params.sr = offmedsdb.sr(i);
            data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
            data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
            legendttls{lgndcnt} = sprintf('sr=%d e=%s',offmedsdb.sr(i),offmedsdb.([labelarea{chanuse} '_electrodes']){i});
            if lgndcnt == 1
                [hfig, hplot] = plot_data_freq_domain(data_tr_prp,params,figtitle); hold on;
                hplot.Color = 'r';
            else
                [hfig, hplot] = plot_data_freq_domain(data_tr_prp,params,figtitle); hold on;
                hplot.Color = [cgrad(i) 0 0];
            end
            lgndcnt = lgndcnt + 1;
        end
        %% medication on
        rowsselect = strcmp(patientdb.Medication,'on');
        onmedsdb = patientdb(rowsselect,:);
        cgrad = linspace(0.5,1,size(onmedsdb,1)); % to set gradient of color
        for i = 1:size(onmedsdb,1)
            data = importdata(onmedsdb.datafullpath{i});
            data = data(:,chanuse);
            params.sr = onmedsdb.sr(i);
            data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
            data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
            legendttls{lgndcnt} = sprintf('sr=%d e=%s',onmedsdb.sr(i),onmedsdb.([labelarea{chanuse} '_electrodes']){i});
            lgndcnt = lgndcnt + 1;
            [hfig, hplot] = plot_data_freq_domain(data_tr_prp,params,figtitle); hold on;
            hplot.Color = [0 cgrad(i) 0];
        end
        legend(legendttls,'FontSize',14,'FontWeight','bold');
        hold off; 
        save_figure(hfig,figname,figdir,'jpeg');
        close all; 
    end
end


end