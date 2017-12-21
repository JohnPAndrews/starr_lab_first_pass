function varargout = emg_movement_detect(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @emg_movement_detect_OpeningFcn, ...
    'gui_OutputFcn',  @emg_movement_detect_OutputFcn, ...
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


% --- Executes just before emg_movement_detect is made visible.
function emg_movement_detect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to emg_movement_detect (see VARARGIN)
set(hObject,'toolbar','figure');
set(hObject,'WindowButtonMotionFcn',@MouseMove);
set(hObject,'WindowButtonUpFcn',@MouseUp);
        

% Choose default command line output for emg_movement_detect
handles.output = hObject;
handles.hfig   = gcf; 
handles.emgdat = [];
handles.xlimsuse = [];
handles.eegraw = varargin{1}; 
%% set some initial values 
% set initial chanels to graph values 
handles.chan56.Value = 1; 
handles.chan78.Value = 1; 
handles.erg2.Value = 1; 
handles.selectStartPressed = 1; 
handles.selectEndPressed = 1; 
handles.MinMoveLenSecs = str2double(handles.MinMoveLen.String);
handles.MinInterMoveLenSecs = str2double(handles.MinInterMoveDis.String);

% set some filtering values  
handles.WindowSizePoints = str2double(handles.windowSizeFilter.String);
handles.FilterOrderUse = str2double(handles.filterOrderUse.String);
handles.NumPointAverageAfterMoveDetect = str2double(handles.pointsAfterAveraging.String); % 
handles.NumPointAverageBeforeMoveDetect = str2double(handles.pointsBeforeAveraging.String); % pointsBeforeAveraging
handles.HighPassValMoveDetect = str2double(handles.highpass.String); %highpass
handles.LowPassValMoveDetect = str2double(handles.lowpass.String); % lowpass


% save handles structure 
guidata(hObject, handles);
%% 
% plot selection 
updatePlot();
%% XXX 
uiwait(handles.figure1); 
%% XXX 
% Update handles structure

% UIWAIT makes emg_movement_detect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = emg_movement_detect_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure 
varargout{1} = handles.output;
%% XXXX 
delete(handles.figure1);
%% XXXX 


% --- Executes on selection change in select_files.
function select_files_Callback(hObject, eventdata, handles)
% hObject    handle to select_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_files


% --- Executes during object creation, after setting all properties.
function select_files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Close_Figure.
function Close_Figure_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
movepoint.startidx = handles.startidx;
movepoint.endidx = handles.endidx;
hlns = handles.hlns;
%% save the manual movement adjust mode 
if handles.ManualMovementAdjustMode.Value
    p =1;
    for lnn = 1:size(hlns,2) % loop on lines
        startidx(lnn,:) = get ( hlns(p,lnn), 'XData');
    end
    movepoint.startidx = startidx(:,1)'; 
end
%%

handles.output = movepoint; 
guidata(gcf,handles);
uiresume(handles.figure1); 

% --- Executes on button press in zoom_in.
function zoom_in_Callback(hObject, eventdata, handles)
zh = zoom(gcf);
zh.Enable = 'on';
zh.Motion = 'horizontal';
zh.Direction = 'in';
zh.ActionPostCallback = @zoomincallback;
% hObject    handle to zoom_in (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function zoomincallback(hobj,evd,handles)
newLim = evd.Axes.XLim;
handles = guidata(gcf);
handles.ZoomVals = newLim;
guidata(gcf,handles);

% --- Executes on button press in zoom_out.
function zoom_out_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);
handles.ZoomVals = handles.xlimsuse;
handles.hAx1.XLim = handles.xlimsuse;
guidata(gcf,handles);




function zoomoutcallback(hobj,evd,handles)
newLim = evd.Axes.XLim;
handles = guidata(gcf);
handles.ZoomVals = newLim;
guidata(gcf,handles);

% --- Executes on button press in ZoomToMovementEnd.
function ZoomToMovementEnd_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomToMovementEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MovementText.String = sprintf('Move %d out of %d',length( handles.startidx),length( handles.startidx));
handles.ZoomVals = [handles.startidx(end) - 8000 handles.startidx(end) + 8000];
handles.curMovement = length( handles.startidx); 
handles.hAx1.XLim = handles.ZoomVals;
guidata(gcf,handles);


% --- Executes on button press in ZoomToMovementStart.
function ZoomToMovementStart_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomToMovementStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MovementText.String = sprintf('Move %d out of %d',1,length( handles.startidx));
handles.ZoomVals = [handles.startidx(1) - 8000 handles.startidx(1) + 8000];
handles.curMovement = 1; 
handles.hAx1.XLim = handles.ZoomVals;
guidata(gcf,handles);



% --- Executes on button press in load_file.
function load_file_Callback(hObject, eventdata, handles)
[fn,pn,ext] = uigetfile('*.mat','choose .mat file with data');
load(fullfile(pn,fn)); 
% get strcuture with data 
s = whos();
strucnames = {s.name}'; 
strucidx   = strcmp({s.class},'struct'); 
data = eval(strucnames{strucidx});
if ~isfield(data,'srate')
    warning('there is no srate field in the structure'); 
end
rawfnms = fieldnames(data);
handles.data = data;
handles.rawfnms = rawfnms;
guidata(hObject, handles);
pos = handles.select_files.Position;
set(handles.select_files,...
    'parent', handles.hfig,...
    'string', rawfnms,...
    'UserData', handles,...
    'Position',pos,...
    'Callback', @UpdatePlot );
set(handles.hfig,'UserData',handles); 

% pop = set ( 
% handles.
%     'parent', handles.hfig,...
%     'style', 'popupmenu',...
%     'string', rawfnms,...
%     'Position',[50 10 60 40],...
%     'UserData', rawfnms
%     'Callback', @UpdatePlot );



% hObject    handle to load_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function MouseDown(gcbo,event,handles)
% get the current xlimmode
handles = guidata(gcf);
hlns = handles.hlns;
if ~isempty(hlns)
    dat = get(gcbo,'UserData');
    dat.mouse = 1;
    set(hlns(dat.plot,dat.line),'UserData',dat);
    xLimMode = get ( dat.hax, 'xlimMode' );
    %setting this makes the xlimits stay the same (comment out and test)
    set ( dat.hax, 'xlimMode', 'manual' );
end


function MouseMove(gcbo,event,handles)
handles = guidata(gcf);
hlns = handles.hlns;

cp = [];
if ~isempty(hlns)
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
%         set(hlns(p,lnmove),'Color','r');
    end
end
end



function MouseUp(gcbo,event,handles)
handles = guidata(gcf);
hlns = handles.hlns;
if ~isempty(hlns)
% reset all the mouse prperties to zero
for p = 1:size(hlns,1) % loop on plots
    for lnn = 1:size(hlns,2) % loop on lines
        dat = get(hlns(p,lnn),'UserData');
        dat.mouse = 0;
        set(hlns(p,lnn),'UserData',dat);
%         set(hlns(p,lnn),'Color','b');
    end
end
end

function Channel_Select_Callback(hObject, eventdata, handles)
% detect movement 
detectMovement();
updatePlot();


% --- Executes during object creation, after setting all properties.
function Channel_Select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Channel_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)


