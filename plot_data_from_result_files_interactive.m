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

% Last Modified by GUIDE v2.5 30-Aug-2017 11:41:17

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
%% XXXX Change list
% 1. press line and it highlights the linke in all order plots - let go
% and it turns off 
% 2. fix the electrode label when pressing on lfp line
% 3. create patches that higlight frequecny underlying 
%% 

%% depedencies 
addpath(genpath(fullfile(pwd,'toolboxes','Cursorbar_v22')));

%% set mouse up function 
set(hObject,'WindowButtonUpFcn', @MouseUp )
set(hObject,'WindowButtonMotionFcn', @MouseMove )
% @MouseUp
%% get dir name 
if isempty(varargin)
    dirname = uigetdir();
else
    dirname  = varargin{1};
end
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

%% plot freq patches 
handles.freqranges = [1 4; 4 8; 8 13; 13 20; 20 30; 30 50; 50 90];
handles.freqnames  = {'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','LowGamma','HighGamma'}';
cuse = parula(size(handles.freqranges,1));
ydat = [-5 -5 -8 -8]; 
axesclr = [handles.axlfp,handles.axecog,handles.axcoher];
handles.axesclr = axesclr;
for a = 1:length(axesclr)
    for p = 1:size(handles.freqranges,1)
        freq = handles.freqranges(p,:);
        xdat = [freq(1) freq(2) freq(2) freq(1)];
        handles.hPatches(p,a) = patch('XData',xdat,'YData',ydat);
        handles.hPatches(p,a).Parent = axesclr(a);
        handles.hPatches(p,a).FaceColor = cuse(p,:);
        handles.hPatches(p,a).FaceAlpha = 0.3;
        handles.hPatches(p,a).EdgeColor = 'none';
        handles.hPatches(p,a).Visible = 'on';
    end
end

%% plot data psd 
areas = {'lfp','ecog'}; 
for a = 1:2
    for s = 1:size(resTabAll,1)
        hax = eval(sprintf( 'handles.ax%s',areas{a}));
        psd = eval(sprintf('resTabAll.psd%s{s}',areas{a}));
        f   = eval(sprintf('resTabAll.psd%sF{s}',areas{a}));
        hlns(s,a) = line(f, log10(psd),'Parent',hax,...
            'ButtonDownFcn',@MouseDown);
        dat = resTabAll(s,{'patient','visit','task','sessionum','med','stim','duration','sr','ecog_elec','lfp_elec','time'});
        legstr{s} = sprintf('%s %s T-%s %s M %s S %s',...
            dat.patient{1},...
            dat.visit{1},...
            dat.task{1}(1:2),...
            char((dat.med)*'on ' + ~(dat.med)*'off'),...
            char((dat.stim)*'on ' + ~(dat.stim)*'off'),...
            dat.([areas{a} '_elec']){1});
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
        dat = resTabAll(s,{'patient','visit','task','sessionum','med','stim','duration','sr','ecog_elec','lfp_elec','time'});
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
%% reset patch ylimits 
for a = 1:length(handles.axesclr)
    set(handles.axesclr(a),'ButtonDownFcn',@MouseDown);
    dataax.isaxis = 1; 
    dataax.mousedown = 0;
    set(handles.axesclr(a),'UserData',dataax);
    handles.reportline(a) = line([1 1], [2 2],...
        'Visible','off');
%     handles.reporttext(a) = text(1, 2,...
%         'Visible','off');
    for p = 1:size(handles.hPatches,1)
        curylim = handles.axesclr(a).YLim;
        handles.hPatches(p,a).YData = [curylim(1) curylim(1) curylim(2) curylim(2)];
    end
end

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
% arange visist strings in the right order 
possstrings = {'OR day','2 day','10 day',...
                '3 week','1 month','2 month',...
                '3 month','6 month','1 year',...
                '2 year'};
vcnt = 1; 
existr = unique(resTabAll.visit);
for p = 1:length(possstrings)
    if any(strcmp(possstrings{p},existr))
        visinorder(vcnt) = existr(strcmp(possstrings{p},existr));
        vcnt = vcnt + 1; 
    end
end
handles.visit.String = visinorder;
handles.visit.Max    = length(unique(resTabAll.visit));
handles.task.String = unique(resTabAll.task);
handles.task.Max    = length(unique(resTabAll.task));
handles.hPatListBox.String = unique(resTabAll.patient);
handles.hPatListBox.Max = length( unique(resTabAll.patient));
%% set data 
handles.resTabAll = resTabAll;
handles.hlns = hlns; % the handels to all the psd lines 
handles.hlnscoh = hlnscoh; % the handles to all the cohernce lines 
handles.legstr = legstr;
handles.output = hObject;
handles.rootDirName = dirname;
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
patuse  = handles.hPatListBox.String(handles.hPatListBox.Value);
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
                for p = 1:length(patuse)
                    idxuse = strcmp(resTabAll.task,taskuse(t)) & ...
                        strcmp(resTabAll.visit, visuse{v} ) & ...
                        strcmp(resTabAll.patient, patuse{p} ) & ...
                        resTabAll.med == medstat(m) & ...
                        resTabAll.stim == stimsta(s) ;
                    idxkeep = idxkeep | idxuse ;
                end
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
handles.idxkeep    = idxkeep;
handles.axecog.XLim = xlimsuse;
handles.axlfp.XLim = xlimsuse;
handles.axcoher.XLim = xlimsuse;
handles.axcoher.YLim = [0 1];

