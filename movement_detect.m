function varargout = movement_detect(varargin)
% MOVEMENT_DETECT MATLAB code for movement_detect.fig
%      MOVEMENT_DETECT, by itself, creates a new MOVEMENT_DETECT or raises the existing
%      singleton*.
%
%      H = MOVEMENT_DETECT returns the handle to a new MOVEMENT_DETECT or the handle to
%      the existing singleton*.
%
%      MOVEMENT_DETECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOVEMENT_DETECT.M with the given input arguments.
%
%      MOVEMENT_DETECT('Property','Value',...) creates a new MOVEMENT_DETECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before movement_detect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to movement_detect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help movement_detect

% Last Modified by GUIDE v2.5 17-Jul-2017 18:21:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @movement_detect_OpeningFcn, ...
                   'gui_OutputFcn',  @movement_detect_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []...
                   );
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before movement_detect is made visible.
function movement_detect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to movement_detect (see VARARGIN)
set(hObject,'toolbar','figure');
set(hObject,'menubar','figure');

% set(hObject, 'WindowButtonMotionFcn',@MouseMove,...
%              'WindowButtonUpFcn',@MouseUp);
% set(handles.figure1, 'WindowButtonMotionFcn', @MouseMove);
% Choose default command line output for movement_detect
eegraw = varargin{1};

handles.output = hObject;
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
for h = 1:5
    evalc(sprintf('plot(handles.axes%d,handles.secs,handles.%s)',h,handles.datnames{h}));
    evalc(sprintf('title(handles.axes%d,''%s'');',h,handles.titlesuse{h}));
    xlimss = get(gca,'XLim'); ylimss = get(gca,'YLim'); 
    hparent = evalc(sprintf('handles.axes%d',h));
    xlabel('seconds')
    hold on; 

end

linkaxes([handles.axes1 handles.axes2 handles.axes3...
    handles.axes4 handles.axes5], 'x');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes movement_detect wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = movement_detect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function varargout = MouseDown(hObject, eventdata, handles)
handles.mousedown = true; 

fprintf('mouse down\n');

function varargout = MouseMove(hObject, eventdata, handles)
if handles.mousedown
    % get the current point on the axes
    cp = get ( ax, 'CurrentPoint' );
    % update the xdata of the line handle.
    set ( handles.axes4, 'XData', [cp(1,1) cp(1,1)] );
end
fprintf('mouse move\n');

function varargout = MouseUp(hObject, eventdata, handles)
handles.mousedown = false; 
fprintf('mouse up\n');



% --- Executes on button press in ipadthresh.
function ipadthresh_Callback(hObject, eventdata, handles)
[x,y] = ginputax(handles.axes4,1);
hold off;
plot(handles.axes4, handles.secs,handles.erg1); 
hold on; 
xlimss = get(handles.axes4,'XLim');
ylimss = get(handles.axes4,'YLim');
plot([xlimss(1), xlimss(2)], [y y],...
    'LineWidth',3,...
    'Color',[0 0.7 0 0.6]);

[pks,locs,w,p] = findpeaks(handles.erg1,'MinPeakHeight',y);
guidata(hObject, handles);
scatter(locs./handles.srate,pks,100,[1 0 0],'filled','MarkerFaceAlpha',0.5);
handles.ipadpeaks = locs; 
title(handles.axes4,sprintf('found %d peaks',length(locs)));
guidata(hObject, handles);

locsec = locs./handles.srate; 
for l = 2:length(locs)
    
end

% hObject    handle to ipadthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on ipadthresh and none of its controls.
function ipadthresh_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ipadthresh (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function ipadthresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ipadthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in markstart.
function markstart_Callback(hObject, eventdata, handles)
[x,y] = ginputax(handles.axes4,1);
xlimss = get(handles.axes4,'XLim');
ylimss = get(handles.axes4,'YLim');
plot([x(1) x(1)], [ylimss(1) ylimss(2)],...
    'LineWidth',3,...
    'Color',[0.7 0 0 0.6]);
handles.startloc =x(1);  

% hObject    handle to markstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in markend.
function markend_Callback(hObject, eventdata, handles)
[x,y] = ginputax(handles.axes4,1);
xlimss = get(handles.axes4,'XLim');
ylimss = get(handles.axes4,'YLim');
plot([x(1) x(1)], [ylimss(1) ylimss(2)],...
    'LineWidth',3,...
    'Color',[0 0 0.7 0.6]);
handles.endloc =x(1);  
% hObject    handle to markend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
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



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes4


% --- Executes on mouse press over axes background.
function axes4_ButtonDownFcn(hObject, eventdata, handles)

% hObject    handle to axes4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in DetectMovement.
function DetectMovement_Callback(hObject, eventdata, handles)
x=2; 
% hObject    handle to DetectMovement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function DetectMovement_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DetectMovement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
