function MAIN_plotStimOnStimOff_Beta_PerSubject()
%% Nicki:
%% This temp funnction plots beta stim on / stim off
%  It overlays different conditions as PSD's on top of each other
%  You can use this to look at various other aspects of data / adopt 

% reqs: 
% must be in patiebnt directorty with mat files
% must have eeglab in matlab search path 

%% user settings 
rootdir           = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/figures/for_nicki/';
patdir            = 'brpd_09';
diruse            = fullfile(rootdir, patdir);
consuse           = {'rest','ipad','walking'};
colruse           = [1 0 0 0.5;...
                     0 1 0 0.5;...
                     0 0 1 0.5];
stimcon           = {'on','off'};
areasuse          = {'stn','m1'}; 
params.msec2trim  = 1e4;
params.sr         = 800;
params.lowcutoff  = 5;
params.plottype   = 'pwelch';
params.noisefloor = 80;
params.LineWidth  = 1; 
params.Alpha      = 0.1;

hfig = figure('Visible','on',...
              'Position',[657          34        1331        1281]);
%% plot avg rest in stim on / stim off across stn and m1 
for a = 1:2 % loop on areas used
    for s = 1:2 % loop on stim on / off
        ff = findFilesBVQX(diruse,sprintf('*%s*stim-%s*%s*.mat',...
            areasuse{a},...
            stimcon{s},...
            consuse{1}));
        for f = 1:length(ff)
            load(ff{f});
            data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
            data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
            data_no_out = zscore(deleteoutliers(data_tr_prp,0.05));
            [smoothdata,filtwts ]= eegfilt(data_no_out',800,13, 30);
            [psdout(f,:),freq] = pwelch(data_tr_prp,length(data_tr_prp),1024,10:1:400,params.sr,'psd');
            psdoutlog(f,:) = log10(psdout(f,:));  
        end
        subplot(3,2,a);
        hold on; 
        hplot = plot(freq,psdoutlog);
        for h = 1:size(hplot,1)
            if s == 1 % stim on 
                hplot(h).Color = [0 1 0 params.Alpha];
            else
                hplot(h).Color = [1 0 0 params.Alpha];
            end
            hplot(h).LineWidth = params.LineWidth;
        end
        hplot = plot(freq,mean(psdoutlog,1));
        hplot.LineWidth = 2; 
        hleg(s) = hplot; 
        if s == 1 % stim on 
            hplot.Color     = [0 1 0];
        else
            hplot.Color     = [1 0 0]; 
        end

        figtitle = sprintf('%s %s rest',areasuse{a}, strrep(patdir,'_',' '));
        htitle = title(figtitle);
        xtitle = 'Frequency (Hz)';
        ytitle = 'Power  (log_1_0\muV^2/Hz)';
        hxlabel = xlabel(xtitle);
        hylabel = ylabel(ytitle);
        xlim([min(freq) max(freq)]);
        
        ax = ancestor(hplot, 'axes');
        hyrule = ax.YAxis;
        hxrule = ax.XAxis;
        
        % format plot - size and fonts
        formatPlot(htitle,hxlabel,hylabel,hxrule,hyrule,hplot);

    end
    hleg = legend([hleg(1), hleg(2)], ...
        {'stim on','stim off'},'FontSize',14,'FontWeight','bold');
end

%% plot rest and walking STIM on in STN and M1 
rowfac = 2; 
for a = 1:2 % loop on areas used
    for s = [1 3]% loop on cons use 
        ff = findFilesBVQX(diruse,sprintf('*%s*stim-%s*%s*.mat',...
            areasuse{a},...
            stimcon{1},... % stim on 
            consuse{s}));
        for f = 1:length(ff)
            load(ff{f});
            data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
            data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
            data_no_out = zscore(deleteoutliers(data_tr_prp,0.05));
            [smoothdata,filtwts ]= eegfilt(data_no_out',800,13, 30);
            [psdout(f,:),freq] = pwelch(data_tr_prp,length(data_tr_prp),1024,10:1:400,params.sr,'psd');
            psdoutlog(f,:) = log10(psdout(f,:));  
        end
        subplot(3,2,a  + rowfac);
        hold on; 
        hplot = plot(freq,psdoutlog);
        for h = 1:size(hplot,1)
            if s == 1 % stim on 
                hplot(h).Color = [0 1 0 params.Alpha];
            else
                hplot(h).Color = [1 0 0 params.Alpha];
            end
            hplot(h).LineWidth = params.LineWidth;
        end
        hplot = plot(freq,mean(psdoutlog,1));
        hplot.LineWidth = 2; 
        hleg(s) = hplot;
        if s == 1 % rest  
            hplot.Color     = [0 1 0];
        elseif s ==3 % walking 
            hplot.Color     = [1 0 0]; 
        end
        figtitle = sprintf('%s %s stim on',areasuse{a}, strrep(patdir,'_',' '));
        htitle = title(figtitle);
        xtitle = 'Frequency (Hz)';
        ytitle = 'Power  (log_1_0\muV^2/Hz)';
        hxlabel = xlabel(xtitle);
        hylabel = ylabel(ytitle);
        xlim([min(freq) max(freq)]);
        
        ax = ancestor(hplot, 'axes');
        hyrule = ax.YAxis;
        hxrule = ax.XAxis;
        
        % format plot - size and fonts
        formatPlot(htitle,hxlabel,hylabel,hxrule,hyrule,hplot);

    end
        hleg = legend([hleg(1), hleg(3)], ...
        {'rest','walking'},'FontSize',14,'FontWeight','bold');

end



%% plot rest and walking STIM off in STN and M1 
rowfac = 4; 
for a = 1:2 % loop on areas used
    for s = [1 3]% loop on cons use 
        ff = findFilesBVQX(diruse,sprintf('*%s*stim-%s*%s*.mat',...
            areasuse{a},...
            stimcon{2},... % stim off 
            consuse{s}));
        for f = 1:length(ff)
            load(ff{f});
            data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
            data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
            data_no_out = zscore(deleteoutliers(data_tr_prp,0.05));
            [smoothdata,filtwts ]= eegfilt(data_no_out',800,13, 30);
            [psdout(f,:),freq] = pwelch(data_tr_prp,length(data_tr_prp),1024,10:1:400,params.sr,'psd');
            psdoutlog(f,:) = log10(psdout(f,:));  
        end
        subplot(3,2,a  + rowfac);
        hold on; 
        hplot = plot(freq,psdoutlog);
        for h = 1:size(hplot,1)
            if s == 1 % stim on 
                hplot(h).Color = [0 1 0 params.Alpha];
            else
                hplot(h).Color = [1 0 0 params.Alpha];
            end
            hplot(h).LineWidth = params.LineWidth;
        end
        hplot = plot(freq,mean(psdoutlog,1));
        hplot.LineWidth = 2;
        hleg(s) = hplot;
        if s == 1 % rest  
            hplot.Color     = [0 1 0];
        elseif s ==3 % walking 
            hplot.Color     = [1 0 0]; 
        end
        figtitle = sprintf('%s %s stim off',areasuse{a}, strrep(patdir,'_',' '));
        htitle = title(figtitle);
        xtitle = 'Frequency (Hz)';
        ytitle = 'Power  (log_1_0\muV^2/Hz)';
        hxlabel = xlabel(xtitle);
        hylabel = ylabel(ytitle);
        xlim([min(freq) max(freq)]);
        
        ax = ancestor(hplot, 'axes');
        hyrule = ax.YAxis;
        hxrule = ax.XAxis;
        
        % format plot - size and fonts
        formatPlot(htitle,hxlabel,hylabel,hxrule,hyrule,hplot);

    end
    hleg = legend([hleg(1), hleg(3)], ...
        {'rest','walking'},'FontSize',14,'FontWeight','bold');

end
hfig.PaperPositionMode = 'auto';
hfig.PaperOrientation = 'landscape';
hfig.PaperSize = [20,20]; 
save_figure(hfig,[patdir 'nicki_plot_no_preproc'],diruse,'pdf')

return; 

%% plot stuff 
for a = 1:2 % loop on areas used
    for s = 1:2 % loop on stim on / off
        for c = 1:length(consuse) % loop on cons used
            ff = findFilesBVQX(diruse,sprintf('*stim-%s*%s*.mat',...
                stimcon{s},...
                consuse{c}));
            for f = 1:length(ff)
                load(ff{f});
                data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
                data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
                data_no_out = zscore(deleteoutliers(data_tr_prp,0.05));
                %             [smoothdata,filtwts ]= eegfilt(data_no_out',800,13, 30);
                subplot(1,2,s);
                [~, hplot(c)] = plot_data_freq_domain(data_no_out,params,[]);
                title(sprintf('Stim %s',stimcon{s}));
                hplot(c).LineWidth = 2;
                hplot(c).Color = colruse(c,:);
                legendttls{c} = consuse{c};
                hold on;
            end
        end
        hleg = legend([hplot(1), hplot(2), hplot(3)], ...
            legendttls,'FontSize',14,'FontWeight','bold');
    end
hfig.PaperPositionMode = 'auto';
hfig.PaperOrientation = 'landscape';
hfig.PaperSize = [20,20]; 
save_figure(hfig,[patdir 'no_bp'],diruse,'pdf')
end