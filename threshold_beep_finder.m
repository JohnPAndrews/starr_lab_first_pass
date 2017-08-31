function varargout = threshold_beep_finder(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @threshold_beep_finder_OpeningFcn, ...
                   'gui_OutputFcn',  @threshold_beep_finder_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before threshold_beep_finder is made visible.
function threshold_beep_finder_OpeningFcn(hObject, eventdata, handles, varargin)
set(hObject,'toolbar','figure');
set(hObject,'menubar','figure');

set(handles.figure1,...
    'WindowButtonMotionFcn', @MouseMove,...
    'WindowButtonUpFcn', @MouseUp );
% set zoooming behaviour 
% 
zoom xon 
handles.ZoomOutPressedEEG = 0; 
handles.ZoomOutPressedECOG = 0; 

% setAxesZoomConstraint(handles.ZoomIn,handles.axEEG,'x')
% 
% set the initial variables eeg 
eegraw = varargin{1};
rawfnms = fieldnames(eegraw);
idxchoose = cellfun(@(x) ~any(strfind(x,'srate')),rawfnms);
rawfnms = rawfnms(idxchoose);
handles.eeg_xlims = [0.5 20].*eegraw.srate; 
% set pop up values 
handles.channel_select_eeg.String = rawfnms;
handles.channel_select_eeg.Value = 1;



% set up variables ecog 
brraw  = varargin{2};
bruse.lfp = brraw.lfp.*-1;
bruse.ecog = brraw.ecog.*-1;
bruse.srate = brraw.sr; 

rawfnms = fieldnames(bruse);
idxchoose = cellfun(@(x) ~any(strfind(x,'srate')),rawfnms);
rawfnms = rawfnms(idxchoose);
handles.channel_select_ecog.String = rawfnms;
handles.channel_select_ecog.Value = 2;
handles.ecog_xlims = [0.5 20].*bruse.srate; 

handles.eegThresh = 20;
handles.ecogThresh = 20;


% save variables in handles strucutre 
handles.eegdat = eegraw; 
handles.ecogdat =  bruse; 

% set ouptput 
handles.output = [];
% Update handles structure
guidata(hObject, handles);
updatePlot();
uiwait(handles.figure1);

% UIWAIT makes threshold_beep_finder wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = threshold_beep_finder_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.allignData;
delete(handles.figure1);


% --- Executes on button press in flipEEG.
function flipEEG_Callback(hObject, eventdata, handles)
idx = handles.channel_select_eeg.Value; 
rawfnms = handles.channel_select_eeg.String;
datplot = handles.eegdat.(rawfnms{idx});
handles.eegdat.(rawfnms{idx}) = datplot .* (-1);
guidata(hObject, handles);
updatePlot();

% hObject    handle to flipEEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in flipECOG.
function flipECOG_Callback(hObject, eventdata, handles)
% hObject    handle to flipECOG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in eeg_channel_selec.
function eeg_channel_selec_Callback(hObject, eventdata, handles)

% hObject    handle to eeg_channel_selec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns eeg_channel_selec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eeg_channel_selec


% --- Executes during object creation, after setting all properties.
function eeg_channel_selec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eeg_channel_selec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ecoc_channel_selec.
function ecoc_channel_selec_Callback(hObject, eventdata, handles)
% hObject    handle to ecoc_channel_selec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ecoc_channel_selec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ecoc_channel_selec


% --- Executes during object creation, after setting all properties.
function ecoc_channel_selec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ecoc_channel_selec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectThreshEEG.
function selectThreshEEG_Callback(hObject, eventdata, handles)
thresh= get ( handles.hThreshEEG, 'YData');
handles.eegThresh = thresh(1);
guidata(handles.figure1, handles);
% hObject    handle to selectThreshEEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in find_beeps_eeg.
function find_beeps_eeg_Callback(hObject, eventdata, handles)
rawfnms = handles.channel_select_eeg.String; 
idx = handles.channel_select_eeg.Value; 
datplot = handles.eegdat.(rawfnms{idx}); 
[b,a]        = butter(3,50 / (handles.eegdat.srate/2),'high'); % user 3rd order butter filter
datplot = filtfilt(b,a,double(datplot)) ; 
datause = zscore(datplot);
xlimsuse = handles.axEEG.XLim;
[pks,locs,~,~] = findpeaks(datause,...
    'MinPeakDistance',2,...
    'MinPeakHeight', handles.eegThresh );
idxuse = locs > xlimsuse(1) & locs < xlimsuse(2);
pksuse = pks(idxuse); 
locuse = locs(idxuse); 
if isfield(handles,'scattereeg')
    for s = 1:length(handles.scattereeg)
        delete(handles.scattereeg(s));
    end
    rmfield(handles,'scattereeg');
end
axes(handles.axEEG);
hold on;
for s = 1:length(pksuse)
    handles.scattereeg(s) = ...
        scatter(...
        locuse(s),pksuse(s),...
        400,'r',...
        'UserData',1,...
        'ButtonDownFcn',@ScatterPressed,...
        'UserData',0);
end
handles.axEEG.XLim = xlimsuse;
guidata(gcf,handles);

% --- Executes on button press in flip_signal_ecog.
function flip_signal_ecog_Callback(hObject, eventdata, handles)
idx = handles.channel_select_ecog.Value; 
rawfnms = handles.channel_select_ecog.String;
datplot = handles.ecogdat.(rawfnms{idx});
handles.ecogdat.(rawfnms{idx}) = datplot .* (-1);
guidata(hObject, handles);
updatePlot();

% hObject    handle to flip_signal_ecog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in select_thresh_ecog.
function select_thresh_ecog_Callback(hObject, eventdata, handles)
thresh = get ( handles.hThreshECOG, 'YData');
handles.ecogThresh = thresh(1);
guidata(handles.figure1, handles);
% hObject    handle to select_thresh_ecog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in find_beeps_ecog.
function find_beeps_ecog_Callback(hObject, eventdata, handles)
rawfnms = handles.channel_select_ecog.String; 
idx = handles.channel_select_ecog.Value; 
datplot = handles.ecogdat.(rawfnms{idx}); 
[b,a]        = butter(3,50 / (handles.ecogdat.srate/2),'high'); % user 3rd order butter filter
datplot = filtfilt(b,a,double(datplot)) ; 
datause = zscore(datplot);
xlimsuse = handles.axECOG.XLim;
[pks,locs,~,~] = findpeaks(datause,...
    'MinPeakDistance',2,...
    'MinPeakHeight', handles.ecogThresh );
idxuse = locs > xlimsuse(1) & locs < xlimsuse(2);
pksuse = pks(idxuse); 
locuse = locs(idxuse); 
% remove ecog 
if isfield(handles,'scatterecog')
    for s = 1:length(handles.scatterecog)
        delete(handles.scatterecog(s));
    end
    rmfield(handles,'scatterecog');
end

axes(handles.axECOG);
for s = 1:length(pksuse)
    handles.scatterecog(s) = ...
        scatter(locuse(s),pksuse(s),...
        400,'r',...
        'UserData',1,...
        'ButtonDownFcn',@ScatterPressed,...
        'UserData',0);
end
guidata(gcf,handles);



% --- Executes on button press in align_start.
function align_start_Callback(hObject, eventdata, handles)
% hObject    handle to align_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in compute_sr.
function compute_sr_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
% get eeg differnces 
cnt = 1; 
for s = 1:length(handles.scattereeg)
    if handles.scattereeg(s).UserData
        eegpoint(cnt) = handles.scattereeg(s).XData;
        cnt = cnt + 1; 
    end
end
% get ecog differences 
cnt = 1; 
for s = 1:length(handles.scatterecog)
    if handles.scatterecog(s).UserData
        ecogpoint(cnt) = handles.scatterecog(s).XData;
        cnt = cnt + 1; 
    end
end

Diffecog = ecogpoint(2)- ecogpoint(1); % XXX just use first point consider changing
Diffeeg = eegpoint(2)- eegpoint(1);
ecogSR  = (handles.eegdat.srate * Diffecog ) / Diffeeg;
ecogsr = round(ecogSR);
handles.allignData.eegsync = eegpoint; 
handles.allignData.ecogsync = ecogpoint; 
handles.allignData.diffecog = Diffecog;
handles.allignData.diffeeg = Diffeeg;
handles.allignData.ecogsr  = ecogsr;
handles.allignData.eegsr   = handles.eegdat.srate;
% update handles structure  
guidata(handles.figure1,handles);

handles.sr_text.String = sprintf('SR is %d',ecogsr);
% hObject    handle to compute_sr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in channel_select_eeg.
function channel_select_eeg_Callback(hObject, eventdata, handles)
updatePlot();


% --- Executes during object creation, after setting all properties.
function channel_select_eeg_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel_select_ecog.
function channel_select_ecog_Callback(hObject, eventdata, handles)
updatePlot();

% hObject    handle to channel_select_ecog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel_select_ecog contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel_select_ecog


% --- Executes during object creation, after setting all properties.
function channel_select_ecog_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_select_ecog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MouseMove(gcbo,event,handles)
handles = guidata(gcf);
if handles.eegThreshMouseDown
    cp = get ( handles.axEEG, 'CurrentPoint' );
    set ( handles.hThreshEEG, 'YData', [cp(1,2) cp(1,2)] );
end

if handles.ecogThreshMouseDown
    cp = get ( handles.axECOG, 'CurrentPoint' );
    set ( handles.hThreshECOG, 'YData', [cp(1,2) cp(1,2)] );
end



function MouseUp(gcbo,event,handles)
handles = guidata(gcf);
handles.eegThreshMouseDown = 0; 
handles.ecogThreshMouseDown = 0;
guidata(gcf,handles);



function MouseDown(obj,event)
handles = guidata(gcf);
%% let the handle let me know which linke it is 
switch obj.UserData
    case 'eeg'
        handles.eegThreshMouseDown = 1;
    case 'ecog'
        handles.ecogThreshMouseDown = 1;
end
guidata(gcf,handles);


function ScatterPressed(obj,event)
if ~obj.UserData
    obj.MarkerFaceColor = 'b';
    obj.UserData = 1;
elseif obj.UserData
    obj.MarkerFaceColor = 'none';
    obj.UserData = 0;
end

handles = guidata(gcf);
guidata(gcf,handles);





function updatePlot()
handles = guidata(gcf);
%% update the plot according to current settings 

%%  plot eeg 
cla ( handles.axEEG );
rawfnms = handles.channel_select_eeg.String; 
idx = handles.channel_select_eeg.Value; 
datplot = handles.eegdat.(rawfnms{idx}); 
[b,a]        = butter(3,50 / (handles.eegdat.srate/2),'high'); % user 3rd order butter filter
datplot = filtfilt(b,a,double(datplot)) ; 
plot(handles.axEEG,zscore(datplot),...
    'LineWidth',0.5,....
    'Color',[1 0 0 0.2]);
hold on;
handles.hThreshEEG = line(handles.axEEG,[0 length(datplot)],...
    [handles.eegThresh handles.eegThresh],...
    'LineWidth',2,...
    'Color',[1 0 0 0.2],...
    'ButtonDownFcn',@MouseDown,...
    'UserData','eeg');
handles.eegThreshMouseDown = 0;

% set zooming eeg 
if handles.ZoomOutPressedEEG
    handles.eeg_xlims = handles.axEEG.XLim;
else
    xlim(handles.axEEG,handles.eeg_xlims)
end


%% plot ecog 
cla ( handles.axECOG );

rawfnms = handles.channel_select_ecog.String; 
idx = handles.channel_select_ecog.Value; 
datplot = handles.ecogdat.(rawfnms{idx}); 
[b,a]        = butter(3,50 / (handles.ecogdat.srate/2),'high'); % user 3rd order butter filter
datplot = filtfilt(b,a,double(datplot)) ; 
plot(handles.axECOG,zscore(datplot),...
    'LineWidth',0.5,....
    'Color',[0 0 1 0.2]);
hold on;
handles.hThreshECOG = line(handles.axECOG,[0 length(datplot)],...
    [handles.ecogThresh handles.ecogThresh],...
    'LineWidth',2,...
    'Color',[1 0 0 0.2],...
    'ButtonDownFcn',@MouseDown,...
    'UserData','ecog');
handles.ecogThreshMouseDown = 0;

% set zooming ecog 
if handles.ZoomOutPressedEEG
    handles.ecog_xlims = handles.axECOG.XLim;
else
    xlim(handles.axECOG,handles.ecog_xlims)
end


guidata(gcf, handles);


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CloseFigure.
function CloseFigure_Callback(hObject, eventdata, handles)
% hObject    handle to CloseFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);
handles.output = handles.allignData; 
uiresume(handles.figure1); 
% delete(handles.figure1);


% --- Executes on button press in ZoomOutEEG.
function ZoomOutEEG_Callback(hObject, eventdata, handles)
rawfnms = handles.channel_select_eeg.String; 
idx = handles.channel_select_eeg.Value; 
datplot = handles.eegdat.(rawfnms{idx}); 

handles.eeg_xlims = [1 length(datplot)];
xlim(handles.axEEG,handles.eeg_xlims)
handles.ZoomOutPressedEEG = 1;
guidata(gcf, handles);


% hObject    handle to ZoomOutEEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in zoomOutECOG.
function zoomOutECOG_Callback(hObject, eventdata, handles)
rawfnms = handles.channel_select_ecog.String; 
idx = handles.channel_select_ecog.Value; 
datplot = handles.ecogdat.(rawfnms{idx}); 

handles.ecog_xlims = [1 length(datplot)];
xlim(handles.axECOG,handles.ecog_xlims)
handles.ZoomOutPressedECOG = 1;
guidata(gcf, handles);


% hObject    handle to zoomOutECOG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
