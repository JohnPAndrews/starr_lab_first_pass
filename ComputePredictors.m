function ComputePredictors(data,sr,varargin)
load /Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/database/database1.mat; 
rootDir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
datDir = fullfile('..','data','database');
idxuse = logical(cellfun(@(x) strcmp(x,'rest'),resTabAll.task) | cellfun(@(x) strcmp(x,'ipad'),resTabAll.task)  | cellfun(@(x) strcmp(x,'walking'),resTabAll.task) )& ... 
    ~logical(resTabAll.Exclude);
            
resTabAll = resTabAll(idxuse,:);    
cnt = 1; 
fnms1 = {'patient','sessionum', 'time' ...
    'duration','task','med' ,...
    'stim','sr','ecog_elec',...
    'lfp_elec'   };
for f = 1:length(fnms1)
    sout.(fnms1{f}) = [];
end
cnt = 1;
for i = 1:size(resTabAll,1)
    patdir = sprintf('brpd_%s',resTabAll.patient{i}(5:6));
    patdir = fullfile(rootDir, patdir);
    % find the raw data
    possstrings = {'OR day','2 day','10 day',...
        '3 week','1 month','2 month',...
        '3 month','6 month','1 year',...
        '2 year'};
    matcstr    =  { 'OR_day','predis','10_day',...
        '03_wek','01_mnt','02_mnt',...
        '03_mnt','06_mnt',...
        '01_yer','02_yer'};
    fdirs = findFilesBVQX(patdir,'*',struct('dirs',1,'depth',1));
    visitstr = matcstr(strcmp(resTabAll.visit{i},possstrings));
    idxvisit = cellfun(@(x) any(strfind(x,visitstr)),fdirs);
    visitdir = fdirs(idxvisit);
    ff = findFilesBVQX(visitdir,'dataBR.mat');
    try
        start = tic; 
        load(ff{1});
        idxsession = resTabAll.sessionum(i) == datTab.sessionum;
        dataSess = datTab(idxsession,:);
        for f = 1:length(fnms1)
            sout(cnt).(fnms1{f}) = dataSess.(fnms1{f});
        end
        sout(cnt).visit  = resTabAll.visit{i};
        sout(cnt).exclude  = resTabAll.Exclude(i);
        td = TimeDomainData(dataSess.lfp{:},dataSess.sr,dataSess.idxclean);
        s1 = td.getTable;
        fnms = fieldnames(s1);
        for f = 1:length(fnms)
            newfn = sprintf('lfp%s',fnms{f});
            sout(cnt).(newfn) = s1.(fnms{f});
        end
        td = TimeDomainData(dataSess.ecog{:},dataSess.sr,dataSess.idxclean);
        s2 = td.getTable;
        fnms = fieldnames(s2);
        for f = 1:length(fnms)
            newfn = sprintf('ecog%s',fnms{f});
            sout(cnt).(newfn) = s2.(fnms{f});
        end
        cnt = cnt + 1; 
        fprintf('%0.3d out of %0.3d in %f\n',...
            i,size(resTabAll,1),toc(start));
    end
end
save(fullfile(datDir,'predictors.mat'),'sout');
return;

p = inputParser;





p.CaseSensitive = false;

validationFcn = @(x) validateattributes(x,{'double'},{'nonempty'});
addParameter(p,'FreqBands',[1 4; 4 8; 8 13; 13 20; 20 30; 30 50; 50 90],validationFcn)
addParameter(p,'FreqNames',{'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','LowGamma','HighGamma'}',validationFcn)

addParameter(p,'PhaseFreq_BandWidth',4,validationFcn)
addParameter(p,'AmpFreq_BandWidth',10,validationFcn)
addParameter(p,'useparfor',0,validationFcn)
addParameter(p,'computeSurrogates',0,validationFcn)
addParameter(p,'plotdata',1,validationFcn)

validationFcn = @(x) validateattributes(x,{'cell'},{'nonempty'});
addParameter(p,'regionnames',{'a1','a2'},validationFcn)

p.parse(varargin{:});

%Extract values from the inputParser
FreqBands            = p.Results.PhaseFreqVector;
AmpFreqVector        = p.Results.AmpFreqVector;
PhaseFreq_BandWidth  = p.Results.PhaseFreq_BandWidth;
AmpFreq_BandWidth    = p.Results.AmpFreq_BandWidth;
useparfor            = p.Results.useparfor; % if true, user parfor, requires parallel computing toolbox
regionames           = p.Results.regionnames;
computesurr          = p.Results.computeSurrogates;
plotdata             = p.Results.plotdata;

figure;
idx = predictors.stim ~=1;
[idx, nms] = findgroups(predictors.patient)
[idx, nms] = findgroups(predictors.med)
[idx, nms] = findgroups(predictors.stim)
[idx, nms] = findgroups(predictors.visit)

figure;
% boxplot(predictors.lfpavgnormBeta(idx),{predictors.patient(idx), predictors.med(idx) ,predictors.visit(idx) });
boxplot(predictors.ecogavgnormBeta(idx),{ predictors.med(idx)});
%% session based: (for each med, stim, condition etc.) 

%% For each freq band 
%% For each region in brain 

%% 1. avg power 
%% 2. peak power 
%% 3. fitted log power. 
%% 4. PAC (both peak and average) 
%% 5. Change from baseline (average of 1-3 months) (peak, percentage, and area under curve) 
%% 6. power normalize (e.g. divide by average power) divided by percentage total power 
%% 7. burst profile 
%% 8. tailored beta peak based on movement with +- 1Hz window 
%% 9. log log infleciton point 
%% 10. log log fitted line percenteges. 

%% exclusion criteria / data cleaning 
%% 1. possess movement related beta peak based on ipad task 
%% 2. within a defiend set of electrodes across tasks (e.g. same electrode pair) 
%% 3. do not contain stimulation based artifacts 



%% patient based: 

%% for each condition 
%% for each med state 
%% for each stim state 

%% 1. variance across time points in power 
%% 2. variance across time points in coherence 