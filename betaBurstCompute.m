function betaBurstCompute()
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
datadir = fullfile('..','data','database');
%% get data
rfs = findFilesBVQX(dirname,'dataBR.mat');
% for rf = 1:length(rfs)
%     load(rfs{rf});
%     if rf ==1
%         datTabAll = datTab;
%     else
%         datTabAll = [datTabAll; datTab];
%     end
% end
load(fullfile(datadir,'database.mat'),'datTabAll');
load(fullfile('..','data','interactive_plot_db','db_all_subs.mat'));
% rfs = findFilesBVQX(dirname,'resultsBR.mat');
% for rf = 1:length(rfs)
%     load(rfs{rf});
%     if rf ==1
%         resTabAll = resTab;
%     else
%         resTabAll = [resTabAll; resTab];
%     end
% end
% save(fullfile(datadir,'resultsdatabase.mat'),'resTabAll');
%% set settings and params

%% choose settings
settings.patuse  = 'brpd09';
settings.task    = 'walking';
settings.med     = 0;
settings.stim    = 0;
settings.visit   = '3 month';
%% choose params
params.betaSpan      = 3; % span in hz on each side of beta peak
parmas.betafiltorder = 4;

%% get idxs for data
idxchoose = ...
    cellfun(@(x) strcmp(x,settings.patuse),datTabAll.patient) & ...
    cellfun(@(x) strcmp(x,settings.task),datTabAll.task) & ...
    cellfun(@(x) strcmp(x,settings.visit),resTabAll.visit) & ...
    resTabAll.Exclude == 0 &...
    resTabAll.med == settings.med & ...
    resTabAll.stim == settings.stim;
