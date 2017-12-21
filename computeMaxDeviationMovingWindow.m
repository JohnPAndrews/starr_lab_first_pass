function computeMaxDeviationMovingWindow(dat,sr)
params.winsize = 2; % in seconds 
params.overlap = 0.9;%

% method 1: bp filter signal, look for max min
for f = 1:100-1
    bp = designfilt('bandpassiir',...
        'FilterOrder',4, ...
        'HalfPowerFrequency1',f,...
        'HalfPowerFrequency2',f+1, ...
        'SampleRate',sr);
    bpdat = filtfilt(bp,dat);
    datbp = abs(hilbert(bpdat)); 
    datplot(f,:) = datbp; 
    spreadsbp(f) = abs(max(datbp) - min(datbp));
    variancesbp(f) = std(datbp);
end
figure;
plot(1:99,variancesbp)
title('variances bp');
figure;
plot(1:99,spreadsbp); 
title('spreads bp');
figure;
imagesc(datplot);
% method 2: use a moving window in freq domain
win = 1:params.winsize *sr; 
cnt = 1; 
while max(win) < length(dat) 
    datchop = dat(win); 
    [fftOut,f]   = pwelch(datchop,sr,sr/2,1:100,sr,'psd');
    datuse(cnt,:) = log10(fftOut); 
    cnt = cnt + 1; 
    win = win + round(params.winsize* sr * (1-params.overlap));
end

figure;
for f = 1:size(datuse,1)
    plot(1:100,datuse(f,:),'LineWidth',0.02,'Color',[0 0 1 0.2]); 
    hold on;
end
title('all pwelch');

figure;
plot(1:100,mean(datuse,1));
title('average pwelche');

figure;
plot(1:100,std(datuse,1))
title('std pwelch');

figure;
spreads = abs(max(log10(datuse),[],1)) - abs(min(log10(datuse),[],1)) ;
plot(1:100,spreads)
title('spreads pwelch');

end