function MAIN_plot_ipad_montage()
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
figdiruse = fullfile('..','figures','ipad_figures_from_json');
patdir  = findFilesBVQX(rootdir,'brpd_*',struct('dirs',1,'depth',1));
chanl = 2; % motor cortex 
cnt = 1; 
nrow = 8;
ncol = 3;
gap = 0.01*3;
marg_h = 0.1;
marg_w = 0.1;

% save data 
for p = [5:8]%2:length(patdir)
    rcnt = 1; 
    [pn,patstr] = fileparts(patdir{p});
    visitdir = findFilesBVQX(patdir{p},'v*',struct('dirs',1,'depth',1));
    for v = 1:length(visitdir)
        datafn = findFilesBVQX(visitdir{v},'dataBR.mat');
        [visitstr,rowuse] = getVisitNameFromDir(visitdir{v});
        if ~isempty(datafn)
            load(datafn{1});
        end
        ipaddir = findFilesBVQX(visitdir{v},'*tsk-ipad*',struct('dirs',1,'depth',1));
        
        if ~isempty(ipaddir)
            for i = 1:length(ipaddir)
                
                [pn,ipadsess] = fileparts(ipaddir{i});
                matfile = findFilesBVQX(ipaddir{i},'analyzed_ipad_data_json_hold_center.mat');
                jsonfile = findFilesBVQX(ipaddir{i},'*.json');
                bdffile = findFilesBVQX(ipaddir{i},'*.bdf');
                brrfile = findFilesBVQX(ipaddir{i},'brpd*.txt');
                finalfile = findFilesBVQX(ipaddir{i},'*hold_centertim.jpeg*.jpeg');
                
                % for plotting
                if ~isempty(matfile)
                    load(matfile{1});
                    drow = datTab(datTab.sessionum == str2num(ipadsess(3:5)),:);
                    if logical(drow.stim); stims ='on'; else; stims ='off';end;
                    if logical(drow.med); meds ='on'; else; meds ='off';end;

                    % save results 
                    rslt(rcnt).patient   = drow.patient{1};
                    rslt(rcnt).visit     = visitstr; 
                    rslt(rcnt).med       = meds; 
                    rslt(rcnt).stim      = stims; 
                    rslt(rcnt).sessnum   = str2num(ipadsess(3:5));
                    rslt(rcnt).sr        = drow.sr(1);
                    rslt(rcnt).task      = drow.task{1};
                    rslt(rcnt).ecog_elec = drow.ecog_elec{1};
                    rslt(rcnt).lfp_elec  = drow.lfp_elec{1};
                    rslt(rcnt).epoch_time  = epoch_time;
                    rslt(rcnt).center_frequencies  = center_frequencies;
                    rslt(rcnt).zertf  = zertf;
                    rslt(rcnt).ertf  = zertf;
                    rslt(rcnt).start_epoch_at_this_time  = timeparams.start_epoch_at_this_time;
                    rslt(rcnt).stop_epoch_at_this_time  = timeparams.stop_epoch_at_this_time;
                    rslt(rcnt).start_baseline_at_this_time  = timeparams.start_baseline_at_this_time;
                    rslt(rcnt).stop_baseline_at_this_time  = timeparams.stop_baseline_at_this_time;
                    rslt(rcnt).extralines  = timeparams.extralines;
                    rslt(rcnt).extralinesec  = timeparams.extralinesec;
                    rslt(rcnt).analysis  = timeparams.analysis;
                    rslt(rcnt).filtertype  = timeparams.filtertype;
                    
                    rcnt = rcnt + 1; 
                end
            end
        end
    end
    resdir = fullfile('..','results','ipad_from_json_results');
    results = struct2table(rslt);
    save(fullfile(resdir,sprintf('%s_spectrogram.mat',patstr)),'results');

end
%% 
% make different color map for z positive and z negative 
%% 
%% plotting 
visits = {'10 day','3 week','1 month','2 month','3 month','6 month','1 year','2 year'};
pats = [3 5];
for p = 1:length(pats)
    areas = {'lfp','ecog'};
    for a = 1:length(areas)
        hfig = figure;
        [ha, pos] = tight_subplot(nrow, ncol, gap, marg_w, marg_h);
        cmin = -4;
        cmax =  4;
        resdir = fullfile('..','results','ipad_from_json_results');
        load(fullfile(resdir,sprintf('brpd_%0.2d_spectrogram.mat',pats(p))),'results');
        for v = 1:length(visits)
            idx = cellfun(@(x) strcmp(x,visits{v}),results.visit);
            idxuse = find(idx == 1);
            for s = 1:length(idxuse)
                idxxx = getRowCol(nrow,ncol,v,s);
                hsub = ha(idxxx);
                axes(ha(idxxx)); hold on;
                tmp = results.zertf{idxuse(s)};
                data = squeeze(tmp(:,:,1,a)); % 3rd dim is condition always = 1
                freqs = results.center_frequencies{idxuse(s)};
                if iscell(results.epoch_time) % sometimes ecah subject has diffeent times (slightly - which makes cell array)
                    epoch_time = results.epoch_time{idxuse(s)};
                else
                    epoch_time = results.epoch_time(idxuse(s),:);
                end
                %             idxzero = data < 1 & data > -1;
                %                 data(idxzero) = 0;
                himg = imagesc(epoch_time,freqs,data);
                caxis([cmin cmax]);
                title(sprintf('%s %s med %s stim %s (%s)',...
                    results.patient{idxuse(s)},...
                    results.visit{idxuse(s)},...
                    results.med{idxuse(s)},...
                    results.stim{idxuse(s)},...
                    results{a}),...
                    'FontWeight', 'bold','FontSize',10);
                axis('xy');
                shading interp
                xlim([min(epoch_time) max(epoch_time)]);
                ylim([min(freqs) max(freqs)]);
                plot([0 0], get(gca,'YLim'),'LineWidth',2,'Color',[0.1 0.1 0.1 0.8]);
                plot([3e3 3e3], get(gca,'YLim'),'LineWidth',2,'Color',[0.1 0.1 0.1 0.8]);
            end
        end
        hfig.PaperPositionMode = 'manual';
        hfig.PaperSize = [8 13];
        hfig.PaperPosition = [0 0 8 13];
        fnmsv = sprintf('%s_%s.jpeg',areas{a},results.patient{1});
        print(hfig,fullfile(figdiruse,fnmsv),'-djpeg','-r300');
        close(hfig);
    end
end




end


function [visitstr, rowuse] = getVisitNameFromDir(viditdrn)

possstrings = {'OR day','2 day','10 day',...
    '3 week','1 month','2 month',...
    '3 month','6 month','1 year',...
    '2 year'};
matcstr    =  { 'OR_day','predis','10_day',...
    '03_wek','01_mnt','02_mnt',...
    '03_mnt','06_mnt',...
    '01_yer','02_yer'};
idxvisit = cellfun(@(x) any(strfind(viditdrn,x)),matcstr);
if sum(idxvisit)==0 % no match 
    [~,visitstr] = fileparts(viditdrn);
    rowuse = 0;
else
    visitstr = possstrings{idxvisit};
    rowuse = find(idxvisit==1) -2;
end

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