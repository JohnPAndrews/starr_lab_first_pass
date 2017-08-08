function varargout = plot_data_from_result_files_interactive(varargin)
% PLOT_DATA_FROM_RESULT_FILES_INTERACTIVE MATLAB code for plot_data_from_result_files_interactive.fig
%      PLOT_DATA_FROM_RESULT_FILES_INTERACTIVE, by itself, creates a new PLOT_DATA_FROM_RESULT_FILES_INTERACTIVE or raises the existing
%      singleton*.
%
%      H = PLOT_DATA_FROM_RESULT_FILES_INTERACTIVE returns the handle to a new PLOT_DATA_FROM_RESULT_FILES_INTERACTIVE or the handle to
%      the existing singleton*.
%
%      PLOT_DATA_FROM_RESULT_FILES_INTERACTIVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOT_DATA_FROM_RESULT_FILES_INTERACTIVE.M with the given input arguments.
%
%      PLOT_DATA_FROM_RESULT_FILES_INTERACTIVE('Property','Value',...) creates a new PLOT_DATA_FROM_RESULT_FILES_INTERACTIVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plot_data_from_result_files_interactive_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plot_data_from_result_files_interactive_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plot_data_from_result_files_interactive

% Last Modified by GUIDE v2.5 27-Jul-2017 20:15:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plot_data_from_result_files_interactive_OpeningFcn, ...
                   'gui_OutputFcn',  @plot_data_from_result_files_interactive_OutputFcn, ...
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


% --- Executes just before plot_data_from_result_files_interactive is made visible.
function plot_data_from_result_files_interactive_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plot_data_from_result_files_interactive (see VARARGIN)

% Choose default command line output for plot_data_from_result_files_interactive
% set mouse up function 

%% set mouse up function 
% set(hObject,'WindowButtonUpFcn', @MouseUp )
% @MouseUp
%% get dir name 
dirname  = varargin{1};
%% get data 
rfs = findFilesBVQX(dirname,'resultsBR.mat');
for rf = 1:length(rfs)
    load(rfs{rf});
    if rf ==1
        resTabAll = resTab;
    else
        resTabAll = [resTabAll; resTab];
    end
end
%% draw the graph 
%% plot data psd 
areas = {'lfp','ecog'}; 
for a = 1:2
    for s = 1:size(resTabAll,1)
        hax = eval(sprintf( 'handles.ax%s',areas{a}));
        psd = eval(sprintf('resTabAll.psd%s{s}',areas{a}));
        f   = eval(sprintf('resTabAll.psd%sF{s}',areas{a}));
        hlns(s,a) = line(f, log10(psd),'Parent',hax,...
            'ButtonDownFcn',@MouseDown);
        dat = resTabAll(s,{'visit','task','sessionum','med','stim','duration','sr','ecog_elec','lfp_elec','time'});
        legstr{s} = sprintf('%s T-%s %s M %s S %s',...
            dat.visit{1},...
            dat.task{1}(1:2),...
            char((dat.med)*'on ' + ~(dat.med)*'off'),...
            char((dat.stim)*'on ' + ~(dat.stim)*'off'),...
            dat.ecog_elec{1});
        dat.legstr = legstr{s};
        dat.hax = hax;
        dat.handlereport = handles.selectedfile;
        dat.idx = s; 
        hlns(s,a).UserData = dat;
        hlns(s,a).Visible = 'off';
    end
end
%% format the lines 
for h = 1:length(hlns)
    for a = 1:2
    hlns(h,a).LineWidth = 2; 
    if hlns(h,a).UserData.med
        hlns(h,a).Color = [0 0.9 0 0.7];
    else
        hlns(h,a).Color = [0.9  0 0 0.8];
    end
    if hlns(h,a).UserData.stim
        hlns(h,a).LineStyle = '-.';
    end
    end
end
%% plot data coherence 
 for s = 1:size(resTabAll,1)
        hax = handles.axcoher;
        psd = resTabAll.cpherpower{s};
        f   = resTabAll.coherfreq{s};
        hlnscoh(s,1) = line(f, psd,'Parent',hax,...
            'ButtonDownFcn',@MouseDown);
        dat = resTabAll(s,{'visit','task','sessionum','med','stim','duration','sr','ecog_elec','lfp_elec','time'});
        legstr{s} = sprintf('%s T-%s %s M %s S',...
            dat.visit{1},...
            dat.task{1}(1:2),...
            char((dat.med)*'on ' + ~(dat.med)*'off'),...
            char((dat.stim)*'on ' + ~(dat.stim)*'off'));
        dat.legstr = legstr{s};
        dat.hax = hax;
        dat.idx = s; 
        dat.handlereport = handles.selectedfile;
        hlnscoh(s,1).UserData = dat;
        hlnscoh(s,1).Visible = 'off';
 end
%% format the lines coherence 
for h = 1:length(hlns)
    hlnscoh(h).LineWidth = 2; 
    if hlnscoh(h).UserData.med
        hlnscoh(h).Color = [0 0.9 0 0.7];
    else
        hlnscoh(h).Color = [0.9  0 0 0.8];
    end
    if hlnscoh(h).UserData.stim
        hlnscoh(h).LineStyle = '-.';
    end
end
%% set initial x limtis 
handles.axecog.XLim = [2 100];
handles.axlfp.XLim = [2 100];
handles.axcoher.XLim = [2 100];
%% set titles and axes 
xlabel(handles.axecog,'Frequency (Hz)');
ylabel(handles.axecog,'Power  (log_1_0\muV^2/Hz)');
title(handles.axecog,'ECOG');

