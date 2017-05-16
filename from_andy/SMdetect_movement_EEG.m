% Find periods of hold and periods of movement given emg and aux data (each channel in 1 row vector), EMG channel and AUX channel (iPAD
% or accelerometer) input (any movement separated by less than 2 sec of hold (mvmt_combine_time) is considered to be part of the same movement period)
% Output is a vector times (IN SECONDS) when movement starts/stops and when hold sections start/stop (also calculates intended mvmt (lasting more than 1 sec), unintended mvmt (lasting less than 1 sec)). 
% This output is based on EMG alone; AUX data, if available, currently serves for visual confirmation only, but to use AUX data instead of EMG data, set reverse_signal to 1
% min_hold_duration is minimum length of hold section to be included in output. Movement of less than 2 sec or at very beginning or end of file will be considered unintended and not reported
% If no AUX data available, set aux_data to []. If no EMG data is available, set emg_data to [] (reverse_signal will then be automatically set to 1)


function [move_start, move_stop, hold_start, hold_stop] = SMdetect_movement_EEG(emg_data, aux_data, sampling_rate, EMG_channel, AUX_channel, std_thresh, mvmt_combine_time, reverse_signal, min_hold_duration)

% clear all
% EMG_channel = 1; 
% AUX_channel = 1;
% std_thresh = 1; %how many standard deviations above the mean signal has to be to be considered movement
% mvmt_combine_time = 2;   %should be, unless case is unusual (this is time in seconds that signal over threshold can be separated by and still be considered part of the same movement)
% reverse_signal = 0; %if 1,use AUX signal to detect movement
% emg_file = 1; %1 if using file with preprocessed emg strucure, otherwise 0
% min_hold_duration = 3; %minimum number of seconds that hold section can be to include it in analysis; WAS 5 for new patients

plot_on = 1; %1 to plot, 0 not to plot 
alter_start_end_times = 0; %keep at 0; was set to 1 in order to artificially shorten and lengthen move/hold times by 0.2 and 0.5ms (this is to catch movemnt that may be below threshold, probably not necessary but keep for consistency)
unintended_move_length = 2; %length of unintended movement in seconds (will be ignored); was 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    EMG = emg_data(EMG_channel, :); 
catch
    reverse_signal = 1; 
end    
try
    AUX = aux_data(AUX_channel, :); 
catch 
    AUX = EMG; 
end
    
if (length(EMG) ~= length(AUX))
    warning('Data duration are different for EMG and AUX');
end

if (reverse_signal == 1)
    EMG = AUX;  %use AUX to detect movement
end

num_pts = size(EMG,2);           %number of EEG data points

fprintf('SMdetect_movement_EEG...Loaded MOVEMENT data contains %f sec of data sampled at %f Hz\n', num_pts/sampling_rate, sampling_rate);

T = (1/sampling_rate)*[1:num_pts];
time_res = (1/sampling_rate);

accel_flag = 0;
if (reverse_signal == 0) %usual situation
    EMG = EMG - mean(EMG);   %so if using aux data, do not subtract the mean
else
    accel_flag = 1;
end    
if (accel_flag == 0) %usual situation
    HEMG = abs(EMG);
else
    HEMG = EMG; %if using accelerometer data, do not take abs value
end    
mean_HEMG = mean(HEMG); std_HEMG = std(HEMG); median_HEMG = median(HEMG);

if (7*median_HEMG < mean_HEMG && accel_flag == 0) %there are times with huge surge in power (this is rare)
    'thresh is mean'
    thresh = mean_HEMG;
else
    thresh = mean_HEMG+std_thresh*std_HEMG;
end  

mvmt_times_ind = find(HEMG > thresh);  %find all time points where signal is above threshold
mvmt_start = []; %in points
mvmt_stop = [];
mvmt_sec = []; mvmt = [];
int_mvmt_sec = []; int_mvmt = []; int_ct = 1; 
unint_mvmt_sec = []; unint_mvmt = []; unint_ct = 1; 
move_start = []; move_stop = [];
try
mvmt_start = [mvmt_times_ind(1)];
for j = 2:length(mvmt_times_ind)
    if (mvmt_times_ind(j) - mvmt_times_ind(j-1) <= round(mvmt_combine_time/time_res))  %if separation less than mvmt_combine_time (in seconds), that is part of the same mvmt
        continue
    else  
        mvmt_stop(length(mvmt_start)) = mvmt_times_ind(j-1); 
        mvmt_start = [mvmt_start mvmt_times_ind(j)];
    end    
end   
mvmt_stop = [mvmt_stop mvmt_times_ind(end)]; 
mvmt(:,1) = mvmt_start;  %mvmt star/stop times in points
mvmt(:,2) = mvmt_stop;
mvmt_sec(:,1) = T(mvmt_start)'; %convert from points to seconds
mvmt_sec(:,2) = T(mvmt_stop)';

