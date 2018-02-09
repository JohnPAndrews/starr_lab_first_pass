function plot_data_from_each_session()
% choose data folder 
% [fn,pn,ext] = uigetfile();
if ismac
[pn,fn,ext] = fileparts('/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brdy_11/v03_10_day/data/dataBR.mat');
addpath(genpath(fullfile('..','..','PAC')));
elseif ~ismac & isunix
    [pn,fn,ext] = fileparts('/home/starr/roee/BR_reorg_manual/brdy_11/v03_10_day/data/dataBR.mat');
    addpath(genpath(fullfile('..','PAC')));
end
[rootdir,~] = fileparts(pn);
figdir = fullfile(rootdir,'figures');
resdir = fullfile(rootdir,'results','pac_results');
mkdir(resdir);

load(fullfile(pn,[fn,ext]));
% load(fullfile(pn,fn));
for s = 1%:size(datTab,1)
%     plot_psd(datTab(s,:),figdir,s); 
%     plot_spectrogram(datTab(s,:),figdir,s); 
    plot_pac(datTab(s,:),figdir,resdir,s); 
end
end

function plot_psd(tr,figdir,serial)
hfig = figure; 
for i = 1:3
    if i == 3 
        hax = subplot(2,2,[3 4]);
    else
        hax = subplot(2,2,i);
    end
    haxes(i) = hax; 
    hold on;
    handles.freqranges = [1 4; 4 8; 8 13; 13 20; 20 30; 30 50; 50 90];
    handles.freqnames  = {'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','LowGamma','HighGamma'}';
    cuse = parula(size(handles.freqranges,1));
    ydat = [10 10 -10 -10];
    handles.axesclr = hax;
    for p = 1:size(handles.freqranges,1)
        freq = handles.freqranges(p,:);
        xdat = [freq(1) freq(2) freq(2) freq(1)];
        handles.hPatches(p) = patch('XData',xdat,'YData',ydat,'YLimInclude','off');
        handles.hPatches(p).Parent = hax;
        handles.hPatches(p).FaceColor = cuse(p,:);
        handles.hPatches(p).FaceAlpha = 0.3;
        handles.hPatches(p).EdgeColor = 'none';
        handles.hPatches(p).Visible = 'on';
    end
end

tmp = tr.lfp{1} - mean(tr.lfp{1});

if isnan(tr.idxclean(1))
    idxclean(1) = tr.sr*5; 
    idxclean(2) = length(tmp) -tr.sr*5; 
else
    idxclean = tr.idxclean; 
end
if strcmp(tr.task{1},'other')
    idxclean(1) = tr.sr*20; 
    idxclean(2) = length(tmp) -tr.sr*20; 
end
% prepare data lfp 
dat = tr.lfp{1} - mean(tr.lfp{1});
lfp = dat(idxclean(1):idxclean(2));
% prepare data ecog 
dat = tr.ecog{1} - mean(tr.ecog{1});
ecog = dat(idxclean(1):idxclean(2));


if tr.sr == 800 
    tr.sr = 794;
end
if tr.med
    meds = 'on';
    clr = [0 0.9 0 0.8];
else
    meds = 'off';
    clr = [0.9 0 0 0.8];
end
if tr.stim
    stims = 'on';
    marker = '-.';
else
    stims = 'off';
    marker = '-';
end
% plot lfp 
ttluse = strrep(  sprintf('lfp %dHz %s %s m-%s s-%s',tr.sr,tr.task{1},tr.lfp_elec{1},meds,stims) , '_', ' ');
axes(haxes(1));
[fftOut,f]   = pwelch(lfp,tr.sr,tr.sr/2,1:100,tr.sr,'psd');
hp = plot(f,log10(fftOut));
hp.LineWidth = 2;
hp.LineStyle = marker; 
hp.Color = clr;
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
title('Freq Domain data');
xlim([1 100]);
title(ttluse);
% plot ecog 
ttluse = strrep(  sprintf('ecog %dHz %s %s m-%s s-%s',tr.sr,tr.task{1},tr.ecog_elec{1},meds,stims) , '_', ' ');
axes(haxes(2));
[fftOut,f]   = pwelch(ecog,tr.sr,tr.sr/2,1:100,tr.sr,'psd');
hp = plot(f,log10(fftOut));
hp.LineWidth = 2;
hp.LineStyle = marker; 
hp.Color = clr;
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
title('Freq Domain data');
xlim([1 100]);
title(ttluse);
% plot coherence 
ttluse = strrep(  sprintf('coherence %dHz %s %s ',tr.sr,tr.task{1}) , '_', ' ');
axes(haxes(3));
[~, hp] = plot_data_coherence(ecog,lfp,tr.sr,[]);
hp.LineWidth = 2;
hp.LineStyle = marker; 
hp.Color = clr;
ylim([0 1]);
xlabel('Frequency (Hz)');
ylabel('Coherence');
title(ttluse);
pause(1);

