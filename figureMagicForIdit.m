function figureMagicForIdit()
%% This function will open figures, and save them in a certain size 

%% params user defined: 
params.papersize        = [16 8.5] .*3; % width / hegiht 
params.PaperOrientation = 'landscape'; %landscaape or portrait 
params.formatType       = 'pdf'; % jpeg, pdf , tiff, bmp , png
params.res              = 600; 
params.FontSize         = 22; 
params.figpos           = [440         -45        1750         843]; 
params.posmode          = 'auto';% 'auto / 'manual' 
%% code 
fprintf('Would you want to :\n');
fprintf('[1] open one figure using gui\n'); 
fprintf('[2] choose a directory of figs to open all of them, and save them in bulk\n'); 
modeuse = input('1 or 2? ');
if modeuse == 1
    [fnm, pn] = uigetfile('*.fig','choose one .fig file'); 
    ff = {fullfile(pn,fnm)};
elseif modeuse ==2
    dnm = uigetdir(pwd,'choose a directory with figs in it'); 
    ff = findFilesBVQX(dnm,'*.fig'); 
end


if isempty(ff) 
    error('did not find any .fig files')
end
% set resolution 
resuse = sprintf('-r%d',params.res);
formatuse = sprintf('-d%s',params.formatType);
for f= 1:length(ff)
    [pn,fn,ext] = fileparts(ff{f}); 
    hfig = open(ff{f});
    hfig.PaperPositionMode = params.posmode; 
%     hfig.PaperUnits = 'normalized'; % normalized gives you better control over papostin 
%     hfig.PaperPosition = [0.1 0.1 16 8.5];
    hfig.PaperOrientation = params.PaperOrientation;
    hfig.PaperSize = params.papersize; 
    hfig.Position = params.figpos; 
    set(findall(hfig,'-property','FontSize'),'FontSize',params.FontSize)
    figfnm = fullfile(pn,[fn '.' params.formatType]);
    print(hfig,figfnm,formatuse,resuse);
    close(hfig); 
end

end