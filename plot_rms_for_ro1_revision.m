function plot_rms_for_ro1_revision()
%% from nicki neursorg paper
%T he average RMS voltage
% at rest, off DBS was 5.1 ± 0.38 mV (mean ± standard
% deviation) for STN and 20.4 ± 2.79 mV for cortex
% signal is in milivolts but Nicki converted to micro volts
% 1 milivotls = 1000 microvolts.
%%
runthis = 0;
if runthis
    %% load data
    fnms = {'/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_01/v03_03_wek/data/dataBR.mat',...
        '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_03/v04_03_wek/data/dataBR.mat',...
        '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_05/v04_03_wek/data/dataBR.mat',...
        '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_06/v05_03_wek/data/dataBR.mat',...
        '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_07/v04_03_wek/data/dataBR.mat',...
        '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_09/v04_03_wek/data/dataBR.mat'};
    fnmspal = {'/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_10/v04_03_wek/data/dataBR.mat'...
        '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brdy_11/v04_03_wek/data/dataBR.mat'};
    
    hfig = figure;
    figcnt = 1;
    area = 'STN';
    for f = 1:length(fnms)
        load(fnms{f});
        idxuse = strcmp(datTab.task,'rest') & ~datTab.med & ~datTab.stim;
        % plotting
        rw = datTab(idxuse,:);
        dat = rw.lfp{:}(rw.idxclean(1):rw.idxclean(2));
        secs = (1:length(dat))./794;
        rms_stn(f) = rms(dat(secs<20)).*1000;
        hsub(figcnt) = subplot(3,3,figcnt);figcnt = figcnt + 1;
        hplt = plot(secs(secs<20),dat(secs<20).*1000);
        title( sprintf('%s %s rms = %.2f %s',...
            rw.patient{1},rw.lfp_elec{1},rms_stn(f),area))
        ylabel('\muV');
        xlabel('seconds');
        set(gca,'FontSize',16)
        hplt.LineWidth = 0.5;
        hplt.Color = [0 0 0.8 0.2];
        ylims(figcnt-1,:) = get(gca,'YLim');
    end
    
    area = 'Pallidum';
    for f = 1:length(fnmspal)
        load(fnmspal{f});
        if strcmp(datTab.patient{1},'BRDY11')
            idxuse = datTab.sessionum == 18;
        else
            idxuse = strcmp(datTab.task,'rest') & ~datTab.med & ~datTab.stim;
        end
        % plotting
        rw = datTab(idxuse,:);
        dat = rw.lfp{:}(rw.idxclean(1):rw.idxclean(2));
        secs = (1:length(dat))./794;
        rms_pal(f) = rms(dat(secs<20)).*1000;
        
        hsub(figcnt) = subplot(3,3,figcnt);figcnt = figcnt + 1;
        hplt = plot(secs(secs<20),dat(secs<20).*1000);
        title( sprintf('%s %s rms = %.2f',...
            rw.patient{1},rw.lfp_elec{1},rms_pal(f),area))
        xlabel('seconds');
        set(gca,'FontSize',16)
        hplt.LineWidth = 0.5;
        hplt.Color = [0 0 0.8 0.2];
        ylims(figcnt-1,:) = get(gca,'YLim');
    end
    %%
    newylim = [min(ylims(:,1)) max(ylims(:,2))];
    for plt = 1:length(hsub)
        hsub(plt).YLim = newylim;
    end
    addpath(genpath(fullfile(pwd,'toolboxes/')));
    subplot(3,3,figcnt);figcnt = figcnt + 1;
    dataplt = [rms_stn rms_pal];
    membership = [ones(length(rms_stn),1); ones(length(rms_pal),1).*2]';
    hnbp = notBoxPlot(dataplt,membership);
    title('Pallidum vs STN RMS');
    ylabel('RMS');
    set(gca,'FontSize',16)
    hax = gca;
    hax.XTickLabel{1} = 'STN';
    hax.XTickLabel{2} = 'Pallidum';
    
    plotwidth = 20;
    plotheight = 10;
    hfig.PaperPositionMode = 'manual';
    hfig.PaperUnits        = 'inches';
    hfig.PaperSize         = [plotwidth plotheight];
    hfig.PaperPosition     = [0 0 plotwidth plotheight];
    hfig.Renderer='Painters';
    
    figdir = '/Users/roee/Starr_Lab_Folder/Grants/RO1_renewal /RO1_v2';
    print(hfig,fullfile(figdir,'RMS-voltage-stn-vs-pal.pdf'),'-dpdf');
    close(hfig);
end

