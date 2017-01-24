% uses 3rd order butterworth filter in both directions instead of eegfilt
% uses self identification of bad channels

function wc_EcogPreprocessing2(EcogFileName)


%% loads file
load(EcogFileName);

%% double to make int16->int32
if ~isempty(ecog)
for i=1:length(ecog.contact)
    ecog.contact(i).raw_signal=double(ecog.contact(i).raw_signal);
end
end

if ~isempty(lfp)
for i=1:length(lfp.contact)
    lfp.contact(i).raw_signal=double(lfp.contact(i).raw_signal);
end
end

if ~isempty(emg)
for i=1:length(emg.chan)
    emg.chan(i).raw_signal=double(emg.chan(i).raw_signal);
end
end

if ~isempty(aux)
for i=1:length(aux.chan)
   aux.chan(i).raw_signal=double(aux.chan(i).raw_signal);
end
end

%% remove DC offset and low freq


for k=1:length(ecog.contact)
    if ~isempty(ecog.contact(k).raw_signal) 
        [b,a]=butter(3,1/ecog.Fs(1),'high');
        ecog.contact(k).signal= filtfilt(b,a, ecog.contact(k).raw_signal); %filter all signal<1hz using butterworth
        ecog.contact(k).signal= ecog.contact(k).signal-mean(ecog.contact(k).signal); %remove d/c offset
%         ecog.contact(k).raw_signal=[]; 
    end
end

if ~isempty(lfp)
    for k=1:length(lfp.contact)
         [b,a]=butter(3,1/lfp.Fs(1),'high');
         lfp.contact(k).signal= filtfilt(b,a,lfp.contact(k).raw_signal);
         lfp.contact(k).signal= lfp.contact(k).signal-mean(lfp.contact(k).signal);
%          lfp.contact(k).raw_signal=[];  
    end
end    
if ~isempty(aux)
    for k=1:length(aux.chan)
        aux.chan(k).signal = aux.chan(k).raw_signal-mean(aux.chan(k).raw_signal);
%         aux.chan(k).raw_signal=[]; 
    end
end

if ~isempty(emg)
    for k=1:length(emg.chan)
        emg.chan(k).signal = emg.chan(k).raw_signal-mean(emg.chan(k).raw_signal);
%         emg.chan(k).raw_signal=[];
    end
end

%% resample data

for i = 1:length(ecog.contact)
    if ~isempty(ecog.contact(i).signal);
        Fs_ecog=ecog.Fs(i);
        if round(ecog.Fs(i))== 2750
            f1 = 2^10;
            f2 = (4^4)*11;
        elseif round(ecog.Fs(i))== 11000
            f1 = 2^10;
            f2 = (2^10)*11;
        else
            f1 = 1000;
            f2 = round(ecog.Fs(i));
        end
        ecog.contact(i).signal=resample(ecog.contact(i).signal,f1,f2);
        ecog.Fs(i)=1000;
    end
end

if ~isempty(lfp)
    for i = 1:length(lfp.contact)
            Fs_lfp=lfp.Fs(i);
        if round(lfp.Fs(i))== 2750
            f1 = 2^10;
            f2 = (4^4)*11;
        elseif round(ecog.Fs(i))== 11000
            f1 = 2^10;
            f2 = (2^10)*11;
        else
            f1 = 1000;
            f2 = round(lfp.Fs(i));
        end
    
            lfp.contact(i).signal=resample(lfp.contact(i).signal,f1,f2);
            lfp.Fs(i)=1000;
    end
end

if ~isempty(aux)
    for i = 1:length(aux.chan)
        Fs_aux=aux.Fs(i);
        if round(aux.Fs(i))== 2750
            f1 = 2^10;
            f2 = (4^4)*11;
        elseif round(aux.Fs(i))== 24414
            f1 = 2^10;
            f2 = (5^5)*8;
        else
            f1 = 1000;
            f2 = round(aux.Fs(i));
        end
        
        aux.chan(i).signal=resample(aux.chan(i).signal,f1,f2);
        aux.Fs(i) = 1000;
    end
end

if ~isempty(emg)
    for i = 1:length(emg.chan)
        Fs_emg=emg.Fs(i);
        if round(emg.Fs(i))== 2750
            f1 = 2^10;
            f2 = (4^4)*11;
        elseif round(emg.Fs(i))== 24414
            f1 = 2^10;
            f2 = (5^5)*8;
        else
            f1 = 1000;
            f2 = round(emg.Fs(i));
        end
            emg.chan(i).signal=resample(emg.chan(i).signal,f1,f2);
            emg.Fs(i)=1000;
    end
end


%% detection of bad electrodes
 figure; hold on
 for i = 1: 14
     subplot(3,5,i)
     plot(ecog.contact(i).signal)
     title(num2str(i))
     ylim([-500 500])
 end
 figure;hold on
 for i = 15: 28
     subplot(3,5,i-14)
     plot(ecog.contact(i).signal)
     title(num2str(i))
    ylim([-500 500])
 end

 
data=[];
for i=1:28
    if ~isempty(ecog.contact(i).signal)
        data(i,:)=ecog.contact(i).signal;
    end
end

eegplot(data,'srate',ecog.Fs(1));


%% common reference
% length_CAR = 28;
% data = nan*ones(length_CAR,length(ecog.contact(1).signal));
% for i = 1: 28
%     if ~isempty(ecog.contact(i).signal)
%         data(i,:) = ecog.contact(i).signal;
%     end
% end
% car=nanmean(data);

