function plot_pac_per_patient()
%% pac params
params.PhaseFreqVector      = 2:4:50;
params.AmpFreqVector        = 2:4:90;
params.PhaseFreq_BandWidth  = 4;
params.AmpFreq_BandWidth    = 10;
params.useparfor            = 0;
params.regionnames          = {'GPi','M1'};
params.computeSurrogates    = 0;
params.plotdata             = 0;

possstrings = {'OR day','2 day','10 day',...
    '3 week','1 month','2 month',...
    '3 month','6 month','1 year',...
    '2 year'};
matcstr    =  { 'OR_day','predis','10_day',...
    '03_wek','01_mnt','02_mnt',...
    '03_mnt','06_mnt',...
    '01_yer','02_yer'};

patdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_03';
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/figures/PAC_activa/brpd03';
visitdir = findFilesBVQX(patdir,'v0*',struct('dirs',1,'depth',1));
for v = 1:length(visitdir)
    ff = findFilesBVQX(visitdir{v},'dataBR.mat');
    if ~isempty(ff)
        [pn,fn] = fileparts(visitdir{v});
        visitstr = possstrings{cellfun(@(x) any(strfind(fn,x)),matcstr)};
        
        load(ff{1});
        for s = 1:size(datTab,1)
            if ~isnan(datTab.idxclean(s,1))
                idxuse = datTab.idxclean(s,1): datTab.idxclean(s,2);
                sr = datTab.sr(s);
                data = [];
                data(1,:) = datTab.lfp{s}(idxuse);
                data(2,:) = datTab.ecog{s}(idxuse);
                results = computePAC(data,sr,params);
                if datTab.med(s); meds = 'On med'; else; meds = 'Off med'; end;
                if datTab.stim(s); stims = 'On stim'; else; stims = 'Off stim'; end;
                ttlstr = sprintf('%s %s %s %s %0.2d',visitstr, datTab.task{s},meds,stims,s);
                plotPAC(results,figdir,ttlstr,params.regionnames);
            end
        end
        
    end
end
ff = findFilesBVQX(figdir,'*.jpeg');
conds = {'walking','rest','ipad'}; 
meds = {'Off med','On med'};
stims = {'Off stim','On stim'};

for c = 1:length(conds)
    for m = 1:length(meds)
        for s = 1:length(stims)
            idx1 = cellfun(@(x) any(strfind(x,conds{c})),ff);
            idx2 = cellfun(@(x) any(strfind(x,meds{m})),ff);
            idx3 = cellfun(@(x) any(strfind(x,stims{s})),ff);
            idxuse = idx1 & idx2 & idx3; 
            dirname = strrep(sprintf('%s_%s_%s',conds{c},meds{m},stims{s}),' ','');
            newdir = fullfile(figdir,dirname);
            mkdir(newdir);
            cff = ff(idxuse);
            for fff = 1:length(cff)
                copyfile(cff{fff},newdir);
            end
        end
    end
end


end

function plotPAC(results,figdir,ttlstr,regionames)
hfig = figure('Visible','Off',...
    'Position',[340         310        1359         797]);
for r = 1:length(results)
    subplot(2,2,r)
    if r <= 2
        ttlgrp = 'PAC within';
    else
        ttlgrp = 'PAC between';
    end
    switch r
        case 1
            ttlAmp = sprintf('%s',regionames{1});
            ttlPha = sprintf('%s',regionames{1});
        case 2
            ttlAmp = sprintf('%s',regionames{2});
            ttlPha = sprintf('%s',regionames{2});
        case 3
            ttlAmp = sprintf('%s',regionames{1});
            ttlPha = sprintf('%s',regionames{2});
        case 4
            ttlAmp = sprintf('%s',regionames{2});
            ttlPha = sprintf('%s',regionames{1});
    end
    contourf(results(r).PhaseFreqVector+results(r).PhaseFreq_BandWidth/2,...
        results(r).AmpFreqVector+results(r).AmpFreq_BandWidth/2,...
        results(r).Comodulogram',30,'lines','none')
    set(gca,'fontsize',14)
    ttly = sprintf('Amplitude Frequency %s (Hz)',ttlAmp);
    ylabel(ttly)
    ttlx = sprintf('Phase Frequency %s (Hz)',ttlPha);
    xlabel(ttlx)
    title(ttlgrp);
    colorbar
end
get(gcf,'Position');
annotation('textbox', [0 0.9 1 0.1], ...
    'String', ttlstr, ...
    'EdgeColor', 'none', ...
    'FontSize',24,...
    'HorizontalAlignment', 'center')
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [14 8];
hfig.PaperPosition = [0 0 14 8];
fnmsv = sprintf('%s.jpeg',ttlstr);
print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r600');
close(hfig);

end
