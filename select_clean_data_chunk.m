function outidx = select_clean_data_chunk(data)
%% Select a sub section of data across channels 
%  This function selects a sub sections of data across various channels 
%  input 
%  data - matrix of channels (rows) by samples (columns) 
%  output 
%  sub section of data slected 

%  instruction: 
%  move green (start) and red (end) markers to select artifact free chunk
%  of data 
%  supply sr in box to change x axis to seconds 

% output 
% idx of start and end lines 
outidx = []; 
%% Set up contorls 
hFig = figure ( 'windowstyle', 'normal',...
    'units','normalized',...
    'WindowButtonMotionFcn', @MouseMove,...
    'WindowButtonUpFcn', @MouseUp );
hDone = uicontrol ( 'parent', hFig,...
    'style', 'pushbutton',...
    'string','DONE!',...
    'units','normalized',...
    'Position',[.75 .01 .1 .1],...
    'Callback', @ClosePlot );
hZoomIn = uicontrol ( 'parent', hFig,...
    'style', 'pushbutton',...
    'string','Zoom In',...
    'units','normalized',...
    'Position',[.65 .01 .1 .1],...
    'Callback', @ZoomIn );
hZoomOut = uicontrol ( 'parent', hFig,...
    'style', 'pushbutton',...
    'string','Zoom Out',...
    'units','normalized',...
    'Position',[.55 .01 .1 .1],...
    'Callback', @ZoomOut );
hSampleRate= uicontrol ( 'parent', hFig,...
    'style', 'edit',...
    'string','15',...
    'units','normalized',...
    'visible','off',... % not working so hide for now 
    'Position',[.45 .01 .1 .1],...
    'Callback', @SampleRate );
hSampleRateText = uicontrol ( 'parent', hFig,...
    'style', 'text',...
    'string','sr is na',...
    'units','normalized',...
    'visible','off',... % not working so hide for now 
    'Position',[.35 .01 .1 .1],...
    'Callback', @SampleRateReport );


%% plot the data 

% set raw data 
handles.data  = data; 
handles.nchan = size(data,1); 
handles.secs = []; 
xplot      = 1:size(data,2); 
% set line locations 
linelocs =  [size(data,2) * 0.1, size(data,2) * 0.9];
axcol = []; 
for sp = 1:handles.nchan
    hax = subplot(handles.nchan,1,sp,...
        'parent',hFig,...
        'nextplot','add',...
        'units','normalized',...
        'UserData',data(sp,:) );
    axcol = [axcol hax];
    hp(sp) = plot(xplot,data(sp,:)); 
    hp(sp).XDataSource = 'xplot';
    hlims(sp,:) = hax.XLim;
    
    hold on; 
    % plot graphs 
    for ln = 1:length(linelocs)
        dat.mouse = 0; 
        dat.plot  = sp; 
        dat.line  = ln;
        dat.hax   = hax; 
        hlns(sp,ln) = line ( [linelocs(ln) linelocs(ln)],ylim,...
            'LineWidth',4,...
            'ButtonDownFcn',@MouseDown,...
            'UserData',dat);
    end
    haxSp(sp) = hax; 
end
% move the plots up a little bit to make roome for buttons 
for h = 1:length(haxSp)
    haxSp(h).Position(2) = haxSp(h).Position(2)+0.05;
end
% initizlise some variables
ln = []; 
p =[]; 
% wait until user is done 
uiwait(hFig);

    function ClosePlot(gcbo,event,handles)
        % get the current xlimmode
        for lnn = 1:size(hlns,2) % loop on lines
            outidx(lnn) = hlns(1,lnn).XData(1);
        end
        delete(gcf)
    end

    function ZoomIn(gcbo,event,handles)
        for p = 1:size(hlns,1)
            for ln = 1:size(hlns,2) % loop on lines
                lines(ln) = hlns(p,ln).XData(1);
            end
            haxSp(p).XLim = [lines(1) * 0.9  lines(2) * 1.1 ];
            ydat = hp(p).YData(round(lines(1)):round(lines(2)));
            haxSp(p).YLim = [min(ydat)*0.9  max(ydat)*1.1];
        end
    end

    function ZoomOut(gcbo,event,handles)
        for p = 1:size(haxSp,2)
            haxSp(p).XLim = hlims(p,:);
            haxSp(p).YLim = [min(hp(p).YData)*0.9 max(hp(p).YData)*1.1];
        end
    end

    function SampleRate(gcbo,event,handles)
        sr = str2double(gcbo.String);
        hSampleRateText.String = sprintf('sr is %s', gcbo.String);
        xplot = xplot./sr; 
%         refreshdata(hFig);
%         for p = 1:length(hp)
%             hp(p).XData = hp(p).XData./sr; 
%             hp(p).YData = hp(p).YData;
%         end
%         refreshdata(hFig);
%         % get the current point
%         dat.hax.XTickLabel = dat.hax.XTick./sr;
%         for p = 1:size(hlns,1) % loop on plots
%             dat = get(hlns(p,1),'UserData');
%             xticks = get(dat.hax,'XTick');
%         end
    end
    

    function SampleRateReport(gcbo,event,handles)
        get(gcbo);
    end

    function MouseDown(gcbo,event,handles)
        % get the current xlimmode
        dat = get(gcbo,'UserData'); 
        dat.mouse = 1; 
        set(hlns(dat.plot,dat.line),'UserData',dat); 
        xLimMode = get ( dat.hax, 'xlimMode' );
        %setting this makes the xlimits stay the same (comment out and test)
        set ( dat.hax, 'xlimMode', 'manual' );
    end

    function MouseMove(gcbo,event,handles)
        cp = []; 
        % get the current point 
        for p = 1:size(hlns,1) % loop on plots 
            for lnn = 1:size(hlns,2) % loop on lines 
                dat = get(hlns(p,lnn),'UserData'); 
                if dat.mouse 
                    cp = get ( dat.hax, 'CurrentPoint' );
                    lnmove = lnn; 
                    break; 
                end
            end
        end
        % move the correct lines in all plots and color the lines red 
        for p = 1:size(hlns,1) % loop on plots
            if ~isempty(cp)
                set ( hlns(p,lnmove), 'XData', [cp(1,1) cp(1,1)] );
                set(hlns(p,lnmove),'Color','r'); 
            end
        end
        
    end

    function MouseUp(gcbo,event,handles)
        % reset all the mouse prperties to zero 
        for p = 1:size(hlns,1) % loop on plots 
            for lnn = 1:size(hlns,2) % loop on lines 
                dat = get(hlns(p,lnn),'UserData'); 
                dat.mouse = 0; 
                set(hlns(p,lnn),'UserData',dat);
                set(hlns(p,lnn),'Color','b'); 
            end
        end
    end

end