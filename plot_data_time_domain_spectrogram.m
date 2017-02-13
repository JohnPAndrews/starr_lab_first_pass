function hfig = plot_data_time_domain_spectrogram(data,params,figtitle)
%% This funciton plots data in the time domain

% inputs = data is a matrix 
sr = params.sr; 
hfig = figure('Position',[680   441   719   537],'Visible','on'); 

% set params for ERSP prodcution 
specparams.tapers       = [3 5]; % precalculated tapers from dpss or in the one of the following
specparams.pad          = 1;% padding factor for the FFT) - optional
specparams.err          = [2 0.05]; % (error calculation [1 p] - Theoretical error bars; [2 p] - Jackknife error bars
specparams.trialave     = 0; % (average over trials/channels when 1, don't average when 0) 
specparams.Fs           = params.sr; % sampling frequency 
specparams.fpass        = [0 100]; %frequency band to be used in the calculation in the form [fmin fmax])- optional. 

movingwin = [1 0.1];% (in the form [window winstep] i.e length of moving window and step size) Note that units here have to be consistent with units of Fs - required

% compute spectrogram along moving windows: 
[S,t,f,Serr]=mtspecgramc(data,movingwin,specparams);
SS(:,:,1)=S;
% plot using imagesc (note that this scales color) 
hplot = imagesc(t,f,10*log10(S'));
axis xy; % flip axis so frequncies go from top to bottom 
% XX need to add units to colorbar. 
colorbar; 

xtitle = 'Time (seconds)'; 
ytitle = 'Frequency'; 
% set titels and get handels 
htitle = title(figtitle); 
hxlabel = xlabel(xtitle);
hylabel = ylabel(ytitle);

ax = ancestor(hplot, 'axes');

% plot countering around "hot" areas 
hold on; 
[~, hcntr] = contour(ax,t,f,10*log10(S')); 
% currently this isn't significance - just countering 
hcntr.LineWidth = 1; 
hcntr.Fill = 'off'; 
hcntr.LineColor = [0 0 0];

hyrule = ax.YAxis;
hxrule = ax.XAxis; 

% format plot - size and fonts 
formatPlot(htitle,hxlabel,hylabel,hxrule,hyrule,hplot)
end