function Select_start_Callback(hObject, eventdata, handles)
handles.selectStartPressed = 1; 
guidata(gcf,handles);

function Select_End_Callback(hObject, eventdata, handles)
handles.selectEndPressed = 1; 
guidata(gcf,handles);

function chan12_Callback(hObject, eventdata, handles)
updatePlot();

function chan34_Callback(hObject, eventdata, handles)
updatePlot();

function chan56_Callback(hObject, eventdata, handles)
updatePlot();

function chan78_Callback(hObject, eventdata, handles)
updatePlot();

function erg2_Callback(hObject, eventdata, handles)
updatePlot();

function erg1_Callback(hObject, eventdata, handles)
updatePlot();

function StartEndPressed(obj,evnt)
handles = guidata(gcf);
cp = get ( obj.Parent, 'CurrentPoint' );
if handles.selectStartPressed
    handles.xlimsuse(1) =  cp(1,1);
end
if handles.selectEndPressed
    handles.xlimsuse(2) =  cp(1,1);
end
guidata(gcf,handles);
updatePlot();

function detectMovement()
handles = guidata(gcf);
npa = handles.NumPointAverageAfterMoveDetect;
npb = handles.NumPointAverageBeforeMoveDetect;

idxchan = handles.Channel_Select.Value;
chanms  = handles.Channel_Select.String;
datuse = handles.dat.(chanms{idxchan});
secs = 1:length(datuse);
M1 = movvar(datuse,[npb npa]); % plot moving variance 
M2 = movmad(datuse,[npb npa]); % plot moving mean abs deviation 
M3 = movmedian(datuse,[2e3 2e3]); % plot moving mean abs deviation 
Mcomp = mean([zscore(M1) ;zscore(M2)]); % average two vals 
Mcomp2 = movmedian(Mcomp,[npb npa]); % smooth previous estimate 

