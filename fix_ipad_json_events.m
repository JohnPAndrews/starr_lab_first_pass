function fix_ipad_json_events()
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
figdiruse = fullfile('..','figures','ipad_figures_from_json');
patdir  = findFilesBVQX(rootdir,'brpd_*',struct('dirs',1,'depth',1));
fid = fopen('failes_ipad_json_sync.txt','w+');



areasuse = {'ecog'};
for a = 1:length(areasuse)
    for p = 2%:length(patdir)
        [pn,patstr] = fileparts(patdir{p});
        visitdir = findFilesBVQX(patdir{p},'v*',struct('dirs',1,'depth',1));
        for v = 3:length(visitdir) % start from 10 day 
            datafn = findFilesBVQX(visitdir{v},'dataBR.mat');
            if ~isempty(datafn)
                load(datafn{1});
            end
            ipaddir = findFilesBVQX(visitdir{v},'*tsk-ipad*',struct('dirs',1,'depth',1));
            
            if ~isempty(ipaddir)
                for ii = 1:length(ipaddir)
                %% detect movement from ipad beeps
                ff = findFilesBVQX(ipaddir{ii},'*.json');
                if ~isempty(ff)
                    if exist(fullfile(ipaddir{ii},'ipad_event_indices_from_json.mat'),'file')
                        load(fullfile(ipaddir{ii},'ipad_event_indices_from_json.mat'));
                        if ~ismember('useNewLineUp', eventsTable.Properties.VariableNames)
                            fprintf(fid,'failed %s \n',ipaddir{ii});
                            try
                                load(fullfile(ipaddir{ii},'ipad_allign_info.mat'));
                                eegraw = loadEEGdata(ipaddir{ii});
                                timeDat = readIpadJson(ff{1});
                                eventsTable = transformJsonDatToEEGidx(timeDat, eegraw);
                                [beepsInIdxs] = createEventMatrices(alligninfo,eventsTable.eegidxtimestamp,brraw,params);   % for now just using ipad beeps
                                eventsTable.bridx = beepsInIdxs;
                                save(fullfile(ipaddir{ii},'ipad_event_indices_from_json.mat'),'eventsTable');
                            catch
                                fprintf('failed %s \n',ipaddir{ii});
                            end
                        end
                    end
                end
                end
            end
        end
    end
end
fclose(fid);
end


function eventsTable = transformJsonDatToEEGidx(timeDat, eegraw)
usegui = 1;
if usegui
    locuse = peakFinder(eegraw);
else
    approvd = 0;
    setsecs = 0;
    while ~approvd
        hfig = figure;
        if setsecs
            idxuse = secs > startsecs & secs < endsecs;
            dat = dat(idxuse);
            secs = secs(idxuse);
        else
            fielduse = 'Erg1';
            dat = zscore(eegraw.(fielduse));
            secs = [1:length(dat)]./eegraw.srate;
            thresh = 3;
        end
        
        hp = plot(secs,dat);
        hold on;
        
        
        [pksuse,locuse,~,~] = findpeaks(dat,secs,...
            'MinPeakDistance',2,...
            'MinPeakHeight', thresh);
        
        for s = 1:length(pksuse)
            handles.scattereeg(s) = ...
                scatter(...
                locuse(s),pksuse(s),...
                400,'r',...
                'UserData',1);
            %         'ButtonDownFcn',@ScatterPressed,...
            
        end
        approvd = input('do you approve (1/0)?');
        setsecs  = input('set secs (1/0)?');
        if setsecs
            startsecs  = input('start? ');
            endsecs  = input('end? ');
            thresh    = input('thresh? ');
            setsecs = 1;
        else
            if ~approvd
                fielduse = 'Erg2';
                close(hfig);
            end
        end
        
    end
end

