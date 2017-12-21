function tremorAnalysisBRPD10()
load(fullfile('..','data','database','predictors.mat')); 
load(fullfile('..','data','database','database1.mat')); 
predictors = struct2table(sout);
idx = strcmp(predictors.patient,'brpd10') & ...
        strcmp(predictors.task,'rest') & ...
        strcmp(predictors.visit,'3 week') ;
p10 = predictors(idx,:);
areas = {'lfp','ecog'};
measure = {'avg','max','avgnorm','maxnorm'};
freqs   = {'Delta', 'Theta', 'Alpha','Beta','LowBeta','HighBeta','LowGamma','HighGamma'};

clrs = [0.9 0 0; 0 0.9 0];
for a = 1:length(areas)
    hfig = figure('Position',[362         257        1435        1007]);
    for m = 1:length(measure)
        hax = subplot(2,2,m);
        hold on;
        title(sprintf('3 week %s %s',areas{a},measure{m}));
        
        for f = 1:length(freqs)
            fnm = sprintf('%s%s%s',areas{a},measure{m},freqs{f});
            y(f,1) = p10.(fnm)(1);
            y(f,2) = p10.(fnm)(2);
        end
        hbar = bar(y,'FaceColor','flat'); 
        
        for k = 1:size(y,2)
            hbar(k).CData = clrs(k,:);
        end
        ylim([-8 -4]);
        legend({'Off M','On M'});
        set(hax,'xticklabel',freqs)
        set(hax,'XTickLabelRotation',45)
        ylabel('Power  (log_1_0\muV^2/Hz)');
        set(hax,'FontSize',20)
    end
end
%% auc analysis 
idx = strcmp(predictors.patient,'brpd10') & ...
        (strcmp(predictors.task,'rest') | strcmp(predictors.task,'walking') | strcmp(predictors.task,'ipad')) & ...  
        ~strcmp(predictors.visit,'2 day');% & ...

p10 = predictors(idx,:);
AUClog = [];
clrs = [0.9 0 0; 0 0.9 0];
measure = {'avg'};
for a = 1:length(areas)
    hfig = figure('Position',[362         257        1435        1007]);
    for m = 1:length(measure)
        hax = subplot(1,1,m);
        hold on;
        title(sprintf('%s %s',areas{a},measure{m}));
        for f = 1:length(freqs)
            fnm = sprintf('%s%s%s',areas{a},measure{m},freqs{f});
            mdl = fitglm(p10.(fnm),p10.med,'Distribution','binomial','Link','logit');
            score_log = mdl.Fitted.Probability; % Probability estimates
            [Xlog,Ylog,Tlog,AUClog(f)] = perfcurve(logical(p10.med),score_log,'true');
        end
        if a == 1 
            lfpauc = AUClog;
        else
            ecogauc = AUClog;
        end
        hbar = bar(AUClog,'FaceColor','flat');
        set(hax,'xtick',1:8)
        set(hax,'xticklabel',freqs)
        set(hax,'XTickLabelRotation',45)
        ylabel('AUC');
        ylim([0.5 1]);
        set(hax,'FontSize',20)
    end
