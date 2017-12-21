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

% Last Modified by GUIDE v2.5 01-Nov-2017 11:17:12

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
resTabAll.Exclude = zeros(size(resTabAll,1),1); % add exclude field if want to exclude variable 
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

%{
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
%}
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
handles.hLFPelec.String = unique(resTabAll.lfp_elec);
handles.hLFPelec.Max = length(unique(resTabAll.lfp_elec));
handles.hECOGelec.String = unique(resTabAll.ecog_elec);
handles.hECOGelec.Max = length(unique(resTabAll.ecog_elec));

%% set data 
handles.resTabAll = resTabAll;
% handles.hlns = hlns; % the handels to all the psd lines 
% handles.hlnscoh = hlnscoh; % the handles to all the cohernce lines 
% handles.legstr = legstr;
handles.output = hObject;
handles.rootDirName = dirname;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plot_data_from_result_files_interactive wait for user response (see UIRESUME)
% uiwait(handles.figure1);

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

function visit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to visit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function stim_Callback(hObject, eventdata, handles)
% hObject    handle to stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function stim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function med_Callback(hObject, eventdata, handles)
% hObject    handle to med (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function med_CreateFcn(hObject, eventdata, handles)
% hObject    handle to med (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function task_Callback(hObject, eventdata, handles)
% hObject    handle to task (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function task_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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
                        resTabAll.stim == stimsta(s) & ... 
                        ~resTabAll.Exclude; % initilized to zero - so if 1 means exclude 
                    idxkeep = idxkeep | idxuse ;
                end
            end
        end
    end
end

%% filter by electdoe type 
if handles.huseElectrodes.Value
    lfpelecs = handles.hLFPelec.String(handles.hLFPelec.Value);
    idxlfp = cellfun(@(x) any(strcmp(x,lfpelecs)) ,resTabAll.lfp_elec);
    
    ecogelecs = handles.hECOGelec.String(handles.hECOGelec.Value);
    idxecog = cellfun(@(x) any(strcmp(x,ecogelecs)) ,resTabAll.ecog_elec);

    idxtmp = idxlfp & idxecog & idxkeep;
    idxkeep = idxtmp;
end

% get psd data in matrix form, use only freq 1:200 
%% do  averages 
idxuse = resTabAll.sr == 800;
newTab = resTabAll(idxkeep & idxuse,:);

avgfnms = {'avgPatients','avgVisit','avgTask','avgMed','avgStim'}; 
avgnms =  {'patient','visit','task','med','stim'}; 
xaxfnms = {'psdlfpF', 'psdecogF', 'coherfreq'};
yaxfnms = {'psdlfp','psdecog','cpherpower'};
% add some column to make plotting easier 
for y = 1:length(yaxfnms)
    newTab.([yaxfnms{y} 'err']) = zeros(size(newTab,1),1);
end
newTab.avgOf = zeros(size(newTab,1),1);
% loop on possible fields to create unique combinations 
% of tables that will be averaged 
for a = 1:length(avgfnms) 
    if handles.(avgfnms{a}).Value
        fnms.(avgnms{a}).names =  {avgfnms{a}};
        fnms.(avgnms{a}).useavg = 1; 
        fnms.(avgnms{a}).numelm = 1;
    else
        fnms.(avgnms{a}).names = unique(newTab.(avgnms{a}));
        fnms.(avgnms{a}).useavg = 0; 
        fnms.(avgnms{a}).numelm = length( unique(newTab.(avgnms{a})));;
    end
end
[a b c d e] = ndgrid(1:fnms.patient.numelm,...
                     1:fnms.visit.numelm,...
                     1:fnms.task.numelm,...
                     1:fnms.med.numelm,...
                     1:fnms.stim.numelm);
out = [a(:) b(:) c(:) d(:) e(:)];
idxuse = zeros(size(newTab,1),1);

tblcnt = 1;
for r = 1:size(out,1)
    if ~fnms.patient.useavg % only add if not averaging 
        idxuse1 = strcmp(newTab.patient, fnms.patient.names{out(r,1)} );
    else
        idxuse1 = ones(size(newTab,1),1);
    end
    if ~fnms.visit.useavg % only add if not averaging 
        idxuse2 = strcmp(newTab.visit,fnms.visit.names{out(r,2)}) ;
    else
        idxuse2 = ones(size(newTab,1),1);
    end
    if ~fnms.task.useavg % only add if not averaging 
        idxuse3 = strcmp(newTab.task, fnms.task.names{out(r,3)} ) ;
    else
        idxuse3 = ones(size(newTab,1),1);
    end
    if ~fnms.med.useavg % only add if not averaging 
        idxuse4 = newTab.med == medstat(out(r,4)) ;
    else
        idxuse4 = ones(size(newTab,1),1);
    end
    if ~fnms.stim.useavg % only add if not averaging 
        idxuse5 = newTab.stim == stimsta(out(r,5)) ;
    else
        idxuse5 = ones(size(newTab,1),1);
    end
    idxuse = idxuse1 & idxuse2 & idxuse3 & idxuse4 & idxuse5; 
    fprintf('sum %d r %d. p-%s t-%s- v-%s m-%d s-%d \n',sum(idxuse),r,...
        fnms.patient.names{out(r,1)},...
        fnms.visit.names{out(r,2)},...
        fnms.task.names{out(r,3)},...
        medstat(out(r,4)),...
        stimsta(out(r,5)) );
    if sum(idxuse) == 1 % if there is stuff to plot - create new table and avg 
        tableUse(tblcnt) = table2struct(newTab(find(idxuse==1,1,'first'),:));
        tableUse(tblcnt).avgOf = sum(idxuse); 
        tblcnt = tblcnt + 1;
    elseif sum(idxuse) > 1 
        tableAvg = newTab(idxuse,:);
        tableUse(tblcnt) = table2struct(newTab(find(idxuse==1,1,'first'),:));
        tableUse(tblcnt).patient =  fnms.patient.names(out(r,1));
        tableUse(tblcnt).visit = fnms.visit.names(out(r,2));
        tableUse(tblcnt).task = fnms.task.names(out(r,3));
        tableUse(tblcnt).med = medstat(out(r,4));
        tableUse(tblcnt).stim = stimsta(out(r,5)); 
        for y = 1:length(yaxfnms)
            if y ~= 3 % coherence is column instead of row vector, dela with transpose 
                tableUse(tblcnt).(yaxfnms{y}) = mean(cell2mat(tableAvg.(yaxfnms{y})));
                tableUse(tblcnt).([yaxfnms{y} 'err']) = std(cell2mat(tableAvg.(yaxfnms{y})));
            else % coherence mistake: 
                tableUse(tblcnt).(yaxfnms{y}) = mean(cell2mat(tableAvg.(yaxfnms{y})')');
                tableUse(tblcnt).([yaxfnms{y} 'err']) = std(cell2mat(tableAvg.(yaxfnms{y})')');
            end
        end
        tableUse(tblcnt).avgOf = sum(idxuse);
        tblcnt = tblcnt + 1;
    end
    idxuse = zeros(size(newTab,1),1);
end
% tableUse = struct2table(tableUse);

%% plot data psd 
% delete existing lines 
if isfield(handles,'hlns')
    for r = 1:size(handles.hlns,1)
        for c = 1:size(handles.hlns,2)
            delete(handles.hlns(r,c));
        end
    end
    handles.hlns = [];
else
    handles.hlns = [];
end

plotidx = find(idxkeep == 1); 
axuse   = [handles.axlfp handles.axecog handles.axcoher];
xaxfnms = {'psdlfpF', 'psdecogF', 'coherfreq'};
yaxfnms = {'psdlfp','psdecog','cpherpower'};
elcfnms = {'lfp_elec', 'ecog_elec','ecog_elec'};
for a = 1:3
    for i = 1:size(plotidx,1)
        s = plotidx(i);
        hax = axuse(a);
        f   = eval(sprintf('resTabAll.%s{s}',xaxfnms{a}));
        if handles.LogLog.Value
            f   = log10(f);
            for aa = 1:length(handles.axesclr)
                for p = 1:size(handles.freqranges,1)
                    freq = handles.freqranges(p,:);
                    xdat = log10([freq(1) freq(2) freq(2) freq(1)]);
                    handles.hPatches(p,aa).XData = xdat;
                end
            end
        else
            for aa = 1:length(handles.axesclr)
                for p = 1:size(handles.freqranges,1)
                    freq = handles.freqranges(p,:);
                    xdat = [freq(1) freq(2) freq(2) freq(1)];
                    handles.hPatches(p,aa).XData = xdat;
                end
            end
        end
        %% get psd to plot 
        if a < 3 
            psd = log10(eval(sprintf('resTabAll.%s{s}',yaxfnms{a})));
            if handles.powerNormalize.Value % normalzie 
                psd = psd./ mean(psd( f>4 & f < 100));
            end
        else
            psd = eval(sprintf('resTabAll.%s{s}',yaxfnms{a})); % don't log10 for cohernce 
        end
        %% 
        hlns(i,a) = line(f, psd,'Parent',hax,...
            'ButtonDownFcn',@MouseDown);
        dat = resTabAll(s,{'patient','visit','task','sessionum','med','stim','duration','sr','ecog_elec','lfp_elec','time'});
        legstr{s} = sprintf('%s %s T-%s %s M %s S %s',...
            dat.patient{1},...
            dat.visit{1},...
            dat.task{1}(1:2),...
            char((dat.med)*'on ' + ~(dat.med)*'off'),...
            char((dat.stim)*'on ' + ~(dat.stim)*'off'),...
            dat.([elcfnms{a} ]){1});
        %% what to do about different sampling rates? 
%         [p,v,t,m,ss] = indixifyData(dat);
%         datpsd(p,v,t,m,ss,:) = psd; 
        %% 
        dat.legstr = legstr{s};
        dat.hax = hax;
        dat.handlereport = handles.selectedfile;
        dat.idxLine = i; 
        dat.idxPlot = a;
        dat.idxTbl  = s; 
        hlns(i,a).UserData = dat;
        hlns(i,a).Visible = 'on';
        hlns(i,a).LineWidth = 2;
        if hlns(i,a).UserData.med
            hlns(i,a).Color = [0 0.9 0 0.7];
        else
            hlns(i,a).Color = [0.9  0 0 0.8];
        end
        if hlns(i,a).UserData.stim
            hlns(i,a).LineStyle = '-.';
        end
    end
end
if exist('hlns','var')
    handles.hlns = hlns;
    for r = 1:size(hlns,1) % lines 
        for c = 1:size(hlns,2) % plot 
            mins(r,c) = min(hlns(r,c).YData);
            maxs(r,c) = max(hlns(r,c).YData);
        end
    end
    minsuse = min(mins,[],1);
    maxsuse = max(maxs,[],1);
    handles.axlfp.YLim = [minsuse(1) maxsuse(1)];
    handles.axecog.YLim = [minsuse(2) maxsuse(2)];
    %% resest limits 
    
else
    fprintf('no lines to draw\n');
end


%% 
% 
% idxset = find(idxkeep==1);
% for x = 1:length(idxset)
%     for a= 1:2
%         hlns(idxset(x),a).Visible = 'on';
%     end
%     hlnscoh(idxset(x),1).Visible = 'on';
% end
% legend(hlns(idxset,1),legstr(idxset));
% legend(hlns(idxset,2),legstr(idxset));
% legend(hlnscoh(idxset),legstr(idxset));
if exist('hlns','var')
    handles.hlns = hlns;
end

if handles.LogLog.Value
    xlimsuse = [0 2];
else
    xlimsuse = [double(str2num(handles.xlimlow.String)) double(str2num(handles.xlimhigh.String))];
end
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

function MouseDown(gcbo,event,handles)
dat = get(gcbo,'UserData');
if isfield(dat,'isaxis')
    dat.mousedown = 1; 
    set(gcbo,'UserData',dat);
else
    dat.handlereport.String = sprintf('%s %s',dat.legstr, dat.time{1});
    handles = guidata(gcf);
    dat.handlereport.UserData = dat.idxLine;
    handles.DatDrawRaw = dat;
end
guidata(gcf,handles);

function MouseUp(gcbo,event,handles)
handles = guidata(gcf);
if handles.showPeak.Value
    for a = 1:length(handles.axesclr)
        if isfield(handles,'hcurs')
            if ~isempty(handles.hcurs(a).UserData) % if its empty, line created mouse not pressed
                if handles.hcurs(a).UserData.mousedown
                    handles.hcurs(a).UserData.mousedown = 0;
                end
            end
        end
    end
end
guidata(gcf,handles);


function MouseMove(gcbo,event,handles)

handles = guidata(gcf);
if handles.showPeak.Value
    for a = 1:length(handles.axesclr)
        if isfield(handles,'hcurs')
            if ~isempty(handles.hcurs(a).UserData) % if its empty, line created mouse not pressed 
                if handles.hcurs(a).UserData.mousedown
                    cp = get ( handles.hcurs(a).UserData.parent, 'CurrentPoint' );
                    handles.hcurs(a).XData = [cp(1) cp(1)];
                    handles.hcurs(a).YData = handles.axesclr(a).YLim;
                    handles.htextbox(a).Position = cp(1,:);
                    handles.htextbox(a).String = sprintf('%0.2f',cp(1));
                    handles.htextbox(a).FontSize = 24;
                    handles.htextbox(a).Visible = 'on';
                end
            end
        end
        %         line(handles.axesclr(a),[cp(1,1) cp(1,1)],ylimuse);
        %     txtuse = sprintf('freq %0.2f',cp(1,1));
        %     text(handles.axesclr(a),cp(1,1),cp(1,2),txtuse);
    end
end

function CrossHairMouseDown(gcbo,event,handles)
handles = guidata(gcf);
parentaxis = gcbo.Parent;
for a = 1:length(handles.axesclr)
    cp = get ( parentaxis, 'CurrentPoint' );
    handles.hcurs(a).XData = [cp(1) cp(1)];
    dat.mousedown = 1; 
    dat.parent = parentaxis; 
    handles.hcurs(a).UserData = dat;
end
guidata(gcf,handles);


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

function xlimhigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xlimhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hPatListBox_Callback(hObject, eventdata, handles)

% hObject    handle to hPatListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function hPatListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPatListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function avgVisit_Callback(hObject, eventdata, handles)
% hObject    handle to avgVisit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function avgTask_Callback(hObject, eventdata, handles)
% hObject    handle to avgTask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function avgMed_Callback(hObject, eventdata, handles)
% hObject    handle to avgMed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function avgStim_Callback(hObject, eventdata, handles)
% hObject    handle to avgStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function useZscoreNormalize_Callback(hObject, eventdata, handles)
% hObject    handle to useZscoreNormalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function powerNormalize_Callback(hObject, eventdata, handles)
% hObject    handle to powerNormalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function computeStats_Callback(hObject, eventdata, handles)
% hObject    handle to computeStats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function Classify_Callback(hObject, eventdata, handles)
% hObject    handle to Classify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function avgPatients_Callback(hObject, eventdata, handles)
% hObject    handle to avgPatients (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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
% legend(hlnslfp(idxset,1),handles.legstr(idxset));
% legend(hlnsecog(idxset,1),handles.legstr(idxset));
% legend(hlnsecoh(idxset),handles.legstr(idxset));


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
save('guioutput.mat','dataSess');


% --- Executes on button press in showPeak.
function showPeak_Callback(hObject, eventdata, handles)
% hObject    handle to showPeak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axesuse = [handles.axlfp handles.axecog handles.axcoher];
if hObject.Value 
    handles = guidata(gcf);
    for i = 1:3
        ylimsax = axesuse.YLim;
        xlimsax = axesuse.XLim;
        xlimuse = [xlimsax(2)-xlimsax(1)]/2;
        handles.hcurs(i) = line([xlimuse xlimuse], ylimsax,...
            'Parent',axesuse(i),...
            'ButtonDownFcn',@CrossHairMouseDown);
        handles.hcurs(i).LineWidth = 4;
        handles.hcurs(i).LineStyle = '-';
        handles.hcurs(i).Color = [0.5 0.5 0.5 0.7];
        textuse = sprintf('%0.2f',xlimuse);
        handles.htextbox(i) = text(axesuse(i),xlimuse,ylimsax(1),textuse,'Visible','off');
    end
    guidata(gcf,handles);
else
    if isfield(handles,'hcurs')
        for i = 1:3
           delete(handles.hcurs(i));
        end
        handles = rmfield(handles,'hcurs');
    end
    if isfield(handles,'htextbox')
        for i = 1:3
            delete(handles.htextbox(i));
        end
        handles = rmfield(handles,'htextbox');
    end
%     datacursormode off
end
guidata(gcf,handles);
% Hint: get(hObject,'Value') returns toggle state of showPeak

function [p,v,t,m,s] = indixifyData(dat);
handles = guidata(gcf);
% patient 
p = find(strcmp(handles.hPatListBox.String,dat.patient)==1);
% visit 
v = find(strcmp(handles.visit.String,dat.visit)==1);
% task 
t = find(strcmp(handles.task.String,dat.task)==1);
% med 
if dat.med; m = 1; else m = 2; end;
% stim 
if dat.stim; s = 1; else s = 2; end;


% --- Executes on button press in ChangeColor.
function ChangeColor_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
idxline = handles.selectedfile.UserData; 
c = uisetcolor([0.6 0.8 1]);
for j = 1:size(handles.hlns,2)
    handles.hlns(idxline,j).Color = c;
end



% hObject    handle to ChangeColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ExcludeSession.
function ExcludeSession_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
idxline = handles.selectedfile.UserData;
idxtable = handles.hlns(idxline,1).UserData.idxTbl;
handles.resTabAll.Exclude(idxtable) = 1; 
c = [0.5 0.5 0.5];
for j = 1:size(handles.hlns,2)
    handles.hlns(idxline,j).Color = c;
end
guidata(gcf,handles);


% --- Executes on button press in SaveDB.
function SaveDB_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
resTabAll = handles.resTabAll; 
uisave('resTabAll','db1');
% hObject    handle to SaveDB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LoadDataBase.
function LoadDataBase_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
uiopen();
handles.resTabAll = resTabAll;
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
handles.hPatListBox.Value = 1; % to deal with cases with one patinte
handles.hPatListBox.Max = length( unique(resTabAll.patient));
handles.hPatListBox.String = unique(resTabAll.patient);
handles.hLFPelec.String = unique(resTabAll.lfp_elec);
handles.hLFPelec.Max = length(unique(resTabAll.lfp_elec));
handles.hECOGelec.String = unique(resTabAll.ecog_elec);
handles.hECOGelec.Max = length(unique(resTabAll.ecog_elec));

guidata(gcf,handles);


% hObject    handle to LoadDataBase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in BuildDataBase.
function BuildDataBase_Callback(hObject, eventdata, handles)
%% get dir name 
dirname = uigetdir();
handles.rootDirName = dirname; 
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
resTabAll.Exclude = zeros(size(resTabAll,1),1); % add exclude field if want to exclude variable 
handles = guidata(gcf);
handles.resTabAll = resTabAll;
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
handles.hPatListBox.Value = 1; % to deal with cases with one patinte
handles.hPatListBox.Max = length( unique(resTabAll.patient));
handles.hPatListBox.String = unique(resTabAll.patient);
handles.hLFPelec.String = unique(resTabAll.lfp_elec);
handles.hLFPelec.Max = length(unique(resTabAll.lfp_elec));
handles.hECOGelec.String = unique(resTabAll.ecog_elec);
handles.hECOGelec.Max = length(unique(resTabAll.ecog_elec));


guidata(gcf,handles);


% --- Executes on button press in LogLog.
function LogLog_Callback(hObject, eventdata, handles)
% hObject    handle to LogLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LogLog


% --- Executes on button press in computePAC.
function computePAC_Callback(hObject, eventdata, handles)
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

idxuse = dataSess.idxclean(1):dataSess.idxclean(2);
data(1,:) = dataSess.lfp{:}(idxuse);
data(2,:) = dataSess.ecog{:}(idxuse);
sr  = dataSess.sr;
params.regionnames = {'lfp','ecog'};
params.AmpFreqVector = 10:4:100;
params.PhaseFreqVector = 5:4:50;
computePAC(data,sr,params);


% --- Executes on selection change in hLFPelec.
function hLFPelec_Callback(hObject, eventdata, handles)
% hObject    handle to hLFPelec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hLFPelec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hLFPelec


% --- Executes during object creation, after setting all properties.
function hLFPelec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hLFPelec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hECOGelec.
function hECOGelec_Callback(hObject, eventdata, handles)
% hObject    handle to hECOGelec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hECOGelec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hECOGelec


% --- Executes during object creation, after setting all properties.
function hECOGelec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hECOGelec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in huseElectrodes.
function huseElectrodes_Callback(hObject, eventdata, handles)
% hObject    handle to huseElectrodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of huseElectrodes


% --- Executes on button press in computeElectrodes.
function computeElectrodes_Callback(hObject, eventdata, handles)
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
                        resTabAll.stim == stimsta(s) & ... 
                        ~resTabAll.Exclude; % initilized to zero - so if 1 means exclude 
                    idxkeep = idxkeep | idxuse ;
                end
            end
        end
    end
end

handles.hLFPelec.Value = 1;
handles.hLFPelec.String = unique(resTabAll.lfp_elec(idxkeep));
handles.hLFPelec.Max = length(unique(resTabAll.lfp_elec(idxkeep)));
handles.hECOGelec.Value = 1;
handles.hECOGelec.String = unique(resTabAll.ecog_elec(idxkeep));
handles.hECOGelec.Max = length(unique(resTabAll.ecog_elec(idxkeep)));

x =2 ;