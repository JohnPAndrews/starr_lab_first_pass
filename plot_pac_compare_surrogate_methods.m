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
        ampidx = repmat([AmpFreqVector+AmpFreq_BandWidth/2],[ 1 length(PhaseFreqVector) ]);
        [~,sortorder] = sort(ampidx);
        zcom = results(aa).zComodulogram;
        zmat = reshape(zcom, [length(PhaseFreqVector)* length(AmpFreqVector)  1]);
        Com_Sqr = results(aa).Comodulogram;
        Com_Mat = reshape(Com_Sqr, [length(PhaseFreqVector)*length(AmpFreqVector) 1]);
        MI_sur = results(aa).MI_surr;
        x = repmat(ones(1,626)+1:626',[100 1])-1;
        % sorting 
        zmat = zmat(sortorder); 
        Com_Mat = Com_Mat(sortorder); 
        MI_sur = MI_sur(:,sortorder); 
        % plotting 
        
%         figure;
%         hs1 = scatter(x(:),MI_sur(:),3,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[0.2 0.2 0.2]);
        hold on; 
        % zscore 
        idx = zmat > 1.645;
        xs = 1:625; 
%         hs2 = scatter(xs(idx)-0.2,Com_Mat(idx),30,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[0.9 0 0 ]);
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
%         hs3 = scatter(xs(idxunder)+0.2,Com_Mat(idxunder),30,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[0 0 0.9 ]);
        sumpv(numtest) = sum(idxunder);
%         legend([hs1 hs2 hs3], {'zscore','perecntile','p-value'}); 
        numtest = numtest + 1; 
        
    end
    
end

z = sum(sumz) /(625*numtest);
pr = sum(sumpr) /(625*numtest);
pv = sum(sumpv) /(625*numtest);
dat = [z pr pv] .* 100;
figure;
hb = bar(dat); 

end