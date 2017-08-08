function [hfig, hplot] = plot_data_coherence(ecog,lfp,Fs,figtitle)
%% error checking 
if isempty(figtitle)
    hfig = [];
else
    hfig = figure('Position',[1000         673         908         665],'Visible','on');
end
%% plot cohenece 

[Cxy,F] = mscohere(ecog,lfp,...
    2^(nextpow2(Fs)),...
    2^(nextpow2(Fs/2)),...
    2^(nextpow2(Fs)),...
    Fs);
idxplot = F > 0 & F < 100; 
hplot = plot(F(idxplot),Cxy(idxplot));
xlabel('Freq (Hz)');
ylabel('coherence'); 
end