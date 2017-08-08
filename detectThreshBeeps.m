function [outdat] = detectThreshBeeps(eegraw)
%% This function looks for peaks 
%% Given start end point constraints 
%% Input: 
%% 1. structure with matrices of data (you can switch between these) 
%% 2. a field 'srate' with the sampling rate of the data 

% Create the variable which is required to know if the line move is active or not.
mouseDown1 = false;
mouseDown2 = false;
mouseDown3 = false;
outdat.beepsloc = [];
outdat.startloc = [];
outdat.endloc   = [];
outdat.srate    = [];

% Create the first value for the xlimMode (used in callbacks)
xLimMode = 'auto';
% create a dialog, with the mouse actions set
hFig = dialog ( 'windowstyle', 'normal', 'WindowButtonMotionFcn', @MouseMove, 'WindowButtonUpFcn', @MouseUp );
% create an axes
ax = axes ( 'parent', hFig, 'position', [0.1 0.2 0.8 0.7], 'nextplot', 'add' );
% create selector for eeg channels
rawfnms = fieldnames(eegraw);
idxchoose = cellfun(@(x) ~any(strfind(x,'srate')),rawfnms);
rawfnms = rawfnms(idxchoose);
pop = uicontrol ( 'parent', hFig,...
    'style', 'popupmenu',...
    'string', rawfnms,...
    'Callback', @UpdatePlot );
but1 = uicontrol ( 'parent', hFig,...
    'style', 'pushbutton',...
    'string','DONE!',...
    'Position',[450 10 60 40],...
    'Callback', @ClosePlot );

but2 = uicontrol ( 'parent', hFig,...
    'style', 'pushbutton',...
    'string','Wheres my beeps?','FontSize',12,...
    'Position',[300 10 150 40],...
    'Callback', @FindBeeps );

but2 = uicontrol ( 'parent', hFig,...
    'style', 'pushbutton',...
    'string','FlipSignal','FontSize',12,...
    'Position',[200 10 100 40],...
    'Callback', @FlipSignal );

beeps = []; % initilize number of beeps found
% initizlie a erg1 as the first plot
if isfield(eegraw,'EXG1')
    pop.Value = 9;
    % eegdata
    x = [1:length(eegraw.EXG1)]./eegraw.srate;
else
    pop.Value = 1; 
    x = [1:length(eegraw.(rawfnms{pop.Value}))]./eegraw.srate;
end

% On first time through create a plot
userPlot = []; % init a value -> this is used to clear the previous user data
scatPlot = []; 
UpdatePlot();
% get the y limits of the data to be plotted
curxlims = get(ax,'xlim');
curylims = get(ax,'ylim');
ylim = get ( ax, 'ylim' );
xlim = get ( ax, 'xlim' );
% plot the vertical line
hLine1 = plot ( ax, [xlim(2)*0.1 xlim(2)*0.1], ylim,...
    'LineWidth',2, 'Color',[0.9 0 1 0.8],...
    'ButtonDownFcn', @MouseDown1 );
hLine2 = plot ( ax, [xlim(2)*0.9 xlim(2)*0.9], ylim,...
    'LineWidth',2, 'Color',[0 0.9 0 0.8],...
    'ButtonDownFcn', @MouseDown2 );
hLine3 = plot ( ax, xlim, [ylim(2)*0.9 ylim(2)*0.9],...
    'LineWidth',2, 'Color',[0 0 0.9 0.8],...
    'ButtonDownFcn', @MouseDown3 );
uiwait(hFig);
% a callback for plotting the user data
    function UpdatePlot ( obj, event )
        % delete any user data which is already plotted
        delete ( userPlot );
        delete ( scatPlot );
        % plot the user data
        ydat = eegraw.(rawfnms{pop.Value});
        userPlot = plot ( ax, x, ydat, 'r.-' );
        ylabel(ax,'volts');
        xlabel(ax,'seconds');
        ttl1 = 'move sliders to select start, end and threshold';
        if isempty(beeps)
            ttl2 = sprintf('found 0 beeps');
        else
            ttl2 = sprintf('found %d beeps',beeps);
        end
        title(ax,{ttl1;ttl2});
    end
% a function which is called whenever the mouse is moved
    function MouseMove ( obj, event )
        % only run this section if the user has clicked on the line
        if mouseDown1
            % get the current point on the axes
            cp = get ( ax, 'CurrentPoint' );
            % update the xdata of the line handle.
            set ( hLine1, 'XData', [cp(1,1) cp(1,1)] );
        end
        if mouseDown2
            % get the current point on the axes
            cp = get ( ax, 'CurrentPoint' );
            % update the xdata of the line handle.
            set ( hLine2, 'XData', [cp(1,1) cp(1,1)] );
        end
        if mouseDown3
            % get the current point on the axes
            cp = get ( ax, 'CurrentPoint' );
            % update the xdata of the line handle.
            set ( hLine3, 'YData', [cp(1,2) cp(1,2)] );
        end
    end
