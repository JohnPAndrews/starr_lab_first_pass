function plot_ipad_data_nicki_json(event_indices,ecog,ecogsr,figdir,timeparams)
addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/eeglab14_1_0b'));

%load ecog file
%load event file
num_channels = 2;  % ecog / lfp
areas = {'lfp','ecog'};
% for ch_index = 1:num_channels
%     ecog.contact_pair(1,ch_index).remontaged_ecog_signal =  ecog.contact_pair(1,ch_index).raw_ecog_signal - ecog.contact_pair(1,ch_index+1).raw_ecog_signal;
% end
start_epoch_at_this_time    = timeparams.start_epoch_at_this_time;%-8000; % ms relative to event (before), these are set for whole analysis
stop_epoch_at_this_time     = timeparams.stop_epoch_at_this_time; % ms relative to event (after)
start_baseline_at_this_time = timeparams.start_baseline_at_this_time;%-6500; % ms relative to event (before), recommend using ~500 ms *note in the msns folder there is a modified version where you can set baseline bounds by trial (good for varible times, ex. SSD)
stop_baseline_at_this_time  = timeparams.stop_baseline_at_this_time;%5-6000; % ms relative to event
start_window_at_this_time   = -500;
minimum_frequency=5;%lowest freq to examine
maximum_frequency=128;
number_of_frequencies = 128;
minimum_frequency_step_size = .5;
sampling_rate = ecogsr;

center_frequencies=...     %picking frequencies to break up into
    make_center_frequencies(...  %generates a 128 point vector from min to max freq
    minimum_frequency,...           %with step size at least step size
    maximum_frequency,...          %and more spacing at the higher freq
    number_of_frequencies,...
    minimum_frequency_step_size)';


[epoch_time,...
    start_epoch_at_this_sample_point,...
    stop_epoch_at_this_sample_point,...
    start_baseline_at_this_sample_point,...
    stop_baseline_at_this_sample_point,...
    number_of_sample_points_in_epoch]=...
    make_epoch_time(...
    start_epoch_at_this_time,...
    stop_epoch_at_this_time,...
    start_baseline_at_this_time,...
    stop_baseline_at_this_time,...
    sampling_rate);


for ch_index = 1:num_channels
    
    signal = ecog.(areas{ch_index})';
    number_of_sample_points_in_signal=length(signal(1,:));
    number_of_conditions=1;  %event indices are cell arrays by condions
    number_of_epochs_per_condition=length(event_indices);
    
    
    
    %calculate whole spectorgram
    if ch_index == 1
        ertf=zeros(...                          %initialize variables
            number_of_frequencies,...
            number_of_sample_points_in_epoch,...
            number_of_conditions,num_channels,...
            'single');
        zertf=zeros(size(ertf),'single');
        
        prestim_ertf_mean=zeros(...  %one less dimension b/c one value per frequency
            number_of_frequencies,...
            number_of_conditions,num_channels,'single');
        
        prestim_ertf_std=zeros(...  %one less dimension b/c one value per frequency
            number_of_frequencies,...
            number_of_conditions,num_channels,'single');
        
    end
    
    for frequency_index=1:number_of_frequencies %loops through one freq at a time
        disp(number_of_frequencies-frequency_index+1)
        %         filtered_signal = eegfilt_fir1(signal,sampling_rate,center_frequencies(frequency_index) - 1,center_frequencies(frequency_index) + 1);
        filtorder = 0; % choose defaults
        revfilt = 0; % choose d efault
        epochframes = 0;
        firtypeuse = 'fir1';
        filtered_signal      = ...
            eegfilt(signal,sampling_rate,center_frequencies(frequency_index) - 1,center_frequencies(frequency_index) + 1,...
            epochframes,filtorder, revfilt, firtypeuse);
        
        analytic_signal = hilbert(filtered_signal);
        % make z-scored event-related time-frequency (zertf)
        for condition=1:number_of_conditions
            
            [ertf(frequency_index,:,condition,ch_index),...   %generated a variable zertf (frequencies, time, conditons)
                zertf(frequency_index,:,condition,ch_index),... %ertf is the raw average amplitude values, zertf does the permutations
                prestim_ertf_mean(frequency_index,condition,ch_index),...
                prestim_ertf_std(frequency_index,condition,ch_index)]=...
                make_zertf_and_zitc_for_many_ipad_eegfilt(...
                analytic_signal,...
                event_indices,...
                start_epoch_at_this_sample_point,...
                stop_epoch_at_this_sample_point,...
                start_baseline_at_this_sample_point,...
                stop_baseline_at_this_sample_point);
        end
    end
