function hfig = plot_data_time_domain(data,params,figtitle,xtitle,ytitle)
%% This funciton plots data in the time domain

% inputs = data is a matrix 
if isempty(figtitle)
    hfig = [];
else
    hfig = figure('Position',[1000         673         908         665],'Visible','off');
end

sr = params.sr; 
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