%also separate movement into intended (longer) and unintended (very brief)
%if movement occur at the very beginning or end of the file, it is considered unintended
for i = 1:size(mvmt_sec,1)
    if (mvmt_sec(i, 2) - mvmt_sec(i, 1) < unintended_move_length)  %brief, unintended movement (less than 2 sec long)
        unint_mvmt_sec(unint_ct,:) = mvmt_sec(i,:);
        unint_mvmt(unint_ct,:) = mvmt(i,:);
        unint_ct = unint_ct + 1; 
    else             
        if ((mvmt_sec(i,1) - 0.1 < T(1)) | (mvmt_sec(i,2) + 0.1 > T(end))) %movement start is within 0.1sec of file beginning, or mvmt end is at file end
            unint_mvmt_sec(unint_ct,:) = mvmt_sec(i,:);
            unint_mvmt(unint_ct,:) = mvmt(i,:);
            unint_ct = unint_ct + 1;  
        else   %task-related, intended movement
            int_mvmt_sec(int_ct,:) = mvmt_sec(i,:);
            int_mvmt(int_ct,:) = mvmt(i,:);
            int_ct = int_ct + 1; 
        end    
    end
end    

move_start = int_mvmt_sec(:, 1);  %only return intended (longer) movement sections
move_stop = int_mvmt_sec(:, 2);

%pad mvmt start times and stop times by 0.2 or 0.5sec to capture periods when movement might be happening but was not above the threshold
if (alter_start_end_times == 1)
    move_start = move_start - 0.2; 
    if (move_start(1) < 0) move_start(1) = 0; end  %make sure you don't make start time negative
    move_stop = move_stop + 0.5;  
    if (move_stop(end) > T(end)) move_stop(end) = T(end); end %make sure you don't make end time beyond end of data
end

catch 
    disp(sprintf('WARNING:No movement detected with EMG signal'))
end 

if (length(move_start) > 20 || length(move_start) < 4)
    disp(sprintf('WARNING: There is an unusual number of movement epochs detected (%d) - recommend visual confirmation', length(move_start)))
end

%confirm detected movement epochs with auxiliary channels 
%AUX = AUX - mean(AUX);
aux_times_ind = find(abs(AUX) > (mean(abs(AUX))+std(abs(AUX))) );  %find all time points where signal is above threshold
aux_start = []; %AUX events in points
aux_stop = [];
aux_start_sec= []; %AUX events in seconds
aux_stop_sec= [];
try
aux_start = [aux_times_ind(1)];
for j = 2:length(aux_times_ind)
    if (aux_times_ind(j) - aux_times_ind(j-1) <= round(1/time_res))  %1 sec so part of the same aux signal
        continue
    else  
        aux_stop(length(aux_start)) = aux_times_ind(j-1); 
        aux_start = [aux_start aux_times_ind(j)];
    end    
end   
aux_stop = [aux_stop aux_times_ind(end)]; 
aux_start_sec = T(aux_start)';
aux_stop_sec = T(aux_stop)';
catch
    disp(sprintf('WARNING:No usable AUX data'))
end    

%find hold sections
hold_start = [];
hold_stop=[];
try
putative_hold_start = [0 mvmt_sec(:,2)'];
putative_hold_stop = [mvmt_sec(:,1)' num_pts/sampling_rate];

%check that hold sections are at least min_hold_duration sec long (ie do not contain brief, unintended movements)
ct = 1; 
for i = 1:length(putative_hold_start)
    if ( (putative_hold_stop(i) - putative_hold_start(i)) < min_hold_duration)  %hold section is less than min_hold_duration sec long, so it will be excluded
        continue
    else
        hold_start(ct) = putative_hold_start(i); 
        hold_stop(ct) = putative_hold_stop(i); 
        ct = ct+1;
    end
end

%shorten hold start times and stop times by 0.2 or 0.5sec to avoid periods when movement might be happening but was not above the threshold
if (alter_start_end_times == 1)
    hold_start = hold_start + 0.5; 
    hold_stop = hold_stop - 0.2; 
end    
catch
     disp(sprintf('WARNING:No usable EMG data to define hold sections'))
end    

if (plot_on ==1)
%plot EMG and AUX channel data 
figure; 
subplot(2,1,1)
plot(T, HEMG, 'r-'); 
hold on; 
plot([T(1) T(end)], thresh*[1 1], 'b-');
for i = 1:length(move_start)
    plot([move_start(i) move_stop(i)], thresh*[1.1 1.1], 'k-', 'LineWidth',2)
end
for i = 1:length(hold_start)
    plot([hold_start(i) hold_stop(i)], thresh*[0.7 0.7], 'g-', 'LineWidth',2)
end
%plot(aux_start_sec, thresh*1.5*ones(1, size(aux_sec,1)), 'c.');
title(['Blue line is EMG threshold; black line is intended movement; green line is hold'])

subplot(2,1,2)
plot(T, abs(AUX), 'r-'); 
hold on; 
for i = 1:length(aux_start_sec)
    plot([aux_start_sec(i) aux_stop_sec(i)], (mean(abs(AUX))+std(abs(AUX)))*[1 1], 'k-', 'LineWidth',2)
end
title(['AUX signal; black line is signal above threshold'])
%plot(aux_sec, (mean(abs(AUX))+std(abs(AUX)))*ones(1, size(aux_sec,1)), 'k.');
end


end