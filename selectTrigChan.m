function eegtrig = selectTrigChan(eegraw)  % select the eeg stim pulse channel 
% create a dialog, with the mouse actions set
hFig = dialog ( 'windowstyle', 'normal' );
% create an axes
ax = axes ( 'parent', hFig, 'position', [0.1 0.2 0.8 0.7], 'nextplot', 'add' );
userPlot = []; % init a value -> this is used to clear the previous user data
% create selector for eeg channels
eegtrig = []; 
rawfnms = fieldnames(eegraw);
if isfield(eegraw,'lfp_elec')
    rawfnms = {'lfp','ecog'};
end

pop = uicontrol ( 'parent', hFig,...
    'style', 'popupmenu',...
    'string', rawfnms,...
    'Position',[50 10 60 40],...
    'Callback', @UpdatePlot );
but = uicontrol ( 'parent', hFig,...
    'style', 'pushbutton',...
    'string','DONE!',...
    'Position',[450 10 60 40],...
    'Callback', @ClosePlot );
UpdatePlot();
uiwait(hFig);


% a callback for plotting the user data
    function UpdatePlot ( obj, event )
        % delete any user data which is already plotted
        delete ( userPlot );
        % plot the user data
        ydat = eegraw.(rawfnms{pop.Value});
        userPlot = plot ( ax, ydat, 'r.-' );
    end
% on close plot return slider locations and beeps found
    function ClosePlot(obj,event)
        
        if isfield(eegraw,'lfp_elec')
            eegtrig.srate    =  eegraw.sr;
        else
            eegtrig.srate    =  eegraw.srate;
        end
        dat     =  eegraw.(rawfnms{pop.Value});
        [b,a]        = butter(3,2 / (eegtrig.srate/2),'high'); % user 3rd order butter filter
        zdat = zscore(filtfilt(b,a,double(dat)));
        if min(zdat) < -7
            zdat = zdat.*(-1);
        end
        eegtrig.data = zdat; 
        delete(gcf)
    end

end