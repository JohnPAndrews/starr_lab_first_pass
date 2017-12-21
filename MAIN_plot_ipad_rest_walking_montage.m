function MAIN_plot_ipad_rest_walking_montage()
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
figdiruse = fullfile('..','figures','ipad_figures_from_json');
patdir  = findFilesBVQX(rootdir,'brpd_*',struct('dirs',1,'depth',1));
chanl = 2; % motor cortex
cnt = 1;
nrow = 8;
ncol = 3;
gap = 0.01*2;
margw = 0.01*2; 
margh = 0.05;

%% add build database 
% build data base 
datAll = [] ;
for p = [ 2]%:length(patdir)
    ff = findFilesBVQX(patdir{p},'dataBR.mat');
    for f = 1:length(ff) % loop on visits 
        load(ff{f}); 
        [visitstr,rowuse] = getVisitNameFromDir(ff{f});
        datUse = datTab(:,{'patient','sessionum','time','duration','task','med','stim','sr','ecog_elec','lfp_elec'}); 
        for s = 1:size(datTab)
            datUse.visit{s} = visitstr;
            dat = datTab.lfp{s};
            datdc = dat-mean(dat);
            [fftOut,f]   = pwelch(datdc,256,256/2,1:100,794,'psd');
            datUse.lfpPower{s} = log10(fftOut);
            datUse.lfpPowerf{s} = f;
            
            dat = datTab.ecog{s};
            datdc = dat-mean(dat);
            [fftOut,f]   = pwelch(datdc,256,256/2,1:100,794,'psd');
            
            datUse.ecogPower{s} = log10(fftOut);
            datUse.ecogPowerf{s} =f;
            % find ipad session and concatenate;
            if strcmp(datUse.task{s},'ipad') % if ipad taks 
            end
        end
        datAll = [datAll ; datUse];
    end
    ff = findFilesBVQX(patdir{p},'results_freq_domain_ipad_json.mat');
end
%% 
areasuse = {'ecog'};
for a = 1:length(areasuse)
    for p = [ 2]%:length(patdir)
        [pn,patstr] = fileparts(patdir{p});
        visitdir = findFilesBVQX(patdir{p},'v*',struct('dirs',1,'depth',1));
        hfig = figure;
        [ha, pos] = tight_subplot(nrow, ncol, gap, margw, margh);
        for v = 3:length(visitdir) % start from 10 day 
            datafn = findFilesBVQX(visitdir{v},'dataBR.mat');
            [visitstr,rowuse] = getVisitNameFromDir(visitdir{v});
            rowuse = rowuse -2; % to start plots from first row 
            if ~isempty(datafn)
                load(datafn{1});
            end
            ipaddir = findFilesBVQX(visitdir{v},'*tsk-ipad*',struct('dirs',1,'depth',1));
            if ~isempty(ipaddir)
                for i = 1:length(ipaddir)
                    
                    [pn,ipadsess] = fileparts(ipaddir{i});
                    matfile = findFilesBVQX(ipaddir{i},'results_freq_domain_ipad_json.mat');
                    jsonfile = findFilesBVQX(ipaddir{i},'*.json');
                    bdffile = findFilesBVQX(ipaddir{i},'*.bdf');
                    brrfile = findFilesBVQX(ipaddir{i},'brpd*.txt');
                    finalfile = findFilesBVQX(ipaddir{i},'*hold_centertim.jpeg*.jpeg');
                    
                    idxx = getRowCol(8,3,rowuse,i);
                    axes(ha(idxx));
                    hold on;
                    drow = datTab(datTab.sessionum == str2num(ipadsess(3:5)),:);
                    if logical(drow.stim); stims ='on'; else; stims ='off';end;
                    if logical(drow.med); meds ='on'; else; meds ='off';end;
                    elec = drow.([areasuse{a} '_elec']);
                    [hpp, conds] = plotOtherRecs(datTab,i,drow.med,drow.stim,areasuse{a},elec,ha(idxx));
                    ttluse = sprintf('%d %s %s S-%s M-%s %s',cnt,drow.patient{1},visitstr,stims, meds,elec{1});
                    title(strrep( ttluse,'_' ,' '),...
                        'FontWeight', 'bold','FontSize',8);

                    % for plotting
                    if ~isempty(matfile)
                        hold on;
                        
                        load(matfile{1});
                        for ll = 1:length(params.labelfind)
                            
                            fftuse  = res.(areasuse{a}).(params.labelfind{ll});
                            f  = 1:length(fftuse);
                            hsb = shadedErrorBar(f,fftuse,{@mean,@(x) std(x)./sqrt(size(x,1))} );
                            hsb.mainLine.Color = params.colorsuse{ll};
                            hsb.mainLine.LineWidth = 1;
                            hsb.patch.FaceColor = params.colorsuse{ll};
                            leglines(ll) = hsb.mainLine;
                            hold on;
                            clear fftOut;
                        end
                        xlim([5 85]);
                        hleg = legend([leglines hpp],{'hold', 'prep','move', 'rest' ,'walking'});
                        hleg.FontSize = 5; 
                        hleg.Box = 'off';
                        hleg.Color = 'none';
                        hleg.Location = 'best';
                       
                    end
                    axis tight;
                    if rowuse == 8 
                        xlabel('Frequency (Hz)','FontSize',8);
                    else
                        xlabel('');
                        xticklabels('');
                    end
                    if i ==1 
                        ylabel('Power  (log_1_0\muV^2/Hz)','FontSize',8);
                    else
                        yticklabels('');
                    end
                end
            end
        end
        hfig.PaperPositionMode = 'manual';
        hfig.PaperSize = [7 12];
        hfig.PaperPosition = [0 0 7 12];
        fnmsv = sprintf('%s_%s_freq.jpeg',patstr,areasuse{a});
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
visitstr = possstrings{idxvisit};
rowuse = find(idxvisit==1) ;

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

function [hp, conds] = plotOtherRecs(datTab,coluse,medss,stimss,areastr,elecstr,hax)
conds = {'rest','walking'};
colors = [0 0 0 0.8 ; 0.5 0.5 0.7 0.8];
for c = 1:length(conds)
    idxuse = datTab.med == medss & datTab.stim == stimss & ... 
        cellfun(@(x) strcmp(x,conds{c}),datTab.task) & ...
        cellfun(@(x) strcmp(x,elecstr),datTab.([areastr '_elec']));
    idxs = find(idxuse==1); 
    if sum(idxuse) > 1 
        idxchoose = idxs(2);
    elseif sum(idxuse) == 1 
        idxchoose = idxs(1);
    end
    datraw = datTab.(areastr){idxchoose};
    idxdat   = datTab.idxclean(idxchoose,:);
    datcnop = datraw(idxdat(1):idxdat(2));
    datdc = datcnop - mean(datcnop);
    [fftOut,f]   = pwelch(datdc,256,256/2,1:100,794,'psd');
    hp(c) = plot(hax,f,log10(fftOut));
    hp(c).LineWidth = 1; 
    hp(c).Color = colors(c,:);
end
end