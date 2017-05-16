%open .bdf EEG file, filter, organize channels and labels, and save in .mat format
clear all

%user defined variables
input_dir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data/Ryder/6_month';
input_file = 'pdbr03_ipad_ondbs_post'; %without .bdf extension
output_dir = [input_dir '\preprocessed'];

eeg_channels = [1:64];
emg_channels = [65 66; 67 68]; %channels which were used for EMG recordings (each pair was used for 1 muscle so make it a matrix with 2 columns)
emg_labels = {'R bicep', 'R ECR'}; 
aux_channels = [74]; %auxiliary channels like ipad sound, accelerometer, ear/mastoid channels (vector) 
aux_labels = {'R wrist accel' 'ipad'}; 
unused_eeg_channels = []; %unused EEG channels indices (they may have been disconnected due to head incisions postop OR they are too noisy); vector; data in those channels will be set to 0

% eeg_channels = [1:32];   %channels which were used for EEG recordings; set to [1:64] or [1:32]
% emg_channels = [33 34; 35 36; 37 38; 39 40]; %channels which were used for EMG recordings (each pair was used for 1 muscle so make it a matrix with 2 columns)
% emg_labels = {'R biceps', 'R ECU', 'R ant tib', 'R nasalis'}; 
% aux_channels = []; %auxiliary channels like ipad sound and accelerometer (vector) 
% %aux_labels = {'L ear', 'R ear', 'finger accelerometer'}; 
% aux_labels = {};
% unused_eeg_channels = []; %unused EEG channels indices (they may have been disconnected due to head incisions postop OR they are too noisy); vector; data in those channels will be set to 0

eeg_locutoff = 1;     %low cutoff frequency for EEG and AUX filtering, set to -1 if not using; 1 for all 
eeg_hicutoff = -1;    %high cutoff frequency for EEG and AUX filtering, set to -1 if not using; (-1 for evoked potentials, 1000 otherwise)
eeg_filter_order = 3;  %filter order for eeg processing; 4000 for fir1, 3 for butter
emg_locutoff = 20;     %low cutoff frequency for EMG filtering, set to -1 if not using; 20 for all
emg_hicutoff = -1;    %high cutoff frequency for EMG filtering, set to -1 if not using; (-1 for evoked potentials, 1000 otherwise)
emg_filter_order = 3; %filter order for emg processing; 4000 for fir1, 3 for butter

notch_freq_vector = []; %frequencies where to apply notch filter; leave blank if notch filtering not desired
notch_filter_on = 0; %1 to apply notch filter to saved pre-processed data, 0 not to apply. If set to 0, notch filter will be applied only to data used for artifact rejection.

%THESE VARIABLES ARE FOR ARTIFACT REJECTION DATASET ONLY (eg resampled and refiltered data will not be saved to preprocessed file)
%new sample frequency will be resample_factor_eeg2*(old_samp_freq/resample_factor_eeg)
%script will only resample if original sampling freq > 2048Hz 
resample_factor_eeg2 = 1; %should be 1 if samp freq 16kHz (that will downsample to 2048Hz)
resample_factor_eeg = 8;  %should be 8 if samp freq 16kHz (that will downsample to 2048Hz)
eeg_artifact_locutoff = -1;     %low cutoff frequency for EEG filtering, set to -1 if not using; set to 1 for DBS ON files, set to 1 for evoked potential files; otherwise -1 
eeg_artifact_hicutoff = -1;    %high cutoff frequency for EEG filtering, set to -1 if not using %set to 50 for DBS ON files, set to 1000 for evoked potential files; otherwise -1
eeg_artifact_filter_order = 750; %filter order for fir1 filter for eeg processing (keep as fir1 because butter does not do well with 50Hz hicutoff)
%analysis_channels = {'Fp1' 'AF7' 'C3' 'C1' 'Cz' 'C2' 'C4' 'FC3' 'FC1' 'FCz' 'FC2' 'FC4' 'CP3' 'CP1' 'CPz' 'CP2' 'CP4'}; %uncomment this is wanting to display only certain channels for artifact removal

%%%END OF USER DEFINED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%read in EEG file
EEG = pop_fileio(fullfile(input_dir , [input_file '.bdf']));

%extract channel labels 
channel_labels = cell(EEG.nbchan, 1);
for i = 1:EEG.nbchan
    channel_labels(i) = cellstr(EEG.chanlocs(i).labels);  %%extract channel names from eeglab EEG data structure and create cell array 
end    

