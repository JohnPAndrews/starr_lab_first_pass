function save_all_session_jsons_one_mat_file()
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data';
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
resultsdir   = fullfile('..','results','mat_file_with_all_session_jsons');
[settings, params] = get_settings_params();
mkdir(resultsdir);
%% save all data to temp results dir to make loading files faster
savedatatomat = 1; % save all data to temp directory...
cnt = 1;
fnmsave = fullfile(settings.rootdir, 'patients-^^^^-.json');
Patients = loadjson(fnmsave,'SimplifyCell',1); % this is how to read the data back in.
symptomcat = {}; 
if savedatatomat
    for p = 1:length(Patients)
        visitfnm = fullfile(settings.rootdir, Patients(p).PatientCode,'visit-details-^^^^-.json');
        visits = loadjson(visitfnm,'SimplifyCell',1); % this is how to read the data back in.
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
                    [pn,fn] = fileparts(ff{f});
                    outdb.patientcode{cnt} = session.patientcode;
                    outdb.visitCategory{cnt} = session.visitCategory;
                    outdb.usevisit(cnt) = session.usevist;
                    outdb.sessionSerialNum(cnt) = pp;
                    outdb.Medication{cnt} = session.Medication;
                    if isempty(session.ConditionTask)
                        outdb.ConditionTask{cnt} = '';
                    else
                        outdb.ConditionTask{cnt} = session.ConditionTask;
                    end
                    if isempty(session.StimOn)
                        outdb.StimOn{cnt} = '';
                    else
                        outdb.StimOn{cnt} = session.StimOn;
                    end
                    outdb.recordingduraton(cnt)  = str2num(session.xmldata.RecordingConfig.DurationSeconds);
                    outdb.daysSinceImplant(cnt) = session.daysSinceImplant;
                    outdb.pathname{cnt} = pn;
                    outdb.datafullpath{cnt} = fullfile(pn,[session.filename '.txt']);
                    outdb.rejectsesssion(cnt) = session.rejectsesssion;
                    if isfield(session,'xmldata') & ~isempty(session.xmldata)
                        outdb.xmlexists(cnt) = 1;
                        outdb.sr(cnt) = str2num(strrep(session.xmldata.SenseChannelConfig.TDSampleRate,'Hz',''));
                        outdb.RecordingType{cnt} = session.xmldata.RecordingType;
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
                                if isfield(session.sessionDetailsFromXLS,'patient0x2CPhenotypeAndSymptoms')
                                    if ~isnan(session.sessionDetailsFromXLS.patient0x2CPhenotypeAndSymptoms)
                                        outdb.symptoms{cnt} = session.sessionDetailsFromXLS.patient0x2CPhenotypeAndSymptoms;
                                    end
                                    
%                                 elseif isfield(session.sessionDetailsFromXLS,'patientActivity')
%                                     outdb.symptoms{cnt} = session.sessionDetailsFromXLS.patientActivity;
                                end
                                symptomcat = [symptomcat(:); fieldnames(session.sessionDetailsFromXLS)];
                            end
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
    save(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
else
    load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
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