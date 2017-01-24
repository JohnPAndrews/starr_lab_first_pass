function hfig = plot_data_freq_domain(data,sr,figtitle)
hfig = figure('Position',[680   441   719   537],'Visible','on'); 
% calculatge fft 
fftOut = fft(data);  
datalen=length(data);
fftlen=length(fftOut);
f = sr/2*linspace(0,1,fftlen/2+1); % frequncies 
fftOut = (abs(fftOut(1:length(f))).^2) / datalen; % return the power of the frequencies

% plot: 
hplot  = plot(f,fftOut); 

% set titels and get handels 
htitle = title(figtitle); 
xtitle = 'Frequency (Hz)'; 
ytitle = 'Log PSD (dB)'; 
hxlabel = xlabel(xtitle);
hylabel = ylabel(ytitle);

ax = ancestor(hplot, 'axes');
hyrule = ax.YAxis;
hxrule = ax.XAxis; 

% format plot - size and fonts 
formatPlot(htitle,hxlabel,hylabel,hxrule,hyrule)
end
