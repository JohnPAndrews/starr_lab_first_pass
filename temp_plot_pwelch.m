hfig = figure; 
dat = brdb.m1_rawdata{7};
[settings, params] = get_settings_params();
params.msec2trim = 10e3;
params.sr = 800;
% trim data
dattrim = preproc_trim_data(dat,params.msec2trim, params.sr);
% dc offset
data_tr_prp = preproc_dc_offset_high_pass(dattrim,params);
x

% zscore + delete outliers
data_no_out = zscore(deleteoutliers(data_tr_prp,0.05));
[psdout,freq,pxxc] = pwelch(data_no_out, gausswin(5e3),floor(5e3*0.6),1:1:400,params.sr,'psd');
findPeaksFromPSDconf(psdout,freq, pxxc,1);% psd, conf intervals, plot (0 = no);

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