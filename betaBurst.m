function varargout = betaBurst(varargin)
% BETABURST MATLAB code for betaBurst.fig
%      BETABURST, by itself, creates a new BETABURST or raises the existing
%      singleton*.
%
%      H = BETABURST returns the handle to a new BETABURST or the handle to
%      the existing singleton*.
%
%      BETABURST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BETABURST.M with the given input arguments.
%
%      BETABURST('Property','Value',...) creates a new BETABURST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before betaBurst_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to betaBurst_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help betaBurst

% Last Modified by GUIDE v2.5 25-Jul-2017 16:54:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @betaBurst_OpeningFcn, ...
                   'gui_OutputFcn',  @betaBurst_OutputFcn, ...
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


% --- Executes just before betaBurst is made visible.
function betaBurst_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to betaBurst (see VARARGIN)
set(hObject,'toolbar','figure');
set(hObject,'menubar','figure');

if isempty(varargin) 
    [fn,pn,ext] = uigetfile('*.txt','choose brain radio .txt file'); 
    sr = input('what is the sampling rate? '); 
    ch = input('lfp(1) or cortex(3)? '); 
    rawdata = importdata(fullfile(pn,fn)); 
    data = rawdata(:,ch); 
else
    data = varargin{1}; 
    sr   = varargin{2}; 
end

secs =( 1:length(data) )./ sr; 
% settings 
handles.rawdata    = data; 
handles.data       = data; 
handles.sr         = sr; 
handles.secs       = secs; 
handles.idxsec     =  [1 length(data)/sr]; 
handles.betapeak   = 15; % beta peak chosen 
handles.betarange  = [12 18]; % beta range 
handles.betathresh = 0.75; 
handles.nbins      = 9; 
handles.zoomout    = false; 
% data 
handles.psdFFt  = [];
handles.psdFreq = []; 

handles.bursts  = []; 
handles.patch   = []; 

handles.psdfiltorder = 4; 
handles.betafiltorder = 8; 

plotData(hObject,handles) 


% Choose default command line output for betaBurst
handles.output  = handles.bursts;
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes betaBurst wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = betaBurst_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on slider movement.
function histogramBins_Callback(hObject, eventdata, handles)
% hObject    handle to histogramBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function histogramBins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to histogramBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function betaPercentile_Callback(hObject, eventdata, handles)
% hObject    handle to betaPercentile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.betaPercentile.Min = 0; 
handles.betaPercentile.Max = 1; 
handles.betaPercentile.SliderStep = [0.01 0.05];
handles.betathresh =  handles.betaPercentile.Value; 
guidata(hObject, handles);

plotData(hObject,handles) 

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function betaPercentile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to betaPercentile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.betaPercentile.Min = 0; 
handles.betaPercentile.Max = 1; 
handles.betaPercentile.SliderStep = [0.01 0.05];
handles.betaPercentile.Value = 0.75; 


% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in compute.
function compute_Callback(hObject, eventdata, handles)
% hObject    handle to compute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plotData(hObject,handles);


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
bursts.bursts = handles.bursts;
bursts.betathresh = handles.betathresh; 
bursts.data       = handles.data; 
bursts.secs       = handles.secs; 
handles.output = bursts; 
guidata(hObject, handles);
uiresume(handles.figure1); 



function plotData(hObject,handles) 
%% plot raw data 
cla(handles.axRaw,'reset');
secs = handles.secs;
data = handles.data;
hRaw = plot(handles.axRaw,secs,data); 
set(handles.axRaw,'YLimMode','manual');
handles.axRaw.YLim(1) = min(data)*1.1; 
handles.axRaw.YLim(2) = max(data)*1.1; 

set(handles.axBetaBurstRaw,'XLimMode','manual');
handles.axRaw.XLim(1) = min(secs);
handles.axRaw.XLim(2) = max(secs);


%% plot the psd 
cla(handles.axPSD,'reset');
hold(handles.axPSD,'on'); 

