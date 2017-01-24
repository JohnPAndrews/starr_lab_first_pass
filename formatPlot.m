function formatPlot(htitle,hxlabel,hylabel,hxrule,hyrule)
% given handels to different plot elements, format the plot 
fontuse = 'Helvetica'; 
fontsizeruler    = 17; 
fontsizelabel    = 16; 
fontsizetitle    = 18; 

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

end