fprintf('\nAnalyzing file: %s\n', [input_dir '\' input_file '.bdf'])
fprintf('Loaded file contains %f min of data, %d channels (%d unused)\n', EEG.pnts/EEG.srate/60, EEG.nbchan, length(unused_eeg_channels))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%remove mean signal from each channel (DC offset)  
disp('Removing mean from each channel')
for chan = 1:EEG.nbchan
        EEG.data(chan,:) = double(EEG.data(chan,:)) - mean(double(EEG.data(chan,:))); %remove mean signal from each channel (DC shift)   
end

%remove all freqs in notch_freq_vector
if (~isempty(notch_freq_vector) && notch_filter_on)
    fprintf('Performing notch filtering on all data +/- 2Hz ...\n');
    for i = notch_freq_vector
        [b,a] = butter(eeg_filter_order, [i-2 i+2]./(EEG.srate/2),'stop');
        for chan = 1:EEG.nbchan
            EEG.data(chan,:) = filtfilt(b,a, double(EEG.data(chan,:)));
        end
    end
end

% %resample data
% eeg_down = [];
% for chan = 1:EEG.nbchan
% 	eeg_down(chan,:) = resample(double(EEG.data(chan,:)), 1, 2); 
% end
% EEG.data = eeg_down; clear eeg_down; 
% EEG.times = EEG.times(1:2:length(EEG.times));
% EEG.srate = EEG.srate/2;
% EEG.pnts = EEG.pnts/2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%filter data
beeg = [];
if (eeg_hicutoff > -1 && eeg_locutoff > -1)
    [beeg,a] = butter(eeg_filter_order, [eeg_locutoff, eeg_hicutoff]./(EEG.srate/2),'bandpass');
elseif (eeg_locutoff > -1)
    [beeg,a] = butter(eeg_filter_order, eeg_locutoff/(EEG.srate/2),'high');
elseif (eeg_hicutoff > -1)
    [beeg,a] = butter(eeg_filter_order, eeg_hicutoff/(EEG.srate/2),'low');    
end

if (length(beeg) > 1)
    disp('Filtering EEG and AUX data')
    for chan = eeg_channels
        EEG.data(chan,:) = filtfilt(beeg, a, double(EEG.data(chan,:)));   %filtfilt (zero phase filtering);
    end 
    for chan = reshape(aux_channels, 1, numel(aux_channels))
        EEG.data(chan,:) = filtfilt(beeg, a, double(EEG.data(chan,:)));   
    end 
    for chan = unused_eeg_channels
        EEG.data(chan,:) = zeros(1,EEG.pnts);  %set unused channels to 0  
    end
end

bemg= [];
if (emg_hicutoff > -1 && emg_locutoff > -1)
    [bemg,a] = butter(emg_filter_order, [emg_locutoff, emg_hicutoff]./(EEG.srate/2),'bandpass');
elseif (emg_locutoff > -1)
    [bemg,a] = butter(emg_filter_order, emg_locutoff/(EEG.srate/2),'high');
elseif (emg_hicutoff > -1)
    [bemg,a] = butter(emg_filter_order, emg_hicutoff/(EEG.srate/2),'low');  
end

if (length(bemg) > 1)
    disp('Filtering EMG data')
    for chan = reshape(emg_channels, 1, numel(emg_channels))
        EEG.data(chan,:) = filtfilt(bemg, a, double(EEG.data(chan,:)));   
    end 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%process EEG for artifact removal; create eeg_downsampled matrix (if sampling freq > 2048Hz); filter if desired 
%In theory, low pass filtering should be done before resampling (to avoid aliasing) but this data is used only for artifact rejection so resampling first to speed up filtering

if (~exist('analysis_channels', 'var'))
    analysis_channels = channel_labels(eeg_channels);
end

channels_ind = [];  
for i = 1:length(analysis_channels)
    flag = 0; ch_label = analysis_channels{i};
    for j = 1:length(channel_labels)
            if strcmp(channel_labels(j), ch_label)
                channels_ind = [channels_ind j]; flag = 1; break
            end
    end 
    if (flag == 0)
        fprintf('WARNING: Could not find channel %s in channel_labels.\n', ch_label)
    end    
end 
if (isempty(channels_ind))
    fprintf('ERROR: Could not find any channels for artifact analysis...exiting\n')
    return; 
end    

%downsample (only if sampling freq > 2048Hz)
if (EEG.srate > 2048)
    eeg_downsampled = [];
    for chan = channels_ind %eeg_channels
        eeg_downsampled(chan,:) = resample(double(EEG.data(chan,:)), resample_factor_eeg2, resample_factor_eeg); 
    end
    samp_freq_downsampled = EEG.srate*resample_factor_eeg2/resample_factor_eeg;
    fprintf('Downsampled frequency is %f ...this dataset will only be used for visual artifact removal\n', samp_freq_downsampled)
else
	disp('No downsampling since original sampling rate is 2048 Hz')
	eeg_downsampled = double(EEG.data(channels_ind,:));
	samp_freq_downsampled = EEG.srate; 
end

%filter %USE FIR1 because butter3 does not work for 50Hz low pass filter (used for DBS files)
bdeeg = [];
if (eeg_artifact_hicutoff > -1 && eeg_artifact_locutoff > -1)
    [bdeeg,a] = fir1(eeg_artifact_filter_order, [eeg_artifact_locutoff, eeg_artifact_hicutoff]./(samp_freq_downsampled/2),'bandpass');
elseif (eeg_artifact_locutoff > -1)
    [bdeeg,a] = fir1(eeg_artifact_filter_order, eeg_artifact_locutoff/(samp_freq_downsampled/2),'high');
elseif (eeg_artifact_hicutoff > -1)
    [bdeeg,a] = fir1(eeg_artifact_filter_order, eeg_artifact_hicutoff/(samp_freq_downsampled/2),'low');    
end
if (length(bdeeg) > 1)
    disp('Filtering EEG data for artifact removal')
    for chan = 1:size(eeg_downsampled,1)
        eeg_downsampled(chan,:) = filtfilt(bdeeg, 1, eeg_downsampled(chan,:));   %filtfilt (zero phase filtering);
    end 
    for chan = unused_eeg_channels
        eeg_downsampled(chan,:) = zeros(1,size(eeg_downsampled,2));  %set unused channels to 0  
    end
else
    disp('Data for artifact removal is NOT being filtered')
end   
 
%notch filtering (if not already applied above)
if (~isempty(notch_freq_vector) && notch_filter_on == 0)
    fprintf('Performing notch filtering on artifact rejecton EEG (will not be saved) ...\n');
    for i = notch_freq_vector
        [b,a] = fir1(eeg_artifact_filter_order, [i-2 i+2]./(samp_freq_downsampled/2),'stop'); 
        for chan = eeg_channels
            eeg_downsampled(chan,:) = filtfilt(b,a, eeg_downsampled(chan,:));
        end
    end
end

%set 'average' montage
avg_signal = mean(eeg_downsampled(setdiff([1:size(eeg_downsampled,1)],unused_eeg_channels),:)); 
for i = 1:size(eeg_downsampled,1)
	eeg_downsampled(i,:) = eeg_downsampled(i,:) - avg_signal; 
	if (ismember(i, unused_eeg_channels))  
    	eeg_downsampled(i,:) = zeros(1,length(eeg_downsampled));   %set unused channel back to zero (above line will set it to avg_signal)
	end    
end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%process data for later use in matlab format
eeg_data = zeros(length(eeg_channels), EEG.pnts);
emg_data = zeros(length(emg_channels), EEG.pnts);
aux_data = zeros(length(aux_channels), EEG.pnts);

for i = 1:length(eeg_channels)
    eeg_data(i,:) = EEG.data(eeg_channels(i),:);  
end 
eeg_channel_labels = channel_labels(eeg_channels);

num_muscles = size(emg_channels,1); 
for i = 1:num_muscles
    emg_data(i,:) = EEG.data(emg_channels(i,1),:) - EEG.data(emg_channels(i,2),:);  %EMG should always be bipolar recorded
end 

for i = 1:length(aux_channels)
    aux_data(i,:) = EEG.data(aux_channels(i),:);  
end 
samp_freq = EEG.srate; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot data 

 eegplot(eeg_downsampled, 'srate', samp_freq_downsampled, 'title', 'Processed EEG data for artifact removal') 
 eegplot(eeg_data, 'srate', EEG.srate, 'title', 'Original EEG data')  
%eegplot(emg_data, 'srate', EEG.srate, 'title', 'EMG data') 
%eegplot(EEG.data(65:end,:), 'srate', EEG.srate, 'title', 'All non-eeg channels')

my_T = (1/EEG.srate)*[0:length(eeg_data)-1];

if (~isempty(emg_channels > 0))
figure()
for i = 1:num_muscles
    subplot(num_muscles, 1, i)
    plot(my_T, emg_data(i,:))
    title(['EMG ' num2str(i) ' '  char(emg_labels(i))])
end 
end

if (~isempty(aux_channels > 0))
figure()
for i = 1:length(aux_channels)
    subplot(length(aux_channels), 1, i)
    plot(my_T, aux_data(i,:))
    title(['AUX ' num2str(i) ' '  char(aux_labels(i))])
end 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%prepare variables
move_start = []; move_stop = []; hold_start = []; hold_stop = []; %for rest files, set these all to []
rej_orig_samp_freq = []; rej_time = [];
if (~isempty(notch_freq_vector) && notch_filter_on == 1)
    add_label = '_notch'; 
    for i = 1:length(notch_freq_vector)
        add_label = strcat(add_label, num2str(notch_freq_vector(i)));
    end
else
    add_label = ''; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

error('RUN movement detection script manually, if movement detection needed')
%emg_data, aux_data, samp_rate, EMG_channel (change manually to which muscle should be used for movement detection), AUX_channel (change manually to accelerometer channel), 
%std_thresh (change manually 0.5-4), mvmt_combine_time (usually 2 sec, activity separated by less than X sec will be considered part of the same movement), 
%reverse_signal (usually 0; set to 1 to use aux channel for movement detection), min_hold_duration (minimum duration for hold section, leave at 3)
%IF NOT PICKING UP SHORT MOVEMENTS, CHANGE unintended_move_length to 1 in SMdetect_movement_EEG
[move_start, move_stop, hold_start, hold_stop] = SMdetect_movement_EEG(emg_data, aux_data, EEG.srate, 2, 1, 3, 1, 0, 3);  

exclude_move_section = [];  %set to exclude certain movement sections (must be done manually, count which MOVE (black) section on the movement analysis graph)
exclude_hold_section = [];  %set to exclude certain movement sections (must be done manually, count which HOLD (green) section on the movement analysis graph)

move_start(exclude_move_section) = [];
move_stop(exclude_move_section) = [];
hold_start(exclude_hold_section) = [];
hold_stop(exclude_hold_section) = [];
 
%manually select artifacts (select artifact segments visually, then choose 'File' > 'Accept and Close', and Rejections will be saved in variable TMPREJ)
error('SELECT ARTIFACT SEGMENTS MANUALLY, THEN GO TO FIGURE > ACCEPT&CLOSE, THEN EXECUTE REMAINDER OF THE SCRIPT')

rej1 = TMPREJ(:,1:2);  %TMPREJ has 78 columns (not sure why), first two columns are start and stop points for the manually-chosen segments (in data points)
rej=sortrows(rej1); %artifact sections will be not be ordered temporally, if they were not chosen like that, so need to sort in ascending order
rej_time = rej./samp_freq_downsampled; %convert to seconds 
rej_orig_samp_freq = (EEG.srate/samp_freq_downsampled)*rej; %convert to original sampling frequency points
rej_time_orig_samp_freq = rej_orig_samp_freq./EEG.srate; %convert to seconds

%save processed file
save([output_dir '\' input_file '_f_' num2str(eeg_locutoff) '_' num2str(eeg_hicutoff), '_butterOrd' num2str(eeg_filter_order) '_' num2str(length(eeg_channels)) 'ch' add_label '.mat'], ...
    'eeg_data', 'emg_data', 'aux_data', 'samp_freq', 'unused_eeg_channels', 'eeg_channel_labels', 'emg_labels', 'aux_labels', 'move_start', 'move_stop', 'hold_start', ...
    'hold_stop', 'rej_orig_samp_freq', 'rej_time');

% %use this if appending new eeg, emg and aux data to existing file (it will only update specified variables)
% save([output_dir '\' input_file '_f_' num2str(eeg_locutoff) '_' num2str(eeg_hicutoff), '_butterOrd' num2str(eeg_filter_order) '_' num2str(length(eeg_channels)) 'ch' add_label '.mat'], ...
%     'emg_data', 'eeg_data', 'aux_data', '-append');

% %use this if appending new move/hold times to existing file (it will only update specified variables)
% save([output_dir '\' input_file '_f_' num2str(eeg_locutoff) '_' num2str(eeg_hicutoff), '_butterOrd' num2str(eeg_filter_order) '_' num2str(length(eeg_channels)) 'ch' add_label '.mat'], ...
%     'move_start', 'move_stop', 'hold_start', 'hold_stop', '-append');


