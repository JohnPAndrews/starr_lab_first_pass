function plot_med_effect()
pats = [3 5];
pats = [3 5 6 7 9 ];
% pats = [6];
% pats = [7 ];
% med effects
db = getBrainRadioDataBase();
areas = {'lfp','ecog'};
visits = {'10 day', '3 week'};
taskstr   = 'rest';
meds = [0 1];
params.colorsuse(1,:) = [0.9 0 0];
params.colorsuse(2,:) = [0 0.9 0];
params.plotwhat       = 'lines'; % average / lines 
figdir = fullfile('..','figures','ipad_figures_from_json','freq_patches');

for a = 1:length(areas)
    hfig = figure;
    cnt = 1;
    for p = 1:length(pats)
        hsub = subplot(2,3,cnt); cnt = cnt + 1;
        hold on;
        patstr = sprintf('brpd%0.2d',pats(p));
        for m = 1:length(meds)
            idxraw = zeros(size(db,1),1);
            for v = 1:length(visits)
                idxraw  = idxraw | cellfun(@(x) strcmp(x,visits{v}),db.visit);
            end
            idxuse = idxraw & ...
                cellfun(@(x) strcmp(x,patstr),db.patient) & ...
                cellfun(@(x) strcmp(x,taskstr),db.task) & ...
                db.med == meds(m);
            % plot data
            idxs = find(idxuse == 1);
            for s = 1:length(idxs)
                idxclean = db.idxclean(idxs(s),:);
                dat = db.(areas{a}){idxs(s)}(idxclean(1):idxclean(2));
                datdc = dat-mean(dat);
                [fftOut,f]   = pwelch(datdc,794,794/2,1:200,794,'psd');
                fftOutAll(s,:) = log10(fftOut);
                
            end
            switch params.plotwhat
                case 'average'
                    hsb = shadedErrorBar(f,fftOutAll,{@mean,@(x) std(x)./sqrt(size(x,1))} );
                    hsb.mainLine.Color = [params.colorsuse(m,:) 0.3];
                    hsb.mainLine.LineWidth = 3;
                    hsb.patch.FaceColor = params.colorsuse(m,:);
                    hsb.patch.FaceAlpha = 0.05;
                    leglines(m) = hsb.mainLine;
                    clear fftOutAll fftOut f
                case 'lines'
                    for s = 1:size(fftOutAll,1)
                        hline(s,m) = plot(f,fftOutAll(s,:));
                        hline(s,m).Color = [params.colorsuse(m,:) 0.4];
                        hline(s,m).LineWidth  = 2;
                        legttl{s,m} = sprintf('%s %s',db.visit{idxs(s)}, db.([areas{a} '_elec']){idxs(s)});
                    end
                    clear fftOutAll fftOut f
            end
        end
        
        switch params.plotwhat
            case 'average'
                legend(leglines',{'off med','on med'} );
            case 'lines'
                idxline = isgraphics(hline,'line');
                legend(hline(idxline),legttl(idxline) );
        end
        clear hline legttl leglines
        % dressing up plot
        xlabel(hsub,'Frequency (Hz)');
        ylabel(hsub,'Power  (log_1_0\muV^2/Hz)');
        ttlstr = sprintf('%s %s',patstr, areas{a});
        title(ttlstr);
        xlim([0 50]);
%         clear leglines
    end
    hfig.PaperPositionMode = 'manual';
    hfig.PaperPosition     = [0 0 12  8];
    figname  = sprintf('all-subs-med-%s-%s.jpeg',areas{a}, params.plotwhat);
    print(hfig,fullfile(figdir,figname),'-djpeg','-r200');
    close(hfig);
    

end


end