idxbig = Mcomp2 > -Mcomp2 & ...
         (Mcomp2 + abs(-Mcomp2)) > 1;

% find start and end of movemnt;
stridx = secs(find(diff(idxbig) == 1));
endidx = secs(find(diff(idxbig) == -1));

% constrain by start and end of file selected 
idxusestart = stridx > handles.xlimsuse(1) & stridx < handles.xlimsuse(2);
idxuseend = endidx > handles.xlimsuse(1) & endidx < handles.xlimsuse(2);
% loop on movement and constraing by min inter move distance and and min
% movement length 
startidxClip = stridx(idxusestart); 
endidxClip = endidx(idxuseend); 
% match all start to end idxs 
if length(startidxClip) ~= length(endidxClip)
    warning('start and end idxis dont match');
end
% get idx for 
minMoveLenPoints = handles.MinMoveLenSecs * handles.eegraw.srate;
idxMinLen = (endidxClip - startidxClip) > minMoveLenPoints;
minInterMoveLenPoints = handles.MinInterMoveLenSecs * handles.eegraw.srate;
idxMinInterMove = [1 diff(startidxClip) > minInterMoveLenPoints]; % first point should be ok 
idxlog = idxMinLen & idxMinInterMove;

% set handles structure 
handles.M1 = M1; 
handles.M2 = M2; 
handles.M3 = M3; 
handles.Mcomp = Mcomp; 
handles.Mcomp2 = Mcomp2; 
handles.startidx = startidxClip(idxlog);
handles.endidx = endidxClip(idxlog); 
handles.MovementText.String = sprintf('Found %d movements',length( handles.startidx));
guidata(gcf,handles);

% Hint: get(hObject,'Value') returns toggle state of erg2
function updatePlot(obj,event,handles)
%% stuff to add: 
% 1. min distance 
handles = guidata(gcf);


handles.WindowSizePoints = str2double(handles.windowSizeFilter.String);

bpvec = [handles.LowPassValMoveDetect handles.HighPassValMoveDetect];