% callback from the user clicking on the line
    function MouseDown1 ( obj, event )
        % get the current xlimmode
        xLimMode = get ( ax, 'xlimMode' );
        % setting this makes the xlimits stay the same (comment out and test)
        set ( ax, 'xlimMode', 'manual' );
        % set the mouse down flag
        mouseDown1 = true;
    end
% callback from the user clicking on the line
    function MouseDown2 ( obj, event )
        % get the current xlimmode
        xLimMode = get ( ax, 'xlimMode' );
        % setting this makes the xlimits stay the same (comment out and test)
        set ( ax, 'xlimMode', 'manual' );
        % set the mouse down flag
        mouseDown2 = true;
    end
    function MouseDown3 ( obj, event )
        % get the current xlimmode
        xLimMode = get ( ax, 'xlimMode' );
        yLimMode = get ( ax, 'ylimMode' );
        % setting this makes the xlimits stay the same (comment out and test)
        set ( ax, 'xlimMode', 'manual' );
        set ( ax, 'ylimMode', 'manual' );
        
        % set the mouse down flag
        mouseDown3 = true;
    end
% on mouse up
    function MouseUp ( obj, event )
        % reset the xlim mode once the moving stops
        set ( ax, 'xlimMode', xLimMode );
        % set x limits based on line move
        curxlims(1) = hLine1.XData(1)*0.9;
        curxlims(2) = hLine2.XData(1)*1.1;
        set ( ax, 'XLim', curxlims );
        
        % set y limits based on data between start and end
        % don't forgt to move the treshold hold line
        ydat = eegraw.(rawfnms{pop.Value});
        if hLine1.XData(1) <= 0 
            hLine1.XData(1) = 0;
        end
        
        if round(hLine2.XData(1)*eegraw.srate) >= length(ydat)
            hLine2.XData(1,1) = (length(ydat)/eegraw.srate)*0.97;
            hLine2.XData(1,2) = (length(ydat)/eegraw.srate)*0.97;
        end
        miny = min( ydat ( round(hLine1.XData(1)*eegraw.srate) : ...
            round(hLine2.XData(1)*eegraw.srate)));
        maxy = max( ydat ( round(hLine1.XData(1)*eegraw.srate) : ...
            round(hLine2.XData(1)*eegraw.srate)));
        curylims(1) = miny*0.9;
        curylims(2) = maxy*1.1;
        set ( ax, 'YLim', curylims );
        curydat = get( hLine3, 'YData');
        if curydat(2) > maxy
            set ( hLine3, 'YData', [maxy*0.9 maxy*0.9] );
        end
        
        
        % reset the mouse down flag.
        mouseDown1 = false;
        mouseDown2 = false;
        mouseDown3 = false;
        
    end
    % when button pressed to find beeps, find some beeps! 
    function FindBeeps(obj,event)
        delete( scatPlot);
        fprintf('find beeps pressed\n');
        ydat = eegraw.(rawfnms{pop.Value});
        thresh = hLine3.YData;
        [pks,locs,~,~] = findpeaks(ydat,...
        'MinPeakDistance',2,...
        'MinPeakHeight',thresh(1));
        set(ax,'nextplot','add');
        idxuse = locs > hLine1.XData(1).*eegraw.srate & locs < hLine2.XData(1).*eegraw.srate;
        scatPlot = scatter(ax, locs(idxuse)./eegraw.srate,pks(idxuse),300,'b');
        ttl1 = 'move sliders to select start, end and threshold';
        beeps = locs(idxuse);
        if isempty(beeps)
            ttl2 = sprintf('found 0 beeps');
        else
            ttl2 = sprintf('found %d beeps',length(beeps));
            outdat.beepsloc = beeps; 
        end
        title(ax,{ttl1;ttl2});
    end
    % flip the current signal 
    function FlipSignal(obj,event)
        eegraw.(rawfnms{pop.Value}) = eegraw.(rawfnms{pop.Value}) .* (-1);
        UpdatePlot();
    end
    % on close plot return slider locations and beeps found
    function ClosePlot(obj,event)
        outdat.beepsloc = beeps;
        outdat.startloc = hLine1.XData(1);
        outdat.endloc   = hLine2.XData(1);
        outdat.srate    = eegraw.srate; 
        delete(gcf)
    end
    


end