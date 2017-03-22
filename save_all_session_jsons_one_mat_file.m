function save_all_session_jsons_one_mat_file()
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data';
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
resultsdir   = fullfile('..','results','mat_file_with_all_session_jsons');
[settings, params] = get_settings_params();
mkdir(resultsdir);
%% save all data to temp results dir to make loading files faster
savedatatomat =0; % save all data to temp directory...
onlyapplymanualfixes = 1;
cnt = 1;
fnmsave = fullfile(settings.rootdir, 'patients-^^^^-.json');
Patients = loadjson(fnmsave,'SimplifyCell',1); % this is how to read the data back in.
symptomcat = {};
if savedatatomat
    %% XX
    %     Patients = Patients(2);
    %% XX
    for p = 1:length(Patients)
        visitfnm = fullfile(settings.rootdir, Patients(p).PatientCode,'visit-details-^^^^-.json');
        visits = loadjson(visitfnm,'SimplifyCell',1); % this is how to read the data back in.
        %% XX
        %         visits = visits(2);
        %% XX
        
        for v = 1:length(visits)
            visitfldr = fullfile(settings.rootdir, Patients(p).PatientCode,visits(v).visitCategory);
            pjsonfnm = findFilesBVQX(visitfldr,'*protocol*.json');
            protocol = loadjson(pjsonfnm{1},'SimplifyCell',1); %
            for pp = 1:length(protocol)
                fsessiondir = findFilesBVQX(visitfldr,sprintf('s_%0.3d*',pp),struct('dirs',1,'depth',1));
                ff = findFilesBVQX(fsessiondir{1},'*session*.json');
                for f = 1:length(ff)
                    start = tic;
                    session  = loadjson(ff{f},'SimplifyCell',1);
                    [pn,fn,ext] = fileparts(ff{f});
                    outdb.patientcode{cnt} = session.patientcode;
                    outdb.visitCategory{cnt} = session.visitCategory;
                    outdb.usevisit(cnt) = session.usevist;
                    outdb.sessionSerialNum(cnt) = pp;
                    outdb.Medication{cnt} = session.Medication;
                    %% condition
                    if isempty(session.ConditionTask)
                        outdb.ConditionTask{cnt} = '';
                    else
                        outdb.ConditionTask{cnt} = session.ConditionTask;
                        outdb.ConditionNotes{cnt} = session.ConditionNotes;
                    end
                    %% stimulation
                    if isempty(session.StimOn)
                        outdb.StimOn{cnt} = '';
                        outdb.insfreq{cnt}  = ''; % default is empty
                    else
                        outdb.StimOn{cnt} = session.StimOn;
                        outdb.insfreq{cnt}  = ''; % default is empty
                    end
                    outdb.recordingduraton(cnt)  = str2num(session.xmldata.RecordingConfig.DurationSeconds);
                    outdb.daysSinceImplant(cnt) = session.daysSinceImplant;
                    outdb.pathname{cnt} = pn;
                    outdb.filename{cnt} = [fn ext];
                    outdb.datafullpath{cnt} = fullfile(pn,[session.filename '.txt']);
                    outdb.rejectsesssion(cnt) = session.rejectsesssion;
                    if isfield(session,'xmldata') & ~isempty(session.xmldata)
                        outdb.xmlexists(cnt) = 1;
                        outdb.sr(cnt) = str2num(strrep(session.xmldata.SenseChannelConfig.TDSampleRate,'Hz',''));
                        outdb.RecordingType{cnt} = session.xmldata.RecordingType;
                        if strcmp(outdb.RecordingType{cnt},'Montage')
                            outdb.ConditionTask{cnt} = 'montage';
                        end
                        outdb.stn_electrodes{cnt} = ...
                            ['+' session.xmldata.SenseChannelConfig.Channel1.PlusInput '-' session.xmldata.SenseChannelConfig.Channel1.MinusInput];
                        outdb.m1_electrodes{cnt} = ...
                            ['+' session.xmldata.SenseChannelConfig.Channel3.PlusInput '-' session.xmldata.SenseChannelConfig.Channel3.MinusInput];
                    else
                        outdb.xmlexists(cnt) = 0;
                        outdb.sr(cnt) = [];
                        outdb.RecordingType{cnt} = '';
                        outdb.stn_electrodes{cnt} = '';
                        outdb.m1_electrodes{cnt} = '';
                    end
                    outdb.symptoms{cnt} = ''; % default is empty
                    if ~isempty(session.sessionDetailsFromXLS)
                        if ~strcmp(session.sessionDetailsFromXLS,'sessionNotExistInXLS');
                            if ~strcmp(session.sessionDetailsFromXLS,'XLS_DoesNotExist');
                                %% add field about stimluation
                                if isfield(session.sessionDetailsFromXLS,'insFreq')
                                    if ~isnan(session.sessionDetailsFromXLS.insFreq)
                                        outdb.insfreq{cnt} = session.sessionDetailsFromXLS.insFreq;
                                    end
                                end
                                if strcmp(outdb.StimOn{cnt},'')
                                    if  isfield(session.sessionDetailsFromXLS,'stim')
                                        temp = session.sessionDetailsFromXLS.stim;
                                        temp = strrep(temp,',',' ');
                                        temp = strrep(temp,' ','');
                                         outdb.StimOn{cnt} = temp; 
                                    end
                                end
                                if strcmp(outdb.StimOn{cnt},'')
                                    if  isfield(session.sessionDetailsFromXLS,'insAmpLeftSide')
                                        if strcmp(session.sessionDetailsFromXLS.insAmpLeftSide,'off') && strcmp(session.sessionDetailsFromXLS.insAmpRightSide,'off')
                                            outdb.StimOn{cnt} = 'off';
                                        end
                                    end
                                end
                                %% add field patients and symptoms
                                if isfield(session.sessionDetailsFromXLS,'patient0x2CPhenotypeAndSymptoms')
                                    if ~isnan(session.sessionDetailsFromXLS.patient0x2CPhenotypeAndSymptoms)
                                        outdb.symptoms{cnt} = session.sessionDetailsFromXLS.patient0x2CPhenotypeAndSymptoms;
                                    end
                                    
                                    %                                 elseif isfield(session.sessionDetailsFromXLS,'patientActivity')
                                    %                                     outdb.symptoms{cnt} = session.sessionDetailsFromXLS.patientActivity;
                                end
                                symptomcat = [symptomcat(:); fieldnames(session.sessionDetailsFromXLS)];
                                outdb.xlsstatus{cnt} = 'xlsExists';
                            else
                                outdb.xlsstatus{cnt} = 'XLS_DoesNotExist';
                            end
                        else
                            outdb.xlsstatus{cnt} = 'sessionNotExistInXLS';
                        end
                    end
                    
                    fprintf('session %0.4d loaded in %f secs\n',...
                        cnt,toc(start));
                    cnt = cnt + 1;
                    clear session;
                end
            end
        end
    end
    allfields = fieldnames(outdb);
    for f = 1:length(allfields)
        for i = 1:length(outdb.(allfields{f}))
            if ismatrix(outdb.(allfields{f}))
                newstruc(i).(allfields{f}) = outdb.(allfields{f})(i);
            elseif iscell(outdb.(allfields{f}))
                newstruc(i).(allfields{f}) = outdb.(allfields{f}){i};
            end
            
        end
    end
    outdb = newstruc;
    sessiondb = struct2table(newstruc);
    sessiondb =  applyManualFixes(sessiondb);
    save(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
else
    load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
end

if onlyapplymanualfixes
    load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
    sessiondb =  applyManualFixes(sessiondb);
    save(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
end


%% some exapmples of sorting, data selections:
% inclusion criteria:
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.ConditionTask,'rest') & ...
    strcmp(sessiondb.visitCategory,'03_wek');

newdb = sessiondb(rowsselect,:);

[tblsorted,index] = sortrows(newdb,{'patientcode','sessionSerialNum'},{'ascend','ascend'});

end

function outsessiondb  =  applyManualFixes(sessiondb)
%% general fixes
outsessiondb = sessiondb;
% get rid of commas in some fields for better csv formatting and fix some
% fields
%% Stimulaiton
% stimulation is always off up to 1 month:
% XXX brpd01 had stim on for last 4 sessions of 03_wek. note this.
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.StimOn,'') & ...
    strcmp(sessiondb.visitCategory,'OR_day') | ...
    strcmp(sessiondb.visitCategory,'predis') | ...
    strcmp(sessiondb.visitCategory,'10_day') | ...
    strcmp(sessiondb.visitCategory,'03_wek') ;
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'StimOn'})= cell2table(repmat({'off'},size(newdb,1),1));

