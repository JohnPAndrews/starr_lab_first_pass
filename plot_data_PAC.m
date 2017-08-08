function [hfig,hplot] = plot_data_PAC(data,sr,figtitle)
%% plot phase amplitude coupling 
% uses tort method 
% modificaiton of Cora Code. 

%% params 
PhaseFreqVector=[4:2:50];
AmpFreqVector=[4:4:150];
bad_times = [];
skip = [];
Fs = sr;
beta_start = 8;
beta_end = 30;

%% error checking 
if isempty(figtitle)
    hfig = [];
else
    hfig = figure('Position',[1000         673         908         665],'Visible','on');
end

signal = data; % make sure data is a row vector 
if size(data,2) < size(data,1)
    signal = data'; 
end

%% compute PAC 

% initialize variables 
Comodulogram = NaN(length(PhaseFreqVector),length(AmpFreqVector),size(signal,1));
mean_Comodulogram = NaN(1,size(signal,1));
mean_beta_PSD = NaN(1,size(signal,1));

[n1_b, n1_a]=butter(3,2*[102 108]/Fs,'stop'); %120hz
signal(1,:)=filtfilt(n1_b, n1_a, signal(1,:));
[Comodulogram(:,:)] = pac_art_reject_surr(signal(1,:),Fs,PhaseFreqVector,AmpFreqVector,bad_times,skip);
mean_Comodulogram(1) = mean(mean(Comodulogram(:,:,1)));

cmax=max(abs(Comodulogram(:)))*.75;
cmin=0;
tempmat=double(squeeze(Comodulogram(:,:)));
hplot = pcolor(PhaseFreqVector',AmpFreqVector,tempmat');
shading interp;
caxis([cmin cmax]);
colorbar;

   
end