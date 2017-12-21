function readIpadDataPlotBehav()
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
patdir  = findFilesBVQX(rootdir,'brpd*',struct('depth',1,'dirs',1));
cnt = 1; 
for p = 1:length(patdir)
    visitdir = findFilesBVQX(patdir{p},'v*',struct('depth',1,'dirs',1));
    for v = 1:length(visitdir)
        [pn,visitdrn] = fileparts(visitdir{v});
        visitstr = getVisitNameFromDir(visitdrn);
        ipaddir = findFilesBVQX(visitdir{v},'s*ipad*',struct('depth',1,'dirs',1));
        datafn  = findFilesBVQX(visitdir{v},'dataBR.mat');
        if ~isempty(datafn)
            load(datafn{1});
        end
        for s = 1:length(ipaddir)
            [pn,fn] = fileparts(ipaddir{s});
            jsonfn = findFilesBVQX(ipaddir{s},'*.json');
            if ~isempty(jsonfn)
                sessnum = str2num(fn(3:5));
                idxuse = datTab.sessionum == sessnum;
                datRow = datTab(idxuse,{'patient','sessionum','task','med','stim'});
                timeDat = readIpadJson(jsonfn{1});
                [eventsTable,behavMeas] = getBehavMeasuresdiPadJsons(timeDat);
                resultsBehav(cnt).patient = datRow.patient;
                resultsBehav(cnt).sessionum =  datRow.sessionum;
                resultsBehav(cnt).visit = visitstr;
                resultsBehav(cnt).task = datRow.task;
                resultsBehav(cnt).med = datRow.med; 
                resultsBehav(cnt).stim  = datRow.stim;
                
                resultsBehav(cnt).preperrors = behavMeas.preperrors;
                resultsBehav(cnt).rt = behavMeas.rt;
                resultsBehav(cnt).speed = behavMeas.speed;
                cnt = cnt +1; 
%                 patient
%                 sessionum
%                 task
%                 med
%                 stim
%                 visit
            end
        end
    end
end
behavResults = struct2table(resultsBehav)

%% plotting 
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/figures/on_off_stim/raw_by_task';

%% rt 
patuse = unique(behavResults.patient);
hfig = figure; 
for p = 1:length(patuse)
    hsub = subplot(2,3,p);
    hold on;
    idxpat  = cellfun(@(x) strcmp(x,patuse{p}),behavResults.patient); 
    idxmed  = ~behavResults.med;
    for s = 1:2 
        if s ==1 % on stim
            idxstim = behavResults.stim;
        elseif s ==2 
            idxstim = ~behavResults.stim;
        end
        idxuse = idxpat & idxmed & idxstim; 
        idxs = find(idxuse ==1); 
        meas = [];
        for i = 1:length(idxs)
            meas = [meas, behavResults.rt{idxs(i),:}];
        end
        notBoxPlot(meas,s);
    end
    hsub.XTick = [1 2];
    hsub.XTickLabel = {'on stim','off stim'};
    ylabel('response time');
    title(['response times ' patuse{p}]); 
end
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [18 14];
hfig.PaperPosition = [0 0 18 14];
print(hfig,fullfile(figdir,['09_behavmeas' patuse{p} '.jpeg']),'-djpeg','-r200');
close(hfig);


%% speed  
patuse = unique(behavResults.patient);
hfig = figure; 
for p = 1:length(patuse)
    hsub = subplot(2,3,p);
    hold on;
    idxpat  = cellfun(@(x) strcmp(x,patuse{p}),behavResults.patient); 
    idxmed  = ~behavResults.med;
    for s = 1:2 
        if s ==1 % on stim
            idxstim = behavResults.stim;
        elseif s ==2 
            idxstim = ~behavResults.stim;
        end
        idxuse = idxpat & idxmed & idxstim; 
        idxs = find(idxuse ==1); 
        meas = [];
        for i = 1:length(idxs)
            meas = [meas, behavResults.speed{idxs(i),:}];
        end
        notBoxPlot(meas,s);
    end
    hsub.XTick = [1 2];
    hsub.XTickLabel = {'on stim','off stim'};
    ylabel('speed');
    title(['speeds ' patuse{p}]); 
end
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [18 14];
hfig.PaperPosition = [0 0 18 14];
print(hfig,fullfile(figdir,['10_behavmeas_speed' patuse{p} '.jpeg']),'-djpeg','-r200');
close(hfig);

end

function [eventsTable,behavMeas] = getBehavMeasuresdiPadJsons(timeDat)

fsv  = {'sound',... % Sound
        'rest_ON',...% Rest epoch Beg Fixation point ON red dot
        'rest_OFF',...% Rest epoch End Fixation point OFF red dot
        'rest_error',...  % Rest epoch Error Fixation error by mvt
        'prep_ON',...% Preparation epoch Beg ON Cue ON blue dot
        'prep_OFF',...% Preparation epoch End Cue OFF blue dot
        'prep_error',... % Preparation  epoch error by mvt
        'target1_ON',... % Target1 ON
        'touch1_OFF',...% Touch1 
        'prep_error',...% Error_touch 
        'target_appear',...% target appers (all targets)  
        'target_touched'% target touched (all targets) 
        };
events = struct();
cnt = 1;
for f = 1:length(fsv)
    dat = timeDat.(fsv{f})./1000;
    for t = 1:length(dat)
        events(cnt).label = fsv{f};
        events(cnt).timestamp = dat(t);
        cnt = cnt +1;
    end
end
eventsTable = struct2table(events);
eventsTable = sortrows(eventsTable,'timestamp');
% prep errors 
idxuse = cellfun(@(x) strcmp(x,'prep_error'),eventsTable.label);
behavMeas.preperrors = length( unique(eventsTable.timestamp(idxuse)));

% response times 
idxuse1 = find(cellfun(@(x) strcmp(x,'target1_ON'),eventsTable.label)==1);
cnt = 1; 
for i = 1:length(idxuse1)
    if strcmp('touch1_OFF',eventsTable.label{idxuse1(i)+2})
        rts(cnt) = eventsTable.timestamp(idxuse1(i)+2)-eventsTable.timestamp(idxuse1(i));
        cnt = cnt +1; 
    end
end

behavMeas.rt         = rts;

% speeds 
idxuse1 = find(cellfun(@(x) strcmp(x,'target_appear'),eventsTable.label)==1);
cnt = 1; 
for i = 1:length(idxuse1)
    if strcmp('target_touched',eventsTable.label{idxuse1(i)+1})
        speeds(cnt) = eventsTable.timestamp(idxuse1(i)+1)-eventsTable.timestamp(idxuse1(i));
        cnt = cnt +1; 
    end
end

behavMeas.speed      = speeds;
end

function visitstr = getVisitNameFromDir(viditdrn)

possstrings = {'OR day','2 day','10 day',...
                '3 week','1 month','2 month',...
                '3 month','6 month','1 year',...
                '2 year'};
matcstr    =  { 'OR_day','predis','10_day',...
                '03_wek','01_mnt','02_mnt',...
                '03_mnt','06_mnt',...
                '01_yer','02_yer'};
idxvisit = cellfun(@(x) any(strfind(viditdrn,x)),matcstr);
visitstr = possstrings{idxvisit};

end