insfreq = outsessiondb.insfreq;
stimon = [];
for s = 1:size(insfreq,1);
    temp = insfreq{s};
    if ~isstr(temp);
        tempfreq{s} = sprintf('-%d',temp);  % just one number
        stimon(s) = 1;
    elseif ~isempty(regexp(temp,'[0-9]+'))
        lowerstr = lower(temp);
        freqfound = regexp(temp,'[0-9]+','match');
        stimon(s) = 1;
        if length(freqfound) == 1 % if only found one freq in string
            if isempty(regexp(lowerstr,'r','match'));
                tempfreq{s} = sprintf('R%s',freqfound{1});
                stimon(s) = 1;
            elseif isempty(regexp(lowerstr,'l','match'));
                tempfreq{s} = sprintf('L%s',freqfound{1});
                stimon(s) = 1;
            else
                tempfreq{s} = sprintf('-%s',freqfound{1});
                stimon(s) = 1;
            end
        else
            if isempty(regexp(lowerstr,'r')) % if no side is mentioend keep blank
                tempfreq{s} = sprintf('-%s-%s',freqfound{1},freqfound{2});
                stimon(s) = 1;
            else
                if regexp(lowerstr,'r') > regexp(lowerstr,'l')
                    tempfreq{s} = sprintf('L%sR%s',freqfound{1},freqfound{2});
                    stimon(s) = 1;
                elseif regexp(lowerstr,'r') < regexp(lowerstr,'l')
                    tempfreq{s} = sprintf('R%sL%s',freqfound{1},freqfound{2});
                    stimon(s) = 1;
                end
            end
        end
    else
        tempfreq{s} = '';
        stimon(s) = 0;
    end
