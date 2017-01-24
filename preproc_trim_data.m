function dataout = preproc_trim_data(data,msec2trim, sr)
dataout = data(round(sr * (msec2trim / 1e3)) : end);
end