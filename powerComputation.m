function powerComputation()

% For 8 subjects, and a treatment effect size of yy
% (difference in pallidal beta band power for dbs off versus on), 
% the study will have a xx% power to detect a treatment effect 
% at the first DBS activation time point. 
% If one subject drops out, power drops to yy% (alpha=.10).

% suggest modifing this to a third time point where DBS is ramped up to 
% thereputic levles, at first time point dbs is low. 

%% Methods to compute power and effect size: 

%% 1. 
addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/notBoxPlot'));
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/measures-of-effect-size-toolbox';
addpath(genpath(dirname));
load /Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/database/predictors.mat
prdicts = struct2table(sout);
idxtask  = cellfun(@(x) strcmp(x,'rest'),prdicts.task) | ...
    cellfun(@(x) strcmp(x,'ipad'),prdicts.task) | ...
    cellfun(@(x) strcmp(x,'walking'),prdicts.task); 
patidx    = cellfun(@(x) strcmp(x,'brpd10'),prdicts.patient);
idxstim   = ~prdicts.stim;
idxvist   = ~cellfun(@(x) strcmp(x,'2 day'),prdicts.patient);
idxuse = idxtask & patidx &idxstim & idxvist;
medstat = prdicts.med(idxuse);
data = prdicts.lfpavgBeta(idxuse);
%% plot data 
hfig = figure;
hsb = subplot(1,2,1);
hnb = notBoxPlot(data,medstat);
title('Average Beta On/Off med off stim');
ylabel('Avg Beta');
hsb.XTickLabel = {'Off M', 'On M'};
set(hsb,'FontSize',14)

std1 = std(data(logical(medstat)));
std2 = std(data(~logical(medstat)));


onM = mean(data(logical(medstat)));
offM = mean(data(~logical(medstat)));
stduse = mean([std1 std2]);
hdgg = mes( data(~logical(medstat)), data(logical(medstat)),'hedgesg');
nn = 1:20;
pwrout = sampsizepwr('t',[offM stduse],onM,[],nn,'alpha',0.01);

hsub = subplot(1,2,2);

plot(nn,pwrout,'b-','LineWidth',3)
ttluse = sprintf('Power versus Sample Size (effect size = %.3f)',hdgg.hedgesg);
title(ttluse)
xlabel('Sample Size')
ylabel('Power')
set(hsub,'FontSize',14)

plotwidth = 20; 
plotheight = 10; 
hfig.PaperPositionMode = 'manual';
hfig.PaperUnits        = 'inches';
hfig.PaperSize         = [plotwidth plotheight];
hfig.PaperPosition     = [0 0 plotwidth plotheight];
figdir = '/Users/roee/Starr_Lab_Folder/Grants/RO1_renewal /Figures';
print(hfig,fullfile(figdir,'effect_size.pdf'),'-dpdf');
close(hfig);