% plotting 
set(findall(hfig,'-property','FontSize'),'FontSize',12)

hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [14 8];
hfig.PaperPosition = [0 0 14 8];
fnmsv = sprintf('psd_s-%0.3d_t-%s.jpeg',serial,tr.task{1});
print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r200');
close(hfig);

end


function plot_spectrogram(tr,figdir,serial)
hfig = figure; 
for i = 1:2
    haxes(i) = subplot(2,1,i);    
end

tmp = tr.lfp{1} - mean(tr.lfp{1});

if isnan(tr.idxclean(1))
    idxclean(1) = tr.sr*5; 
    idxclean(2) = length(tmp) -tr.sr*5; 
else
    idxclean = tr.idxclean; 
end
if strcmp(tr.task{1},'other')
    idxclean(1) = tr.sr*20; 
    idxclean(2) = length(tmp) -tr.sr*20; 
end
% prepare data lfp 
dat = tr.lfp{1} - mean(tr.lfp{1});
lfp = dat(idxclean(1):idxclean(2));
% prepare data ecog 
dat = tr.ecog{1} - mean(tr.ecog{1});
ecog = dat(idxclean(1):idxclean(2));


if tr.sr == 800 
    tr.sr = 794;
end
if tr.med
    meds = 'on';
    clr = [0 0.9 0 0.8];
else
    meds = 'off';
    clr = [0.9 0 0 0.8];
end
if tr.stim
    stims = 'on';
    marker = '-.';
else
    stims = 'off';
    marker = '-';
end
% plot lfp 
params.sr = tr.sr; 
params.contouroff = [];
ttluse = strrep(  sprintf('lfp %dHz %s %s m-%s s-%s',tr.sr,tr.task{1},tr.lfp_elec{1},meds,stims) , '_', ' ');
axes(haxes(1));
plot_data_time_domain_spectrogram(lfp,params,[]); 
title(ttluse);
% plot ecog 
params.sr = tr.sr; 
params.contouroff = [];
ttluse = strrep(  sprintf('ecog %dHz %s %s m-%s s-%s',tr.sr,tr.task{1},tr.ecog_elec{1},meds,stims) , '_', ' ');
axes(haxes(2));
plot_data_time_domain_spectrogram(ecog,params,[]); 
title(ttluse);


% plotting 
set(findall(hfig,'-property','FontSize'),'FontSize',12)

hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [14 8];
hfig.PaperPosition = [0 0 14 8];
fnmsv = sprintf('spect_s-%0.3d_t-%s.jpeg',serial,tr.task{1});
print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r200');
close(hfig);

end

function plot_pac(tr,figdir,resdir, serial)


tmp = tr.lfp{1} - mean(tr.lfp{1});

if isnan(tr.idxclean(1))
    idxclean(1) = tr.sr*5; 
    idxclean(2) = length(tmp) -tr.sr*5; 
else
    idxclean = tr.idxclean; 
end
if strcmp(tr.task{1},'other')
    idxclean(1) = tr.sr*20; 
    idxclean(2) = length(tmp) -tr.sr*20; 
end
% prepare data lfp 
dat = tr.lfp{1} - mean(tr.lfp{1});
lfp = dat(idxclean(1):idxclean(2));
% prepare data ecog 
dat = tr.ecog{1} - mean(tr.ecog{1});
ecog = dat(idxclean(1):idxclean(2));


if tr.sr == 800 
    tr.sr = 794;
end
if tr.med
    meds = 'on';
    clr = [0 0.9 0 0.8];
else
    meds = 'off';
    clr = [0.9 0 0 0.8];
end
if tr.stim
    stims = 'on';
    marker = '-.';
else
    stims = 'off';
    marker = '-';
end
% plot pac 

params.PhaseFreqVector = 2:10:50;
params.AmpFreqVector   = 5:10:80;
params.useparfor   = 0;
params.plotdata = 0;
params.regionnames = {'GPi','M1'} ;
 
data(1,:) = lfp';
data(2,:) = ecog';
results = computePAC(data,tr.sr,params);

if params.plotdata
    % plotting
    hfig = gcf;
    ttluse = strrep(  sprintf('%dHz %s %s m-%s s-%s',tr.sr,tr.task{1},tr.ecog_elec{1},meds,stims) , '_', ' ');
    suptitle(ttluse);
    set(findall(hfig,'-property','FontSize'),'FontSize',12)
    
    hfig.PaperPositionMode = 'manual';
    hfig.PaperSize = [14 8];
    hfig.PaperPosition = [0 0 14 8];
    fnmsv = sprintf('pac_s-%0.3d_t-%s.jpeg',serial,tr.task{1});
    print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r200');
    close(hfig);
end
fnmsv = sprintf('pac_s-%0.3d_t-%s.mat',serial,tr.task{1});
save(fullfile(resdir,fnmsv),'results');

end