idxchoose = find(idxchoose==1);
r = []; lags = []; cnt = 1;betapeak = []; 
%% loop on data found
for ii = 1:length(idxchoose)
    %% extract the data
    data = []; timedat = [];
    idxclean = datTabAll.idxclean(idxchoose(ii),:);
    data(1,:) = datTabAll.lfp{idxchoose(ii)}(idxclean(1):idxclean(2)); % lfp
    data(2,:) = datTabAll.ecog{idxchoose(ii)}(idxclean(1):idxclean(2)); % ecog
    timedat   = [idxclean(1):1:idxclean(2)]./datTabAll.sr(idxchoose(ii))';
    sr        = datTabAll.sr(idxchoose(ii));
    %%  locate the peak in the beta range
    skipthis = 0;
    for tt = 1:2
        [psd,f] = pwelch(data(tt,:),sr,sr/2,1:sr/2,sr,'psd');
        if sum(psd) == 0
            skipthis = 1;
        else
            psd = log10(psd);
            idxfreq = f > 13 & f < 30;
            [psdval,idxmax] = max(psd(idxfreq));
            betapeak(tt) = f(psd == psdval);
        end
    end
    if ~skipthis
        %% bp data in the beta range acording to peak found
        betafilt =[];betaEnv=[];
        for tt = 1:2
            bp = designfilt('bandpassiir',...
                'FilterOrder',parmas.betafiltorder, ...
                'HalfPowerFrequency1',betapeak(tt)-params.betaSpan,...
                'HalfPowerFrequency2',betapeak(tt)+params.betaSpan, ...
                'SampleRate',sr);
            betafilt(tt,:) = filtfilt(bp,data(tt,:));
            [up, low] = envelope(betafilt(tt,:),120,'analytic'); % analytic rms (
            
            betaEnv(tt,:) = up;
        end
        %% cross correlate envelope
        [r(cnt,:),lags(cnt,:)] = xcorr ( betaEnv(1,:)-mean(betaEnv(1,:)),betaEnv(2,:)-mean(betaEnv(2,:)),10e3,'coeff');
        cnt = cnt +1;
    end
end



%% Methods to corrleate Beta Bursts: %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1. Crosse Correlate entire signal %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
shadedErrorBar(lags(1,:)./sr,mean(r,1),std(r),'lineprops','b');
titletxt = sprintf('envelope cross correlation p- %s t- %s',...
    settings.patuse,...
    settings.task);
title(titletxt);
ylabel('r value');
xlabel('time (secs)');

return;
% plot cross correlation
figure;
hold on;
for ll = 1:size(r,1)
    plot(lags(ll,:),r(ll,:));
end


%% 2. Cross correlate based on beta  %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract idx for max beta burst, in one signal
% chop out window around this location
% cross correlate
% average
% free paramaters: thershold for enevelope, beta window


%% 3. compute erp of data            %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extrasct idx for max of beta burst
% take other signal and compute mean erp starting at burst

%% 4. PSTH of data .                %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extrasct idx for max of beta burst
% for each idx: count number of bursts, within window of size win
% construct PSTH
%


%% 5. ROC / SDT appr                %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extrasct idx for max of beta burst
% take other signal and compute mean erp starting at burst


%% 6. GLM appraoch                  %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extrasct idx for max of beta burst
% for each burst foudn, find the corresondong burst in other strucutre 
% compute len + amp in that burst, and the next one 

% stn leads 
pred = []; resp =[];
clear mdlstn 
cnt = 1; 

for b = 1:length(idxuse(1).startidx)
    idx2 = find(idxuse(1).startidx(b) < idxuse(2).startidx)
   
    if ~isempty(idx2) & length(idx2) > 1
        resp(b) = idxuse(1).burstamp(b) * idxuse(1).burstlen(b);
        pred(b,1) = idxuse(2).burstlen(idx2(1));
        pred(b,2) = idxuse(2).burstamp(idx2(1));
        pred(b,3) = (idxuse(2).startidx(idx2(1))- idxuse(1).startidx(b))/sr;
%         pred(b,3) = idxuse(2).burstlen(idx2(2));
%         pred(b,4) = idxuse(2).burstamp(idx2(2));
%         pred(b,5) = idxuse(2).burstlen(idx2(3));
%         pred(b,6) = idxuse(2).burstamp(idx2(3));

    end
end
[mdlstn ] = fitlm(pred,resp,'linear','VarNames',{'length','amplitude','delay','stn'});
[mdlstng ] = fitglm(pred,resp,'VarNames',{'length','amplitude','delay','stn'});
[t, dev stats ] = glmfit(pred,resp,'normal');
figure;
plotSlice(mdlstn);
% m1 first 
pred = []; resp =[];
for b = 1:length(idxuse(2).maxburstidx)
    idx2 = find(idxuse(2).maxburstidx(b) < idxuse(1).maxburstidx)
   
    if ~isempty(idx2) & length(idx2) > 2
        resp(b) = idxuse(2).burstamp(b) * idxuse(2).burstlen(b)
        pred(b,1) = idxuse(1).burstlen(idx2(1));
        pred(b,2) = idxuse(1).burstamp(idx2(1));
%         pred(b,3) = idxuse(1).burstlen(idx2(2));
%         pred(b,4) = idxuse(1).burstamp(idx2(2));
%         pred(b,5) = idxuse(1).burstlen(idx2(3));
%         pred(b,6) = idxuse(1).burstamp(idx2(3));

    end
end
mdlm1 = fitglm(pred,resp,...
    'linear');
mdlm1lin = fitlm(pred,resp,'linear');
figure;
plotSlice(mdl);




figure;
hold on;
plot(betaEnv(1,:));
thresh = prctile(betaEnv(1,:),75);
for b = 1:length(idxuse(1).startidx)
    scatter(idxuse(1).startidx(b),thresh(1),100);
end

%% plot raw data
figure;
hax(1) = subplot(2,1,1);
plot(timedat,data(1,:));
title('lfp raw data '); xlabel('time (secs'); ylabel('voltage');
hax(2) = subplot(2,1,2);
plot(timedat,data(2,:));
title('ecog raw data'); xlabel('time (secs'); ylabel('voltage');
linkaxes(hax,'x');

%%  locate the peak in the beta range
% find lfp peak
f = resTabAll.psdlfpF{idxchoose,:};
psd = resTabAll.psdlfp{idxchoose,:};
idxfreq = f > 13 & f < 30;
[psdval,idxmax] = max(psd(idxfreq));
betapeak(1) = f(psd == psdval);

% find ecog peak
f = resTabAll.psdecogF{idxchoose,:};
psd = resTabAll.psdecog{idxchoose,:};
idxfreq = f > 13 & f < 30;
[psdval,idxmax] = max(psd(idxfreq));
betapeak(2) = f(psd == psdval);

%% compute burst
idxuse = [];
%% XXXXXXXXXXX
betapeak(1) = 26.7; betapeak(2) = 26.7;
%% 
for i = 1:2
    bp = designfilt('bandpassiir',...
        'FilterOrder',parmas.betafiltorder, ...
        'HalfPowerFrequency1',betapeak(i)-params.betaSpan,...
        'HalfPowerFrequency2',betapeak(i)+params.betaSpan, ...
        'SampleRate',sr);
    betafilt(i,:) = filtfilt(bp,data(i,:));
    [up, low] = envelope(betafilt(i,:),120,'analytic'); % analytic rms
    
    betaEnv(i,:) = up;
    thresh = prctile(up,75);
    % find start and end indices of line crossing threshold
    startidx = find(diff(up > thresh) == 1) + 1;
    endidx = find(diff(up > thresh) == -1) + 1;
    endidx = endidx(endidx > startidx(1));
    startidx = startidx(1:length(endidx));
    idxuse(i).startidx = startidx;
    idxuse(i).endidx   = endidx;
    
    for b = 1:size(startidx,2)
        bursts.len(b) = timedat(endidx(b)) - timedat(startidx(b));
        idxuse(i).burstlen(b) = bursts.len(b) ;
        bursts.amp(b) = max(up(startidx(b):endidx(b)));
        idxuse(i).burstamp(b) = max(up(startidx(b):endidx(b)));
        idxuse(i).maxburstidx(b) = find(bursts.amp(b) == up);
        patchd(b).x      = timedat(startidx(b):endidx(b));
        patchd(b).y      = up(startidx(b):endidx(b));
    end
end
%% plot beta data
figure;
hax(1) = subplot(2,1,1);
plot(timedat,betafilt(1,:));
title('lfp beta filtered data '); xlabel('time (secs'); ylabel('voltage');
hax(2) = subplot(2,1,2);
plot(timedat,betafilt(2,:));
title('ecog beta filtered data'); xlabel('time (secs'); ylabel('voltage');
linkaxes(hax,'x');

% find max bursts
win = 800;
for i = 1:2
    startidx = idxuse(i).startidx;
    endidx = idxuse(i).endidx;
    maxidx = idxuse(i).maxburstidx;
    for b = 1:size(startidx,2)
        % use burst len
        datlfp = betafilt(1,startidx(b):endidx(b)) - mean(betafilt(1,startidx(b):endidx(b)));
        datecog = betafilt(2,startidx(b):endidx(b)) - mean(betafilt(2,startidx(b):endidx(b)));
        [C{b},LAGS{b}] = xcorr(datlfp,datecog,'coeff');
        % use max burst point, with window size defined by paramater
        if maxidx(b)-win > 0 & maxidx(b)+win < length(betafilt) % so don't get negative points
            idxusemax = maxidx(b)-win:maxidx(b)+win;
            
            datlfp = betaEnv(1,idxusemax) - mean(betaEnv(1,idxusemax));
            datecog = betaEnv(2,idxusemax) - mean(betaEnv(2,idxusemax));
            [Cmax{b},LAGSmax{b}] = xcorr(datlfp,datecog,'coeff');
        end
    end
end
figure;
for ll = 1:length(C)
    plot(LAGS{ll},C{ll});
    hold on;
end
figure;
for ll = 1:length(Cmax)
    plot(LAGSmax{ll},Cmax{ll});
    hold on;
end
cnt = 1;
for ll = 1:length(Cmax)
    if isempty(Cmax{ll})
    else
        cmaxmat(cnt,:) = Cmax{ll};
        lagsmat(cnt,:) = LAGSmax{ll};
        cnt = cnt + 1;
    end
end
x = lagsmat(1,:);
figure;
shadedErrorBar(x,mean(cmaxmat,1),std(cmaxmat),'lineprops','b');

%
%     H(1) = shadedErrorBar(x, y, {@mean, @(x) 2*std(x)  }, , 0);
%     H(2) = shadedErrorBar(x, y, {@mean, @(x) 1*std(x)  }, '-m', 0);
%     H(3) = shadedErrorBar(x, y, {@mean, @(x) 0.5*std(x)}, {'-b', 'LineWidth', 2}, 0);

legend([H(3).mainLine, H.patch], ...
    '\mu', '2\sigma', '\sigma', '0.5\sigma', ...
    'Location', 'Northwest')

%% histogram / raster approach
windowsize = 800*3;
spikeTrain = zeros(length(idxuse(1).startidx),windowsize);
ssX = zeros(length(idxuse(1).startidx),1);
ssY = zeros(windowsize,1);
ssZ = zeros(length(idxuse(1).startidx),windowsize);
for b = 1:length(idxuse(1).maxburstidx)
    idxsrch = idxuse(1).maxburstidx(b):idxuse(1).maxburstidx(b)+windowsize;
    burstslen(b) = timedat(idxuse(1).endidx(b)) - timedat(idxuse(1).startidx(b));
    spikesidx = intersect( idxsrch, idxuse(2).maxburstidx) - idxsrch(1);
    spikeTrain(b,spikesidx) = 1;
    % find idxes for surf amp
    [~,ia,ib] =  intersect( idxsrch, idxuse(2).maxburstidx);
    burstAmp  = idxuse(2).burstamp(ib);
    surfSpike(b,spikesidx) = 1;
    ssX(b) = b;
    ssY(spikesidx) = 1;
    ssZ(b,spikesidx) = burstAmp;
    if max(idxsrch) < size(betaEnv,2)
        erpuse(b,:) = betaEnv(2,idxsrch);
    end
end
[n,idx] = sort(burstslen);
lst = logical(spikeTrain);
lstSorted = lst(idx,:);
% plot spikes
figure;
LineFormat = struct();
LineFormat.Color = [0.3 0.3 0.3];
LineFormat.LineWidth = 1;
LineFormat.LineStyle = ':';
plotSpikeRaster(lstSorted,'PlotType','vertline','LineFormat',LineFormat);
% plot 3d mat
figure;
surf(ssZ(idx,:,:));
figure;
imagesc(zscore(ssZ(idx,:,:)));
for i = 1:2
    idxuse(i).startidx
end
% plot shaded erp
figure;
shadedErrorBar(1:size(erpuse,2),mean(erpuse,1),std(erpuse),'lineprops','g');
% correlate each code to each other, randomly
[r,lags] = xcorr ( betaEnv(1,:)-mean(betaEnv(1,:)),betaEnv(2,:)-mean(betaEnv(2,:)),10e3,'coeff');
figure;plot(lags,r);



%% plot freq patches
handles.freqranges = [1 4; 4 8; 8 13; 13 20; 20 30; 30 50; 50 90];
handles.freqnames  = {'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','LowGamma','HighGamma'}';
cuse = parula(size(handles.freqranges,1));
ydat = [-5 -5 -8 -8];
axesclr = [handles.axlfp,handles.axecog,handles.axcoher];
handles.axesclr = axesclr;
for a = 1:length(axesclr)
    for p = 1:size(handles.freqranges,1)
        freq = handles.freqranges(p,:);
        xdat = [freq(1) freq(2) freq(2) freq(1)];
        handles.hPatches(p,a) = patch('XData',xdat,'YData',ydat);
        handles.hPatches(p,a).Parent = axesclr(a);
        handles.hPatches(p,a).FaceColor = cuse(p,:);
        handles.hPatches(p,a).FaceAlpha = 0.3;
        handles.hPatches(p,a).EdgeColor = 'none';
        handles.hPatches(p,a).Visible = 'on';
    end
end



end