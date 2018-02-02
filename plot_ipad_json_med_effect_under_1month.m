function plot_ipad_json_med_effect_under_1month()
pats = [3 5];
pats = [3 5 6 7 9 10];
pats = [6];
% pats = [7 ];
% med effects
meds  = {'off','on'};
handles.freq = [22 28; 100 120];
handles.name = {'beta', 'gama'};
figdir = fullfile('..','figures','ipad_figures_from_json','freq_patches');
resdir = fullfile('..','results','ipad_from_json_results');
a = 1; % 2 = motor cortex area 1= stn / lfp / gpi 
if a == 1 
    area = 'stn';
else
    area = 'm1';
end
for p = 1:length(pats)
    load(fullfile(resdir,sprintf('brpd_%0.2d_spectrogram.mat',pats(p))),'results');
    
    %% plotting
    %% plot pvals significant
    
    %% plot spectrograms common colormap
    visits = {'10 day','3 week','1 month','2 month','3 month','6 month','1 year','2 year'};
    visits = {'10 day','3 week'};
    
    hfig = figure;
    nrows = length(visits);
    if length(visits) == 2
        ncols = 2;
    else
        ncols = 3;
    end
    
    
    % get common colormap
    datall = [];
    for v = 1:length(visits)
        idx = cellfun(@(x) strcmp(x,visits{v}),results.visit);
        idxuse = find(idx == 1);
        %% exceptions for specific subjects 
        % subject 6 has 2 3 week visits 
        if pats(p) == 6 & strcmp(visits{v},'3 week');
            idxuse = idxuse(3:4);
        end
        for s = 1:length(idxuse)
            freqs = results.center_frequencies{idxuse(s)};
            tmp = results.zertf{idxuse(s)};
            if iscell(results.epoch_time)
                epoch_time = results.epoch_time{idxuse(s)};
            else
                epoch_time = results.epoch_time(idxuse(s),:);
            end
            data = squeeze(tmp(:,:,1,a)); % 3rd dim is condition always = 1
            bs = 3e3; % baseline start
            be = 4e3; % baseline start
            tidx = epoch_time > bs & epoch_time < be;% get idx for time
            datchunk = data(:,tidx);
            meandat  = mean(datchunk,2);
            pvals = normpdf(meandat,0,1);
            alphause = 0.05;
            [pvalssig,critp] = fdr_bh(pvals,alphause);
            
            minz = min(meandat(~pvalssig));
            maxz = max(meandat(~pvalssig));
            % plot
            plotidx = getRowCol(nrows,ncols,v,s);
            hsub = subplot(nrows,ncols,plotidx); hold on;
            
            hplt = plot(freqs,meandat); % plot mean freq movement
            hold on;
            hplt.LineWidth = 2;
            xlims = [min(freqs) max(freqs)];
            xlim(xlims);
            hsiglines = plot(xlims, [minz minz], xlims, [maxz maxz],...
                'LineWidth',1,...
                'LineStyle','-.',...
                'Color',[0.1 0.1 0.1 0.5]);
            legend([hsiglines(1)],sprintf('alpha = %0.3f',alphause));
            ylims = get(gca,'YLim');
            plotpatch = 1 ;
            ranges = [13 30; 50 120]; 
            if plotpatch
                freqpatch = [];  startidx = []; endidx = [];
                % beta 
                freqpatch(1,1) =  freqs( min(meandat(freqs > ranges(1,1) & freqs < ranges(1,2))) == meandat) - 5;
                freqpatch(1,2) =  freqs( min(meandat(freqs > ranges(1,1) & freqs < ranges(1,2))) == meandat) + 5;
                % gamma 
                freqpatch(2,1) =  freqs( max(meandat(freqs > ranges(2,1) & freqs < ranges(2,2))) == meandat) - 10;
                freqpatch(2,2) =  freqs( max(meandat(freqs > ranges(2,1) & freqs < ranges(2,2))) == meandat) + 10;

                
                
                for fp = 1:size(freqpatch,1)
                    ydat = [ylims(1) ylims(1) ylims(2) ylims(2)];
                    xdat = [freqpatch(fp,1) freqpatch(fp,2) freqpatch(fp,2) freqpatch(fp,1)];
                    hpatch = patch('XData',xdat,'YData',ydat);
                    hpatch.Parent = hsub;
                    hpatch.FaceColor = [0.7 0.7 0.7];
                    hpatch.FaceAlpha = 0.2;
                    hpatch.EdgeColor = 'none';
                    hpatch.Visible = 'on';
                    xloc = mean(freqpatch(fp,:));
                    htext = text(double(xloc), double(ylims(1)),...
                        sprintf('%0.1f - %0.1f',freqpatch(fp,1),freqpatch(fp,2)),...
                        'FontSize',16);
                    htext.Rotation = 90;
                end
            end
            xlabel('Frequency (Hz)','FontSize',12);
            ylabel('Average Z (1000ms-mv)','FontSize',12);
            
            datall = [datall; data(:)];
            
            title(sprintf('p-%d %s med %s stim %s',...
                pats(p),...
                results.visit{idxuse(s)},...
                results.med{idxuse(s)},...
                results.stim{idxuse(s)}),'FontSize',12);
            
        end
    end
    hfig.PaperPositionMode = 'manual';
    hfig.PaperPosition     = [0 0 8  8]; 
    figname  = sprintf('p-%d-avg-movemnt-freqs-area-%s.jpeg',pats(p),area);
    print(hfig,fullfile(figdir,figname),'-djpeg','-r200');
    close(hfig);
    
    %% calc averages in freq patches 
    for m = 1:length(meds)
        % select on / off med during 10 day and 3 week
        idx = cellfun(@(x) strcmp(x,meds{m}),results.med) & ...
            (cellfun(@(x) strcmp(x,'10 day'),results.visit) | cellfun(@(x) strcmp(x,'3 week'),results.visit));
        idxuse = find(idx == 1);
        if pats(p) == 6 & strcmp(visits{v},'3 week');
            idxuse = idxuse([1 3]);
        end
        for s = 1:length(idxuse)
            tmp = results.zertf{idxuse(s)};
            data = squeeze(tmp(:,:,1,a)); % 3rd dim is condition always = 1
            
            freqs = results.center_frequencies{idxuse(s)};
            if iscell(results.epoch_time)
                epoch_time = results.epoch_time{idxuse(s)};
            else
                epoch_time = results.epoch_time(idxuse(s),:);
            end
            for h = 1:size(freqpatch,1)
                fs = freqpatch(h,1); % freq start
                fe = freqpatch(h,2); % freq end
                fidx = freqs > fs & freqs < fe;
                
                % get baseline
                bs = results.start_baseline_at_this_time(idxuse(s)); % baseline start
                be = results.stop_baseline_at_this_time(idxuse(s)); % baseline start
                tidx = epoch_time > bs & epoch_time < be;% get idx for time
                datchunk = data(fidx,tidx);
                avgres(1,s,h,m) = mean(datchunk(:)); ; % basline
                stdres(1,s,h,m) = std(abs(datchunk(:))); % std
                % get prep
                bs = 0; % prep start
                be = 1e3; % prep end
                tidx = epoch_time > bs & epoch_time < be;% get idx for time
                datchunk = data(fidx,tidx);
                avgres(2,s,h,m) = mean(datchunk(:)); ; % basline
                stdres(2,s,h,m) = std(abs(datchunk(:))); % std
                
                % get move
                bs = 3e3; % baseline start
                be = 4e3; % baseline start
                tidx = epoch_time > bs & epoch_time < be;% get idx for time
                datchunk = data(fidx,tidx);
                avgres(3,s,h,m) = mean(datchunk(:)); ; % basline
                stdres(3,s,h,m) = std(abs(datchunk(:))); % std
            end
        end
    end
    
    cmin = min(datall(:));
    cmax = max(datall(:));
    cmin =  -5;
    cmax =   3;
    %% plot
    hfig = figure;
    for v = 1:length(visits)
        idx = cellfun(@(x) strcmp(x,visits{v}),results.visit);
        idxuse = find(idx == 1);
        if pats(p) == 6 & strcmp(visits{v},'3 week');
            idxuse = idxuse(3:4);
        end
        for s = 1:length(idxuse)
            tmp = results.zertf{idxuse(s)};
            data = squeeze(tmp(:,:,1,a)); % 3rd dim is condition always = 1
            freqs = results.center_frequencies{idxuse(s)};
            if iscell(results.epoch_time)
                epoch_time = results.epoch_time{idxuse(s)};
            else
                epoch_time = results.epoch_time(idxuse(s),:);
            end
            plotidx = getRowCol(nrows,ncols,v,s);
            hsub = subplot(nrows,ncols,plotidx); hold on;
            % get pvals:
            pvals = normpdf(data,0,1);
            [pvalssig,critp] = fdr_bh(pvals,alphause);
            %% zero out
            % zero out values:
            %             data(~pvalssig) = 0;
            % zero out based on average
            idxszero = data > minz & data < maxz;
            data(idxszero) = 0;
            
            minz = min(data(~pvalssig));
            maxz = max(data(~pvalssig));
            % zero out baseline
            %             idxzero = data < 1 & data > -1;
            %             data(idxzero) = 0;
            imagesc(epoch_time,freqs,data);
            caxis([cmin cmax]);
            title(sprintf('p-%d,%s med %s stim %s',...
                pats(p),...
                results.visit{idxuse(s)},...
                results.med{idxuse(s)},...
                results.stim{idxuse(s)}));
            axis('xy');
            shading interp
            xlim([min(epoch_time) max(epoch_time)]);
            ylim([min(freqs) max(freqs)]);
            plot([0 0], get(gca,'YLim'),'LineWidth',2,'Color',[0.1 0.1 0.1 0.8]);
            plot([3e3 3e3], get(gca,'YLim'),'LineWidth',2,'Color',[0.1 0.1 0.1 0.8]);
            hcb = colorbar;
            cth = get(hcb,'Title');
            set(cth,'String','z-score');
        end
    end
    hfig.PaperPositionMode = 'manual'; 
    hfig.PaperPosition     = [0 0 8  8]; 
    figname  = sprintf('p-%d-spectrogram-freqs-area-%s.jpeg',pats(p),area);
    print(hfig,fullfile(figdir,figname),'-djpeg','-r200');
    close(hfig);
    %% plot bar of certain freq ranges
    addpath(genpath(fullfile(pwd,'toolboxes','superbar')));
    hfig = figure;
    nrows = size(handles.freq,1);
    ncols = 1;
    
    cnt = 1;
    for h = 1:size(freqpatch,1)
        hsub = subplot(nrows,ncols,cnt); cnt = cnt + 1;
        hold on;
        meanScors = squeeze(mean(avgres,2));% cond, freq band , med state
        meanErrs  = squeeze(mean(stdres,2));% cond, freq band , med state
        % off med
        bars(1,:) = [meanScors(2,h,1), meanScors(3,h,1)];
        errbars(1,:) = [meanErrs(2,h,1), meanErrs(3,h,1)];
        % on med
        bars(2,:) = [meanScors(2,h,2), meanScors(3,h,2)];
        errbars(2,:) = [meanErrs(2,h,2), meanErrs(3,h,2)];
        C(1, 1, :) = [.9 .3 .3]; % group, series
        C(1, 2, :) = [.3 .9 .3];
        C(2, 1, :) = [.9 .3 .3];
        C(2, 2, :) = [.3 .9 .3];
        
        hbar = superbar(bars,'E',errbars,'BarFaceColor',C);
        legend([hbar(1,1), hbar(1,2)],{'prep','move'})
        set(gca,'XTick',[1 2]);
        set(gca,'XTickLabel',{'off med','on med'});
        title(sprintf('p-%d%s (%0.1f-%0.1f)',pats(p),handles.name{h},freqpatch(h,1),freqpatch(h,2)));
    end
    % print 
    hfig.PaperPositionMode = 'manual'; 
    hfig.PaperPosition     = [0 0 8  8]; 
    figname  = sprintf('p-%d-bar-graphs-freqs-area-%s.jpeg',pats(p),area);
    print(hfig,fullfile(figdir,figname),'-djpeg','-r200');
    close(hfig);
    
    ttlsave = sprintf('p-%d-avg-freqs-ranges-area-%s.mat',pats(p),area);
    save(fullfile(resdir,ttlsave),'avgres','stdres','freqpatch','alphause','handles');
    clear meanScors meanErrs avgres stdres