fsv  = {'sound',... % Sound
        'start',...
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
% for f = 1:length(fsv)
%     dat = timeDat.(fsv{f})./1000;
%     for t = 1:length(dat)
%         events(cnt).label = fsv{f};
%         events(cnt).timestamp = dat(t);
%         if strcmp(fsv{f},'sound')
%             events(cnt).eegtimestamp = locuse(t);
%         else 
%             events(cnt).eegtimestamp = NaN;
%         end
%         cnt = cnt +1;
%     end
% end
for f = 1:length(fsv)
    dat = timeDat.(fsv{f})./1000;
    for t = 1:length(dat)
        events(cnt).label = fsv{f};
        events(cnt).timestamp = dat(t);
        events(cnt).eegtimestamp = NaN;
        cnt = cnt +1;
    end
end

% calculate sound time stamps 

eventsTable = struct2table(events);
eventsTable = sortrows(eventsTable,'timestamp');
idxfound = cellfun(@(x) strcmp(x,'sound'),eventsTable.label);
idxuse = find(idxfound==1); 
ipadtime = eventsTable.timestamp(idxuse);
outidx =  allignSoundFromJsonAndEEG(locuse,ipadtime);
eventsTable.eegtimestamp( idxuse(outidx.ipad)) = locuse(outidx.eeg);
eventsTable.useNewLineUp = repmat(1,size(eventsTable,1),1);
curidx = 1; 
soundidx = find(cellfun(@(x) strcmp(x,'sound'),eventsTable.label)==1,1);
while curidx <= size(eventsTable,1)
    if ~strcmp(eventsTable.label{curidx},'sound')
        if soundidx > curidx
            eventsTable.eegtimestamp(curidx) = eventsTable.eegtimestamp(soundidx) - ...
                (eventsTable.timestamp(soundidx) - eventsTable.timestamp(curidx));
        elseif soundidx < curidx
            eventsTable.eegtimestamp(curidx) = eventsTable.eegtimestamp(soundidx) + ...
                (eventsTable.timestamp(curidx) - eventsTable.timestamp(soundidx) );

        end
    else
        soundidx = curidx; 
    end
    curidx = curidx +1;
end
eventsTable.eegidxtimestamp = ceil(eventsTable.eegtimestamp .* eegraw.srate);
end

function eegraw = loadEEGdata(rootdir)
%% step 1 - convert .bdf to EEG format
bdffnms = findFilesBVQX(rootdir,'*.bdf');
ff = findFilesBVQX(rootdir,'EEGRAW_*.mat');
if ~isempty(ff)
    load(ff{1});
    eegraw = eegraw;
    skipthis = 1;
else
    skipthis = 0;
end
if ~skipthis
    for b = 1:length(bdffnms)
        addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/eeglab14_1_0b'));
        start = tic;
        [pn,fn,ext] = fileparts(bdffnms{b});
        EEG = pop_biosig(bdffnms{b});
        labs = {EEG.chanlocs.labels};
        idxchan = find(cellfun(@(x) any(strfind(x,'EXG')),labs)==1) ;
        eegraw = [];
        for c = 1:length(idxchan)
            eegraw.(labs{idxchan(c)}) = EEG.data(idxchan(c),:);
        end
        idxchan = find(cellfun(@(x) any(strfind(x,'Erg')),labs)==1) ;
        for c = 1:length(idxchan)
            eegraw.(labs{idxchan(c)}) = EEG.data(idxchan(c),:);
        end
        eegraw.srate = EEG.srate;
        save(fullfile(pn,['EEGRAW_' fn '.mat']),'eegraw');
        fprintf('saved file %d out of %d in %f\n',b,length(bdffnms),toc(start));
        restoredefaultpath;
        rmpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/eeglab14_1_0b'));
    end
    
end
end

function  [beepIdxBR] = createEventMatrices(alligninfo,beepsfound,brraw,params)
beepSecsEEG = beepsfound ./ alligninfo.eegsr  - alligninfo.eegsync(1) ./ alligninfo.eegsr;
beepSecsBR  = beepSecsEEG + alligninfo.ecogsync(1) ./ alligninfo.ecogsr;
beepIdxBR   = round(beepSecsBR .* alligninfo.ecogsr);

end