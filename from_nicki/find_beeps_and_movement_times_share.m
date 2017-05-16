%find movement onsets for EEG data

%start out by plotting ipad channel and making sure you can visually see
%what is real
%also plot both emg channels and decide which to use for automatic
%detection
ipad_number = 1;
accel_number = 2;
num_trials = 20; %20
time_to_go = 8; %8, time from beep to go cue in seconds (may be a bit inexact b/c of ipad timing noise)u
use_emg = 1;
use_accel = 1;
if use_emg == 1
emg_detect = 1;
end
if use_accel == 1
accel_detect = abs(aux.chan(1,accel_number).raw); %to account for negative deflextions
accel_plot = aux.chan(1,accel_number).raw;
end
ipad_chan = aux.chan(1,ipad_number).raw;
%ipad_chan = ipad_chan - mean(ipad_chan);

plot_ipad = abs(ipad_chan);
indexes = nan(1,2);

display('mark time indexes');

for n = 1:2
    plot(plot_ipad);
    [indexes(n),~] = ginput(1);
end

indexes = round(indexes);
plot_ipad = plot_ipad - mean(plot_ipad(indexes(1):indexes(2)));

threshold_bounds = nan(1,2);

display('mark threshold');
for n = 1:1
plot(plot_ipad(indexes(1):indexes(2)));
[~,threshold_bounds(n)] = ginput(1);
end


%threshold_bounds(2) = threshold_bounds(2)+1000; %this is just in case it plots so that it is hard to click above the tallest peak
%beeps = find(plot_ipad(indexes(1):indexes(2))>threshold_bounds(1)&plot_ipad(indexes(1):indexes(2))<threshold_bounds(2));
beeps = find(plot_ipad(indexes(1):indexes(2))>threshold_bounds(1));
bad_beeps = find(diff(beeps)<300);
beeps(bad_beeps+1) = [];

beeps = beeps +indexes(1) - 1;

beeps(end) = []; 

if size(beeps,2)~=num_trials
    display('incorrect number of beeps!!!');
end

%check if beeps are good.
plot(aux.chan(1,1).raw);
hold on;
scatter(beeps,aux.chan(1,1).raw(beeps),'r');

ok_beeps = input('is this ok? 1 if yes, 0 if no');
if ok_beeps==1
    close all
%%
%now auto-detect move onset
if use_emg ~=0
for emg_process = 1:size(emg.chan,2)-1
emg_filt(emg_process,:) = eegfilt(emg.chan(1,emg_process+1).raw,Fs_emg,2,[]);
end
emg_plot = abs(emg_filt(emg_detect,:)).*100;
plot(emg_plot);
hold on;
end
if use_accel ~=0
    hold on;
    plot(accel_detect,'r');
end
plot_range = nan(1,2);
for n=1:2
    display('indicate range to plot');
[plot_range(n),~] = ginput(1);
end
close all;

if use_accel~=0
    plot(accel_detect(plot_range(1):plot_range(2)),'r');
    hold on;
end
if use_emg ~=0
plot(emg_plot(plot_range(1):plot_range(2)));
hold on;
end
choice = input('do you want to use emg or accel to mark? 1 emg, 2 accel');

display('mark_threshold')
[~,emg_thresh] = ginput(1);

emg_auto = nan(1,20);
for trials = 1:num_trials
    data_check = beeps(trials) + time_to_go.*Fs_emg;
    if choice == 1
    temp = find(emg_plot(data_check:end)>emg_thresh);
    emg_auto(trials) = temp(1)+data_check -1;
    else
       temp = find(accel_detect(data_check:end)>emg_thresh);
    emg_auto(trials) = temp(1)+data_check -1;
    end
end
colors = ['b' 'r' 'k' 'c'];
emg_verify = emg_auto;
time_range = [time_to_go - 3 time_to_go+3];
for trials = 1:num_trials
    if use_emg == 0
        emg_traces = 0;
    end
    figure;
    if use_emg ~=0
    emg_order = [2 1];
    for emg_traces = 1:size(emg.chan,2)-1
    plot((emg_filt(emg_order(emg_traces),[beeps(trials)+[(time_range(1).*Fs_emg):(time_range(2).*Fs_emg)]])-(700*(emg_order(emg_traces)-1))).*100,colors(emg_traces));
    hold on;
    end
    end
    if use_accel ~=0
        emg_traces = emg_traces+1;
        plot((accel_plot([beeps(trials)+[(time_range(1).*Fs_emg):(time_range(2).*Fs_emg)]])./10)-700*(emg_traces-1),colors(emg_traces));
    end
    hold on;
    yL = get(gca,'YLim');
    line([emg_auto(trials)-beeps(trials)-[(time_range(1).*Fs_emg)]+1 emg_auto(trials)-beeps(trials)-[(time_range(1).*Fs_emg)]+1],yL,'Color','k');
    n=input('is onset good? 1 yes, 0 no, 3 exclude');
    if n == 0
        [x,~] = ginput(1);
        emg_verify(trials) = x + beeps(trials)+[(time_range(1).*Fs_emg)] - 1;
    end
    if n == 3
        emg_verify(trials) = NaN;
    end
    close all;
end
remove_trials = find(isnan(emg_verify));
emg_verify(remove_trials) = [];
emg_verify = round(emg_verify);
if choice == 1
plot(emg_plot);
else
    plot(accel_plot);
end
hold on;
scatter(emg_verify,emg_plot(emg_verify),'r');

    
commit = input('are you happy? 1 is yes, 0 no');
if commit == 1
    time_events = emg_verify./Fs_emg; %convert to time
    event_indices{1,1} = round(time_events.*Fs_ecog); %convert to ecog time stamps
    save movement_onsets event_indices 
end
end