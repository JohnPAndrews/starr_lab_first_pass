function varargout = emg_movement_detect(varargin)
% EMG_MOVEMENT_DETECT MATLAB code for emg_movement_detect.fig
%      EMG_MOVEMENT_DETECT, by itself, creates a new EMG_MOVEMENT_DETECT or raises the existing
%      singleton*.
%
%      H = EMG_MOVEMENT_DETECT returns the handle to a new EMG_MOVEMENT_DETECT or the handle to
%      the existing singleton*.
%
%      EMG_MOVEMENT_DETECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMG_MOVEMENT_DETECT.M with the given input arguments.
%
%      EMG_MOVEMENT_DETECT('Property','Value',...) creates a new EMG_MOVEMENT_DETECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before emg_movement_detect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to emg_movement_detect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help emg_movement_detect

% Last Modified by GUIDE v2.5 02-Aug-2017 10:07:41

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

% Choose default command line output for emg_movement_detect
handles.output = hObject;
handles.hfig   = gcf; 
handles.emgdat = [];

% Update handles structure
guidata(hObject, handles);

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


% --- Executes on button press in compute.
function compute_Callback(hObject, eventdata, handles)
% hObject    handle to compute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in zoom_in.
function zoom_in_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_in (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in zoom_out.
function zoom_out_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in move_right.
function move_right_Callback(hObject, eventdata, handles)
% hObject    handle to move_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in move_left.
function move_left_Callback(hObject, eventdata, handles)
% hObject    handle to move_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
dat = get(gcbo,'UserData');
dat.mouse = 1;
set(hlns(dat.plot,dat.line),'UserData',dat);
xLimMode = get ( dat.hax, 'xlimMode' );
%setting this makes the xlimits stay the same (comment out and test)
set ( dat.hax, 'xlimMode', 'manual' );


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

function UpdatePlot ( gcbo,event,handles )
% delete any user data which is already plotted
dat = get(gcbo);
data = dat.UserData.data;
srate = dat.UserData.data.srate;
% plot the user data
rawdat = data.(dat.UserData.rawfnms{dat.UserData.select_files.Value});
[b,a]        = butter(3,2 / (srate/2),'high'); % user 3rd order butter filter
ydat = filtfilt(b,a,double(rawdat));
userPlot = plot ( dat.UserData.axes1, ydat, 'r' );
