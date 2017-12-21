function MAIN_plot_ipad_montage()
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
figdiruse = fullfile('..','figures','ipad_figures_from_json');
patdir  = findFilesBVQX(rootdir,'brpd_*',struct('dirs',1,'depth',1));
chanl = 2; % motor cortex 
cnt = 1; 
nrow = 8;
ncol = 3;
gap = 0.01*2;
marg_h = 0.05;
marg_w = 0.05;

for p = [4]%2:length(patdir)
    [pn,patstr] = fileparts(patdir{p});
    visitdir = findFilesBVQX(patdir{p},'v*',struct('dirs',1,'depth',1));
    hfig = figure; 
    [ha, pos] = tight_subplot(nrow, ncol, gap, marg_w, marg_h);
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
                    idxxx = getRowCol(8,3,rowuse,i);
%                     hsub = subplot(8,3,idxxx);
                    axes(ha(idxxx));
%                     hsub.Position - pos{idxxx};
                    
                    hold on;
                    
                    load(matfile{1});
                    tempmat=double(squeeze(zertf(:,:,1,chanl)));
                    pcolor(epoch_time,center_frequencies,tempmat);
                    shading interp;
                    axis tight 
                    cmax=3;
                    cmin=-cmax;
                    caxis([cmin cmax]);
                    hold on;
                    
                    plot([0 0 ],ha(idxxx).YLim ,...
                        'LineWidth',2,...
                        'Color',[0.1 0.1 0.1 0.7]);        
                    plot([timeparams.extralinesec timeparams.extralinesec],ha(idxxx).YLim ,...
                        'LineWidth',2,...
                        'Color',[0.2 0.2 0.2 0.7]);
                    drow = datTab(datTab.sessionum == str2num(ipadsess(3:5)),:);
                    if logical(drow.stim); stims ='on'; else; stims ='off';end;
                    if logical(drow.med); meds ='on'; else; meds ='off';end;
                    ttluse = sprintf('%d %s %s S-%s M-%s',cnt,drow.patient{1},visitstr,stims, meds);
                    title(strrep( ttluse,'_' ,' '),...
                        'FontWeight', 'bold','FontSize',10);
                    %xlabel('time (msec)');
                    %ylabel('power');
                    if rowuse == 8
                        xlabel('Time (msec)','FontSize',8);
                    else
                        xlabel('');
                        xticklabels('');
                    end
                    if i ==1
%                         ylabel('Power  (log_1_0\muV^2/Hz)','FontSize',8);
                    else
                        yticklabels('');
                    end

                    set(gca,'XTickLabel','');
                    set(gca,'YTickLabel','');
                end
            end
        end
    end
    hfig.PaperPositionMode = 'manual';
    hfig.PaperSize = [7 12];
    hfig.PaperPosition = [0 0 7 12];
    fnmsv = sprintf('%s.jpeg',patstr);
    print(hfig,fullfile(figdiruse,fnmsv),'-djpeg','-r300');
    close(hfig);
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
rowuse = find(idxvisit==1) -2;

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