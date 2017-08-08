function ipad_adjust_lines_manually()
fnmtmp = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized/brpd_10/v04_03_wek/s_005_tsk-ipad/ipad_event_indices.mat';
load(fnmtmp,...
        'beepsInIdxs','brraw','eegraw','alligninfo','beepsfound');
hFig = figure ( 'windowstyle', 'normal',...
    'WindowButtonMotionFcn', @MouseMove,...
    'WindowButtonUpFcn', @MouseUp );
%% compute data to plot 
% set raw data 
[b,a]        = butter(3,2 / (eegraw.srate/2),'high'); % user 3rd order butter filter
handles.chan12 = filtfilt(b,a,double(eegraw.EXG2 - eegraw.EXG1)) ; 
handles.chan34 = filtfilt(b,a,double(eegraw.EXG4 - eegraw.EXG3)) ; 
handles.chan56 = filtfilt(b,a,double(eegraw.EXG6 - eegraw.EXG5)) ; 
handles.erg1 = filtfilt(b,a,double(eegraw.Erg1)) ; 
handles.erg2 = filtfilt(b,a,double(eegraw.Erg2)); 
handles.datnames  = {'chan12','chan34','chan56','erg1','erg2'}; 
handles.titlesuse = {'sync','ecr','deltoid','erg1','erg2'}; 
handles.mousedown  = false; 
handles.srate      = eegraw.srate; 
handles.ipadpeaks  = [];
secs = (1:length(handles.erg1) )./eegraw.srate; 
handles.secs = secs; 

% an initial X for my example
linelocs =  beepsfound.beepsloc + 3; % seconds to add to beeps 
nplots = length(handles.titlesuse);
axcol = []; 
for sp = 1:nplots
    hax = subplot(nplots,1,sp,...
        'parent',hFig,...
        'nextplot','add'...
        );
    axcol = [axcol hax];
    fnm = handles.datnames{sp}; 
    plot(handles.secs,handles.(fnm)); 
    xlim([beepsfound.startloc beepsfound.endloc]);
    title(handles.titlesuse{sp});
    
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
end
linkaxes(axcol,'x');

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