hp = designfilt('highpassiir','FilterOrder',handles.psdfiltorder,'HalfPowerFrequency',1,'SampleRate',handles.sr,'DesignMethod','butter');
datdc = data - mean(data); 
dfilt = filtfilt(hp,datdc); 
[fftOut,f] = pwelch(dfilt,handles.sr,handles.sr/2,1:100,handles.sr,'psd');
handles.psdFFt  = log10(fftOut); 
handles.psdFreq = f; 
hplot = plot(handles.axPSD, handles.psdFreq,handles.psdFFt); 
hplot.LineWidth = 2; 
xtitle = 'Frequency (Hz)';
ytitle = 'Power  (log_1_0\muV^2/Hz)';
hxlabel = xlabel(handles.axPSD,xtitle);
hylabel = ylabel(handles.axPSD,ytitle);
x = [ handles.betarange handles.betarange(2) handles.betarange(1)]; 
y = [ handles.axPSD.YLim(1) handles.axPSD.YLim(1) handles.axPSD.YLim(2) handles.axPSD.YLim(2)];

hpatch = patch(x, y,'red','Parent',handles.axPSD);
hpatch.FaceColor = [0.8 0.8 0];
hpatch.FaceAlpha = 0.2;
hpatch.EdgeColor = 'none';


%% plot the beta threshold 
cla(handles.axBetaBurstRaw,'reset');
hold(handles.axBetaBurstRaw,'on'); 
set(handles.axBetaBurstRaw,'YLimMode','manual');

bp = designfilt('bandpassiir','FilterOrder',handles.betafiltorder, ...
    'HalfPowerFrequency1',handles.betarange(1),'HalfPowerFrequency2',handles.betarange(2), ...
    'SampleRate',handles.sr);
betafilt = filtfilt(bp,dfilt); 
hRaw = plot(handles.axBetaBurstRaw,secs,betafilt);  
hold on;
hRaw.LineWidth = 1; 
hRaw.Color     = [0 0 0.9 0.2];
[up, low] = envelope(betafilt,120,'analytic'); % analytic rms
hold on; 
% [up] = hilbert(betafilt); % analytic rms
henv = plot(handles.axBetaBurstRaw,secs,up); 
hold on; 
henv.LineWidth = 1;
henv.Color = [1 0 0 0.4];

if handles.betathresh > 1 
    error('beta thresh larger than 1'); 
end 
thresh = prctile(up,round(handles.betathresh*100));
xlims = get(handles.axBetaBurstRaw,'XLim');
plot(handles.axBetaBurstRaw,xlims,[thresh thresh]);
handles.axBetaBurstRaw.YLim(1) = min(betafilt)*1.1; 
handles.axBetaBurstRaw.YLim(2) = max(betafilt)*1.1; 

% handles.axBetaBurstRaw.XLim(1) = min(secs);
% handles.axBetaBurstRaw.XLim(2) = max(secs);
ttluse = sprintf('beta threshold is %0.2f',handles.betathresh);
title(handles.axBetaBurstRaw,ttluse);
hold on; 


%% plot the burst raw 
% handles.axBurstAmp 
% handles.betathresh = 0.9;
% thresh = prctile(up,handles.betathresh);
% xlims = get(handles.betathreshplot,'XLim');
% plot(handles.betathreshplot,xlims,[thresh thresh]);

% find start and end indices of line crossing threshold 
startidx = find(diff(up > thresh) == 1) + 1; 
endidx = find(diff(up > thresh) == -1) + 1; 
endidx = endidx(endidx > startidx(1));
startidx = startidx(1:length(endidx));
for b = 1:size(startidx,1) 
    bursts.len(b) = secs(endidx(b)) - secs(startidx(b));
    bursts.amp(b) = max(up(startidx(b):endidx(b)));
    patchd(b).x      = secs(startidx(b):endidx(b));
    patchd(b).y      = up(startidx(b):endidx(b));
end