end

%% load patients and display box plot of averages - med effect
resdir = fullfile('..','results','ipad_from_json_results');
figdir = fullfile('..','figures','ipad_figures_from_json','freq_patches');
ff = findFilesBVQX(resdir,'p-*.mat'); 
freqnames = {'beta', 'gamma'};
hfig = figure;
for frq = 1:2
    subplot(2,1,frq);
    for f = 1:length(ff)-1
        load(ff{f})
        [~,fn] =fileparts(ff{f});
        patsuse{f} = fn(3);
        hold on;
        % avgres cond, session, freqband , med state
        meanScors = squeeze(mean(avgres,2));% cond, freq band , med state
        datplot(1) = meanScors(3,frq,1); % off med movement
        datplot(2) = meanScors(3,frq,2); % on med movement
        
        hleg(f,frq) = plot([1 2],datplot,'-o',...
            'LineWidth',2,...
            'MarkerSize',10);
        xlim([0 3]);
        set(gca,'XTick', [ 1 2]);
        set(gca,'XTickLabel',{'off med','on med'});
        title(sprintf('all subs movment - %s',freqnames{frq}));
       
    end
    ylabel('avg z-score');
    legend(hleg(:,frq),patsuse);
end
hfig.PaperPositionMode = 'manual';
hfig.PaperPosition     = [0 0 8  8];
print(hfig,fullfile(figdir,'avg-z-score-across-subs'),'-djpeg','-r200');
close(hfig);
%% plot not boxplot 

