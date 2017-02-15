function hfig = plot_data_freq_domain(data,params,figtitle)
sr = params.sr; 
hfig = figure('Position',[680   441   719   537],'Visible','off');

switch params.plottype
    case 'reg'
        % calculatge fft        
        L=length(data);
        NFFT=1024;
        X=fft(data,NFFT);
        Px=X.*conj(X)/(NFFT*L); %Power of each freq components
        fftOut = Px(1:NFFT/2); 
        f=params.sr*(0:NFFT/2-1)/NFFT;
        
%         fftOut = fft(data);
%         datalen=length(data);
%         fftlen=length(fftOut);
%         f = sr/2*linspace(0,1,fftlen/2+1); % frequncies
%         fftOut = (abs(fftOut(1:length(f))).^2) / datalen; % return the power of the frequencies
    case 'pwelch'
        NFFT = 512; 
        segLength = 256;
        resBandwith = segLength/params.sr;
        numberFFTaverages = length(data)/segLength; 
        [fftOut,f] = pwelch(data,ones(segLength,1),0,NFFT,params.sr,'power');
        %[fftOut,f] = pwelch(data,512,256,1024,params.sr); % from nicki 
        % plot only stuff below noise floor:
        f = f(f<params.noisefloor); 
        fftOut = fftOut(f<params.noisefloor); 
end

% plot:
hplot  = plot(f,fftOut);

% set titels and get handels
htitle = title(figtitle);
xtitle = 'Frequency (Hz)';
ytitle = 'Power spectrum (dBW)';
hxlabel = xlabel(xtitle);
hylabel = ylabel(ytitle);

ax = ancestor(hplot, 'axes');
hyrule = ax.YAxis;
hxrule = ax.XAxis;

% format plot - size and fonts
formatPlot(htitle,hxlabel,hylabel,hxrule,hyrule,hplot)
end
