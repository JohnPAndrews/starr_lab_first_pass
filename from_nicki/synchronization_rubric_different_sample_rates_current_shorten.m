%%synchronize data

%first find pulse times with SSEP channel
% 
% %for gs4000
% ssep = aux.chan(1,4).raw;
% ssep = abs(diff(ssep)); 
% plot(ssep);
% 
% %for alpha omega
% ssep = aux.chan(1,3).raw;
% ssep = abs(diff(ssep)); 
% plot(ssep);
% 
% 
% 
% %indentify threshold
% threshold = .015;
% pulse_times = find(ssep>threshold);

%plot emg with ssep times marked and ecog
ecog_FS_old = Fs_ecog;
emg_FS = Fs_emg;
emg_data = emg.chan(1,1).raw;
ecog_data = ecog.contact_pair(1,1).remontaged_ecog_signal;
ecog_data2 = ecog.contact_pair(1,2).remontaged_ecog_signal;
ecog_times = ([1:length(ecog_data)])./ecog_FS_old;
emg_times = ([1:length(emg_data)])./emg_FS;
plot(emg_times(1:(30*emg_FS)),emg_data(1:(30*emg_FS)),'r');
hold on;
% plot((pulse_times(1:end-10)./emg_FS),emg_data(pulse_times(1:end-10)),'bo');
% hold on;
plot(ecog_times(1:(30*ecog_FS_old)),(ecog_data(1:(30*ecog_FS_old)).*1000000)*-1+200000,'k');

display('mark begining pulses on external data first (red), then brain radio data')
vector = NaN(1,2);
vector2 = NaN(1,2);

    [vector(1,1),~]=ginput(1);
    [vector2(1,1),~]=ginput(1);

offset_use = abs(vector(1,1)-vector2(1,1));
close all;
%figure;
plot(emg_times((length(emg_times)-(30*emg_FS)):length(emg_times)),emg_data((length(emg_times)-(30*emg_FS)):length(emg_times)),'r');
hold on;
% plot((pulse_times(1:end-10)./emg_FS),emg_data(pulse_times(1:end-10)),'bo');
% hold on;
plot(ecog_times((length(ecog_times)-(30*ecog_FS_old)):length(ecog_times)),((ecog_data((length(ecog_times)-(30*ecog_FS_old)):length(ecog_times)).*1000000))*-1+200000,'k');

display('mark end pulses on external data (red) first, then brain radio data')

[vector(1,2),~]=ginput(1);
[vector2(1,2),~]=ginput(1);

close all;

offset1 =  abs((diff(vector))); %this is the real time
offset2 =  abs((diff(vector2))); %this is real time

ecog_FS = round((offset2*ecog_FS_old./offset1));

% emg_data = emg.chan(1,1).raw;
% ecog_data = ecog.contact_pair(1,1).remontaged_ecog_signal;
% ecog_data2 = ecog.contact_pair(1,2).remontaged_ecog_signal;
% ecog_times = ([1:length(ecog_data)])./ecog_FS;
% emg_times = ([1:length(emg_data)])./emg_FS;
% plot(emg_times,emg_data,'r');
% hold on;
% % plot((pulse_times(1:end-10)./emg_FS),emg_data(pulse_times(1:end-10)),'bo');
% % hold on;
% plot(ecog_times,((ecog_data.*1000000))*-1+600000,'k');
% 
% 
% 
% %find relaible pulse (ideally first of last of trai), and mark on each.
% 
% vector = NaN(1,2);
% for e = 1:2
%     [vector(1,e),~]=ginput(1);
% end
% 
% offset = (abs(diff(vector))); %this is in time
offset = offset_use;
ecog_cut = [zeros(1,round(offset.*ecog_FS)) ecog_data];
ecog_cut2 = [zeros(1,round(offset.*ecog_FS)) ecog_data2];

ecog_times_new = [1:length(ecog_cut)]./ecog_FS;

plot(emg_times,emg_data,'r');
hold on;
plot(ecog_times_new,((ecog_cut.*-100000))+3000,'k');
%plot(ecog_times_new,((ecog_cut.*100000))-50000,'k');

%check if it matches up if so....
ecog.contact_pair(1,1).remontaged_ecog_signal = ecog_cut;
ecog.contact_pair(1,2).remontaged_ecog_signal = ecog_cut2;
ecog.synch_STN_time = offset;

Fs_ecog = ecog_FS;

save 'brpd09_6month_dbsoff_ipad_synch_ecog.mat' ecog emg Fs_ecog Fs_emg aux