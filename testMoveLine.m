function varargout = testMoveLine(varargin)
% TESTMOVELINE MATLAB code for testMoveLine.fig
%      TESTMOVELINE, by itself, creates a new TESTMOVELINE or raises the existing
%      singleton*.
%
%      H = TESTMOVELINE returns the handle to a new TESTMOVELINE or the handle to
%      the existing singleton*.
%
%      TESTMOVELINE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTMOVELINE.M with the given input arguments.
%
%      TESTMOVELINE('Property','Value',...) creates a new TESTMOVELINE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testMoveLine_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testMoveLine_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testMoveLine

% Last Modified by GUIDE v2.5 18-Jul-2017 21:56:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @testMoveLine_OpeningFcn, ...
    'gui_OutputFcn',  @testMoveLine_OutputFcn, ...
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


% --- Executes just before testMoveLine is made visible.
function testMoveLine_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testMoveLine (see VARARGIN)

% Choose default command line output for testMoveLine
handles.output = hObject;

% some dummy data
x = -pi:0.01:pi;
% an initial X for my example
vLineX = randi(length(x));
set(handles.axes1,'parent',hObject, 'nextplot', 'add' );
set(handles.axes2,'parent',hObject, 'nextplot', 'add' );

plot ( handles.axes1, [x(vLineX) x(vLineX)],ylim,...
    'LineWidth',4,...
    'ButtonDownFcn',@MouseDown1,...
    'UserData',0);

plot ( handles.axes2, [x(vLineX) x(vLineX)],ylim,...
    'LineWidth',4,...
    'ButtonDownFcn',@MouseDown2,...
    'UserData',0);

handles.mousedown1 = 0;
handles.mousedown2 = 0;

guidata(hObject,handles); % need handles, may need error info
set ( hObject, 'WindowButtonMotionFcn', @MouseMove, 'WindowButtonUpFcn', @MouseUp );


% UIWAIT makes testMoveLine wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = testMoveLine_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function MouseDown1(hObject,eventdata,handles)
data = guidata(gcbo); % need handles, may need error info
handles.mousedown1 = 1;
guidata(gcbo,data); % need handles, may need error info



function MouseDown2(hObject,eventdata,handles)
data = guidata(gcbo); % need handles, may need error info
data.mousedown2 = 1;
guidata(gcbo,data); % need handles, may need error info





function MouseMove ( hObject,eventdata,handles )
data = guidata(gcbo); % need handles, may need error info
% only run this section if the user has clicked on the line
if data.mousedown1
    % get the current point on the axes
    cp = get ( data.axes1, 'CurrentPoint' );
    % update the xdata of the line handle.
    set ( data.hLine1, 'XData', [cp(1,1) cp(1,1)] );
    set ( data.hLine2, 'XData', [cp(1,1) cp(1,1)] );
end
if data.mousedown2
    % get the current point on the axes
    cp = get ( data.axes2, 'CurrentPoint' );
    % update the xdata of the line handle.
    set ( data.hLine1, 'XData', [cp(1,1) cp(1,1)] );
    set ( data.hLine2, 'XData', [cp(1,1) cp(1,1)] );
end



function MouseUp ( hObject, eventdata ,handles)
data = guidata(gcbo); % need handlexLimModes, may need error info
% xLimMode = 'manual';
% reset the xlim mode once the moving stops
% set ( data.axes1, 'xlimMode', xLimMode );
% set ( data.axes2, 'xlimMode', xLimMode );
% reset the mouse down flag.

data.mousedown1 = false;
data.mousedown2 = false;
guidata(gcbo, data);