% set data 
if ~isfield(handles,'dat') % only filter for the first time
    eegraw = handles.eegraw;
    [b,a]        = butter(handles.FilterOrderUse,bpvec / (eegraw.srate/2),'bandpass'); % user 3rd order butter filter
    dat.chan12 = filtfilt(b,a,double(eegraw.EXG2 - eegraw.EXG1)) ;
    dat.chan34 = filtfilt(b,a,double(eegraw.EXG4 - eegraw.EXG3)) ;
    dat.chan56 = filtfilt(b,a,double(eegraw.EXG6 - eegraw.EXG5)) ;
    dat.chan78 = filtfilt(b,a,double(eegraw.EXG7 - eegraw.EXG8)) ;
    if isfield(eegraw,'Erg1')
        dat.erg1 = filtfilt(b,a,double(eegraw.Erg1));
    else
        dat.erg1 = dat.chan78;
    end
    if isfield(eegraw,'Erg2')
        dat.erg2 = filtfilt(b,a,double(eegraw.Erg2));
    else
        dat.erg2 = dat.chan78;
    end 
    handles.dat = dat;
end



%% create subplots 
% set channels names
chanNames = {'chan12', 'chan34','chan56','chan78','erg1','erg2'};

% figure out how many channels to plot 
for c = 1:length(chanNames)
    chnplt(c) = handles.(chanNames{c}).Value;
end
numplots = sum(chnplt);

% refilter channels used to detect movement 
eegraw = handles.eegraw;
[b,a]        = butter(handles.FilterOrderUse,bpvec / (eegraw.srate/2),'bandpass'); % user 3rd order butter filter
idxchan = handles.Channel_Select.Value;
if strcmp(handles.Channel_Select.String,'na')
    chanNamesUse = chanNames;
else
    chanNamesUse  = handles.Channel_Select.String;
end
switch chanNamesUse{idxchan}
    case 'chan12'
        handles.dat.(chanNamesUse{idxchan}) = filtfilt(b,a,double(eegraw.EXG2 - eegraw.EXG1)) ;
    case 'chan34'
        handles.dat.(chanNamesUse{idxchan}) = filtfilt(b,a,double(eegraw.EXG4 - eegraw.EXG3)) ;
    case 'chan56'
        handles.dat.(chanNamesUse{idxchan}) = filtfilt(b,a,double(eegraw.EXG6 - eegraw.EXG5)) ;
    case 'chan78'
        handles.dat.(chanNamesUse{idxchan}) = filtfilt(b,a,double(eegraw.EXG7 - eegraw.EXG8)) ;
    case 'erg1'
        handles.dat.(chanNamesUse{idxchan}) = filtfilt(b,a,double(eegraw.Erg1));
    case 'erg2'
        handles.dat.(chanNamesUse{idxchan}) = filtfilt(b,a,double(eegraw.Erg2));
end
if ~strcmp(handles.Channel_Select.String,'na') % zscore for display 
    handles.dat.(chanNamesUse{idxchan}) = zscore(handles.dat.(chanNamesUse{idxchan}) );
end

% creat plots 
pltcnt = 1; 
for c = 1:length(chanNames)
    if handles.(chanNames{c}).Value
        % set subplot 
        handles.(sprintf('hAx%d',pltcnt)) = subplot(numplots,1,pltcnt,...
                                        'Parent',handles.hpanel_plots);
        hax(pltcnt) = handles.(sprintf('hAx%d',pltcnt));
        
        % plot data 
        datplot = handles.dat.(chanNames{c});
        plot(datplot,...
            'ButtonDownFcn',@StartEndPressed,...
            'LineWidth',0.2,...
            'Color',[0 0 1 0.2],...
            'UserData',datplot);
        title(chanNames{c});
        chanspltd{pltcnt} = chanNames{c};
        set(hax(pltcnt),'UserData',datplot);
        pltcnt = pltcnt + 1;
    end
end
if handles.Channel_Select.Value > length(chanspltd)
    handles.Channel_Select.Value = 1;
end
handles.Channel_Select.String = chanspltd; 
linkaxes(hax,'x'); % make sure zoom is only on x axis 
% set the xlims to use 
if isempty(handles.xlimsuse) % first time use  zoom out value 
    handles.xlimsuse = [1 length(dat.chan12)];
end
if handles.selectStartPressed
    handles.selectStartPressed = 0;