end
tempfreq = tempfreq';
outsessiondb.insfreq = tempfreq;
% if not empty - then stim was on
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    logical(stimon)';
newdb = outsessiondb(rowsselect,:);
outsessiondb(rowsselect,{'StimOn'})= cell2table(repmat({'on'},size(newdb,1),1));

%% medication
for s = 1:size(sessiondb.Medication,1);
    if isnan(sessiondb.Medication{s})
        outsessiondb.Medication{s} = '';
    elseif isempty(sessiondb.Medication{s})
        outsessiondb.Medication{s} = '';
    elseif isstr(sessiondb.Medication{s})
        outsessiondb.Medication{s} = strrep(outsessiondb.Medication{s},',',' ');
    end
end

%% symptoms
for s = 1:size(sessiondb.symptoms,1);
    if ~isempty(sessiondb.symptoms{s})
        outsessiondb.symptoms{s} = strrep(outsessiondb.symptoms{s},',',' ');
    end
end
%% condition notes
for s = 1:size(sessiondb.ConditionNotes,1);
    if isempty(sessiondb.ConditionNotes{s})
        outsessiondb.ConditionNotes{s} = '';
    end
end


%%  fix formating of electrodes - so formats better in excel
for s = 1:size(sessiondb.m1_electrodes,1);
    tmp = outsessiondb.m1_electrodes{s};
    tmp = strrep(tmp,'+','p');
    tmp = strrep(tmp,'-','n');
    outsessiondb.m1_electrodes{s} = tmp;
    
    tmp = outsessiondb.stn_electrodes{s};
    tmp = strrep(tmp,'+','p');
    tmp = strrep(tmp,'-','n');
    outsessiondb.stn_electrodes{s} = tmp;
end
% OR day is always rest
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.ConditionTask,'') & ...
    strcmp(sessiondb.visitCategory,'OR_day');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'rest'},size(newdb,1),1));


%% brpd 01
% two testing files misclafieid from 3 week visit
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_01') & ...
    strcmp(sessiondb.ConditionTask,'') & ...
    strcmp(sessiondb.visitCategory,'03_wek');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'test'},size(newdb,1),1));