% plot the start and end idxs on beta plot 
hold(handles.axBetaBurstRaw,'on'); 
scatter(handles.axBetaBurstRaw,secs(startidx),repmat(thresh,1,length(startidx)),10,'g');
scatter(handles.axBetaBurstRaw,secs(endidx),repmat(thresh,1,length(endidx)),10,'r');
for b = 1:length(patchd)
    p = patch(patchd(b).x,patchd(b).y,'red','Parent',handles.axBetaBurstRaw);
    p.FaceColor = [0.8 0 0]; 
    p.FaceAlpha = 0.5; 
    p.EdgeColor = 'none';
end
handles.bursts = bursts; 
handles.patch  = patchd; 
% now plot the actual threshold graph 
cla(handles.axBurstAmp,'reset');
scatter(handles.axBurstAmp,bursts.len*1000,bursts.amp); 
xlabel(handles.axBurstAmp,'burst length (ms)'); 
ylabel(handles.axBurstAmp,'burst amp (mv)'); 
ttluse = sprintf('%d bursts found',length(bursts.len));
title(handles.axBurstAmp,ttluse);

hold on;
%% plot the axHistogram 
cla(handles.axHistogram,'reset');
histogram(handles.axHistogram,bursts.len*1000)
xlabel(handles.axHistogram,'burst length (ms)'); 
ylabel(handles.axHistogram,'count'); 

handles.axHistogram;
guidata(hObject, handles);



% --- Executes on button press in zoomout.
function zoomout_Callback(hObject, eventdata, handles)
handles.xlims = [1 length(handles.data)/handles.sr];
handles.zoomout = true; 


secs =( 1:length(handles.rawdata) )./ handles.sr; 
% settings 
handles.data       = handles.rawdata;
handles.secs       = secs; 
guidata(hObject, handles);

plotData(hObject,handles);

% hObject    handle to zoomout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in selectData.
function selectData_Callback(hObject, eventdata, handles)
handles.xlims = [1 length(handles.data)/handles.sr];

xlims = handles.axRaw.XLim;
secs =( 1:length(handles.rawdata) )./ handles.sr;
idxuse = xlims(1) < secs & xlims(2) > secs; 
handles.secs = secs(idxuse); 
handles.data = handles.rawdata(idxuse); 

guidata(hObject, handles);
% hObject    handle to selectData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in uislidepsdfiltorder.
function uislidepsdfiltorder_Callback(hObject, eventdata, handles)
% hObject    handle to uislidepsdfiltorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.psdfiltorder =hObject.Value; 
guidata(hObject, handles);


% Hints: contents = cellstr(get(hObject,'String')) returns uislidepsdfiltorder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uislidepsdfiltorder


% --- Executes during object creation, after setting all properties.
function uislidepsdfiltorder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uislidepsdfiltorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'String',{'1';'2';'3';'4';'5';'6';'7';'8'});
hObject.Value = 4; 
handles.psdfiltorder = 4; 
guidata(hObject, handles);


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in uislidebetafilterorder.
function uislidebetafilterorder_Callback(hObject, eventdata, handles)
% hObject    handle to uislidebetafilterorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.psdfiltorder =hObject.Value; 
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns uislidebetafilterorder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uislidebetafilterorder


% --- Executes during object creation, after setting all properties.
function uislidebetafilterorder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uislidebetafilterorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String',{'1';'2';'3';'4';'5';'6';'7';'8'});
hObject.Value = 8; 
handles.betafiltorder = 8; 
guidata(hObject, handles);


% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function betamin_Callback(hObject, eventdata, handles)
% hObject    handle to betamin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject.String 
handles.betarange(1) = str2double(get(hObject,'String')) ;
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of betamin as text
%        str2double(get(hObject,'String')) returns contents of betamin as a double


% --- Executes during object creation, after setting all properties.
function betamin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to betamin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function betamax_Callback(hObject, eventdata, handles)
% hObject    handle to betamax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject.String 
handles.betarange(2) = str2double(get(hObject,'String')) ;
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of betamax as text
%        str2double(get(hObject,'String')) returns contents of betamax as a double


% --- Executes during object creation, after setting all properties.
function betamax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to betamax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
