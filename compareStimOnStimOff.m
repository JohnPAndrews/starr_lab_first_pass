function compareStimOnStimOff()
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
    logical(strcmp(sessiondb.StimOn,'on') |  strcmp(sessiondb.StimOn,'off') ) & ...
    sessiondb.sr == 800;
newdb = sessiondb(logidxoverall,:);
fprintf('%d stim off, %d stim on\n',...
    sum(logical(strcmp(newdb.StimOn,'on'))),...
    sum(logical(strcmp(newdb.StimOn,'off'))));

labelarea = {'stn','m1'};
chanidx = [1 3];
params.noisefloor = 400;

% hfig = figure('visible','on','position',[170        -330        2264        1056]);
for cc = 1:2
    for i = 1:size(newdb,1)
        ticOpen = tic;
        start = tic;
        data = importdata(newdb.datafullpath{i});
        data = data(:,(chanidx(cc)));
        params.sr = newdb.sr(i);
        data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
        data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
        if ~isempty(data_tr_prp(~isnan(data_tr_prp)))
            data_no_out = zscore(deleteoutliers(data_tr_prp,0.05));
            topen = toc(ticOpen); ticPlot = tic;
            tplot = toc(ticPlot);
            NFFT = 512;
            segLength = 1024;
            
            [fftOut,freq] = pwelch(data_no_out,ones(segLength,1),0,NFFT,params.sr,'psd');
            
            idxfreqrange = freq < 170 & freq > 120;
            idxcontrol = freq < 110 & freq > 90;
            avgcontrol = mean(fftOut(idxcontrol));
            maxstim    = max(fftOut(idxfreqrange));
            ratioval = abs(maxstim /avgcontrol );
            hfig = figure;
            [~, hplot] = plot_data_freq_domain(data_no_out,params,'placeholder'); hold on;
            if ratioval > 5 % bcs negative numbers - so smaller is "bigger" or more power.
                %                 subplot(1,2,1);
                %                 [~, hplot] = plot_data_freq_domain(data_no_out,params,'placeholder'); hold on;
                savedir = eval([labelarea{cc} 'figStimOn']);                
%                 hplot.Color = [0 1 0 0.1];
            else
                %                 subplot(1,2,2);
                %                 [~, hplot] = plot_data_freq_domain(data_no_out,params,'placeholder'); hold on;
                savedir = eval([labelarea{cc} 'figStimOff']);
%                 hplot.Color = [1 0 1 0.1];
            end
            ydat = hplot.YData;
            minvals(i) = min(ydat);
            maxvals(i) = max(ydat);
            
            figline1 =  strrep(...
                sprintf('%s-p-%s-v-%s',...
                labelarea{cc},newdb.patientcode{i}, newdb.visitCategory{i}),...
                '_','-');
            
            figline2 = strrep(...
                sprintf('e-%s-Stim-%s',...
                newdb.([labelarea{cc} '_electrodes']){i},newdb.StimOn{i}),...
                '_','-');
            
            
            figtitle = {figline1 ; figline2};
            title(figtitle);
            figname = sprintf('%0.3d_%s_p-%s_v-%s_stim-%s_serial-%d',...
                i,...
                labelarea{cc},...
                newdb.patientcode{i},...
                newdb.visitCategory{i},...
                newdb.StimOn{i},...
                newdb.sessionSerialNum(i));
            hfig.PaperPositionMode = 'auto' ;
            ticSave = tic;
            save_figure(hfig,figname,savedir,'jpeg');
            tsave = toc(ticSave);
            totalTime = toc(ticOpen);
            fprintf('fig %s \t import data %.2f \t plot fig %.2f\t save fig %.2f\t total time %f\n',...
                figname, topen/totalTime, tplot/totalTime,tsave/totalTime, totalTime);
        end
    end
    %     subplot(1,2,1);
    %     title('stim on');
    %     set(gca,'YLim', [min(minvals) max(maxvals)]);
    %     subplot(1,2,2);
    %     title('stim off');
    %     set(gca,'YLim', [min(minvals) max(maxvals)]);
    %
    %     save_figure(hfig,...
    %         sprintf('%s_all_one_plot',labelarea{cc}),...
    %         figdir,'jpeg');
end
end