function formatPlot(htitle,hxlabel,hylabel,hxrule,hyrule,hplot)
% given handels to different plot elements, format the plot
fontuse = 'Helvetica';
fontsizeruler    = 16;
fontsizelabel    = 17;
fontsizetitle    = 18;

htitle.FontSize  = fontsizetitle;
htitle.FontName  = fontuse;
try
    hxlabel.FontSize = fontsizelabel;
    hxlabel.FontName = fontuse;
end
try
    hxrule.FontSize  = fontsizeruler;
    hxrule.FontName  = fontuse;
end
hylabel.FontSize = fontsizelabel;
hylabel.FontName = fontuse;

hyrule.FontSize  = fontsizeruler;
hyrule.FontName  = fontuse;

try
    hplot.LineWidth = 3;
end
end