%% plot med effect in general in stn 

end

function plotidx = getRowCol(nrows,ncols,rowuse,coluse)
cnt = 1;
for i = 1:nrows
    for j = 1:ncols
        x(i,j) = cnt;
        cnt = cnt +1;
    end
end
plotidx = x(rowuse,coluse);
end

function leftover()
% plot patches based on specific frequences thate pass trhehsold 
% need more works keeps failing bcs dif subjects have difffernt ranges 
plotpatch = 1 ;
if plotpatch
    freqpatch = [];  startidx = []; endidx = [];
    startidx = find(diff(pvalssig) == 1)+1;
    endidx  = find(diff(pvalssig) == -1)+1;
    if ~isempty(startidx) & isempty(endidx)
        
        
        freqpatch(1,:) = [freqs(startidx(1)), freqs(endidx(1))];
        if length(endidx) == 1 & length(startidx)==2
            endidx(2) = length(freqs);
        end
        if length(endidx) ==2
            freqpatch(2,:) = [freqs(startidx(2)), freqs(endidx(2))];
        end
        
        for p = 1:size(freqpatch,1)
            ydat = [ylims(1) ylims(1) ylims(2) ylims(2)];
            xdat = [freqpatch(p,1) freqpatch(p,2) freqpatch(p,2) freqpatch(p,1)];
            hpatch = patch('XData',xdat,'YData',ydat);
            hpatch.Parent = hsub;
            hpatch.FaceColor = [0.3 0.3 0.3];
            hpatch.FaceAlpha = 0.3;
            hpatch.EdgeColor = 'none';
            hpatch.Visible = 'on';
            xloc = mean(freqpatch(p,:));
            htext = text(double(xloc), double(minz),...
                sprintf('%0.1f - %0.1f',freqpatch(p,1),freqpatch(p,2)),...
                'FontSize',16);
            htext.Rotation = 90;
        end
    end
end
end