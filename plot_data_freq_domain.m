
function [hfig,hplot] = plot_data_freq_domain(data,params,figtitle)
sr = params.sr;

if isempty(figtitle)
    hfig = [];
else
    hfig = figure('Position',[1000         673         908         665],'Visible','on');
end

switch params.plottype
    case 'reg'
        % calculatge fft
        L=length(data);
        NFFT=1024;
        X=fft(data,NFFT);
        Px=X.*conj(X)/(NFFT*L); %Power of each freq components
        fftOut = log10(Px(1:NFFT/2));
        f=params.sr*(0:NFFT/2-1)/NFFT;
        
        %         fftOut = fft(data);
        %         datalen=length(data);
        %         fftlen=length(fftOut);
        %         f = sr/2*linspace(0,1,fftlen/2+1); % frequncies
        %         fftOut = (abs(fftOut(1:length(f))).^2) / datalen; % return the power of the frequencies
    case 'pwelch'
        NFFT = 512;
        segLength = 1024;
        resBandwith = segLength/params.sr;
        numberFFTaverages = length(data)/segLength;
        [fftOut,f] = pwelch(data,params.sr,params.sr/2,1:params.noisefloor,params.sr,'psd');
        %[fftOut,f] = pwelch(data,512,256,1024,params.sr); % from nicki
        % plot only stuff below noise floor:
        
        freqlog = f<params.noisefloor; 
        if isfield(params,'lowcutoff')
            freqlog = freqlog & ... 
                f>params.lowcutoff;
        end
        f = f(freqlog);  % frequncies
        fftOut = log10(fftOut(freqlog));
end

% plot:
hplot  = plot(f,fftOut);

% set titels and get handels
htitle = title(figtitle);
xtitle = 'Frequency (Hz)';
ytitle = 'Power  (log_1_0\muV^2/Hz)';
hxlabel = xlabel(xtitle);
hylabel = ylabel(ytitle);

% ax = ancestor(hplot, 'axes');
% hyrule = ax.YAxis;
% hxrule = ax.XAxis;
% 
% % format plot - size and fonts
% formatPlot(htitle,hxlabel,hylabel,hxrule,hyrule,hplot);
end
