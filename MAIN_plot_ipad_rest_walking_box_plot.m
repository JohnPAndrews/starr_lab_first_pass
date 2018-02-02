function MAIN_plot_ipad_rest_walking_box_plot()
resdir = fullfile('..','results','ipad_from_json_results');
load(fullfile(resdir,sprintf('%s.mat','brpd_05')),'results');
addpath(genpath(fullfile(pwd,'toolboxes','notBoxPlot')));
%% box plots 
% med effect 
% stim effect 
handles.freqranges = [1 4; 4 8; 8 13; 13 30;13 20; 20 30; 30 50; 50 90];
handles.freqnames  = {'Delta', 'Theta', 'Alpha','Beta','LowBeta','HighBeta','LowGamma','HighGamma'}';
medstates = {'off','on','off'};
stmstates = {'off','off','on'}; 
conds     = {'rest','walking','hold','prep','move'}; 
hfig = figure;
cnt = 1; 
for h = 1:size(handles.freqranges,1)
    for ms = 1:3
            hsub = subplot(8,3,cnt); cnt = cnt + 1;
            hold on;
            idxuse = cellfun(@(x) strcmp(x,medstates{ms}),results.med) & ...
                cellfun(@(x) strcmp(x,stmstates{ms}),results.stim);
            f = results.freqs(1,:);
            idxfreq = f > handles.freqranges(h,1) &  f <= handles.freqranges(h,2);
            for c = 1:length(conds)
                y = mean(results.(conds{c})(idxuse,idxfreq),2); % average freq
                notBoxPlot(y,c);
            end
            title(sprintf('%s med - %s stim %s',handles.freqnames{h}, medstates{ms},stmstates{ms}));
            hsub.XTick = 1:length(conds);
            hsub.XTickLabel = conds; 
            hsub.XTickLabelRotation = 45;
    end
end

%% shaded error bars 
hsb = shadedErrorBar(f,fftuse,{@mean,@(x) std(x)./sqrt(size(x,1))} );
hsb.mainLine.Color = params.colorsuse{ll};
hsb.mainLine.LineWidth = 1;
hsb.patch.FaceColor = params.colorsuse{ll};

% plot shaded error bars 
% med on / off before 1 month 

% stim on / off after 1 month 
end