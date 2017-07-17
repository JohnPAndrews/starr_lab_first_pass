function [pksfound] = findPeaksFromPSDconf(psdout, freq, pxxc,plotpeaks)
%% Find real frequency peaks from pwelch funciton 
%% This function takes the output from pwelch function (non loged) 
%% And returns "real peaks" in the PSD defined as regions in which 
%% Lower confidence bound peak is higher than 
%% upper confidence bound local minimum flanking it. 

%% input: 
%% 1. psdout = output of pwelch function 
%% 2. freq   = matrix of freq values from pwelch 
%% 3. pxxc   = confidence intervals of psd function 
%% 3. plot   = boolean value 0 = don't plot, 1 = plot peaks found 

%% output: 
%% 2 x peaks found matrix 
%% First row is the freq of the peaks founds
%% Second row is the peaks value in the psd  
[realpks,reallocspks] = findpeaks(log10(psdout),freq'); % read psd peaks
[pks,locspks] = findpeaks(log10(pxxc(:,1)),freq'); % lower bound peaks
[upks,ulocspks] = findpeaks(log10(pxxc(:,2)),freq'); % upper bound peaks
[mins,locsmins] = findpeaks(log10(pxxc(:,2)).*-1,freq'); % upper bound mins
mins = mins.*-1; % bcs beforehand it was actually peaks :-) 
locsreal = [];
pksreal = [];
cntreal = 1;
for p = 2:length(pks)
    locpk = locspks(p);
    idxupr = find(locsmins > locpk == 1,1,'first');
    idxler = find(locsmins < locpk == 1,1,'last');
    if pks(p) > mins(idxupr) &  pks(p) > mins(idxler)
        locsreal(cntreal) = locspks(p);
        pksreal(cntreal)  = realpks(p);
        cntreal = cntreal + 1;
    end
end
if ~isempty(locsreal)
    pksfound(:,1) = locsreal;
    pksfound(:,2) = pksreal;
else
    pksfound = []; 
end

if plotpeaks
    hfig = figure; 
    hplotPsd = plot(freq,log10(psdout));
    hplotPsd.LineWidth = 2; 
    hplotPsd.Color = [0 0 1 0.8]; 
    hold on;
    hplotConf = plot(freq,log10(pxxc),'-.r');
    for i = 1:2
        hplotConf(i).LineWidth = 1;
        hplotConf(i).Color = [1 0 0 0.5];
    end
    hold on;
    % plot lower bound peaks
    s = scatter(locspks,pks,50,[1,0,0],'o','filled',...
        'MarkerFaceAlpha',0.6,...
        'MarkerEdgeColor',[0 0 0],...
        'MarkerEdgeAlpha',0.6);   
     % plot lower bound local mins 
     s = scatter(locsmins,mins,50,[0,0,1],'o','filled',...
        'MarkerFaceAlpha',0.6,...
        'MarkerEdgeColor',[0 0 0],...
        'MarkerEdgeAlpha',0.6);   
    % plot peaks found 
    s = scatter(locsreal,pksreal,200,[27,158,119]/255,'o','filled',...
        'MarkerFaceAlpha',0.6,...
        'MarkerEdgeColor',[0 0 0],...
        'MarkerEdgeAlpha',0.6);                    
    title('Peaks Exceeding confidence bounds');
    xlabel('Freq'); 
    ytitle = 'Power  (log_1_0\muV^2/Hz)';
    ylabel(ytitle); 
end
end