end
if handles.selectEndPressed
    handles.selectEndPressed = 0;
end

%% plot lines from movement detect 

%% plot data 
handles.hlns = [];
if isfield(handles, 'startidx')
    idxchan = handles.Channel_Select.Value;
    stridx = handles.startidx;
    endidx = handles.endidx;
    % plot emg markers
    for p = 1:length(hax)
        ylims = hax(p).YLim;
        for i = 1:length(stridx)
            dat.mouse = 0;
            dat.plot = p;
            dat.line = i;
            dat.hax = hax(p); 
            hlns(dat.plot, dat.line) = ...
            line(hax(p),...
                [stridx(i) stridx(i)], ylims,...
                'LineWidth',2,...
                'Color',[0 0.9 0 0.7],...
                'UserData',dat,...
                'ButtonDownFcn',@MouseDown);
            line(hax(p),...
                [endidx(i) endidx(i)], ylims,...
                'LineWidth',2,...
                'Color',[0.9 0 0 0.7]);
        end
    end 
    handles.hlns = hlns;
end

if handles.PlotBasisMovDetect.Value
    idxchan = handles.Channel_Select.Value;
    axes(hax(idxchan)); 
    hold on; 
    %% plot data on which markers are based
        hplt = plot(hax(idxchan),...
            zscore(handles.Mcomp),...
            'LineWidth',3,...
            'Color',[0 0.9 0 0.8]);
        hplt = plot(hax(idxchan),...
            zscore(-handles.Mcomp),...
            'LineWidth',3,...
            'Color',[1 0 0 0.8]);
end

if isfield(handles,'ZoomVals')
    xlim(handles.ZoomVals);
    zvls = handles.ZoomVals;
    fnms = fieldnames(handles);
    hplots = fnms(cellfun(@(x) any(strfind(x,'hAx')), fnms));
    chanms = handles.Channel_Select.String; 
    for h = 1:length(chanms)
        ylimuse(1) = min(handles.dat.(chanms{h})(zvls(1):zvls(2)));
        ylimuse(2) = max(handles.dat.(chanms{h})(zvls(1):zvls(2)));
        handles.(hplots{h}).YLim = ylimuse; 
    end
end
% update ylim vals 

% update handles structure 
guidata(gcf,handles);


% --- Executes on button press in PlotBasisMovDetect.
function PlotBasisMovDetect_Callback(hObject, eventdata, handles)
updatePlot();
% hObject    handle to PlotBasisMovDetect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function MinMoveLen_Callback(hObject, eventdata, handles)
% hObject    handle to MinMoveLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinMoveLen as text
%        str2double(get(hObject,'String')) returns contents of MinMoveLen as a double
handles = guidata(gcf); 
handles.MinMoveLenSecs = str2double(get(hObject,'String'));
guidata(gcf,handles); 
detectMovement();
updatePlot();

% --- Executes during object creation, after setting all properties.
function MinMoveLen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinMoveLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MinInterMoveDis_Callback(hObject, eventdata, handles)
% hObject    handle to MinInterMoveDis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinInterMoveDis as text
%        str2double(get(hObject,'String')) returns contents of MinInterMoveDis as a double
handles = guidata(gcf); 
handles.MinInterMoveLenSecs = str2double(get(hObject,'String'));
guidata(gcf,handles); 
detectMovement();
updatePlot();

% --- Executes during object creation, after setting all properties.
function MinInterMoveDis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinInterMoveDis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function lowpass_Callback(hObject, eventdata, handles)
handles = guidata(gcf); 
handles.LowPassValMoveDetect = str2double(get(hObject,'String')); % lowpass
guidata(gcf,handles);
updatePlot();


% --- Executes during object creation, after setting all properties.
function lowpass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowpass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function highpass_Callback(hObject, eventdata, handles)
handles = guidata(gcf); 
handles.HighPassValMoveDetect = str2double(get(hObject,'String')); %highpass
guidata(gcf,handles);
updatePlot();


