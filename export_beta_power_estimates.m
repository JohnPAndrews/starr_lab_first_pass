function export_beta_power_estimates()
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
resultsdir   = fullfile('..','results','mat_file_with_all_session_jsons');
figdir = fullfile('..','figures','for_nicki');
evalc('mkdir(figdir)');

% stnfigStimOn = fullfile(figdir,'stn_stimOn'); mkdir(stnfigStimOn)
% stnfigStimOff = fullfile(figdir,'stn_stimOff');mkdir(stnfigStimOff)
% m1figStimOn = fullfile(figdir,'m1_stimOn'); mkdir(m1figStimOn)
% m1figStimOff = fullfile(figdir,'m1_stimOff');mkdir(m1figStimOff)

[settings, params] = get_settings_params();
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
%% set params.
% inclusion criteria
% patient run 
patstr = 'brpd_07';
figdir = fullfile(figdir,patstr);
mkdir(figdir);
logidxoverall = ...
    sessiondb.usevisit == 1 & ...
    ~strcmp(sessiondb.visitCategory,'000000') & ...
    logical(strcmp(sessiondb.StimOn,'on') |  strcmp(sessiondb.StimOn,'off') ) & ...
    logical(strcmp(sessiondb.patientcode,patstr)) &  ...
    sessiondb.sr == 800;
newdb = sessiondb(logidxoverall,:);
fprintf('%d stim off, %d stim on\n',...
    sum(logical(strcmp(newdb.StimOn,'on'))),...
    sum(logical(strcmp(newdb.StimOn,'off'))));

labelarea = {'stn','m1'};
chanidx = [1 3];
params.noisefloor = 400;
params.msec2trim = 10000;

for i = 1:size(newdb,1)
    for cc = 1:2
        ticOpen = tic;
        start = tic;
        data = importdata(newdb.datafullpath{i});
        data = data(:,(chanidx(cc)));
        params.sr = newdb.sr(i);
        data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
        data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
        %% data valiation:
        analyzesession = ~isempty(data_tr(~isnan(data_tr))); % check NaN's
        % length
        if length(data_tr)/params.sr < 20; analyzesession = 0; end;
        if analyzesession
            data_no_out = zscore(deleteoutliers(data_tr_prp,0.05));
            [smoothdata,filtwts ]= eegfilt(data_no_out',800,13, 30);
            
            hfig = figure('Visible','off'); 
            hfig.Position = [1000         650        1160         688]; 
            subplot(2,2,1); 
            plot_data_time_domain(smoothdata,params,...
                [],...
                'Time (sec)',...
                '\muV');
            title('\beta (13-30Hz) Time Domain'); 
            subplot(2,2,2); 
            params.noisefloor = 50; 
            params.lowcutoff = 5; 
            plot_data_freq_domain(data_tr,params,...
                []);
            title('\beta (13-30Hz) Freq Domain'); 
            subplot(2,2,3); 
            params.freqbands = [13 30];
            params.contouroff = 1; 
            plot_data_time_domain_spectrogram(data_tr,params,[]); 
            
            figname = sprintf('%0.3d_%s_p-%s_v-%s_stim-%s_cond-%s_serial-%d',...
                i,...
                labelarea{cc},...
                newdb.patientcode{i},...
                newdb.visitCategory{i},...
                newdb.StimOn{i},...
                newdb.ConditionTask{i},...
                newdb.sessionSerialNum(i));

            title('\beta (13-30Hz) Spectrogram');
            hsuptitle = suptitle(strrep(figname,'_',' '));
            hsuptitle.FontSize = 24;
            hsuptitle.FontWeight = 'bold';            
            
            
            datfn = fullfile(figdir,[figname '.mat']); 
            dbrow = newdb(i,:); 
            hfig.PaperPositionMode = 'auto';
            save(datfn, 'data','dbrow'); 
            save_figure(hfig,figname,figdir,'jpeg'); 
            save_figure(hfig,figname,figdir,'fig');
            close(hfig);
        end
    end
end

    

end