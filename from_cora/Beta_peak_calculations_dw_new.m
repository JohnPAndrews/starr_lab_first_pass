%given a PSD vector (befor log is taken) and frequency vector (both must be row vectors),find amplitude of the beta peak from imaginary baseline
%(baseline is defined by a poly fit to psd data excluding the beta peak and noise areas and very low frequencies)
%Also calculate width of beta peak (gaussian curve is fit to beta peak, and sigma calculated)

%THIS WORKS FOR LOG POWER 

%This version uses polynomial curve fit for the baseline 

%flag and initial_peak should normally be set to zero (or not set at all); flag is only sent to 1 when beta peak
%(initial_peak) is 'wrong' and a new peek needs to be found. 'Wrong' means
%that gaussian could not be fit so in some cases a new better peak can be
%found, but sometimes where just is no proper peak (this will be only tried
%once)


%f must be column vector, psd_data is row vector
clear all;


%% Define disease state;

Dx = input('Enter patient diagnosis (1=PD, 2=C-Dys, 3=G-Dys, 4=Epilepsy, 5=Other): ');

    if Dx==1
        cd('D:/Starr Lab/Data/PD GPi/New PSD analysis/');
    elseif Dx==2
        cd('D:/Starr Lab/Data/DYT GPi/Cranio dyt/New PSD analysis/');
    elseif Dx==3
        cd('D:/Starr Lab/Data/DYT GPi/Gen dyt/New PSD analysis/');
    end;
  

[fn, pn]=uigetfile('*_ecogPSDrest30s.mat');

 load(fn);
 fn = strrep(fn,'_ecogPSDrest30s.mat',''); %remove from file name

 f=freq; %frequency column vector
 
 
    if size(psdall,2)==6;
        psd_lfp= psdall(:,6)'; % if 6 ecog contacts, then lfp is contact 6
    elseif size(psdall,2)>6;
        LFP_chan=input('enter lfp channel:');
        psd_lfp=psdall(:,LFP_chan)'; % if 28 ecog strip, then assume lfp is contact 29
    end;

%% Plot figures and fits
plot_figure = 1; %set to 1 to plot analysis figure, otherwise 0

psd = log10(psd_lfp);  
ff = f';
freq_res = ff(2) - ff(1); %Fs/NFFT; 

max_freq = find(f>=250);  %remove frequencies above 250Hz
psd(max_freq)=[];
ff(max_freq)=[];

fr_start = 8; %smallest freq for alpha-beta peak search
fr_end = 30; %largest freq for alpha-beta peak search
%if (flag == 1) %rare case when new alternate peak should be found
%    if (initial_peak < 13)
%        fr_start = 13; 
%        fr_end = 30;
%    elseif (initial_peak > 25)
%        fr_start = 8;
%        fr_end = initial_peak-1; 
%    end    
%end    
fr_start_ind = find(ff >= fr_start, 1); %vector index for fr_start
fr_end_ind = find(ff >= fr_end, 1); %vector index for fr_end
alpha_beta_freq = find(ff >= fr_start & ff <= fr_end); %frequency indices in alpha/beta range
[peaks,peaklocs] = findpeaks(psd); %use findpeaks to find local maxima
alpha_beta_freq_out = find(peaklocs < fr_start_ind | peaklocs > fr_end_ind); %peaks OUTSIDE alpha/beta range
peaks(alpha_beta_freq_out)=[]; %remove peaks from outside alpha/beta range since we are not interested in those
peaklocs(alpha_beta_freq_out)=[];
[mymax_amp, mti] = max(peaks); %find largest local peak
mymax_ind = peaklocs(mti); %alpha-beta peak frequency index of the largest local peak


%find local minimum just before beta-peak, but not too close (this will help define imaginary baseline)
[mins,minlocs] = findpeaks(-1*psd); %use findpeaks to find local minima, so need to flip the data 
mins = -1*mins; %convert back to greater than 0
tmpi = find(minlocs >= mymax_ind); 
mins(tmpi) = []; %remove all local min that are to the right of the beta peak
minlocs(tmpi) = []; %remove all local min that are to the right of the beta peak
[tmpvt, tmpi2] = min(mins); %find smallest local min
putative_starts = minlocs; 
my_startA = minlocs(tmpi2); %assign it smallest local min so it is at least defined
for i = length(putative_starts):-1:1 %go backwards
	if (ff(mymax_ind) - ff(putative_starts(i)) >= 10 | (mymax_amp - psd(putative_starts(i)) > 0.5) )  %local minimim at least 10Hz away from beta peak or local minimum more than 50% smaller than beta peak
    	my_startA = putative_starts(i);  %start for imaginary baseline (index)
    	break;
    else
    	continue
	end
end
%alternate way to find minimum just before beta-peak - USE THIS METHOD primarily, unless it fails then can use above calculated value
low_freq = find(ff >= 5 & ff <= ff(mymax_ind)-3);
lfflag = 0;
if (isempty(low_freq))  %rare case, so odd-looking curve
   % fprintf('Find low_freq between 5 and %f Hz\n', ff(mymax_ind))
    low_freq = find(ff >= 5 & ff < ff(mymax_ind));
    lfflag = 1; 