% --- Executes during object creation, after setting all properties.
function highpass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highpass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pointsBeforeAveraging_Callback(hObject, eventdata, handles)
% hObject    handle to pointsBeforeAveraging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pointsBeforeAveraging as text
%        str2double(get(hObject,'String')) returns contents of pointsBeforeAveraging as a double
handles = guidata(gcf); 
handles.NumPointAverageBeforeMoveDetect = str2double(get(hObject,'String')); % pointsBeforeAveraging
guidata(gcf,handles);
detectMovement();
updatePlot();

% --- Executes during object creation, after setting all properties.
function pointsBeforeAveraging_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pointsBeforeAveraging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pointsAfterAveraging_Callback(hObject, eventdata, handles)
% hObject    handle to pointsAfterAveraging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pointsAfterAveraging as text
%        str2double(get(hObject,'String')) returns contents of pointsAfterAveraging as a double
handles = guidata(gcf); 
handles.NumPointAverageAfterMoveDetect = str2double(get(hObject,'String')); % pointsAfterAveraging
guidata(gcf,handles);
detectMovement();
updatePlot();


% --- Executes during object creation, after setting all properties.
function pointsAfterAveraging_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pointsAfterAveraging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in windowuse.
function windowuse_Callback(hObject, eventdata, handles)
% hObject    handle to windowuse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns windowuse contents as cell array
%        contents{get(hObject,'Value')} returns selected item from windowuse


% --- Executes during object creation, after setting all properties.
function windowuse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowuse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in filterOrderUse.
function filterOrderUse_Callback(hObject, eventdata, handles)
% hObject    handle to filterOrderUse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filterOrderUse contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filterOrderUse
handles = guidata(gcf); 
handles.FilterOrderUse = str2double(get(hObject,'String')); %filterOrderUse
guidata(gcf,handles);
updatePlot();


% --- Executes during object creation, after setting all properties.
function filterOrderUse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterOrderUse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function windowSizeFilter_Callback(hObject, eventdata, handles)
% hObject    handle to windowSizeFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of windowSizeFilter as text
%        str2double(get(hObject,'String')) returns contents of windowSizeFilter as a double
handles = guidata(gcf); 
handles.WindowSizePoints = str2double(get(hObject,'String'));
guidata(gcf,handles);
updatePlot();


% --- Executes during object creation, after setting all properties.
function windowSizeFilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowSizeFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ZoomToPreviousMovement.
function ZoomToPreviousMovement_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomToPreviousMovement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'curMovement')
    if handles.curMovement == 1
        curMove = 1; 
    else
        curMove = handles.curMovement - 1;
    end
end
handles.curMovement = curMove; 
handles.MovementText.String = sprintf('Move %d out of %d',handles.curMovement,length( handles.startidx));
handles.ZoomVals = [handles.startidx(handles.curMovement) - 8000 handles.startidx(handles.curMovement) + 8000];
handles.hAx1.XLim = handles.ZoomVals;
guidata(gcf,handles);

% --- Executes on button press in ZoomToNextMovement.
function ZoomToNextMovement_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomToNextMovement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'curMovement')
    if handles.curMovement == length( handles.startidx)
        curMove = length( handles.startidx); 
    else
        curMove = handles.curMovement + 1;
    end
end
handles.curMovement = curMove; 
handles.MovementText.String = sprintf('Move %d out of %d',handles.curMovement,length( handles.startidx));
handles.ZoomVals = [handles.startidx(handles.curMovement) - 8000 handles.startidx(handles.curMovement) + 8000];
handles.hAx1.XLim = handles.ZoomVals;
guidata(gcf,handles);

% --- Executes on button press in ManualMovementAdjustMode.
function ManualMovementAdjustMode_Callback(hObject, eventdata, handles)
% hObject    handle to ManualMovementAdjustMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ManualMovementAdjustMode
