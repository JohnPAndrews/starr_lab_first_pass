function reportStimHarmonic()

f = 160; % stim freqency
Fs = 800; %sampling frequcny
for n = 1:10
    if tone<100 & tone > 0  
    fprintf('%0.2d harmonic at \t %0.3f\n',n,tone);
    end
end


    %% print all tones 
    clc
    f = 145; % stim freqency
    Fs = 794; %sampling frequcny
    for n = 1:20
        tone = abs(n*f-round(n*f/Fs)*Fs);
        fprintf('%0.2d harmonic at \t %0.3f\n',n,tone);
    end
%%
end