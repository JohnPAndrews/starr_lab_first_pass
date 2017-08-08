function testMoveLine2()
hFig = figure ( 'windowstyle', 'normal',...
    'WindowButtonMotionFcn', @MouseMove,...
    'WindowButtonUpFcn', @MouseUp );
% some dummy data
x = -pi:0.01:pi;
% an initial X for my example
vLineX = randi(length(x));
% plot 1 
hs1 = subplot(1,2,1,...
    'parent',hFig,...
    'nextplot','add'...
    );
hold on; 
hp1 = line ( [x(vLineX) x(vLineX)],ylim,...
    'LineWidth',4,...
    'ButtonDownFcn',@MouseDown1,...
    'UserData',0);
xlim([-pi pi])

% plot 2 
hs2 = subplot(1,2,2,...
    'parent',hFig,...
    'nextplot','add'...
    );
hold on;
hp2 = line (  [x(vLineX) x(vLineX)],ylim,...
    'LineWidth',4,...
    'ButtonDownFcn',@MouseDown2,...
    'UserData',0);
xlim([-pi pi])

    function MouseDown1(gcbo,event,handles)
        set(gcbo,'UserData',1)
        % get the current xlimmode
        xLimMode = get ( hs1, 'xlimMode' );
        % setting this makes the xlimits stay the same (comment out and test)
        set ( hs1, 'xlimMode', 'manual' );

    end


    function MouseDown2(gcbo,event,handles)
        set(gcbo,'UserData',1)
        % get the current xlimmode
        xLimMode = get ( hs2, 'xlimMode' );
        % setting this makes the xlimits stay the same (comment out and test)
        set ( hs2, 'xlimMode', 'manual' );

    end

    function MouseMove(gcbo,event,handles)
        if get(hp1,'UserData')
            cp = get ( hs1, 'CurrentPoint' );
            % update the xdata of the line handle
            set ( hp1, 'XData', [cp(1,1) cp(1,1)] );
            set ( hp2, 'XData', [cp(1,1) cp(1,1)] );
        end
        if get(hp2,'UserData')
            xlims = get(hs1,'xlim');
            % get the current point on the axes
            cp = get ( hs2, 'CurrentPoint' );
            set ( hp1, 'XData', [cp(1,1) cp(1,1)] );
            set ( hp2, 'XData', [cp(1,1) cp(1,1)] );
        end
    end

    function MouseUp(gcbo,event,handles)
        set(hp1,'UserData',0)
        set(hp2,'UserData',0)
%         set ( hs1, 'xlimMode', xLimMode );
%         set ( hs2, 'xlimMode', xLimMode );
    end


end

