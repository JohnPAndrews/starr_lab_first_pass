function varargout = MAIN_tremor_Visit_GUI(varargin)
% MAIN_TREMOR_VISIT_GUI MATLAB code for MAIN_tremor_Visit_GUI.fig
%      MAIN_TREMOR_VISIT_GUI, by itself, creates a new MAIN_TREMOR_VISIT_GUI or raises the existing
%      singleton*.
%
%      H = MAIN_TREMOR_VISIT_GUI returns the handle to a new MAIN_TREMOR_VISIT_GUI or the handle to
%      the existing singleton*.
%
%      MAIN_TREMOR_VISIT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_TREMOR_VISIT_GUI.M with the given input arguments.
%
%      MAIN_TREMOR_VISIT_GUI('Property','Value',...) creates a new MAIN_TREMOR_VISIT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MAIN_tremor_Visit_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MAIN_tremor_Visit_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MAIN_tremor_Visit_GUI

% Last Modified by GUIDE v2.5 14-Dec-2017 20:05:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MAIN_tremor_Visit_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @MAIN_tremor_Visit_GUI_OutputFcn, ...
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


% --- Executes just before MAIN_tremor_Visit_GUI is made visible.
function MAIN_tremor_Visit_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MAIN_tremor_Visit_GUI (see VARARGIN)

% Choose default command line output for MAIN_tremor_Visit_GUI
handles.output = hObject;
handles.hLL.String = {'0' '1','2','3', '4'};
handles.hLU.String = {'0' '1','2','3', '4'};
handles.hRU.String = {'0' '1','2','3', '4'};
handles.hRL.String = {'0' '1','2','3', '4'};
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MAIN_tremor_Visit_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MAIN_tremor_Visit_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hClearPorts.
function hClearPorts_Callback(hObject, eventdata, handles)
% hObject    handle to hClearPorts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hTestTriggers.
function hTestTriggers_Callback(hObject, eventdata, handles)
pause(0.2);
for i = 1:7
    fwrite(sp,uint8(2^i))
    pause(0.2);
end
% hObject    handle to hTestTriggers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hConnectDevice.
function hConnectDevice_Callback(hObject, eventdata, handles)
handles = guidata(gcf); 
handles.sp = openSerialPort();
guidata(gcf,handles); 
% hObject    handle to hConnectDevice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hPlaySound.
function hPlaySound_Callback(hObject, eventdata, handles)
% hObject    handle to hPlaySound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hStartLog.
function hStartLog_Callback(hObject, eventdata, handles)
% hObject    handle to hStartLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in hLU.
function hLU_Callback(hObject, eventdata, handles)
% hObject    handle to hLU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hLU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hLU


% --- Executes during object creation, after setting all properties.
function hLU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hLU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hRU.
function hRU_Callback(hObject, eventdata, handles)
% hObject    handle to hRU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hRU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hRU


% --- Executes during object creation, after setting all properties.
function hRU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hRU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hLL.
function hLL_Callback(hObject, eventdata, handles)
% hObject    handle to hLL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hLL contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hLL


% --- Executes during object creation, after setting all properties.
function hLL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hLL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hRL.
function hRL_Callback(hObject, eventdata, handles)
% hObject    handle to hRL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hRL contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hRL


% --- Executes during object creation, after setting all properties.
function hRL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hRL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hEndLog.
function hEndLog_Callback(hObject, eventdata, handles)
% hObject    handle to hEndLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function hCurrentLogFileText_Callback(hObject, eventdata, handles)
% hObject    handle to hCurrentLogFileText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hCurrentLogFileText as text
%        str2double(get(hObject,'String')) returns contents of hCurrentLogFileText as a double


% --- Executes during object creation, after setting all properties.
function hCurrentLogFileText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hCurrentLogFileText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