%% build data base
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
ff = findFilesBVQX(rootdir,'dataBR.mat');
tcnt = 1; 
for f = 1:length(ff)
    load(ff{f});
    idxuse = strcmp(datTab.task,'montage') & ~datTab.med & ~datTab.stim;
    %% get visit 
    possstrings = {'OR day','2 day','10 day',...
        '3 week','1 month','2 month',...
        '3 month','6 month','1 year',...
        '2 year'};
    matcstr    =  { 'OR_day','predis','10_day',...
        '03_wek','01_mnt','02_mnt',...
        '03_mnt','06_mnt',...
        '01_yer','02_yer'};
    
    
    idxvisit = cellfun(@(x) any(strfind(ff{f},x)),matcstr);
    visitstr = possstrings(idxvisit);
    if isempty(visitstr)
        idxuse = 0;
    else
        if ~strcmp(visitstr{1},'3 week')
            idxuse = 0;
        else
            datout(tcnt).patient = datTab.patient{1};
            datout(tcnt).visit = visitstr{:};
        end
    end
    
    
    if sum(idxuse)==0
    elseif sum(idxuse) > 0
        idxs = find(idxuse==1); 
        hfig = figure; 
        pltcnt = 1;
        for i = 1:length(idxs)
            rw = datTab(idxs(i),:);
            dat = datTab.lfp{idxs(i)};
            rawdat = [datTab.lfp{idxs(i)} , datTab.ecog{idxs(i)}]';
            outidx = select_clean_data_chunk(rawdat);
            
            
            secs = (1:length(dat))./422; 
            idxsecs = secs>outidx(1)./422 & secs < outidx(2)./422;
            rmsval = rms(dat(idxsecs)).*1000;
            elec = datTab.lfp_elec{idxs(i)};
            elecraw = strrep(strrep(elec,'+',''),'-','');
            % lfp 
            datout(tcnt).(elecraw) = rmsval; % lfp 
            % ecog 
            datecog = datTab.ecog{idxs(i)};
            rmsvalecog = rms(datecog(idxsecs)).*1000;
            elececog = datTab.ecog_elec{idxs(i)};
            elecrawecog = strrep(strrep(elececog,'+',''),'-','');
            datout(tcnt).(elecrawecog) = rmsvalecog; % lfp 
            
            datout(tcnt).outidx1(1) = outidx(1); 
            datout(tcnt).outidx2(1) = outidx(2); 
            
            subplot(3,2,pltcnt); pltcnt = pltcnt+1;
            hplt = plot( secs(idxsecs), dat(idxsecs).*1000); 
            title(sprintf('%s %0.2f',elecraw, rmsval)); 
                ylabel('RMS');
                ylabel('\muV');
                xlabel('seconds');
                set(gca,'FontSize',12)
                hplt.LineWidth = 0.5;
                hplt.Color = [0 0 0.8 0.2];
        end
        tcnt = tcnt + 1;
        suptitle(sprintf('%s %s',datTab.patient{1}, visitstr{1}));
        plotwidth = 20;
        plotheight = 12;
        hfig.PaperPositionMode = 'manual';
        hfig.PaperUnits        = 'inches';
        hfig.PaperSize         = [plotwidth plotheight];
        hfig.PaperPosition     = [0 0 plotwidth plotheight];
        hfig.Renderer='Painters';
        
        figdir = '/Users/roee/Starr_Lab_Folder/Grants/RO1_renewal /RO1_v2';
        figname = sprintf('%s %s montage.pdf',datTab.patient{1}, visitstr{1});
        print(hfig,fullfile(figdir,figname),'-dpdf');
        close(hfig);

    end
    
end
tableout = struct2table(datout);
writetable(tableout,'tableoutro1.csv');
%% plot 
hfig = figure;
hnbp = notBoxPlot(x(:,1),x(:,2));
title('Pallidum vs STN RMS');
ylabel('RMS');
set(gca,'FontSize',16)
hax = gca;
hax.XTickLabel{1} = 'STN';
hax.XTickLabel{2} = 'Pallidum';
hax.XTickLabel{3} = 'Cortex';

plotwidth = 20;
plotheight = 10;
hfig.PaperPositionMode = 'manual';
hfig.PaperUnits        = 'inches';
hfig.PaperSize         = [plotwidth plotheight];
hfig.PaperPosition     = [0 0 plotwidth plotheight];
hfig.Renderer='Painters';

figdir = '/Users/roee/Starr_Lab_Folder/Grants/RO1_renewal /RO1_v2';
print(hfig,fullfile(figdir,'RMS-stn-vs-pal-vs-m1.pdf'),'-dpdf');
close(hfig);

end
