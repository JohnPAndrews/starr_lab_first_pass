%%convert ipad data recorded with EEG.
%clear all;

%EEG = pop_biosig('filename');

for chan = 1:size(EEG.data,1)
    EEG.data(chan,:) = EEG.data(chan,:) - mean(double(EEG.data(chan,:))); %remove mean of each channel
end

Fs_ecog = 794; %sampling rate for brain radio
Fs_emg = EEG.srate;%sampling rate for EEG

D = dir('*MR_1.txt');
file_num = 1;

FID = fopen(D(file_num).name);
 C = textscan(FID,'%f%f%f%f%f%f','Delimiter',',');
 fclose(FID);
 
 ecog.contact_pair(1,1).remontaged_ecog_signal = C{1,1}';
 ecog.contact_pair(1,2).remontaged_ecog_signal = C{1,3}'; 
 
 emg.chan(1,1).raw = EEG.data(65,:) - EEG.data(66,:); %channel to synchronize data
 emg.chan(1,2).raw = EEG.data(67,:) - EEG.data(68,:);%emg 1 (usually ECR)
 emg.chan(1,3).raw = EEG.data(69,:) - EEG.data(70,:);%emg 2 (usually deltoid)
 
 
 if size(EEG.data,1) > 75
 aux.chan(1,1).raw = EEG.data(75,:);
 aux.chan(1,2).raw = EEG.data(76,:); %74 accelerometer if present
 else
 aux.chan(1,1).raw = EEG.data(73,:); %73 ipad audio 
 aux.chan(1,2).raw = EEG.data(74,:);
 end
 
 %save ecog emg aux Fs_ecog Fs_emg
 %save('filename.mat');
 