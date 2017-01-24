function dataout = preproc_notch_filter(data,params)

[n1_b, n1_a] = butter(3,[58 62]  /   (params.sr/2),'stop');   %60hz
[n2_b, n2_a] = butter(3,[118 122]/ (params.sr/2),'stop');     %120hz
[n3_b, n3_a] = butter(3,[178 182]/ (params.sr/2),'stop');     %180hz

dataout = filtfilt(n1_b, n1_a, data);    %notch out at 60
dataout = filtfilt(n2_b, n2_a, dataout); %notch out at 120
dataout = filtfilt(n3_b, n3_a, dataout); %notch out at 180

end