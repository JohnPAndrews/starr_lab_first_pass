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
patdir            = 'brpd_07';
diruse            = fullfile(rootdir, patdir);
consuse           = {'rest','ipad','walking'};
colruse           = [1 0 0 0.5;...
                     0 1 0 0.5;...
                     0 0 1 0.5];
stimcon           = {'on','off'};
params.msec2trim  = 1e4;
params.sr         = 800;
params.lowcutoff  = 5;
params.plottype   = 'pwelch';
params.noisefloor = 80;

%% plot stuff 
hfig = figure('Visible','off',...
              'Position',[110  237  1331 496]);
for s = 1:2
    for c = 1:length(consuse)
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