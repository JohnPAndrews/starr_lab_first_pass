function doPreprocessingSaveData()
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
resultsdir   = fullfile('..','results','mat_file_with_all_session_jsons');
figdir = fullfile('..','figures','stimOnVsOffDataDriven');
evalc('mkdir(figdir)');

stnfigStimOn = fullfile(figdir,'stn_stimOn'); mkdir(stnfigStimOn)
stnfigStimOff = fullfile(figdir,'stn_stimOff');mkdir(stnfigStimOff)
m1figStimOn = fullfile(figdir,'m1_stimOn'); mkdir(m1figStimOn)
m1figStimOff = fullfile(figdir,'m1_stimOff');mkdir(m1figStimOff)

[settings, params] = get_settings_params();
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
%% set params.
% inclusion criteria
logidxoverall = ...
    sessiondb.usevisit == 1 & ...
    ~strcmp(sessiondb.visitCategory,'000000') & ...
    sessiondb.sr == 800;

%%
labelarea = {'stn','m1'};
chanidx = [1 3];
params.noisefloor = 400;

for s = 1:length(logidxoverall)
    if logidxoverall(s)
        for cc = 1:2
            ticOpen = tic;
            start = tic;
            dataraw = importdata(sessiondb.datafullpath{s});
            data = dataraw(:,(chanidx(cc)));
            params.sr = sessiondb.sr(s);
            data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
            data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
            %% data validation:
            analyzesession = ~isempty(data_tr_prp(~isnan(data_tr_prp))); % check NaN's
            % length
            if length(data_tr)/params.sr < 20; analyzesession = 0; end;
            % both STN and M1 data 
            if ~(logical(sum(dataraw(:,1))) && logical(sum(dataraw(:,3))))  
                analyzesession = 0; 
            end;
            %% data analysis 
            if analyzesession
                hold on;
                hfig = figure('Position',[5           1        1436         804]);
                cnt =1; 
                for i = 1:2
                    data = dataraw(:,chanidx(i));
                    params.sr = sessiondb.sr(s);
                    data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
                    data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
                    data_no_out = zscore(deleteoutliers(data_tr_prp,0.05));
                    subplot(2,2,cnt);  cnt = cnt + 1; 
                    plot_data_time_domain_spectrogram(data_no_out ,params,[])
                    title(labelarea{i});
                    subplot(2,2,cnt);  cnt = cnt + 1; 
                    plot_data_freq_domain(data_no_out ,params,[]);
                    title(labelarea{i});
                end
                sessionlen(s) = length(data_tr_prp)/params.sr; 
                fprintf('sesssion loaded in %f\n',toc(start)); 
                
            end
            
        end
    end
end
save('temp.mat');
figure; 
histogram(sessionlen); 