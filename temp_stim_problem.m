rootdir = '/Users/roee/Desktop/Desktop_files/temp/ForScottStim';
ff = findFilesBVQX(rootdir,'*.txt');
sr = 800; 
hfig = figure();
cnt =1; 
for f = 1:length(ff) 
[pn,fn] = fileparts(ff{f});
pat = fn(1:6);
dat = importdata(ff{f});
lfp = dat(:,1);
secs = [1:size(lfp,1)] ./ sr ;
idxuse = secs >10 & secs < 15;

hsub = subplot(4,2,cnt); cnt = cnt +1 ; 
datuse = dat(idxuse) - mean(dat(idxuse));
plot(secs(idxuse),datuse,'LineWidth',0.1,'Color',[0 0 0.9 0.2]); 
xlabel('secs');
ylabel('raw data'); 
title([ pat 'raw data']); 

hax = subplot(4,2,cnt); cnt = cnt +1 ; 
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
datuse = dat(idxuse) - mean(dat(idxuse));
[fftOut,f]   = pwelch(dat(idxuse),794,794/2,1:100,794,'psd');
plot(f,log10(fftOut),'LineWidth',3); 
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
title([ pat 'freq domain']); 

end

hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [11 14];
hfig.PaperPosition = [0 0 11 14];
print(hfig,fullfile(rootdir,'stim_problem.jpeg'),'-djpeg','-r600');
