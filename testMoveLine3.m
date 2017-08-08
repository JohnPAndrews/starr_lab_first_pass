function testMoveLine3()
hFig = figure ( 'windowstyle', 'normal',...
    'WindowButtonMotionFcn', @MouseMove,...
    'WindowButtonUpFcn', @MouseUp );
% some dummy data
x = -pi:0.01:pi;
% an initial X for my example
linelocs =  [randi(length(x)) randi(length(x))];
nplots = 3; 
for sp = 1:nplots
    hax = subplot(1,nplots,sp,...
        'parent',hFig,...
        'nextplot','add'...
        );
    hold on; 
    % plot graphs 
    for ln = 1:length(linelocs)
        dat.mouse = 0; 
        dat.plot  = sp; 
        dat.line  = ln;
        dat.hax   = hax; 
        hlns(sp,ln) = line ( [x(linelocs(ln)) x(linelocs(ln))],ylim,...
            'LineWidth',4,...
            'ButtonDownFcn',@MouseDown,...
            'UserData',dat);
    end
end
linkaxes();

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

