function outdata = run_data_prpeproc(dat,params)
%% this function runs a bunch of preprocessing steps on data
if isempty(dat) % give sturccture with empty fieldsnames
    outdata.psdoutlog_zscore = [];
    outdata.psdoutlogfreq_zscore= [];
    outdata.beta_psdoutlog_zscore = [];
    outdata.beta_peak_zscore= [];
    outdata.psdoutlog= [];
    outdata.psdoutlogfreq= [];
    outdata.beta_psdoutlog= [];
    outdata.beta_psdoutlog= [];
else
    try
        % trim data
        dattrim = preproc_trim_data(dat,params.msec2trim, params.sr);
        % dc offset
        data_tr_prp = preproc_dc_offset_high_pass(dattrim,params);
        % zscore + delete outliers
        data_no_out = zscore(deleteoutliers(data_tr_prp,0.05));
        
        % zscore measures:
        % zscore psd full range
        %                 [smoothdata,filtwts ]= eegfilt(data_no_out',800,5, 50);
        [psdout,freq,pxxc] = pwelch(data_no_out, gausswin(5e3),floor(5e3*0.6),5:1:90,params.sr,'psd');
        outdata.psdoutlog_zscore = log10(psdout);
        outdata.psdoutlogfreq_zscore = freq;
        % zscore psd bandpass beta
        [smoothdata,filtwts ]= eegfilt(data_no_out',800,10, 30);
        [smoothdatapsd,freq,pxxc] = pwelch(smoothdata', gausswin(5e3),floor(5e3*0.6),5:1:90,params.sr,'psd');
        outdata.beta_psdoutlog_zscore = log10(smoothdatapsd);
        % zscore peak beta  (13-30 range)
        outdata.beta_peak_zscore = max(outdata.beta_psdoutlog_zscore);
        % raw measures (no outliers, no zscore)
        
        
        %  psd full range
        [psdout,freq,pxxc] = pwelch(data_no_out, gausswin(5e3),floor(5e3*0.6),5:1:90,params.sr,'psd');
        outdata.psdoutlog = log10(psdout);
        outdata.psdoutlogfreq = freq;
        %  psd bandpass beta
        [smoothdata,filtwts ]= eegfilt(data_no_out',800,10, 30);
        [smoothdatapsd,freq,pxxc] = pwelch(smoothdata', gausswin(5e3),floor(5e3*0.6),5:1:90,params.sr,'psd');
        outdata.beta_psdoutlog = log10(smoothdatapsd);
        %  peak beta  (13-30 range)
        outdata.beta_psdoutlog = max(outdata.beta_psdoutlog);
        % area under peak (between peak and regression line)
    catch
        outdata.psdoutlog_zscore = 'err';
        outdata.psdoutlogfreq_zscore= 'err';
        outdata.beta_psdoutlog_zscore = 'err';
        outdata.beta_peak_zscore= 'err';
        outdata.psdoutlog= 'err';
        outdata.psdoutlogfreq= 'err';
        outdata.beta_psdoutlog= 'err';
        outdata.beta_psdoutlog= 'err';
        
    end
end