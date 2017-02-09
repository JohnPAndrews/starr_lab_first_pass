function hfig = plot_data_time_domain(data,params,figtitle,xtitle,ytitle)
%% This funciton plots data in the time domain

% inputs = data is a matrix 
sr = params.sr; 
hfig = figure('Position',[680   441   719   537],'Visible','on'); 
hplot = plot(data); 

xlabels = get(gca,'XTick');
set(gca,'XTickLabel',xlabels/sr); 


% set titels and get handels 
htitle = title(figtitle); 
hxlabel = xlabel(xtitle);
hylabel = ylabel(ytitle);

ax = ancestor(hplot, 'axes');
hyrule = ax.YAxis;
hxrule = ax.XAxis; 

% format plot - size and fonts 
formatPlot(htitle,hxlabel,hylabel,hxrule,hyrule,hplot)
end