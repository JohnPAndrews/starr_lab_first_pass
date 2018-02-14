function plot_pac_results_from_folder 
pn = uigetdir();
ff = findFilesBVQX(pn,'*.mat');
plotuse = {'zscore','prctile','pval'}; 

for f = 1:length(ff)
    
    load(ff{f});
    
    [pn,fn] = fileparts(ff{f});
    [pn2,fn] = fileparts(pn);
    [pn3,fn] = fileparts(pn2);
    for p = 1:length(plotuse)
        params.plottype = plotuse{p};
        figdir = fullfile(pn3,'figures');
        hfig = plot_pac_from_results(results,params);
        suptitle(ttluse);
        hfig.PaperPositionMode = 'manual';
        hfig.PaperSize = [14 8];
        hfig.PaperPosition = [0 0 14 8];
        fnmsv = sprintf('pac_s-%0.3d_t-%s_%s.jpeg', f ,tr.task{1},plotuse{p});
        print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r200');
%         close(hfig);
    end
end
end