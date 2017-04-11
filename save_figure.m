function save_figure(hfig,figname,figdir,filetypesave)
%% Save a figure to a specific directory 
%  This function saves a figure, given figure handle to a directory. 
%  It uses user specified fig names, dirs and file types. 
%  The purpose is to easily save figures, that format properly. 
%
%  Input: 
%  hfig         - handle of figure to be saved 
%  figname      - figure name (string) 
%  figdir       - figure directory (string) 
%  filetypesave - jpg, pdf, tiff, png , bmp (etc..) user strings, no dot 
%
%  Output: 
%  Figure is saved to correct directory with supplied filename 

figfnm = fullfile(figdir, [figname, '.' filetypesave]); 

formatype = ['-d' filetypesave]; 

% hfig.PaperOrientation
% hfig.PaperPosition
% hfig.PaperPositionMode
% hfig.PaperUnits 
if strcmp(filetypesave,'fig')
    savefig(hfig,figfnm); 
else
    print(hfig,figfnm,formatype,'-r200');
end
% close(hfig); 

end