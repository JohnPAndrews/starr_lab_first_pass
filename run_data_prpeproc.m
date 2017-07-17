function outdata = run_data_prpeproc(dat,params)
%% this function runs a bunch of preprocessing steps on data
addpath(genpath(fullfile(pwd,'toolboxes','eeglab14_1_0b')));
if isempty(dat) % give sturccture with empty fieldsnames
    fieldnamesuse = {   ...
                        'psd_tr_ofst'
                        'psd_tr_ofst_freq'
                        'psd_tr_ofst_conf'
                        'psd_tr_ofst_peaks'
                        'psd_tr_ofst_peaks_beta_peak_exist'
                        'psd_tr_ofst_peaks_beta_peak_val'
                        'psd_tr_ofst_out_zscr'
                        'psd_tr_ofst_out_zscr_freq'
                        'psd_tr_ofst_out_zscr_conf'
                        'psd_tr_ofst_out_zscr_peaks'
                        'psd_tr_ofst_out_zscr_peaks_beta_peak_exist'
                        'psd_tr_ofst_out_zscr_peaks_beta_peak_val'
                        'freqranges'
                        'freqnames'
                        'Delta_raw'
                        'Delta_avg'
                        'Delta_max'
                        'Theta_raw'
                        'Theta_avg'
                        'Theta_max'
                        'Alpha_raw'
                        'Alpha_avg'
                        'Alpha_max'
                        'LowBeta_raw'
                        'LowBeta_avg'
                        'LowBeta_max'
                        'HighBeta_raw'
                        'HighBeta_avg'
                        'HighBeta_max'
                        'Beta_raw'
                        'Beta_avg'
                        'Beta_max'
                        'LowGamma_raw'
                        'LowGamma_avg'
                        'LowGamma_max'
                        'HighGamma_raw'
                        'HighGamma_avg'
                        'HighGamma_max'
                        };
    for f = 1:length(fieldnamesuse)
        outdata.(fieldnamesuse{f}) = []; 
    end
