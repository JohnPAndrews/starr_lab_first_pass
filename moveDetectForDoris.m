function moveDetectForDoris()
% load emg data 
load sample_data_emg.mat
M1 = movvar(datuse,[1e3 1e3]); % plot moving variance 
M2 = movmad(datuse,[1e3 1e3]); % plot moving mean abs deviation 
M3 = movmedian(datuse,[2e3 2e3]); % plot moving mean abs deviation 
Mcomp = mean([zscore(M1) ;zscore(M2)]); % add these two vals 
Mcomp2 = movmedian(Mcomp,[1000 1000]); % smooth previous estimate 

idxbig = Mcomp2 > -Mcomp2 & ...
         (Mcomp2 + abs(-Mcomp2)) > 1;

stridx = secs(find(diff(idxbig) == 1));
endidx = secs(find(diff(idxbig) == -1));


%% plot data 
hfig = figure; 
% plot emg signal 
hplt = plot(secs,zscore(datuse)); % raw data 
hold on; 
hplt.LineWidth = 0.5;
hplt.Color     = [0 0 1 0.1];
xlim([47 251])
ylims = ylim; 
hplt = plot(secs,zscore(Mcomp),...
    'LineWidth',3,...
    'Color',[0 0.9 0 0.8]); 

return;
% plot emg markers 
for i = 1:length(stridx)
    line([stridx(i) stridx(i)], ylims,...
        'LineWidth',2,...
        'Color',[0 0.9 0 0.7]);
    
    
    line([endidx(i) endidx(i)], ylims,...
        'LineWidth',2,...
        'Color',[0.9 0 0 0.7]);
end
ylim([-4 4]);
%% plot data on which markers are based 
hplt = plot(secs,zscore(Mcomp2),...
    'LineWidth',3,...
    'Color',[0 0.9 0 0.8]); 

hplt = plot(secs,zscore(-Mcomp2),...
    'LineWidth',3,...
    'Color',[1 0 0 0.8]); 

hplt = plot(secs, idxbig,...
    'LineWidth',3,...
    'Color',[0.6 0.7 0 0.8]); 