end
% 1 = rest off stim 
% 2 = rest on/off stim 
% 3 = rest walking ipad, on/off stim 
lfp1(3,:) = lfpauc;
ecog1(3,:) = AUClog;
figure;
bar(ecog1');
legend({'rest off stim','rest on/offstim','all conds on/off stim'});
idx = strcmp(resTabAll.patient,'brpd10') & ...
        (strcmp(resTabAll.task,'rest') | strcmp(resTabAll.task,'walking') | strcmp(resTabAll.task,'ipad')) & ...  
        ~strcmp(resTabAll.visit,'2 day');
areas = {'lfp','ecog'};
resp = resTabAll.med(idx);
lfp = cell2mat(resTabAll.psdlfp(idx));
ecog = cell2mat(resTabAll.psdecog(idx));
coher = cell2mat(resTabAll.cpherpower(idx));
AUClog  = [];
for f = 1:90
    %lfp 
    mdl = fitglm(lfp(:,f),resp,'Distribution','binomial','Link','logit');
    score_log = mdl.Fitted.Probability; % Probability estimates
    [Xlog,Ylog,Tlog,lfpauc(f)] = perfcurve(logical(resp),score_log,'true');
      %ecog 
    mdl = fitglm(ecog(:,f),resp,'Distribution','binomial','Link','logit');
    score_log = mdl.Fitted.Probability; % Probability estimates
    [Xlog,Ylog,Tlog,ecogauc(f)] = perfcurve(logical(resp),score_log,'true');
     % lfp + ecog 
    mdl = fitglm([lfp(:,f) ecog(:,f)],resp,'Distribution','binomial','Link','logit');
    score_log = mdl.Fitted.Probability; % Probability estimates
    [Xlog,Ylog,Tlog,both(f)] = perfcurve(logical(resp),score_log,'true');

end
hfig= figure;
line(1:90,lfpauc,'LineWidth',2,'Color','r');
hold on;
line(1:90,ecogauc,'LineWidth',2,'Color','b');
line(1:90,both,'LineWidth',2,'Color','g');
ylabel('AUC');
xlabel('Frequency (Hz)'); 
legend({'lfp','ecog','lfp+ecog'}); 
        set(gca,'FontSize',20)
title('AUC - logistic regression - PSD - on/off meds')
figdir = fullfile('..','figures','gpi_gpe');
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [15 8];
hfig.PaperPosition = [0 0 15 8];
print(hfig,fullfile(figdir,'AUC_analysis.pdf'),'-dpdf');


coher = cell2mat(resTabAll.cpherpower(idx));


%% beta burst 

load(fullfile('..','data','database','databaseRaw.mat')); 
idx = strcmp(datTabAll.patient,'brpd10') & ...
    ~strcmp(datTabAll.visit,'2 day') & ...
    strcmp(datTabAll.visit,'3 week') & ...
    strcmp(datTabAll.task,'rest') & ...
    ~datTabAll.stim & ...
    ~datTabAll.med;


        (strcmp(datTabAll.task,'rest') | strcmp(datTabAll.task,'walking') | strcmp(datTabAll.task,'ipad'));
idxuse = find(idx == 1);
bpfreqs = [13 20; 22 30];% + 40;
bpfreqs = [15-2 15+2; 25-2 25+2];% + 40;


% cross correlation


freq = 1:2:100; 
ampsig = [];
for f = 1:length(freq) - 1
    bp = designfilt('bandpassiir','FilterOrder',4, ...
        'HalfPowerFrequency1',freq(f),'HalfPowerFrequency2',freq(f)+2, ...
        'SampleRate',794);
    filtdat = filtfilt(bp,dat);
    ampsig(f,:) = abs(hilbert(filtdat)); 
end
ampsigabs = abs(ampsig) - mean(ampsig,2);
D = pdist(ampsigabs,'mahalanobis');
figure;
imagesc(squareform(D)); 
        
hfig = figure;
threshuse = 0.75;
burstdiv = [0.1 0.2; 0.2 0.3; 0.3 0.4; 0.4 0.5; 0.5 0.6;0.6 0.7; 0.7 0.8; 0.9 2];
burstbar = []; threshes = []; ratios = []; respons = []; patchd = []; 
for i = 1:length(idxuse)
    areas = {'lfp','ecog'};
    patchd = [];
    for a = 1%:length(areas) % XXXX 
        hax = subplot(1,2,a); 
        hold on;
        dat = datTabAll.(areas{a}){idxuse(i)};
        cleanidx = datTabAll.idxclean(idxuse(i),:);
        dat = dat(cleanidx(1):cleanidx(2));
        secs = (1:length(dat) ) ./ 794;
        resp = datTabAll.med(idxuse(i));
        
        bp = designfilt('bandpassiir','FilterOrder',4, ...
            'HalfPowerFrequency1',bpfreqs(a,1),'HalfPowerFrequency2',bpfreqs(a,2), ...
            'SampleRate',794);
        betafilt = filtfilt(bp,dat);
        [up, low] = envelope(betafilt,120,'analytic'); % analytic rms
        thresh = prctile(up,round(threshuse*100));
        threshes(i,a) = thresh;
        startidx = find(diff(up > thresh) == 1) + 1;
        endidx = find(diff(up > thresh) == -1) + 1;
        endidx = endidx(endidx > startidx(1));
        startidx = startidx(1:length(endidx));
        bursts = struct(); 
        for b = 1:size(startidx,1)
            bursts.len(b) = secs(endidx(b)) - secs(startidx(b));
            bursts.amp(b) = max(up(startidx(b):endidx(b)));
            patchd(b).x      = secs(startidx(b):endidx(b));
            patchd(b).y      = up(startidx(b):endidx(b));

        end
        comp = bursts.len .* bursts.amp;
        med  = median(bursts.len);
        ratios(i,a) = sum(comp(bursts.len > med)) /  sum(comp(bursts.len < med));
        respons(i) = resp; 
        for bb = 1:size(burstdiv)
            idx = bursts.len > burstdiv(bb,1) & bursts.len < burstdiv(bb,2);
            burstbar(i,bb,a) = sum(idx) / length(idx);
        end
        % bin burst on len 
        if logical(resp) 
            scatter(bursts.len,bursts.amp,50,[0 0.9 0 ],'filled','o','MarkerFaceAlpha',0.6); 
        else
            scatter(bursts.len,bursts.amp,50,[0.9 0 0 ],'filled','o','MarkerFaceAlpha',0.6);
        end
        xlabel('length (seconds)');
        ylabel('amplitude'); 
        title(areas{a});
        legend({'Off med','On med'});
        set(hax,'FontSize',20)
    end
end
figdir = fullfile('..','figures','gpi_gpe');
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [20 8];
hfig.PaperPosition = [0 0 20 8];
print(hfig,fullfile(figdir,'beta_burst_all_rest-0.75.pdf'),'-dpdf');

%% algorithem demo
% plot the start and end idxs on beta plot 
hfig = figure;
hax1 = subplot(3,2,[1 2]); 
plot(secs,dat); 
title('Raw unfiltered data'); 
xlabel('time');
ylabel('power');
xlim([10 30]);

hax2 = subplot(3,2,[3 4]); 
plot(secs,betafilt,'LineWidth',0.5,'Color',[0 0 0.9 0.4]); 
hold on; 
plot(secs,up,'LineWidth',2,'Color','r'); 
for b = 1:length(patchd)
    p = patch(patchd(b).x,patchd(b).y,'green','Parent',hax2);
    p.FaceColor = [0 0.9 0]; 
    p.FaceAlpha = 0.5; 
    p.EdgeColor = 'none';
end
line([min(secs) max(secs)],[ thresh thresh],...
    'LineWidth',3,'Color',[0.5 0.5 0.5],...
    'LineStyle','-.');
xlabel('time');
ylabel('power');
xlim([10 30]);

hax3 = subplot(3,2,5); 
hold on; 
handles.freqranges = [15-2 15+2];
cuse = parula(size(handles.freqranges,1));
ydat = [10 10 -10 -10];
handles.axesclr = hax3;
for p = 1:size(handles.freqranges,1)
    freq = handles.freqranges(p,:);
    xdat = [freq(1) freq(2) freq(2) freq(1)];
    handles.hPatches(p) = patch('XData',xdat,'YData',ydat,'YLimInclude','off');
    handles.hPatches(p).Parent = hax3;
    handles.hPatches(p).FaceColor = cuse(p,:);
    handles.hPatches(p).FaceAlpha = 0.3;
    handles.hPatches(p).EdgeColor = 'none';
    handles.hPatches(p).Visible = 'on';
end
[psd,freqs] = pwelch(dat,800,800/2,1:100,800,'psd');
psd = log10(psd);
plot(freqs,psd,'LineWidth',3);
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
title('Freq Domain data');
ylim([ -7.9263   -5.6229]);

hax3 = subplot(3,2,6); 
scatter(bursts.len,bursts.amp,50,[0.9 0 0 ],'filled','o','MarkerFaceAlpha',0.6);
xlabel('length (seconds)');
ylabel('amplitude');
title(areas{a});

figdir = fullfile('..','figures','gpi_gpe');
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [10 15];
hfig.PaperPosition = [0 0 10 15];
print(hfig,fullfile(figdir,'beta_burst_selection_demo.pdf'),'-dpdf');

% 


% thresholds on / off meds 
figure;
subplot(1,2,1);
boxplot(threshes(:,1),respons);
title('threshold on/off meds LFP'); 
set(gca,'XTickLabel',{'Off LD','On LD'});
subplot(1,2,2);
boxplot(threshes(:,2),respons);
title('threshold on/off meds M1'); 
set(gca,'XTickLabel',{'Off LD','On LD'});
    
    
% compute stats 
pvals = [];
for a = 1:2
    for f = 1:size(burstbar,2)
        x = burstbar(logical(respons),f,a); 
        y = burstbar(~logical(respons),f,a);      
        [~,pvals(f,a)] = ttest2(x,y);
    end
end
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(pvals,0.05,'dep','no');
hvals = adj_p <= 0.05;

% draw burst percentages 
hfig = figure; 
brs = []; SEM = [];
for a = 1:length(areas)
    % on med 
    brs(1,:) = mean(burstbar(logical(respons),:,a),1);
    SEM(1,:) = std(burstbar(logical(respons),:,a),1)/sqrt(sum(respons)); 
    % off med 
    brs(2,:) = mean(burstbar(logical(~respons),:,a),1);
    SEM(2,:) = std(burstbar(logical(~respons),:,a),1)/sqrt(sum(~respons)); 
    
    % plot 
    hax = subplot(1,2,a);
    hbrs= barwitherr(SEM',brs');
    hold on;
    % plot significance 
    idxh = find(hvals(:,a) == 1);
    
    for h = 1:length(idxh)
        yheight = max([brs(1,idxh(h)) brs(2,idxh(h))]);
        scatter(idxh(h),yheight*1.2,100,'r','*');
    end
    hold on;
    legend({'ON LD','OFF LD'});
    ylabel('% Amount of bursts');
    xlabel('Time Windows (s)'); 
    set(hax,'xticklabel',{'0.1-0.2','0.2-0.3','0.3-0.4','0.4-0.5','0.5-0.6','0.6-0.7','0.7-0.8','>0.9'})
%     set(hax,'XTickLabelRotation',45) 
    ttluse = sprintf('%s on-%d off-M%d',areas{a},sum(datTabAll.med(idxuse)),sum(~datTabAll.med(idxuse)));
    title(ttluse);
    set(hax,'FontSize',20)
end
figdir = fullfile('..','figures','gpi_gpe');
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [25 8];
hfig.PaperPosition = [0 0 25 8];
print(hfig,fullfile(figdir,'beta_burst_bar_graph_rest_all_visit_no_stim.pdf'),'-dpdf');





figure;
legend({'Off M','On M'});


figure;
hax = subplot(1,2,1); 
boxplot(ratios(:,1),respons);
set(hax,'xtick',1:2)
set(hax,'xticklabel',{'Off med', 'On med'})
ylabel('Burst ratio (AU)');
title('LFP burst ratios'); 

hax = subplot(1,2,2); 
boxplot(ratios(:,2),respons);
set(hax,'xtick',1:2)
set(hax,'xticklabel',{'Off med', 'On med'})
ylabel('Burst ratio (AU)');
title('M1 burst ratios'); 


end