end

fnmsv = fullfile(figdir,sprintf('analyzed_ipad_data_json_%s.mat',timeparams.analysis ));
save(fnmsv);

%% plot
hfig = figure;
for ch_plot = 1:num_channels
    for condition=1:1
        h = subplot(2,2,ch_plot);
        cmax=3;%max(abs(squeeze(zertf(:))));
        cmin=-cmax;
        tempmat=double(squeeze(zertf(:,:,condition,ch_plot)));
        pcolor(epoch_time,center_frequencies,tempmat);
        shading interp;
        caxis([cmin cmax]);
        colorbar;
        hold on;
        %         contour(epoch_time,center_frequencies,tempmat,...
        %             threshold*[1 1],'k');
        %         contour(epoch_time,center_frequencies,tempmat,...
        %             -threshold*[1 1],'r');
        hold off;
        if ecog.med; meds = 'on'; else meds = 'off'; end
        if ecog.stim; stims = 'on'; else stims = 'off'; end
        elec = ecog.(sprintf('%s_elec',areas{ch_plot}));
        ttluse = sprintf('%s %s meds %s stim e %s',...
            areas{ch_plot},meds,stims,elec);
        title(ttluse, 'FontWeight', 'bold','FontSize',16);
        hold on;
        set(h,'YScale','log');
        set(h,'YTick',[2.5 4 8 16 32 64 128 250]);
        %         plot(ones(1,length(center_frequencies)).*500,center_frequencies);
        %         hold on;
        plot(zeros(1,length(center_frequencies)),center_frequencies,...
            'LineWidth',2,...
            'Color',[0.1 0.1 0.1 0.7]);
        if timeparams.extralines
            plot(zeros(1,length(center_frequencies))+timeparams.extralinesec,center_frequencies,...
                'LineWidth',2,...
                'Color',[0.2 0.2 0.2 0.7]);
        end
        hold on;
        xlabel('time (msec)');
        ylabel('power');
        
        h=subplot(2,2,ch_plot+2);
        cmax=3;%max(abs(squeeze(zertf(:))));
        cmin=-cmax;
        tempmat=double(squeeze(zertf(:,:,condition,ch_plot)));
        pcolor(epoch_time,center_frequencies,tempmat);
        shading interp;
        caxis([cmin cmax]);
        colorbar;
        hold on;
        hold off;
        title(ttluse, 'FontWeight', 'bold','FontSize',16);
        hold on;
        
        plot([0 0 ],[h.YLim ],...
            'LineWidth',2,...
            'Color',[0.1 0.1 0.1 0.7]);        xlabel('time (msec)');
        if timeparams.extralines
            plot([timeparams.extralinesec timeparams.extralinesec],[h.YLim ],...
                'LineWidth',2,...
                'Color',[0.2 0.2 0.2 0.7]);
        end
        ylabel('power');
        hold on;
    end
end

ttlfig = sprintf('iPad %s meds %s stim',meds,stims);
set(findall(hfig,'-property','FontSize'),'FontSize',12)
% suptitle(ttlfig);
fnmsv = sprintf('ipad_spectrogram_%s_%s-meds-%stim.fig',meds,stims,timeparams.analysis);
saveas(hfig,fullfile(figdir,fnmsv));
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [14 8];
hfig.PaperPosition = [0 0 14 8];
fnmsv = sprintf('ipad_spectrogram_%s_%s-meds-%stim.jpeg',meds,stims,timeparams.analysis);
print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r600');
% print(hfig,fullfile(figdir,fnmsv),'-dpdf');

close(hfig);
end