%% reset patch ylimits 
for a = 1:length(handles.axesclr)
    for p = 1:size(handles.hPatches,1)
        curylim = handles.axesclr(a).YLim;
        handles.hPatches(p,a).YData = [curylim(1) curylim(1) curylim(2) curylim(2)];
    end
end

guidata(gcf,handles);

% hObject    handle to redraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function MouseDown(gcbo,event,handles)
dat = get(gcbo,'UserData');
if isfield(dat,'isaxis')
    dat.mousedown = 1; 
    set(gcbo,'UserData',dat);
else
    dat.handlereport.String = sprintf('%s %s',dat.legstr, dat.time{1});
    handles = guidata(gcf);
    handles.DatDrawRaw = dat;
end
guidata(gcf,handles);




function MouseUp(gcbo,event,handles)
% handles = guidata(gcf);
% for a = 1:length(handles.axesclr)
%     dat = get(handles.axesclr(a),'UserData');
%     dat.mousedown  = 0;
%     set(handles.axesclr(a),'UserData',dat);
% end
% reset all the colors 

function MouseMove(gcbo,event,handles)
% handles = guidata(gcf);
% for a = 1:length(handles.axesclr)
%     dat = get(handles.axesclr(a),'UserData');
%     ylimuse = handles.axesclr(a).YLim;
%     cp = get ( handles.axesclr(a), 'CurrentPoint' );
%     if dat.mousedown  & handles.showPeak.Value 
%         handles.reportline
% %         line(handles.axesclr(a),[cp(1,1) cp(1,1)],ylimuse);
%         txtuse = sprintf('freq %0.2f',cp(1,1));
%         text(handles.axesclr(a),cp(1,1),cp(1,2),txtuse);
%     end
% end


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


% --- Executes on selection change in hPatListBox.
function hPatListBox_Callback(hObject, eventdata, handles)
% hObject    handle to hPatListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPatListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPatListBox


% --- Executes during object creation, after setting all properties.
function hPatListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPatListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in avgVisit.
function avgVisit_Callback(hObject, eventdata, handles)
% hObject    handle to avgVisit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avgVisit


% --- Executes on button press in avgTask.
function avgTask_Callback(hObject, eventdata, handles)
% hObject    handle to avgTask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avgTask


% --- Executes on button press in avgMed.
function avgMed_Callback(hObject, eventdata, handles)
% hObject    handle to avgMed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avgMed


% --- Executes on button press in avgStim.
function avgStim_Callback(hObject, eventdata, handles)
% hObject    handle to avgStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avgStim


% --- Executes on button press in useZscoreNormalize.
function useZscoreNormalize_Callback(hObject, eventdata, handles)
% hObject    handle to useZscoreNormalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useZscoreNormalize


% --- Executes on button press in powerNormalize.
function powerNormalize_Callback(hObject, eventdata, handles)
% hObject    handle to powerNormalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of powerNormalize


