function plot_data_from_ipad_json_freq_domain(dirname)
% dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_03/v09_01_yer/s_012_tsk-ipad';
fnload = {'ipad_event_indices_from_json.mat',...
           'BRRAW*.mat',...
           'EEGRAW*.mat',...
           'ipad_allign_info*.mat'};
for f = 1:length(fnload)
    ff = findFilesBVQX(dirname,fnload{f});
    if isempty(ff{1})
        errmsg = sprintf('missing file %s',fnload{f});
        error(errmsg);
    else
        load(ff{1});
    end
end

%         'rest_ON',...% Rest epoch Beg Fixation point ON red dot
%         'rest_OFF',...% Rest epoch End Fixation point OFF red dot
%         'rest_error',...  % Rest epoch Error Fixation error by mvt
%         'prep_ON',...% Preparation epoch Beg ON Cue ON blue dot
%         'prep_OFF',...% Preparation epoch End Cue OFF blue dot
%         'prep_error',... % Preparation  epoch error by mvt
%         'target1_ON',... % Target1 ON
%         'touch1_OFF',...% Touch1 
%         'prep_error',...% Error_touch 
%         'target_appear',...% target appers (all targets)  
%         'target_touched'% target touched (all targets) 


idx2 = cellfun(@(x) strcmp(x,'target1_ON'),eventsTable.label);
idx1 = cellfun(@(x) strcmp(x,'touch1_OFF'),eventsTable.label);
% seqence - rest 0-5 secs 5-8prep - 8-12.5 move 
params.labelfind = {'rest_ON','prep_ON','touch1_OFF'} ; % labels to start on 
colorsuse        = {'r','g','b'};
params.colorsuse = colorsuse; 
params.timebefr  = ceil([4 0 0].* 794); % start time 
params.timeaftr  = ceil([5 1 1].*794); % end time 
areasuse = {'lfp','ecog'};
windowsize = 256;
params.windowsize = windowsize;
params.leglines = {'hold', 'prep','move'};

hfig = figure; 
for a = 1:length(areasuse)
    hsub = subplot(1,2,a);
    title(areasuse{a});
    hold on;
    for ll = 1:length(params.labelfind)
        idx = cellfun(@(x) strcmp(x,params.labelfind{ll}),eventsTable.label);
        idxbr = eventsTable.bridx(idx);
        idxbr = idxbr(~isnan(idxbr));
        for i = 1:length(idxbr)
            sampleidx = [idxbr(i) + params.timebefr(ll) : 1 : idxbr(i) + params.timeaftr(ll)];
            dat = brraw.(areasuse{a})(sampleidx);
            if sum(dat) ~= 0
                [fftOut,f]   = pwelch(dat,windowsize,windowsize/2,1:120,794,'psd');
                fftuse(i,:)  = log10(fftOut);
            end
        end
        if sum(dat) ~= 0
            res.(areasuse{a}).(params.labelfind{ll}) = fftuse;
            hsb = shadedErrorBar(f,fftuse,{@mean,@(x) std(x)./sqrt(size(x,1))} );
            hsb.mainLine.Color = colorsuse{ll};
            hsb.mainLine.LineWidth = 3;
            hsb.patch.FaceColor = colorsuse{ll};
            leglines(ll) = hsb.mainLine;
            legend(leglines,{'hold', 'prep','move'});

        else
            res.(areasuse{a}).(params.labelfind{ll}) = [];
        end
        hold on;
        clear fftOut;
    end
    ylabel('Power  (log_1_0\muV^2/Hz)');
    xlabel('Frequency (Hz)');
    xlim([5 120]);
    axis tight;
end
save(fullfile(dirname,'results_freq_domain_ipad_json.mat'),'res','params');
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [14 8];
hfig.PaperPosition = [0 0 14 8];
fnmsv = sprintf('ipad_spectrogram_freq_domain.jpeg');
print(hfig,fullfile(dirname,fnmsv),'-djpeg','-r200');
close(hfig);
return;
%%
params.sr = 794;
params.contouroff = [];
hfig = plot_data_time_domain_spectrogram(brraw.ecog,params,'m1');
hold on;
for ll = 1:length(params.labelfind)
    idx = cellfun(@(x) strcmp(x,params.labelfind{ll}),eventsTable.label);
    idxbr = eventsTable.bridx(idx);
    hl = line(([idxbr idxbr]./794)',repmat([0 100],length(idxbr),1)',...
        'LineWidth',4,...
        'Color',colorsuse{ll});
end
idx = cellfun(@(x) strcmp(x,'target_touched'),eventsTable.label);
idxbr = eventsTable.bridx(idx);
hl = line(([idxbr idxbr]./794)',repmat([0 100],length(idxbr),1)',...
    'LineWidth',2,...
    'Color','k');

idx2 = cellfun(@(x) strcmp(x,'target1_ON'),eventsTable.label);
idx1 = cellfun(@(x) strcmp(x,'touch1_OFF'),eventsTable.label);
% eventsTable.timestamp(idx1) - eventsTable.timestamp(idx2)
% figure;notBoxPlot( eventsTable.timestamp(idx1) - eventsTable.timestamp(idx2))