% 1 month visit:
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_01') & ...
    strcmp(sessiondb.visitCategory,'01_mnt') &...
    strcmp(sessiondb.ConditionTask,'') & ...
    (sessiondb.sessionSerialNum <=5 | sessiondb.sessionSerialNum ==14 | sessiondb.sessionSerialNum ==18  | sessiondb.sessionSerialNum ==20);
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'test'},size(newdb,1),1));
% 2 month visit:
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_01') & ...
    strcmp(sessiondb.visitCategory,'02_mnt') &...
    strcmp(sessiondb.StimOn,'');
newdb = sessiondb(rowsselect,:);
if ~isempty(newdb)
    outsessiondb(rowsselect,{'StimOn'})= {'on','off','off','off','off','off','off'}';
end
% 3 month visit  - stim on for this visit
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_01') & ...
    strcmp(sessiondb.visitCategory,'03_mnt') &...
    strcmp(sessiondb.StimOn,'');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'StimOn'})= cell2table(repmat({'on'},size(newdb,1),1));

% 6 month visit
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_01') & ...
    strcmp(sessiondb.visitCategory,'06_mnt') &...
    strcmp(sessiondb.ConditionTask,'') & ...
    sessiondb.sessionSerialNum ==12;
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'rest'},size(newdb,1),1));
outsessiondb(rowsselect,{'StimOn'})= cell2table(repmat({'on'},size(newdb,1),1));
% 1 year visit
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_01') & ...
    strcmp(sessiondb.ConditionTask,'') & ...
    strcmp(sessiondb.visitCategory,'01_yer') &...
    sessiondb.sessionSerialNum ==15;
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'test'},size(newdb,1),1));

%% brpd 02
%% brpd 03
% pre dis
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_03') & ...
    strcmp(sessiondb.visitCategory,'predis') & ...
    (sessiondb.sessionSerialNum ==18  | sessiondb.sessionSerialNum ==20);
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'test'},size(newdb,1),1));

% 03_mnth
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_03') & ...
    strcmp(sessiondb.visitCategory,'03_mnt') & ... 
    strcmp(sessiondb.StimOn,''); 
newdb = sessiondb(rowsselect,:);
if ~isempty(newdb)
    outsessiondb(rowsselect,{'StimOn'})= {'on','on','on','on','washout','washin','on','on','on','on','on'}';
end

% 1 year
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_03') & ...
    strcmp(sessiondb.visitCategory,'01_yer') & ....
    sessiondb.sessionSerialNum ==10;
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'test'},size(newdb,1),1));

% 2 year % brpd 03 has two 2 year visits, one was at 431 days post implant
% for testing, the 731 day was the official one.
% this sesems to be fixed in new db
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_03') & ...
    strcmp(sessiondb.visitCategory,'02_yer') & ...
    strcmp(sessiondb.ConditionTask,'') & ...
    sessiondb.daysSinceImplant == 731;
newdb = sessiondb(rowsselect,:);
if ~isempty(newdb) % it could already be fixed from previous runs of this code...
    outsessiondb(rowsselect,{'ConditionTask'}) = {'rest';'rest';'ipad';'walking'} ;% based on CRF
end
%% brpd 04
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_04') & ...
    strcmp(sessiondb.ConditionTask,'') & ...
    strcmp(sessiondb.visitCategory,'01_mnt');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'homeRecording'},size(newdb,1),1));
outsessiondb(rowsselect,{'Medication'})= cell2table(repmat({'off'},size(newdb,1),1));
% 10 day
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_04') & ...
    strcmp(sessiondb.ConditionTask,'') & ...
    strcmp(sessiondb.visitCategory,'10_day');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'homeRecording'},size(newdb,1),1));
% 03 wek
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_04') & ...
    strcmp(sessiondb.ConditionTask,'') & ...
    strcmp(sessiondb.visitCategory,'03_wek');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'homeRecording'},size(newdb,1),1));
% 02 mnth 
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_04') & ...
    strcmp(sessiondb.StimOn,'') & ...
    strcmp(sessiondb.visitCategory,'02_mnt');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'StimOn'})= cell2table(repmat({'off'},size(newdb,1),1));

