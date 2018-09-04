function analyzeRCSdata()
dat = importdata('rcsrawTDdata_2018_07_12.csv');
%% plot data 
sr = 1e3; 
x = dat.data; 
secs = (1:length(x))./sr ;
figure; 
plot(secs,x); 
%% plot 
hfig = figure; 
params.sr =1e3;
params.plottype = 'pwelch';
params.noisefloor = 1e2;
% plot_data_freq_domain(x,params,[]); 

plot_data_time_domain_spectrogram(x,params,[])

end