function hfig = plot_pac_from_results(results,params)
hfig = figure;
for aa = 1:length(results)
    if length(results) ~=1
        subplot(2,2,aa)
        if aa <= 2
            ttlgrp = 'PAC within';
        else
            ttlgrp = 'PAC between';
        end
    else
        ttlgrp = 'PAC within';
    end
    
    AmpFreq_BandWidth = results(aa).AmpFreq_BandWidth;
    AmpFreqVector = results(aa).AmpFreqVector;
    PhaseFreq_BandWidth  = results(aa).PhaseFreq_BandWidth;
    PhaseFreqVector  = results(aa).PhaseFreqVector;
    ttlAmp = results(aa).ttlAmp;
    PhaseArea = results(aa).PhaseArea;
    
    % reshaped to original 
    Com_Sqr = results(aa).Comodulogram;
    Com_Mat = reshape(Com_Sqr, [length(PhaseFreqVector)*length(AmpFreqVector) 1]);
    MI_sur = results(aa).MI_surr;
    % z scorring 
    Com_reshaped = results(aa).Comodulogram;
    zcom = results(aa).zComodulogram;
    idxover = zcom < -1.645 | zcom > 1.645;
    Com_reshaped(~idxover) = 0;
    Com_reshaped(idxover) = 1;
    zmat = reshape(Com_reshaped, length(PhaseFreqVector), length(AmpFreqVector));
    % prctile 
    pmatuse = Com_Mat; 
    idxover = pmatuse >= prctile(MI_sur,99.5)';
    pmatuse(~idxover) = 0; 
    pmatuse(idxover) = 1; 
    pmat = reshape(pmatuse, length(PhaseFreqVector), length(AmpFreqVector));
    % p-value 
    pmatvalsuse = Com_Mat;
    compMatrix = repmat(Com_Mat,[1 size(MI_sur,1) ])';
    pvals = 1-sum(double((compMatrix >= MI_sur)),1)./size(MI_sur,1);
    idxunder = pvals <= 0.05;
    [h,p] = fdr_bh(pvals,0.05,'pdep','yes');
    pmatvalsuse(logical(~h)) = 0; 
    pmatvalsuse(logical(h)) = 1; 
    pvalmat = reshape(pmatvalsuse, length(PhaseFreqVector), length(AmpFreqVector));
    
    
    
    
    switch params.plottype
        case 'zscore'
            datplot = zmat;
        case 'prctile'
            datplot = pmat;
        case 'pval'
            datplot = pvalmat;
    end

    
    idxdat = datplot~=0;
%     datplot(idxdat) = 1; 
    contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,datplot',30,'lines','none')  % not sig
%     colormap(parula(1000)); 
%     
%     c = repmat([0 0 0.9],200,1);
%     idxstartcolors = floor(find(sort(datplot(:))>=valmin,1)/625.*100) *2; 
%     idxstartcolors = 1; 
%     numcolors = 200 - idxstartcolors;
%     cuse = colormap(parula(numcolors*2));
%     cuse = cuse(numcolors+1:end,:);
%     c(end-numcolors+1:end,:) = cuse; 
%     colormap(c); 
%     
%     dattemp1 = datplot;
%     dattemp2 = datplot; 
%     dattemp1(datplot==0) = NaN; % XXX 
%     dattemp2(datplot~=0) = NaN; % XXX 
%     contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,dattemp2',30,'lines','none')  % not sig 
%     caxis(gca,[0 0.1]);
%     hold on; 
%     contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,dattemp1',30,'lines','none') % sig 
%     valmin = min(datplot(datplot>0));
%     valmax =  max(datplot(datplot>0));
%     caxis(gca,[0 valmax]);
    
    set(gca,'fontsize',14)
    ttly = sprintf('Amplitude Frequency %s (Hz)',ttlAmp);
    ylabel(ttly)
    ttlx = sprintf('Phase Frequency %s (Hz)',PhaseArea);
    xlabel(ttlx)
    title([ttlgrp ' ' params.plottype]);
end

end