xlabel(handles.axlfp,'Frequency (Hz)');
ylabel(handles.axlfp,'Power  (log_1_0\muV^2/Hz)');
title(handles.axlfp,'LFP');

xlabel(handles.axcoher,'Frequency (Hz)');
ylabel(handles.axcoher,'Coherence');
title(handles.axcoher,'Coherence between LFP-ECOG');

%% set list box handles 
handles.stim.String = {'on','off'};
handles.stim.Max    = length({'on','off'});
handles.med.String = {'on','off'};
handles.med.Max    = length({'on','off'});
handles.visit.String = unique(resTabAll.visit);
handles.visit.Max    = length(unique(resTabAll.visit));
handles.task.String = unique(resTabAll.task);
handles.task.Max    = length(unique(resTabAll.task));
%% set data 
handles.resTabAll = resTabAll;
handles.hlns = hlns; % the handels to all the psd lines 
handles.hlnscoh = hlnscoh; % the handles to all the cohernce lines 
handles.legstr = legstr;
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plot_data_from_result_files_interactive wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plot_data_from_result_files_interactive_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in visit.
function visit_Callback(hObject, eventdata, handles)
% hObject    handle to visit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns visit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from visit


% --- Executes during object creation, after setting all properties.
function visit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to visit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in stim.
function stim_Callback(hObject, eventdata, handles)
% hObject    handle to stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns stim contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stim


% --- Executes during object creation, after setting all properties.
function stim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in med.
function med_Callback(hObject, eventdata, handles)
% hObject    handle to med (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns med contents as cell array
%        contents{get(hObject,'Value')} returns selected item from med


% --- Executes during object creation, after setting all properties.
function med_CreateFcn(hObject, eventdata, handles)
% hObject    handle to med (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in task.
function task_Callback(hObject, eventdata, handles)
% hObject    handle to task (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns task contents as cell array
%        contents{get(hObject,'Value')} returns selected item from task


% --- Executes during object creation, after setting all properties.
function task_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in redraw.
function redraw_Callback(hObject, eventdata, handles)
%% get status of list boxes 
taskuse = handles.task.String(handles.task.Value);
visuse  = handles.visit.String(handles.visit.Value);
stimsta = [1 0];
stimsta = stimsta(handles.stim.Value);
medstat  = [1 0]; 
medstat = medstat(handles.med.Value);

%% get variables from handles structure 
resTabAll= handles.resTabAll;
hlns = handles.hlns;
legstr = handles.legstr;
hlnscoh = handles.hlnscoh;
%% redraw the graph 
for s = 1:size(hlns,1)
    for a = 1:2
    hlns(s,a).Visible = 'off';
    end
    hlnscoh(s,1).Visible = 'off';
end

% get idixes lit up
idxkeep = logical(zeros(size(resTabAll,1),1));
for t = 1:length(taskuse)
    for v = 1:length(visuse)
        for m = 1:length(medstat)
            for s = 1:length(stimsta)
                idxuse = strcmp(resTabAll.task,taskuse(t)) & ...
                    strcmp(resTabAll.visit, visuse{v} ) & ...
                    resTabAll.med == medstat(m) & ...
                    resTabAll.stim == stimsta(s) ;
                idxkeep = idxkeep | idxuse ;
            end
        end
    end
end

idxset = find(idxkeep==1);
for x = 1:length(idxset)
    for a= 1:2
        hlns(idxset(x),a).Visible = 'on';
    end
    hlnscoh(idxset(x),1).Visible = 'on';
end
legend(hlns(idxset,1),legstr(idxset));
legend(hlns(idxset,2),legstr(idxset));
legend(hlnscoh(idxset),legstr(idxset));

xlimsuse = [double(str2num(handles.xlimlow.String)) double(str2num(handles.xlimhigh.String))];
handles.axecog.XLim = xlimsuse;
handles.axlfp.XLim = xlimsuse;
handles.axcoher.XLim = xlimsuse;
handles.axcoher.YLim = [0 1];

% hObject    handle to redraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function MouseDown(gcbo,event,handles)
dat = get(gcbo,'UserData');
dat.handlereport.String = sprintf('%s %s',dat.legstr, dat.time{1});


% function MouseUp(gcbo,event,handles)
% for h = 1:length(hlns)
%     for a = 1:2
%     hlns(h,a).LineWidth = 2; 
%     if hlns(h,a).UserData.med
%         hlns(h,a).Color = [0 0.9 0 0.7];
%     else
%         hlns(h,a).Color = [0.9  0 0 0.8];
%     end
%     if hlns(h,a).UserData.stim
%         hlns(h,a).LineStyle = '-.';
%     end
%     end
% end
% reset all the colors 

function xlimlow_Callback(hObject, eventdata, handles)
% hObject    handle to xlimlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xlimlow as text
%        str2double(get(hObject,'String')) returns contents of xlimlow as a double


% --- Executes during object creation, after setting all properties.
function xlimlow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xlimlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xlimhigh_Callback(hObject, eventdata, handles)
% hObject    handle to xlimhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xlimhigh as text
%        str2double(get(hObject,'String')) returns contents of xlimhigh as a double


% --- Executes during object creation, after setting all properties.
function xlimhigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xlimhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