% 03 mnt
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_04') & ...
    strcmp(sessiondb.ConditionTask,'') & ...
    strcmp(sessiondb.visitCategory,'03_mnt');
newdb = sessiondb(rowsselect,:);
if ~isempty(newdb) % it could already be fixed from previous runs of this code...
    outsessiondb(rowsselect,{'ConditionTask'})= {'gonogo';'gambling'};
end
% 06 mnt
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_04') & ...
    strcmp(sessiondb.ConditionTask,'') & ...
    strcmp(sessiondb.visitCategory,'06_mnt');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'test'},size(newdb,1),1));
% 01 yer
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_04') & ...
    strcmp(sessiondb.ConditionTask,'') & ...
    strcmp(sessiondb.visitCategory,'01_yer');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'moving'},size(newdb,1),1));

rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_04') & ...
    strcmp(sessiondb.ConditionTask,'rest') & ...
    strcmp(sessiondb.StimOn,'') & ...
    strcmp(sessiondb.visitCategory,'01_yer');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'StimOn'})= cell2table(repmat({'off'},size(newdb,1),1));

%% brpd 05
% 1 month 
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_05') & ...
    strcmp(sessiondb.ConditionTask,'rest') & ...
    strcmp(sessiondb.StimOn,'') & ...
    strcmp(sessiondb.visitCategory,'01_mnt');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'StimOn'})= cell2table(repmat({'off'},size(newdb,1),1));

rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_05') & ...
    strcmp(sessiondb.ConditionTask,'rest') & ...
    strcmp(sessiondb.StimOn,'') & ...
    strcmp(sessiondb.visitCategory,'02_mnt');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'StimOn'})= cell2table(repmat({'off'},size(newdb,1),1));

% 01 yer
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_05') & ...
    strcmp(sessiondb.ConditionTask,'') & ...
    strcmp(sessiondb.visitCategory,'02_mnt');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'homeRecording'},size(newdb,1),1));
%% brpd 07
% 1 month 
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_07') & ...
    strcmp(sessiondb.ConditionTask,'rest') & ...
    strcmp(sessiondb.StimOn,'') & ...
    strcmp(sessiondb.visitCategory,'01_mnt');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'StimOn'})= cell2table(repmat({'off'},size(newdb,1),1));
%3 month 
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_07') & ...
    strcmp(sessiondb.StimOn,'') & ...
    strcmp(sessiondb.visitCategory,'03_mnt');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'StimOn'})= cell2table(repmat({'off'},size(newdb,1),1));

%6 month 
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_07') & ...
    strcmp(sessiondb.StimOn,'') & ...
    strcmp(sessiondb.visitCategory,'06_mnt');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'StimOn'})= cell2table(repmat({'off'},size(newdb,1),1));

%% brpd 06
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_06') & ...
    strcmp(sessiondb.ConditionTask,'') & ...
    strcmp(sessiondb.visitCategory,'03_mnt');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'homeRecording'},size(newdb,1),1));
%% brpd 09
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_09') & ...
    strcmp(sessiondb.ConditionTask,'') & ...
    strcmp(sessiondb.visitCategory,'03_mnt');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'ConditionTask'})= cell2table(repmat({'homeRecording'},size(newdb,1),1));
% 1 month 
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_09') & ...
    strcmp(sessiondb.ConditionTask,'rest') & ...
    strcmp(sessiondb.StimOn,'') & ...
    strcmp(sessiondb.visitCategory,'01_mnt');
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'StimOn'})= cell2table(repmat({'off'},size(newdb,1),1));
% 3 months 
rowsselect = ...
    sessiondb.usevisit == 1 & ...
    strcmp(sessiondb.patientcode,'brpd_09') & ...
    strcmp(sessiondb.visitCategory,'03_mnt') & ...
    strcmp(sessiondb.StimOn,'')  & ... 
    strcmp(sessiondb.ConditionTask,'rest') ;
newdb = sessiondb(rowsselect,:);
outsessiondb(rowsselect,{'StimOn'})= cell2table(repmat({'off'},size(newdb,1),1));

end