else
    try
        if sum(isnan(dat))
            warning(sprintf('found %d nans in raw data',sum(isnan(dat)))); 
            dat = dat(~isnan(dat));
        end
        % trim data
        dattrim = preproc_trim_data(dat,params.msec2trim, params.sr);
        % dc offset
        data_tr_prp = preproc_dc_offset_high_pass(dattrim,params);
        [psdout,freq,pxxc] = pwelch(data_tr_prp, gausswin(5e3),floor(5e3*0.6),1:1:400,params.sr,'psd');
        outdata.psd_tr_ofst = log10(psdout);
        outdata.psd_tr_ofst_freq = freq;
        outdata.psd_tr_ofst_conf = log10(pxxc);
        outdata.psd_tr_ofst_peaks = findPeaksFromPSDconf(psdout,freq, pxxc,0);% psd, conf intervals, plot (0 = no);
        pkfnd = find(outdata.psd_tr_ofst_peaks(:,1) >= 13 & outdata.psd_tr_ofst_peaks(:,1) <= 30 == 1);
        if ~isempty(pkfnd);
            outdata.psd_tr_ofst_peaks_beta_peak_exist =  1; 
            outdata.psd_tr_ofst_peaks_beta_peak_val   =  outdata.psd_tr_ofst_peaks(pkfnd,:); 
        else
            outdata.psd_tr_ofst_peaks_beta_peak_exist = 0;
            outdata.psd_tr_ofst_peaks_beta_peak_val   = NaN;
        end
        
        % zscore + delete outliers
        data_no_out = zscore(deleteoutliers(data_tr_prp,0.05));
        [psdout,freq,pxxc] = pwelch(data_no_out, gausswin(5e3),floor(5e3*0.6),1:1:400,params.sr,'psd');
        outdata.psd_tr_ofst_out_zscr = log10(psdout);
        outdata.psd_tr_ofst_out_zscr_freq = freq;
        outdata.psd_tr_ofst_out_zscr_conf = log10(pxxc);
        outdata.psd_tr_ofst_out_zscr_peaks = findPeaksFromPSDconf(psdout,freq, pxxc,0);% psd, conf intervals, plot (0 = no); 
        pkfnd = find(outdata.psd_tr_ofst_out_zscr_peaks(:,1) >= 13 & outdata.psd_tr_ofst_out_zscr_peaks(:,1) <= 30 == 1);
        if ~isempty(pkfnd);
            outdata.psd_tr_ofst_out_zscr_peaks_beta_peak_exist =  1;
            outdata.psd_tr_ofst_out_zscr_peaks_beta_peak_val   =  outdata.psd_tr_ofst_out_zscr_peaks(pkfnd,:); ;
        else
            outdata.psd_tr_ofst_out_zscr_peaks_beta_peak_exist =  0;
            outdata.psd_tr_ofst_out_zscr_peaks_beta_peak_val   =  NaN;
        end
        
        
        freqranges = [1 4; 4 8; 8 13; 13 20; 20 30; 13 30; 30 50; 50 90];
        freqnames  = {'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','Beta','LowGamma','HighGamma'}';
        outdata.freqranges = freqranges; 
        outdata.freqnames = freqnames; 
        for f = 1:size(freqranges,1) 
            filtorder = 0; % choose defaults
            revfilt = 0; % choose d efault
            epochframes = 0;
            firtypeuse = 'fir1';
            %     data,srate,locutoff,hicutoff,epochframes,filtorder,revfilt,firtype,causal
            fnmuseraw = sprintf('%s_raw',freqnames{f});
            fnmuseavg = sprintf('%s_avg',freqnames{f});
            fnmusemax = sprintf('%s_max',freqnames{f});
            outdata.(fnmuseraw)      = ...
                eegfilt(data_tr_prp',params.sr,freqranges(f,1),freqranges(f,2),...
                epochframes,filtorder, revfilt, firtypeuse);
            
            [smoothdatapsd,freq,pxxc] = pwelch(outdata.(fnmuseraw), gausswin(5e3),floor(5e3*0.6),...
                freqranges(f,1):freqranges(f,2),params.sr,'psd');
            outdata.(fnmuseavg) = mean(log10(smoothdatapsd));
            outdata.(fnmusemax) = max(log10(smoothdatapsd));

        end
        return;
        % for each freq range plot, filter with eegfilt and record: 
        % 1. avg 
        % 2. peak 
        % 3. AUC 
        % 4. Cohernce between M1 and STN 
        
%         Delta - 1-4
%         Theta - 4-8
%         Alpha - 8 -13
%         Beta  - 13 -30
%         Low gamma - 30-50
%         High gamma - 50-90]
  
    catch
            fieldnamesuse = {   ...
                        'psd_tr_ofst'
                        'psd_tr_ofst_freq'
                        'psd_tr_ofst_conf'
                        'psd_tr_ofst_peaks'
                        'psd_tr_ofst_peaks_beta_peak_exist'
                        'psd_tr_ofst_peaks_beta_peak_val'
                        'psd_tr_ofst_out_zscr'
                        'psd_tr_ofst_out_zscr_freq'
                        'psd_tr_ofst_out_zscr_conf'
                        'psd_tr_ofst_out_zscr_peaks'
                        'psd_tr_ofst_out_zscr_peaks_beta_peak_exist'
                        'psd_tr_ofst_out_zscr_peaks_beta_peak_val'
                        'freqranges'
                        'freqnames'
                        'Delta_raw'
                        'Delta_avg'
                        'Delta_max'
                        'Theta_raw'
                        'Theta_avg'
                        'Theta_max'
                        'Alpha_raw'
                        'Alpha_avg'
                        'Alpha_max'
                        'LowBeta_raw'
                        'LowBeta_avg'
                        'LowBeta_max'
                        'HighBeta_raw'
                        'HighBeta_avg'
                        'HighBeta_max'
                        'Beta_raw'
                        'Beta_avg'
                        'Beta_max'
                        'LowGamma_raw'
                        'LowGamma_avg'
                        'LowGamma_max'
                        'HighGamma_raw'
                        'HighGamma_avg'
                        'HighGamma_max'
                        };
    for f = 1:length(fieldnamesuse)
        outdata.(fieldnamesuse{f}) = NaN; 
    end
    end
end