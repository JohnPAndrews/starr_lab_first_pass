function formatPlot(htitle,hxlabel,hylabel,hxrule,hyrule,hplot)
% given handels to different plot elements, format the plot 
fontuse = 'Helvetica'; 
fontsizeruler    = 12; 
fontsizelabel    = 13; 
fontsizetitle    = 14; 

htitle.FontSize  = fontsizetitle;
htitle.FontName  = fontuse; 

hxlabel.FontSize = fontsizelabel; 
hxlabel.FontName = fontuse; 

hxrule.FontSize  = fontsizeruler; 
hxrule.FontName  = fontuse; 

hylabel.FontSize = fontsizelabel; 
hylabel.FontName = fontuse; 

hyrule.FontSize  = fontsizeruler; 
hyrule.FontName  = fontuse; 

try
    hplot.LineWidth = 3;
end
end