% --- Executes on button press in computeStats.
function computeStats_Callback(hObject, eventdata, handles)
% hObject    handle to computeStats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Classify.
function Classify_Callback(hObject, eventdata, handles)
% hObject    handle to Classify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in avgPatients.
function avgPatients_Callback(hObject, eventdata, handles)
% hObject    handle to avgPatients (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avgPatients


% --- Executes on button press in exoprt_figure.
function exoprt_figure_Callback(hObject, eventdata, handles)
hfig = figure; 
hax = subplot(2,2,1);
poslfp = hax.Position; 
delete(hax);
hax = subplot(2,2,2);
posecog = hax.Position; 
delete(hax);
hax = subplot(2,2,[3 4]);
posecoher = hax.Position; 
delete(hax);

h = copyobj(handles.axlfp,hfig);
h.Position = poslfp;
hlnslfp = get(h,'Children');
h = copyobj(handles.axecog,hfig);
h.Position = posecog;
hlnsecog = get(h,'Children');
h = copyobj(handles.axcoher,hfig);
h.Position = posecoher;
hlnsecoh = get(h,'Children');

idxset = find(handles.idxkeep==1);
legend(hlnslfp(idxset,1),handles.legstr(idxset));
legend(hlnsecog(idxset,1),handles.legstr(idxset));
legend(hlnsecoh(idxset),handles.legstr(idxset));

% hObject    handle to exoprt_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in drawRaw.
function drawRaw_Callback(hObject, eventdata, handles)
dat = handles.DatDrawRaw;
rootdir = handles.rootDirName;
patdir = sprintf('brpd_%s',dat.patient{1}(5:6));
patdir = fullfile(rootdir, patdir);
% find the raw data  
possstrings = {'OR day','2 day','10 day',...
                '3 week','1 month','2 month',...
                '3 month','6 month','1 year',...
                '2 year'};
matcstr    =  { 'OR_day','predis','10_day',...
                '03_wek','01_mnt','02_mnt',...
                '03_mnt','06_mnt',...
                '01_yer','02_yer'};
fdirs = findFilesBVQX(patdir,'*',struct('dirs',1,'depth',1));
visitstr = matcstr(strcmp(dat.visit,possstrings)); 
idxvisit = cellfun(@(x) any(strfind(x,visitstr)),fdirs);
visitdir = fdirs(idxvisit); 
ff = findFilesBVQX(visitdir,'dataBR.mat');
load(ff{1}); 
idxsession = datTab.sessionum == dat.sessionum;
dataSess = datTab(idxsession,:);
% Matlab 
% % plot the raw data 
% datplot = dataSess.ecog{1};
% wind = hamming(dataSess.sr/2)';
% nlap = round(dataSess.sr/2*0.9);
% nfft = 256; 
% sr = dataSess.sr;
% [s,f,t] =spectrogram(datplot,wind,nlap,nfft,sr,'yaxis','power');
% hfig = figure;
% dat = log10(abs(s(:)));
% datsort = sort(dat);
% clims = [datsort(round(length(datsort)*0.01)) , ... 
%             datsort(round(length(datsort)*0.99))];
% imagesc(t,f,log10(abs(s)),clims);
% set(gca,'YDir','normal');
% shading interp 
% set(gca,'YLim',[0 100]);
% using eeglab
addpath(genpath(fullfile(pwd,'toolboxes','chronux_2_11')));
specparams.tapers       = [3 5]; % precalculated tapers from dpss or in the one of the following
specparams.pad          = 1;% padding factor for the FFT) - optional
specparams.err          = [2 0.05]; % (error calculation [1 p] - Theoretical error bars; [2 p] - Jackknife error bars
specparams.trialave     = 0; % (average over trials/channels when 1, don't average when 0) 
specparams.Fs           = dataSess.sr; % sampling frequency 
movingwin = [1 0.1];% (in the form [window winstep] i.e length of moving window and step size) Note that units here have to be consistent with units of Fs - required

% compute spectrogram along moving windows: 
hfig = figure; 
areas = {'ecog','lfp'}; 
pltcnt= 1; 
for a = 1:length(areas)
    datplot = dataSess.(areas{a}){1};
    hax(pltcnt) = subplot(4,1,pltcnt);pltcnt = pltcnt + 1; 
    params.sr = dataSess.sr;
    plot([1:length( datplot)]./params.sr,datplot);
    ttls = sprintf('%s %s',...
        areas{a},...
        dataSess.([areas{a} '_elec']){1});
    title(ttls);
    xlabel('time');
    ylabel('power');
end
% plot_data_freq_domain(datplot,params,[]); 
for a = 1:length(areas)
    hax(pltcnt) = subplot(4,1,pltcnt);pltcnt = pltcnt + 1;
    datplot = dataSess.(areas{a}){1};
    [S,t,f,Serr]=mtspecgramc(datplot,movingwin,specparams);
    SS(:,:,1)=S;
    idxf = f > 0 & f < 100;
    % plot using imagesc (note that this scales color)
    temp = 10*log10(S(:,idxf));
    sortemp = sort(temp(:));
    clims = [sortemp(round(length(sortemp)*0.01)) sortemp(round(length(sortemp)*0.95))];
    hplot = imagesc(t,f,10*log10(S'),clims);
    axis xy; % flip axis so frequncies go from top to bottom
    % XX need to add units to colorbar.
    colormap(gca,parula(1e3))
    caxis(clims);
    % colorbar;
    xlabel('Time (seconds)');
    ylabel('Frequency');
    ylim([0 120]);
    ttls = sprintf('%s %s',...
        areas{a},...
        dataSess.([areas{a} '_elec']){1});
    title(ttls);
end

if dataSess.med; meds = 'on';else; meds = 'off'; end;
if dataSess.stim; stims = 'on';else; stims = 'off'; end;
ttls = sprintf('%s %s dur-%s med-%s stim-%s sr-%d',...
        dataSess.patient{1},...
        dataSess.task{1},...
        dataSess.duration{1},...
        meds,...
        stims,...
        dataSess.sr);
linkaxes(hax,'x');
if ~isnan(dataSess.idxclean(1))
    xlim(dataSess.idxclean./dataSess.sr);
end
suptitle(ttls);
% hObject    handle to drawRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in showPeak.
function showPeak_Callback(hObject, eventdata, handles)
% hObject    handle to showPeak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if hObject.Value 
    handles = guidata(gcf);
    for i = 1:3
        handles.hcurs(i) = cursorbar(handles.axesclr(i));
    end
    guidata(gcf,handles);
else
    if isfield(handles,'hcurs')
        for i = 1:3
           delete(handles.hcurs(i));
        end
    end
%     datacursormode off
end
% Hint: get(hObject,'Value') returns toggle state of showPeak