%% identify bad electrodes (those with big peaks in PSD between 10-200Hz)
 
length_CAR = 28;
Fs= 1000;
 WINDOW = 2^(nextpow2(Fs));
 NOVERLAP = 2^(nextpow2(Fs/2));
 NFFT = 2^(nextpow2(Fs));
 thresh = 70;
 
 figure
 good_el=[];
 for i = 1: length_CAR
     if ~isempty(ecog.contact(i).signal)
         [psd,F] = pwelch(ecog.contact(i).signal,WINDOW,NOVERLAP,NFFT,Fs);
         idx = find(F>=30 & F<= 200);
         subplot(2,14,i)
         plot(F,psd)
         xlim([1 200])
         ylim([0 100])
         if isempty(find(psd(idx)>70))
             good_el = [good_el i];
         end
     end
 end
 
bad=input('bad contacts:');
good_el = setdiff(1:28,bad);
 
% car=nanmean(data(good_el,:));
% for i = 1: length_CAR
%     if ~isempty(ecog.contact(i).signal)
%         ecog.contact(i).signal = ecog.contact(i).signal-car;
%     end
% end

if ~isempty(lfp)
    for i = 1:length(lfp.contact)-1
        lfp.contact(i).signal=lfp.contact(i).signal-lfp.contact(i+1).signal;
    end
end

%% notch filter around 60Hz, 120Hz and 180Hz
% butterworth notch filter - model order, [low/(Fs/2) high/(Fs/2)]
for i=1:length(ecog.contact)
    if ~isempty(ecog.contact(i).signal)
        [n1_b, n1_a]=butter(3,2*[58 62]/ecog.Fs(i),'stop'); %60hz
        [n2_b, n2_a]=butter(3,2*[118 122]/ecog.Fs(i),'stop'); %120hz
        [n3_b, n3_a]=butter(3,2*[178 182]/ecog.Fs(i),'stop'); %180hz
        
        ecog.contact(i).signal=filtfilt(n1_b, n1_a, ecog.contact(i).signal); %notch out at 60
        ecog.contact(i).signal=filtfilt(n2_b, n2_a, ecog.contact(i).signal); %notch out at 120
        ecog.contact(i).signal=filtfilt(n3_b, n3_a, ecog.contact(i).signal); %notch out at 180
    end
end
if ~isempty(lfp)
    for i=1:length(lfp.contact)
        [n1_b, n1_a]=butter(3,2*[58 62]/lfp.Fs(i),'stop'); %60hz
        [n2_b, n2_a]=butter(3,2*[118 122]/lfp.Fs(i),'stop'); %120hz
        [n3_b, n3_a]=butter(3,2*[178 182]/lfp.Fs(i),'stop'); %180hz
        
        lfp.contact(i).signal=filtfilt(n1_b, n1_a, lfp.contact(i).signal); %notch out at 60
        lfp.contact(i).signal=filtfilt(n2_b, n2_a, lfp.contact(i).signal); %notch out at 120
        lfp.contact(i).signal=filtfilt(n3_b, n3_a, lfp.contact(i).signal); %notch out at 180
    end
end

%% save data
EcogFileName =  strrep(EcogFileName,'_raw','');
EcogFileName = [EcogFileName(1:end-4) '_filt'];
name = EcogFileName ;
save(EcogFileName,'ecog','lfp','aux','emg','bad');

%% find stim artifact
% if ~isempty(strfind(EcogFileName,'DBS')) || ~isempty(strfind(EcogFileName,'stim'))
%     WINDOW = 512;           % segment length and Hamming window length for welch's method
%     NOVERLAP = 256;         % # signal samples that are common to adjacent segments for welch's method
%     NFFT = 512;
%     epoch = 1000;
%     slid=100;
%     stim = [1: slid :length(ecog.contact(17).signal)-epoch] ;
%     [psd,f] = pwelch(ecog.contact(17).signal,WINDOW ,NOVERLAP,NFFT,Fs);
%     stim_peak = nan*ones(1,length(stim)-1);
%     
%     freq = find(f>= 150 & f<= 200);
%     [v,p] = max(psd(freq));
%     f_max = p + freq(1)-1;
%     f_stim = f(f_max);
%     
%     for t = 1: length(stim)-1
%         tt = stim(t);
%         [psd,f] = pwelch(ecog.contact(17).signal(tt:tt+epoch),WINDOW ,NOVERLAP,NFFT,Fs);
%         stim_peak(t) = psd(f_max);
%     end
%     
%     figure
%     plot(stim_peak)
%     title(['f=  ' num2str(f_stim)])
%     saveas(gcf,[EcogFileName '_stim_art'],'fig');
%     % normalize signal
%     %     std_stim = std(stim_peak);
%     %     mean_stim = mean(stim_peak);
%     %     sup_mean = find(stim_peak > mean(stim_peak));
%     sup_mean = find(stim_peak > 1);
%     
%     [pos,n] = evFindGroups(sup_mean,10,50);
%     if ~isempty(pos)
%     start_stim = sup_mean(pos(1));
%     stop_stim = sup_mean(pos(2));
%     
%     [n1_b, n1_a]=butter(3,2*[f_stim-3 f_stim+3]/Fs,'stop');
%     for k=1:length(ecog.contact)
%         ecog.contact(k).signal=filtfilt(n1_b, n1_a, ecog.contact(k).signal); %notch stim art
%     end
%     save (EcogFileName,'start_stim','stop_stim','f_stim','-append')
% end