end      
[tmpa tmpi] = min(psd(low_freq));
my_start = tmpi + low_freq(1)-1;  %beginning of beta bump - force fitted curve to pass thru this point
if (tmpi == 1 | tmpi == length(low_freq) | lfflag == 1) %meaning my_start is not a local minimum (it's just the first or last, smallest point) OR we are dealing with low frequencies (lfflag ==1)
    if(psd(my_start) > psd(my_startA))
        my_start = my_startA;   %use the other starting point
    end    
end    


%define data
ydata = psd;  
ydata1 = psd; 
xdata1 = ff;    
    
ydata1_cd = psd; %cora-doris algorithm
xdata1_cd = ff;    

%for imaginary baseline, exclude beta peak and noise areas; 1st point will be my_start calculated above
%if beta peak is too high in frequency (e.g. > 25Hz), then also exclude frequencies up to 45 Hz
if (ff(mymax_ind) < 25)
    exclude = find(ff >=0 & ff < ff(my_start) | ff > ff(my_start) & ff<40 | ff>=52 & ff<64 | ff>=116 & ff<124 | ff>=176 & ff<184 | ff>=236 & ff<244 | ff>=250);
else
    exclude = find(ff >=0 & ff < ff(my_start) | ff > ff(my_start) & ff<45 | ff>=52 & ff<64 | ff>=116 & ff<124 | ff>=176 & ff<184 | ff>=236 & ff<244 | ff>=250);
end    
xdata1(exclude)=[];
ydata1(exclude)=[];

%cora-doris algorithm
WINDOW = 1024; 
min_p = dsearchn(ff',10); % include data from 6to 10 Hz to do the fit
exclude_cd = find(ff >=0 & ff<min_p-4*round(WINDOW/1000) | ff>min_p & ff<35 | ff>=56 & ff<64 | ff>=116 & ff<124 | ff>=176 & ff<184 | ff>=236 & ff<244| ff>=250);
xdata1_cd(exclude_cd)=[];
ydata1_cd(exclude_cd)=[];

% fit a 5th order polynomial to psd data
polyfit_order = 5; 
%fitResults1 = polyfit(xdata1, ydata1, polyfit_order);
fitResults1 = polyfix(xdata1,ydata1,xdata1(1),ydata1(1),polyfit_order);  %forcing curve to pass thru a given point (i.e. our starting point calculated above)
fitValues = polyval(fitResults1, ff);
ydata2 = ydata - fitValues;  %data curve where baseline is subtracted (use this to find beta peak width, see below)

%cora-doris algorithm
fitResults1_cd = polyfit(xdata1_cd, ydata1_cd, 5);
fitValues_cd = polyval(fitResults1_cd, ff); 
ydata2_cd = ydata - fitValues_cd;
     
amp = ydata2(mymax_ind); %return the amplitude based on the original beta peak location

%fit gaussian to the beta peak to find width of peak
%beta_f = find(ff >= 10 & ff <= 34);  %10 and 34 (cora-doris alghorithm)
beta_f = (my_start:mymax_ind+length(my_start:mymax_ind)); %data that gaussian will be fitted on; chose equal number of points to the left and to the right of the peak  

%gauss fit function from cora and doris
%[sigma,mu,A]=mygaussfit(ff(beta_f),ydata2(beta_f));
%fit_gauss=A*exp(-(ff-mu).^2/(2*sigma^2));

%alternate gauss fit function, works better
[sigma2, mu2, s] = gaussfit(ff(beta_f),ydata2(beta_f));
A2 = s/(sqrt(2*pi)*sigma2); 
fit_gauss2=A2*exp(-(ff-mu2).^2/(2*sigma2^2));

%if sigma is not real, that means gaussian fit is very poor (inverted) so
%need to recalculate beta peak and look for a different peak. This probably
%won't be necessary with new gauss fit function which works better
if (sigma2 < 0)
    if (flag == 0)
        [amp, width] = SMfind_relative_amplitudeLOG2(psd_lfp, f, 1, ff(mymax_ind)); %try recalculating to find different beta peak
        return
    else
        disp(sprintf('Poor gaussian fit...no fix')); 
    end    
end    
width = sigma2; 
beta_freq= ff(mymax_ind);
    
% g1 = gausswin(10); % <-- this value determines the width of the smoothing window
% g1 = g1/sum(g1);
% ydataC = conv(ydata, g1, 'same');

if (plot_figure == 1)
figure()
subplot(1,2,1)
plot(ff,ydata)
hold on
plot(ff,fitValues,'r')
%plot(ff,fitValues_cd,'m')
plot(ff,fit_gauss2+fitValues,'k', 'LineWidth', 2)
plot(xdata1, ydata1, 'r.')
plot(ff(mymax_ind), mymax_amp, 'k*') 
plot(ff(my_startA), psd(my_startA), 'ko') 
legend({'data', 'fitted polynomial', 'c-d fit', 'gauss2 fit', 'points used for polyfit', 'data alpha-beta peak', 'alt fit pt'});
%myyaxis = get(gca,'ylim');

subplot(1,2,2)
plot(ff,ydata2,'b')
hold on;
%plot(ff,fit_gauss,'r')
plot(ff,fit_gauss2,'k')  
plot(ff(beta_f), ydata2(beta_f), 'r.')
plot(ff(mymax_ind), ydata2(mymax_ind), 'k*') 
plot(mu2, A2, 'r*') 
legend({'data minus fit', 'gaussian fit for beta peak', 'gauss 2 fit', 'points used for gaussfit', 'original beta peak', 'gaussian beta peak'});
%ylim(myyaxis);
end;

%% save values, mu (frequency of peak), A (amplitude of the peak), sigma (width of the peak)

	if Dx==1
        cd('D:/Starr Lab/Data/PD GPi/New Beta analysis/');
    elseif Dx==2
        cd('D:/Starr Lab/Data/DYT GPi/Cranio dyt/New Beta analysis/');
    elseif Dx==3
        cd('D:/Starr Lab/Data/DYT GPi/Gen dyt/New Beta analysis/');
    end;
    
    save ([fn '_beta.mat'], 'psd_lfp', 'f', 'width', 'amp', 'beta_freq');

%% save figure

    savefig([fn '_betafit.fig']);



