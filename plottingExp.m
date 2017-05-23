function plottingExp()
%% set plotting paramaters 
plotheight = 8.5;
plotwidth  = 16;
subplotsx  = 3;
subplotsy  = 2;
leftedge   = 1;
rightedge  = 1;
topedge    = 1;
bottomedge = 1.5;
spacex     = 1;
spacey     = 1;
fontsize   = 12;
sub_pos    = subplot_pos(plotwidth,plotheight,leftedge,rightedge,bottomedge,topedge,subplotsx,subplotsy,spacex,spacey);

   unqvisits = {'OR_day',    'predis',  '10_day',...
        '03_wek',    '01_mnt',    '02_mnt',...
        '03_mnt',    '06_mnt',    '01_yer',...
        '02_yer'}';
    
% clf(f);
close all; 
screensize = get( groot, 'Screensize' );
hfig                   = figure; 
% hfig.Position          = [1 1 , screensize(3:4)*0.9];
hfig.PaperPositionMode = 'manual'; 
hfig.PaperOrientation  = 'landscape';
hfig.PaperUnits        = 'inches';
hfig.PaperSize         = [plotwidth plotheight]; 
hfig.PaperPosition     = [0 0 plotwidth plotheight]; 

subposlin = cell2mat(sub_pos(:));
for i = 1:6
    s(i) = subplot('Position',subposlin(i,:));
    s(i).FontSize = fontsize; 
    title(sprintf('fig %d',i)); 
    
    set(gca,'XTickLabelRotation',45);
    xlim([0 (length(unqvisits) +1)]);
    set(gca,'XTick',0:(length(unqvisits) +1));
    set(gca,'XTickLabel',[' ' ; strrep(unqvisits,'_',' '); ' '])

end
print(hfig,fullfile(pwd,'1_test.pdf'),'-dpdf');
close(hfig); 
end