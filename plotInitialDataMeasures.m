function plotInitialDataMeasures(datastruc,settings,params)
data               = datastruc.data(:,params.channel2anlyze);
settings.patientid = datastruc.xmlstruc.Children(6).Children.Data;
params.sr          = str2double(datastruc.xmlstruc.Children(18).Children(20).Children.Data(1:3));
%% plot raw data
hfig      = plot_data_time_domain(data,params.sr,'Raw Data','Time (sec)','mini-volts?');
save_figure(hfig,['00_',settings.patientid],settings.figout,settings.figformat);  

%% trim first part of data, plot time, freq domain  
data_trim = preproc_trim_data(data,params.msec2trim, params.sr);
% data_trim = simulateTimeDomainSignal(); % XXXXXX GET RID OF THIS XXX 
hfig      = plot_data_time_domain(data_trim,params.sr,'Trimmed Raw Data','Time (sec)','mini-volts?');
save_figure(hfig,['01_',settings.patientid],settings.figout,settings.figformat); 

hfig      = plot_data_freq_domain(data_trim,params.sr,'PSD of trimmed data');
save_figure(hfig,['02_',settings.patientid],settings.figout,settings.figformat);  

%% remove DC offset and low freq
filt_data = preproc_dc_offset_high_pass(data_trim,params);
hfig      = plot_data_freq_domain(filt_data,params.sr,'High passed + DC offset');
save_figure(hfig,['03_',settings.patientid],settings.figout,settings.figformat);  


%% notch filter around 60Hz, 120Hz and 180Hz
notcddat  = preproc_notch_filter(filt_data,params);
hfig      = plot_data_freq_domain(notcddat,params.sr,'High passed + DC offset + notch');
save_figure(hfig,['04_',settings.patientid],settings.figout,settings.figformat);  


 
% plot ESRP 
end