addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/export_fig'));
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/plot2svg_20120915/plot2svg_20120915';
addpath(genpath(fn));
hfig = gcf; 
axes = hfig.Children;

axes(1).YLim = [0 1];
axes(2).YLim = [-8 -5];
axes(3).YLim = [-8 -5];
subplot(2,2,3,axes(1))
figdir = '/Users/roee/Starr_Lab_Folder/Grants/RO1_renewal /Figures/bnc2';
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [14 8];
hfig.PaperPosition = [0 0 14 8];
fnmsv = sprintf('11_walking_1_month.pdf');
print(hfig,fullfile(figdir,fnmsv),'-dpdf','-painters');

hcf = hfig;
axes = hfig.Children;
set(hcf, 'Fill', 'off');    % Removes the contourf
print(hcf, fullfile(figdir,fnmsv),'Vector', '-dsvg');   % Saves the svg
set(hcf, 'Fill', 'on');     % Shows again the coutourf
set(hc, 'Visible', 'off');  % Hides the coutour lines
% When turning off the axis, the dimensions of the plot will change
% We will save the dimensions to perserve them
OriginalPosition = get(gca, 'Position');  % Save dimensions
axis off;
% Next lines to remove title
h_ch = get(gcf,'Children');
h_str = get(h_ch, 'Title');
set(h_str, 'String',''); % Remove title
set(gca, 'Position', OriginalPosition); % Now reset the plot dimensions
print(hcf, fullfile(figdir,fnmsv),'Bitmap', '-dpng'); 

%% export ipad 

