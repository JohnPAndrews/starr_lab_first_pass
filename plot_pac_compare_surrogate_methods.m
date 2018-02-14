function plot_pac_compare_surrogate_methods()
pn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brdy_11/v03_10_day/results/pac_results';
ff = findFilesBVQX(pn,'*.mat');
plotuse = {'zscore','prctile','pval'}; 
numtest = 1; 
for f = 1:length(ff)
    
    load(ff{f});
    for aa = 1:length(results)
        
        AmpFreq_BandWidth = results(aa).AmpFreq_BandWidth;
        AmpFreqVector = results(aa).AmpFreqVector;
        PhaseFreq_BandWidth  = results(aa).PhaseFreq_BandWidth;
        PhaseFreqVector  = results(aa).PhaseFreqVector;
        ttlAmp = results(aa).ttlAmp;
        PhaseArea = results(aa).PhaseArea;
        
        % reshaped to original
        zcom = results(aa).zComodulogram;
        zmat = reshape(zcom, [length(PhaseFreqVector)* length(AmpFreqVector)  1]);
        Com_Sqr = results(aa).Comodulogram;
        Com_Mat = reshape(Com_Sqr, [length(PhaseFreqVector)*length(AmpFreqVector) 1]);
        MI_sur = results(aa).MI_surr;
        x = repmat(ones(1,626)+1:626',[100 1])-1;
        % plotting 
        
%         figure;
%         scatter(x(:),MI_sur(:),3,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[0.2 0.2 0.2]);
        hold on; 
        % zscore 
        idx = zmat > 1.645;
        xs = 1:625; 
%         scatter(xs(idx)-0.2,Com_Mat(idx),30,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[0.9 0 0 ]);
        sumz(numtest) = sum(idx);
        % percentiles 
        pmatuse = Com_Mat;
        idxover = pmatuse > prctile(MI_sur,99.5)';
%         scatter(xs(idxover),Com_Mat(idxover),30,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[0 0.9 0 ]);
        sumpr(numtest) = sum(idxover);
        % pvalues 
        compMatrix = repmat(Com_Mat,[1 size(MI_sur,1) ])';
        pvals = 1-sum(double((compMatrix >= MI_sur)),1)./size(MI_sur,1);
        idxunder = pvals < 0.05';
%         scatter(xs(idxunder)+0.2,Com_Mat(idxunder),30,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[0 0 0.9 ]);
        sumpv(numtest) = sum(idxunder);

        numtest = numtest + 1; 
        
    end
    
end
sum(sumz) /(625*numtest);
sum(sumpr) /(625*numtest);
sum(sumpv) /(625*numtest);
end