function hfig = plot_data_time_domain_spectrogram(data,params,figtitle,xtitle,ytitle)
%% This funciton plots data in the time domain

% inputs = data is a matrix 
sr = params.sr; 
hfig = figure('Position',[680   441   719   537],'Visible','on'); 

% set params for ERSP prodcution 
specparams.tapers = [3 5];
specparams.pad = 1;
specparams.err = [2 0.05];
specparams.trialave = 0;
specparams.Fs = params.sr;
movingwin = [1 0.1];

% compute spectrogram along moving windows: 
[S,t,f,Serr]=mtspecgramc(data,movingwin,specparams);
SS(:,:,1)=S;
% plot using imagesc (note that this scales color) 
hplot = imagesc(t,f,10*log10(S'));
axis xy; % flip axis so frequncies go from top to bottom 
% XX need to add units to colorbar. 
colorbar; 


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